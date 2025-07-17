alacrittyalacritty- Window manager (just creates windows)
- Desktop environment e.g. GNOME - full GUI with its own programs 

https://hyprland.org/
https://wayland.freedesktop.org/

x.org vs wayland

### X.org
- old
- not maintained
- 25 years old

### Wayland

- new protocol
- issues with screen sharing, gaming

### Installation
`
`sudo pacman -S hyprland`

- it was getting 404
- need to update mirror list and package database: `sudo pacman -Syy`
- error on missing `libxml2.so.16`

```
:: Running post-transaction hooks...
( 1/10) Creating system user accounts...
Creating group 'seat' with GID 971.
Creating group 'avahi' with GID 970.
Creating user 'avahi' (Avahi mDNS/DNS-SD daemon) with UID 970 and GID 970.
( 2/10) Reloading system manager configuration...
( 3/10) Updating udev hardware database...
( 4/10) Reloading device manager configuration...
( 5/10) Arming ConditionNeedsUpdate...
( 6/10) Updating the MIME type database...
/usr/bin/update-mime-database: error while loading shared libraries: libxml2.so.16: cannot open shared object file: No such file or directory
error: command failed to execute correctly
( 7/10) Updating fontconfig configuration...
( 8/10) Reloading system bus configuration...
( 9/10) Updating fontconfig cache...
(10/10) Probing GDK-Pixbuf loader modules...
g_module_open() failed for /usr/lib/gdk-pixbuf-2.0/2.10.0/loaders/libpixbufloader_svg.so: libxml2.so.16: cannot open shared object file: No such file or directory
```


`sudo pacman -S libxml2` fails:

```
[milan@jantar /]$ sudo pacman -S libxml2 [sudo] password for milan: resolving dependencies... looking for conflicting packages... error: failed to prepare transaction (could not satisfy dependencies) :: installing libxml2 (2.14.2-2) breaks dependency 'libxml2.so=2-64' required by libarchive
```
- upgrading entire system `sudo pacman -Syu`


### Now step back - create missing home folder

symptoms:

```
milan ~  $ ssh -p 2222 milan@127.0.0.1
milan@127.0.0.1's password:
Last login: Wed Apr 30 08:45:30 2025 from 10.0.2.2
Could not chdir to home directory /home/milan: No such file or directory
```

```
[milan@jantar /]$ cd ~
-bash: cd: /home/milan: No such file or directory
```

fix:

```
sudo mkdir -p /home/milan 
sudo chown milan:milan /home/milan
sudo chmod 700 /home/milan
sudo cp -r /etc/skel/. /home/milan/
sudo chown -R milan:milan /home/milan
```


### continue with Hyprland settings

- missing `~/.config/hypr/hyprland.conf` - create one by running `Hyprland` - it will fail but creates the file
- `sudo pacman -Syu alacritty` - terminal
- set that terminal as default in configuration file
##### VirtualBox enable 3D acceleration

- stop VM
- enable 3D
- after new start install Guest Additions:
  
```
sudo pacman -S virtualbox-guest-utils
sudo systemctl enable vboxservice.service
sudo systemctl start vboxservice.service
```
- also `sudo pacman -S linux-headers`


### Lenovo ThinkPad (AMD)

`sudo pacman -S hyprland`
`sudo pacman -Syu alacritty`

set `$terminal = alacritty` in `~/.config/hypr/hyprland.conf`

