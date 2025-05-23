### install

always use `pacman -Syu`

- S - sync
- u - upgrades all packages
- y - refresh

- `pacman -Syu package_name`
- `pacman -Sw package_name` - downloads without installing

#### package groups

Installs packages belonging to a group simultaneously.

`pacman -Syu gnome`


### remove

- `pacman -R package_name`- keeps the dependencies on the system
- `pacman -Rs package_name` - remove package AND its dependencies 


### upgrading

`pacman -Syu` - upgrades all the packages on the system


### querying package database

sync first `# pacman -Fy`
than `pacman -Ss string`


### cache

in `/var/cache/pacman/pkg`

`pacman -Sc` - remove unused and old packages


## Configuration

`/etc/pacman.conf`


Other
---

Get version and other details on an installed package:

`pacman -Qi bluez`


```
[root@jantar bluetooth]# pacman -Qi bluez
Name            : bluez
Version         : 5.82-1
Description     : Daemons for the bluetooth protocol stack
Architecture    : x86_64
URL             : http://www.bluez.org/
Licenses        : GPL-2.0-only
Groups          : None
Provides        : None
Depends On      : systemd-libs  dbus  glib2  alsa-lib  glibc
Optional Deps   : None
Required By     : None
Optional For    : None
Conflicts With  : None
Replaces        : None
Installed Size  : 1619.80 KiB
Packager        : Robin Candau <antiz@archlinux.org>
Build Date      : Wed 02 Apr 2025 03:11:26 PM CEST
Install Date    : Thu 08 May 2025 04:26:04 PM CEST
Install Reason  : Explicitly installed
Install Script  : No
Validated By    : Signature
```

If unsure what package owns a specific file

```
[root@jantar bluetooth]# pacman -Qo /usr/lib/bluetooth/bluetoothd
/usr/lib/bluetooth/bluetoothd is owned by bluez 5.82-1
```