
https://wiki.archlinux.org/title/Hyprland#Hypridle
	sudo pacman -Syu hypridle

	pacman -Ql hypridle

	stat /usr/bin/hypridle

	vim ~/.config/hypr/hypridle.conf



https://wiki.archlinux.org/title/Hyprland#Hyprlock
	sudo pacman -Syu hyprlock

	vim ~/.config/hypr/hyprlock.conf

config file copy from https://github.com/mylinuxforwork/dotfiles/blob/main/share/dotfiles/.config/hypr/hyprlock.conf

add the hypridle to `hyprland.cong`:

`exec-once= = hypridle`