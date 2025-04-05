
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
### Encryption

- disk encryption, always do!

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





    