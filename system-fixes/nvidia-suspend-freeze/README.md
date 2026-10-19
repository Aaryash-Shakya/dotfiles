# NVIDIA suspend/resume freeze

## Symptom

After resume from suspend (S3), the whole graphics stack freezes:

- Mouse and keyboard dead in the Hyprland session.
- `Ctrl+Alt+F3/F4` does **not** switch to a TTY (modeset hung).
- Re-suspending (`Fn+F4`) and waking again does **not** recover — same dead state.
- Only the power button recovers (hard reset).

## Diagnosis

This is an Optimus laptop: Intel `i915` iGPU + NVIDIA dGPU (open driver `610.43.02`).

In the failing boot, `journalctl -b -1` showed, right at resume:

```
kernel: [drm:__nv_drm_semsurf_wait_fence_work_cb [nvidia_drm]] *ERROR* [nvidia-drm] [GPU ID 0x00000100] Failed to register auto-value-update on pre-wait value for sync FD semaphore surface
```

NVIDIA lost its VRAM/GPU state across suspend, so the DRM fence was invalid on
resume → compositor frozen. Hyprland later had to be `SIGKILL`ed
(`wayland-wm@hyprland.desktop.service: Failed with result 'timeout'`).

Root cause = two missing pieces required for NVIDIA to survive suspend:

- `nvidia-suspend.service`, `nvidia-resume.service`, `nvidia-hibernate.service`
  were all **disabled**.
- `NVreg_PreserveVideoMemoryAllocations` was **unset** (no `modprobe.d` nvidia
  config existed at all).

## Fix

1. Enable the NVIDIA suspend/resume/hibernate services:

   ```bash
   sudo systemctl enable nvidia-suspend.service nvidia-resume.service nvidia-hibernate.service
   ```

2. Preserve VRAM across suspend — `/etc/modprobe.d/nvidia-power.conf`:

   ```
   options nvidia NVreg_PreserveVideoMemoryAllocations=1 NVreg_TemporaryFilePath=/var/tmp
   ```

   `/tmp` is tmpfs (RAM), unusable for dumping VRAM during suspend — use a
   disk-backed path (`/var/tmp`).

3. Reboot.

## Notes

- `mkinitcpio -P` is **not** needed here: `MODULES=()` is empty and no nvidia
  files live in the initramfs, so NVIDIA loads late from userspace and reads the
  modprobe options on a normal boot.
- These are system files (`/etc/...`), not tracked in this dotfiles repo — this
  doc is the record of the change.

---

# Part 2 — freeze recurred: unfrozen sessions race the VRAM save (2026-07-08)

## Symptom

Same lid-open freeze as Part 1, but **after** the Part 1 fix was confirmed
still in place (services enabled, `PreserveVideoMemoryAllocations=1` live).
Screen shows a stale frame, keyboard dead. Intermittent, not every suspend.

## Diagnosis

Different signature. `journalctl` at the freeze showed the errors firing at
**suspend entry**, not resume:

```
systemd-sleep: User sessions remain unfrozen on explicit request ($SYSTEMD_SLEEP_FREEZE_USER_SESSIONS=0).
kernel: PM: suspend entry (deep)
kernel: NVRM: nvCheckOkFailedNoLog: Check failed: Out of memory [NV_ERR_NO_MEMORY] (0x00000051) returned from _memdescAllocInternal(pMemDesc) @ mem_desc.c:1338
kernel: [drm:__nv_drm_semsurf_wait_fence_work_cb [nvidia_drm]] *ERROR* ... Failed to register auto-value-update on pre-wait value for sync FD semaphore surface
```

Chain of causation:

1. systemd normally **freezes all user processes** before suspending, so nothing
   touches the GPU during suspend.
2. The `nvidia-utils` package disables that — it ships
   `/usr/lib/systemd/system/systemd-suspend.service.d/10-nvidia-no-freeze-session.conf`
   setting `SYSTEMD_SLEEP_FREEZE_USER_SESSIONS=false` (NVIDIA added this to dodge
   a *different* deadlock). Confirmed present on this system.
3. So during the VRAM-save step of suspend (the Part 1 `PreserveVideoMemoryAllocations`
   mechanism), Hyprland + quickshell are **still running and still submitting GPU
   work**.
4. That race makes a driver allocation fail (`NV_ERR_NO_MEMORY` in
   `_memdescAllocInternal`).
5. The failed alloc leaves an **invalid explicit-sync fence**
   (`semsurf_wait_fence`). Hyprland waits on that fence forever on wake → frozen
   frame, dead input.

Confirmed as a known, widely-reported bug (not specific to this machine):

- basecamp/omarchy#4891 — identical logs, Hyprland + hybrid NVIDIA laptops.
- NVIDIA/open-gpu-kernel-modules#931 — NVIDIA's own explanation of the
  unfrozen-session race.

Ruled out:

- **Driver downgrade** — reproduces on 580 / 595 / 610 branches; not a 610
  regression.
- **`render:explicit_sync = 0`** — option **removed** in Hyprland 0.55 (explicit
  sync is now mandatory), so it can't be dodged compositor-side.

## Fix

A `systemd-sleep` hook that does manually, for just the two GPU-heavy processes,
what NVIDIA's package disabled globally: pause them before suspend, resume them
after wake.

Install (source tracked in this repo at `system-fixes/nvidia-suspend-freeze/nvidia-freeze-gpu-clients`):

```bash
sudo install -Dm755 system-fixes/nvidia-suspend-freeze/nvidia-freeze-gpu-clients \
  /etc/systemd/system-sleep/nvidia-freeze-gpu-clients
```

Script:

```sh
#!/bin/sh
case "$1" in
    pre)
        pkill -STOP -x Hyprland
        pkill -STOP -x 'quickshell|qs'
        ;;
    post)
        pkill -CONT -x 'quickshell|qs'
        pkill -CONT -x Hyprland
        ;;
esac
```

- quickshell's process name is **`qs`**, not `quickshell` — the `-x 'quickshell|qs'`
  pattern covers both.
- GPU sits idle during the VRAM save → no alloc race → valid fence → clean wake.

## Recovery / rollback

- **Revert:** `sudo rm /etc/systemd/system-sleep/nvidia-freeze-gpu-clients`
- **If the `post` step ever fails** and apps stay paused: switch to a TTY
  (`Ctrl+Alt+F3`) and `pkill -CONT -x Hyprland` — no reboot needed.

## If it still recurs

1. Re-enable full session freeze (overrides NVIDIA's drop-in), accepting the
   deadlock risk NVIDIA warned about (Ubuntu bug 2158993):
   `SYSTEMD_SLEEP_FREEZE_USER_SESSIONS=true`.
2. Boot `linux-cachyos-lts` (6.18) — kernel 7.x has separate NVIDIA s2idle
   resume-hang reports (NVIDIA/open-gpu-kernel-modules#1117).
3. Add more GPU clients to the `pkill` lists if some other process is racing.

## Recurrence log

- **2026-10-19:** screen froze after a resume despite the hook; hard reset needed.
  Kernel log clean (no Xid/hung-task), Hyprland silent after first wake and ignored
  SIGTERM at shutdown. The hook now logs process state: after the next freeze run
  `journalctl -b -1 -t gpu-freeze`. `T` at `post+2s` = SIGCONT didn't land;
  `S` = Hyprland running but hung for another reason.
