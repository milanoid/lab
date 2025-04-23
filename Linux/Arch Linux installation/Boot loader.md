
- `grub` - old
- we will use `systemd-boot`

`bootctl install` - installs boot loader
`bootctl update`

## boot loader configuration

- add an entry (represents an item in the boot menu)
  `/boot/loader/entries/arch.conf`:
```
title Milan's Arch Linux
linux /vmlinuz-linux
initrd /initramfs-linux.img

options rd.luks.name=<device-UUID>=<volumegroup> root=/dev/volegroup/root rw
```

```
title Milan's Arch Linux
linux /vmlinuz-linux
initrd /initramfs-linux.img

options rd.luks.name=<dev/sda-uuid-find-by-blkid>=svarog root=/dev/svarog/root rw
```

To find out what is the actual UUID of the device: `blkid`

! Trick for copying the uuid while in the vim:
	`:.!blkid` - pastes the output of the command to the file


### adding user

- `useradd milan`
- grant the user toot privileges `usermod -aG wheel milan`
- `groups milan` - shows the user is member of `wheel` group (linux convention for user with root privileges)
- in Arch we need to update `sudoers` file `visudo` - uncomment `wheel ALL`
- set a root password: `passwd`
- set user password: `passwd milan`

