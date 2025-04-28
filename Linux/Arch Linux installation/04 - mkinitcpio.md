Finishing up setup for vim and localization.

- create `/etc/locale.conf`:
 
```
LANG=en_US.UTF-8
```  
- edit `/etc/locale.gen` - uncomment the `en_US.UTF-8`
- run `locale-gen` command

setting up hostname - `/etc/hostname`

 
 `initramfs

### mkinitcpio

- needed as we use encryption

From man page:

Creates an initial ramdisk environment for booting the Linux kernel. The initial ramdisk is in essence a very small environment (early userspace) which loads various kernel modules and sets up necessary things before handing over control to init. This makes it possible to have, for example, encrypted root file systems and root file systems on a software RAID array.

- `mkinitcpio` - creates initial ram-disk environment

- `/etc/mkinitcpio.conf` - update HOOKS

update `HOOKS` according to 4.4 in https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system#LVM_on_LUKS

```
HOOKS=(base systemd autodetect microcode modconf kms keyboard sd-vconsole block sd-encrypt lvm2 filesystems fsck)
```

regenerate initramfs - `mkinitcpio -P`

- ERRORs on generating
- need to create `/etc/vconsole.conf` with `FONT=latarcyrheb-sun32`
- `ls /usr/share/kbd/consolefonts/ | grep latar` - check the font exists
- install `lvm2` package: `pacman -Syu lvm2`
