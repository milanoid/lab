
#### browser

`sudo pacman -Syu qutebrowser`

qutebrowser key bindings cheat sheet https://raw.githubusercontent.com/qutebrowser/qutebrowser/main/doc/img/cheatsheet-big.png

`$mainMod` is Super/Windows key/CMD

copy/paste

`CTRL-C`, `CTRL-V`, in terminal - `CTRL-SHIFT-C`

#### Hyprland default keybindings

```
###################
### KEYBINDINGS ###
###################

# See https://wiki.hyprland.org/Configuring/Keywords/
$mainMod = SUPER # Sets "Windows" key as main modifier

# Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
bind = $mainMod, Q, exec, $terminal
bind = $mainMod, C, killactive,
bind = $mainMod, M, exit,
bind = $mainMod, E, exec, $fileManager
bind = $mainMod, V, togglefloating,
bind = $mainMod, R, exec, $menu
bind = $mainMod, P, pseudo, # dwindle
bind = $mainMod, J, togglesplit, # dwindle
```

#### Bluetooth

`sudo pacman -Syu bluez bluez-utils`




# YAY - Installing from the AUR

AUR - Arch User Repository

Repo with user packages. Installing would require build all the dependencies manually. That's difficult and tedious. Here it comes YAY handy as it does the heavy lifting.

https://github.com/Jguer/yay?tab=readme-ov-file#source

`sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si`

install error: "A failure occurred in build()" - due to a resolve.d settings vs Go.

See https://wiki.archlinux.org/title/Systemd-resolved#DNS

"To provide [domain name resolution](https://wiki.archlinux.org/title/Domain_name_resolution "Domain name resolution") for software that reads `/etc/resolv.conf` directly, such as [web browsers](https://wiki.archlinux.org/title/Web_browsers "Web browsers"), [Go](https://wiki.archlinux.org/title/Go "Go") and [GnuPG](https://wiki.archlinux.org/title/GnuPG "GnuPG"), _systemd-resolved_ has four different modes for handling the file—stub, static, uplink and foreign."

Need to create a symbolic link 

`# ln -sf ../run/systemd/resolve/stub-resolv.conf /etc/resolv.conf`

### install a package

`yay showmethekey`

