
- installation guide https://wiki.archlinux.org/title/Installation_guide#
- using Oracle Virtual Box


### Network setup

- needed for Wifi, when connected over ethernet it works out of the box
- `ip link` - show IP devices

`iwclt`
`station list`
`station wlan0 scan`
`station wlan0 show`
`station wlan0 get-networks`
`station connect <my-wifi-network>`

`cat /etc/os-release` - OS info

#### 1.8 Update the system clock

`timedatectl`

## 1.9 Disk partitioning

*Always* use disk encryption!

Without unlocking with correct password all the data are not readable. So even someone steals your machine without the password no data can be read.

![[Screenshot 2025-04-26 at 18.27.36.png]]

- `lsblk` - list block devices
- `sda` -> first disk, as a file in `/dev/sda`
### LVM

- `LVM` - Logical Volume Manager - 2 partitions (1 small for boot, 1 big volume)
  - the big volume can contain logical partitions and those can be resized!
  - a logical volume can span more than 1 physical device!

### Partitioning using `fdisk`

I'm using 20 GB VM disk.

#### Boot partition

(EFI system partition) is an OS independent partition that acts as the storage place for the UEFI **boot loaders**, applications and drivers to be launched by the UEFI firmware. It is mandatory for UEFI boot.

1G for (EFI system) boot partition

- `fdisk /dev/sda`
- `g` - create a new empty GPT partition table
- `n` - add a new partition, for last sector type `+1G`
- `t` - change type to `EFI System` (option 1)

15G for the LVM (remains ~ 4G as buffer for resizing if needed)

- `n`
- `t` - `Linux LVM` (option 44)
- `p` - print the partition table

```
Command (m for help): p
Disk /dev/sda: 20 GiB, 21474836480 bytes, 41943040 sectors
Disk model: VBOX HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: 986202E7-06CA-481C-9EAB-3A2656A6592D

Device       Start      End  Sectors Size Type
/dev/sda1     2048  2099199  2097152   1G EFI System
/dev/sda2  2099200 33556479 31457280  15G Linux LVM
```

Once all done -> `w` for write, check the partitions again by `lsblk`


## Encryption

Using [LVM on LUKS](https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system#LVM_on_LUKS) scenario.

- disk encryption, always do!
- `dm-crypt` - https://wiki.archlinux.org/title/Dm-crypt
- `LUKS` - https://en.wikipedia.org/wiki/Linux_Unified_Key_Setup
- `LVM on LUKS` - https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system#LVM_on_LUKS

#### create logical volumes

1. SWAP
2. `/` (root)
3. `home`
4. `data`

### Create the LUKS encrypted container at partition

`cryptosetup luksFormat /dev/sda2` - the big LVM partition

- issue with ENTER key (^M instead) - `CTRL-j` sends `LF` `\n` simulating a proper ENTER


### Open the container and create volumes and volume group

- `cryptsetup open /dev/sda2 cryptlvm`

##### Possible Issue #1 - 2G RAM vs cryptlvm
```
root@archiso ~ # cryptsetup open /dev/sda2 cryptlvm
Enter passphrase for /dev/sda2:
Warning: keyslot operation could fail as it requires more than available memory.
```

- `pvcreate /dev/mapper/cryptlvm` - creates a physical volume (container)

```
root@archiso ~ # pvcreate /dev/mapper/cryptlvm
  Physical volume "/dev/mapper/cryptlvm" successfully created.
```

#### volume group

Using name `svarog`

- `vgcreate svarog /dev/mapper/cryptlvm` - create a group called `svarog`
`
```
root@archiso ~ # vgcreate svarog /dev/mapper/cryptlvm
  Volume group "svarog" successfully created
```

#### logical volumes

Total partition size is 15G.
```
lvcreate -L 2G -n swap svarog
lvcreate -L 10G -n root svarog
lvcreate -l 50%FREE -n home svarog # 1.49G
lvcreate -l 100%FREE -n data svarog # 1.49G
```


`lvdisplay`

#### formating

Setting up the filesystem. Common is `ext4`.

```
mkfs.ext4 /dev/svarog/root
mkfs.ext4 /dev/svarog/home
mkfs.ext4 /dev/svarog/data
mkswap /dev/svarog/swap
```

#### preparing boot partition

- `/dev/sda1`
- must be `fat32`
- mount it to `/boot`

`mkfs.fat -F32 /dev/sda1`

`mount --mkdir /dev/sda1 /mnt/boot`

### LVM - part 2

Reconsidering the layout -> remove the `data` volume and resize the `home`.

```
root@archiso ~ # lvremove /dev/svarog/data
Do you really want to remove active logical volume svarog/data? [y/n]: y
  Logical volume "data" successfully removed.
```

- renaming volume: `vgrename`
- removing volume: `lvremove`
- resize volume: `lvresize /dev/svarog/home -L +1.49G`

After resizing of a logical volume we need to run resize the file system too!

- `resize2fs /dev/svarog/home`

#### Final layout

- sda1 - boot 1G
- sda2 - cryptlvm - svarog - swap 2G
- sda2 - cryptlvm - svarog - root 10G
- sda2 - cryptlvm - svarog - home 3G

```
root@archiso ~ # lsblk
NAME              MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINTS
loop0               7:0    0 841.4M  1 loop  /run/archiso/airootfs
sda                 8:0    0    20G  0 disk
├─sda1              8:1    0     1G  0 part  /mnt/boot
└─sda2              8:2    0    15G  0 part
  └─cryptlvm      253:0    0    15G  0 crypt
    ├─svarog-swap 253:1    0     2G  0 lvm
    ├─svarog-root 253:2    0    10G  0 lvm
    └─svarog-home 253:3    0     3G  0 lvm
sr0                11:0    1   1.2G  0 rom   /run/archiso/bootmnt
```

### Mounting the filesystem

`mount /dev/svarog/root /mnt` - mounting the `root` to `/mnt`

activate swap partition: `swapon /dev/svarog/swap`