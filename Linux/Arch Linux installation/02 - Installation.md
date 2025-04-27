
#### Issue with mounting sda1 to /mnt/boot

I did run command `mount --mkdir /dev/sda1 /mnt/boot` according the guide. But when comparing my system against Mischa's I spotted inconsistency between output of `lsblk` (shows mountpoint /mnt/boot) and `df -h` (does not)

```
root@archiso ~ # lsblk
NAME              MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINTS
loop0               7:0    0 841.4M  1 loop  /run/archiso/airootfs
sda                 8:0    0    20G  0 disk
├─sda1              8:1    0     1G  0 part  /mnt/boot
└─sda2              8:2    0    15G  0 part
  └─cryptlvm      253:0    0    15G  0 crypt
    ├─svarog-swap 253:1    0     2G  0 lvm
    ├─svarog-root 253:2    0    10G  0 lvm   /mnt
    └─svarog-home 253:3    0     3G  0 lvm
sr0                11:0    1   1.2G  0 rom   /run/archiso/bootmnt
```

```
root@archiso ~ # df -h
Filesystem               Size  Used Avail Use% Mounted on
dev                      896M     0  896M   0% /dev
run                      972M   11M  962M   2% /run
efivarfs                 256K   22K  230K   9% /sys/firmware/efi/efivars
/dev/sr0                 1.2G  1.2G     0 100% /run/archiso/bootmnt
cowspace                 256M  1.2M  255M   1% /run/archiso/cowspace
/dev/loop0               842M  842M     0 100% /run/archiso/airootfs
airootfs                 256M  1.2M  255M   1% /
tmpfs                    972M     0  972M   0% /dev/shm
tmpfs                    972M     0  972M   0% /tmp
tmpfs                    1.0M     0  1.0M   0% /run/credentials/systemd-journald.service
tmpfs                    1.0M     0  1.0M   0% /run/credentials/systemd-resolved.service
tmpfs                    972M  2.7M  970M   1% /etc/pacman.d/gnupg
tmpfs                    1.0M     0  1.0M   0% /run/credentials/systemd-networkd.service
tmpfs                    1.0M     0  1.0M   0% /run/credentials/getty@tty1.service
tmpfs                    195M  8.0K  195M   1% /run/user/0
/dev/mapper/svarog-root  9.8G  2.1M  9.3G   1% /mnt
```
I've re run the mount command `mount /dev/sda1 /mnt/boot` and now it does appear in the `df -h` output once. But twice in `lsblk` and `mount` output. Claude says it should be OK. And actually Mischa has it there twice too!

---

Use the [pacstrap(8)](https://man.archlinux.org/man/pacstrap.8) script to install the [base](https://archlinux.org/packages/?name=base) package, Linux [kernel](https://wiki.archlinux.org/title/Kernel "Kernel") and firmware for common hardware:

`# pacstrap -K /mnt base linux linux-firmware`


### fstab

`fstab` - automatically mounts filesystem on boot

generate `fstab` file:  `# genfstab -U /mnt >> /mnt/etc/fstab`


**update: this was probably the point where things got of the track in the first installation**
 (messy, had to run also `genfstab -U /mnt/boot >> /mnt/etc/fstab` and edit the `fstab` manually)


#### Switching to disk system context

- up until now removing the usb/iso would break the system

`arch-chroot /mnt`

- after that I am in the context as after a normal boot


### additional system settings

- `ln -sf /usr/share/zoneinfo/Europe/Prague /etc/localtime`
- `stat /etc/localtime`
- `hwclock --systohc` - sync time


### Installation of other packages

`pacman -Syu vim which sudo man-db man-pages texinfo amd-ucode`

**update - yes - it was wrong!**
! seems I am not correctly chrooted - all the packages are being installed to / with filesyste `airootfs`

### Localisation

- `locale-gen`
- create `/etc/locale.conf` with `LANG=en_US.UTF-8`
- not really needed as long en-US is fine by you