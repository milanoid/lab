https://wiki.hyprland.org/Configuring/Monitors/

`hyprctl monitors all` - show all known monitors

```
Monitor eDP-1 (ID 0):
	1920x1080@60.02000 at 2560x0
	description: Lenovo Group Limited 0x40A9
	make: Lenovo Group Limited

Monitor DP-2 (ID 1):
	2560x1440@59.95100 at 1280x0
	description: Eizo Nanao Corporation EV2795 29110100
	make: Eizo Nanao Corporation
```

in `~/.config/hypr/hyprland.conf` set:

```
monitor=,preferred,auto,auto
hypr
## my configuration for EIZO + Lenovo A485 display
monitor = DP-2,preferred,0x0,auto
```
