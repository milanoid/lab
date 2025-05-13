### The boot process

Power ON -> BIOS -> MBR or EFI Partition -> Boot Loader (e.g. GRUB) -> Kernel -> Initial RAM disk (initramfs) -> /sbin/init (parent process) -> Command Shell using getty -> GUI (X Window or Wayland)

#### BIOS

- HW initialisation
- POST (Power On Self Test) - inits screen, keyboard and tests memory
- stored in ROM
- after this the boot process is controlled by OS

#### MBR, EFI and Boot Loader

- after BIOS the control is passed to `boot loader`
- boot loader stored on system's storage device (HDD, SSD)
- boot loader is in `boot sectore` (BIOS/MBR systems) or EFI/UEFI partition
- date/time and peripherals info loaded from CMOS (powered by battery)
- boot loaders examples - GRUB, ISOLINUX, DAS U-Boot
- boot loader responsible for loading the kernel image

#### Boot Loader in Action

##### First stage

- BIOS/MBR method -> boot loader resides at the first sector of the hard disk (also know as Master Boot Record - MBR)
- searches for bootable partition
- searches for second stage boot loader, for example GRUB and loads it to memory

- EFI/UEFI method -> UEFI firmware reads its Boot Manager data
- Boot Manager determines witch UEFI application is to be launched and from where
- firmware launches UEFI application, e.g. GRUB

##### Second stage

- resides in `/boot`
- splash screen is displayed allows us to choose OS  and/or kernel to boot
- boot loader loads kernel of the selected OS into RAM and passes the control
- kernel is compressed, so it needs to uncompress themself first
- then kernel check and analyse the system HW and loads device drivers

#### Initial RAM Disk

- `initramfs` - filesystem image with programs to mount the root filesystem
- `udev` for user device
- `mount` - instructs OS that a filesystem is ready for use and mounts a device to filesystem hierarchy (the `mount point`)
- `/sbin/init` is executed - it handles the mounting and pivoting to the final root system

#### Text mode login

- at the end of the boot process `init` starts text-mode login prompt
- after login user has access to `command shell`
- in case GUI is loaded the text mode login is skipped

##### Switching between terminals

- `ALT-F1` or `ALT-F2` - for GUI
- in GUI switching by `CTRL-ALT-Fkey` (with F7 or F1 leading to GUI)
- command shell - usually `bash`

#### Kernel

- boot loaders loads both kernel and initial RAM-based file system (`initramfs)` into memory
- when kernel is loaded it configures memory and the HW attached to the system (CPU, I/O subsystem, storage devices, etc.)
- kernel also loads some necessary `user space applications`

#### /sbin/init and Services

- after the setup the kernel runs `/sbin/init` - the initial process
- the init runs all other processes, with exception of so called kernel processes
- init is responsible for keeping the system running and for shutting it down cleanly
- acts as a manager for all non-kernel processes, restarts login service when user log in and out

#### Setup Alternatives

- `SysVinit` - a legacy thing
- superseded with 
	  `Upstart` (developed by Ubuntu, adopted by Fedora and RHEL 6)
	  `systemd` (adopted by Fedora, RHEL 7 and SUSE, Replaced Upstart in Ubuntu 16.04)
#### systemd Features

- start up faster than the previous methods
- replaces serialised set of steps with parallelisation techniques
- `systemd` command `systemctl` is used for most basic tasks

##### `systemctl`

- starting, stopping, restarting a service
  `sudo systemctl start|stop|restart httpd.service`
- enabling or disabling a system service from starting up at system boot
  `sudo systemctl enable|disable httpd.service`
- checking on the status of a service
  `sudo systemctl status httpd.service`

#### Linux Filesystems

- conventional: `ext3`, `ext4`, `Btrfs`, `NTFS`,`vfat`, `exfat` etc.
- Flash storage: `ubifs`, `jffs2`, `yaffs`, etc.
- Database fs
- Special purpose fs: `procfs`, `sysfs`, `tmpfs`, `squashfs`, `fuse`, etc.

#### Partition and Filesystems

- partition is a dedicated subsection of physical storage media
- `fs` is a method of storing and accessing files


#### The Filesystem Hierarchy Standard

- standard layout called `Filesystem Hierarchy Standard` (FHS)
- `/` character used to separate paths and does not have drive letters
- drives and/or partitions are mounted as directories in the single `fs`
- removable media at
	   `/run/media/yourusername/disklabel` on new systems
	   `/media`- for older distributions

### Linux Distribution  Installation

- distros offers a reasonable default layout
- smaller partitions for `swap`, `home`, `var`
- one large for normal files

- `AppArmor` - security framework (Ubuntu)