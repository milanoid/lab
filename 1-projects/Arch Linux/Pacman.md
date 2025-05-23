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