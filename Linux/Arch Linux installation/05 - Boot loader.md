
- `grub` - old
- we will use `systemd-boot`

`bootctl install` - installs boot loader
`bootctl update`

### issue and a workaround

[https://github.com/systemd/systemd/issues/36174](https://github.com/systemd/systemd/issues/36174 "https://github.com/systemd/systemd/issues/36174")

```
bootctl --esp-path=/mnt/boot install
arch-chroot /mnt
bootctl install
bootctl update
```

## boot loader configuration

- add an entry (represents an item in the boot menu)
  `/boot/loader/entries/arch.conf`:
```
title Arch Linux
linux /vmlinuz-linux
initrd /initramfs-linux.img

options rd.luks.name=<device-UUID>=<volumegroup> root=/dev/volegroup/root rw
```

2nd installation final version of the file:
```
title Arch Linux
linux /vmlinuz-linux
initrd /initramfs-linux.img

options rd.luks.name=ea2959bd-3327-414e-8e72-993cd5873b95=svarog root=/dev/svarog/root rw
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

