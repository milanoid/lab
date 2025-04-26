Finishing up setup for vim and localization.

- create `/etc/locale.conf`:
 
```
LANG=en_US.UTF-8
```  
- edit `/etc/locale.gen` - uncomment the `en_US.UTF-8`
- run `locale.gen` command

setting up hostname - `/etc/hostname`

 
 `initramfs

### mkinitcpio

`mkinitcpio` - creates initial ram-disk environment

`/etc/mkinitcpio.conf` - update HOOKS

regenerate initramfs - `mkinitcpio -P`

- ERRORs on generating
- need to create `/etc/vconsole.conf` with `FONT=latarcyrheb-sun32`
- install `lvm2` package: `pacman -Syu lvm2`
