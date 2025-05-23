
`hyprctl clients` - show all currently running windows

Settings in `~/.config/hypr/hyprland.conf`

https://wiki.hyprland.org/Configuring/Window-Rules/


### waybar

`pacman -Syu waybar`

When running `waybar` in terminal it shows a lot of errors and warnings. To fix some of those:

`sudo usermod -aG input milan`

#### customization

https://wiki.hyprland.org/Useful-Utilities/Status-Bars/

1. copy waybar config files to home: `cp * /etc/xdg/waybar/ ~/.config/waybar`