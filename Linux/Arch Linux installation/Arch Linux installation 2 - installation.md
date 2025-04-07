Use the [pacstrap(8)](https://man.archlinux.org/man/pacstrap.8) script to install the [base](https://archlinux.org/packages/?name=base) package, Linux [kernel](https://wiki.archlinux.org/title/Kernel "Kernel") and firmware for common hardware:

`# pacstrap -K /mnt base linux linux-firmware`


### fstab

`fstab` - automatically mounts filesystem on boot

generate `fstab` file:  `# genfstab -U /mnt >> /mnt/etc/fstab`

(messy, had to run also `genfstab -U /mnt/boot >> /mnt/etc/fstab` and edit the `fstab` manually)


#### Switching to disk system context

- up until now removing the usb/iso would break the system

`arch-chroot /mnt`

- after that I am in the context as after a normal boot


### additional system settings

- `ln -sf /usr/share/zoneinfo/Europe/Prague /etc/localtime`
- `hwclock --systohc` - sync time

### Localization

- `locale-gen`


### Installation of other packages

`pacman -Syu vim sudo which man-db man-pages texinfo`


! seems I am not correctly chrooted - all the packages are being installed to / with filesyste `airootfs`

`pacmn -Syu amd-ucode`
