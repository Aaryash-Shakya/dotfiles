-- Custom keybinds
-- Docs: https://wiki.hypr.land/Configuring/Basics/Binds/
-- Descriptions surface in the cheatsheet via `hyprctl binds -j`.

-- User
hl.bind(
  "CTRL + SUPER + slash",
  hl.dsp.exec_cmd("xdg-open ~/.config/illogical-impulse/config.json"),
  { description = "Edit shell config" }
)
hl.bind(
  "CTRL + SUPER + ALT + slash",
  hl.dsp.exec_cmd("xdg-open ~/.config/hypr/custom/keybinds.lua"),
  { description = "Edit extra keybinds" }
)

-- Move Workspace (hidden from cheatsheet)
hl.bind("CTRL + SUPER + SHIFT + ALT + Left",  hl.dsp.workspace.move({ monitor = "l" }))
hl.bind("CTRL + SUPER + SHIFT + ALT + Right", hl.dsp.workspace.move({ monitor = "r" }))
hl.bind("CTRL + SUPER + SHIFT + ALT + Up",    hl.dsp.workspace.move({ monitor = "u" }))
hl.bind("CTRL + SUPER + SHIFT + ALT + Down",  hl.dsp.workspace.move({ monitor = "d" }))
