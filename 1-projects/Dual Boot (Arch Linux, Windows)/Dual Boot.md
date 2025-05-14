
As the first system installed is Arch Linux, I will follow the guide https://wiki.archlinux.org/title/Dual_boot_with_Windows#Linux_before_Windows

To be on save side - I did backup entire disk with Arch Linux using CloneZilla to my NAS. [[CloneZilla backup and restore]]]



### Installing Windows 10 alongside my Arch Linux

The disk is 256G SSD with 2 partitions for Arch Linux (EFI and LVM). There are 100G unallocated.

On Windows installation boot select Advanced and make sure to select unallocated part of the disk.

#### Turn off Windows Fast Boot and Hybernation

- hybernation feature could corrupt shared boot partition

`powercfg /H off`

After that power off (restart is not enough) the system to be 100% sure the hybernation is off.

https://www.tenforums.com/tutorials/4189-turn-off-fast-startup-windows-10-a.html








