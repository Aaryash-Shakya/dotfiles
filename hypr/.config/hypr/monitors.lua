-- Hand-maintained. nwg-displays still writes monitors.conf but Hyprland 0.55+
-- lua mode does not source .conf. Mirror changes here.

hl.monitor({ output = "eDP-1",    mode = "1920x1080@144", position = "1920x0", scale = 1 })
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60",  position = "0x0",    scale = 1 })
