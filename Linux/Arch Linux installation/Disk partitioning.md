
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

- `lsblk` - list block devices
- `sda` -> first disk, as a file in `/dev/sda`
### LVM

- `LVM` - Logical Volume Manager - 2 partitions (1 small for boot, 1 big volume)
  - the big volume can contain logical partitions and those can be resized!
  - a logical volume can span more than 1 physical device!

### Partitioning using `fdisk`

1G for boot partition, rest for the LVM

- `fdisk /dev/sda`
- `g` - create a new partition table
- `n` - add a new partition, for last sector type `+1G`
- `t` - change type to `EFI System` (option 1)

Rest for the LVM

- `n`
- `t` - `Linux LVM` (option 44)
- `p` - print the partition table

Once all done -> `w` for write, check the partitions again by `lsblk`


## Encryption

- disk encryption, always do!
- `dm-crypt` - https://wiki.archlinux.org/title/Dm-crypt
- `LUKS` - https://en.wikipedia.org/wiki/Linux_Unified_Key_Setup
- `LVM on LUKS` - https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system#LVM_on_LUKS

#### create logical volumes

1. SWAP
2. `home`
3. `data`

### Create the LUKS encrypted container at partition

`cryptosetup luksFormat /dev/sda2` - the big LVM partition

- issue with ENTER key (^M instead) - `CTRL-j` sends `LF` `\n` simulating a proper ENTER


### Open the container and create volumes

`cryptsetup open /dev/sda2 cryptlvm`

`pvcreate /dev/mapper/cryptlvm` - creates a physical volume

`vgcreate svarog /dev/mapper/cryptlvm` - create a group called `svarog`

```
lvcreate -L 2G -n swap svarog
lvcreate -L 3G -n root svarog
lvcreate -l 50%FREE -n home svarog
lvcreate -l 100%FREE -n data svarog
```


`lvdisplay`

#### formating

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

- renaming volume: `vgrename`
- removing volume: `lvremove`
- resize volume: `lvresize /dev/svarog/home -L 1.9G`

After resizing of a logical volume we need to run resize the file system too:

- `resize2fs /dev/svarog/home`

### Mounting the filesystem

`mount/dev/svarog/root /mnt` - mounting the `root` to `/mnt`

activate swap partition: `swapon /dev/svarog/swap`