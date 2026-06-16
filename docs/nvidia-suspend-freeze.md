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
