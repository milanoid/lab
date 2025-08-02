### UbuntuServer@HPmini01

HW: HP EliteDesk 705 G2 Mini (CPU AMD A7/A8 8GB RAM, 128GB SSD, TDP 15W)
hostname: hpmini01
mac address: EC:B1:D7:6B:21:0E
private ip address: 192.168.1.236

### UbuntuServer@HPmini02

HW: HP EliteDesk 705 G2 Mini (CPU AMD PRO A8-8600B, 8GB RAM, 128GB SSD, TDP 15W)
hostname: hpmini02
mac address: EC:B1:D7:6E:E0:CF
private ip address: 192.168.1.232


Disk partitioning

- Use entire disk
- Set up this disk as an LVM group
- DO NOT Encrypt the LVM group with LUKS (after a restart I would need type in password via keyboard)
- LVM Volume group: ubuntu-vg
- LVM Logical volume: ubuntu-lv (ext4, mount /) 100G, free space left

```bash
milan@hpmini01:~$ sudo lsblk
NAME                        MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINTS
sda                           8:0    0 119.2G  0 disk
├─sda1                        8:1    0     1G  0 part  /boot/efi
├─sda2                        8:2    0     2G  0 part  /boot
└─sda3                        8:3    0 116.2G  0 part
  └─dm_crypt-0              252:0    0 116.2G  0 crypt
    └─ubuntu--vg-ubuntu--lv 252:1    0   100G  0 lvm   /
```

SSH
- Install SSH server, Allow password authentication over ssh

Featured server snaps
- nothing

Enabling ssh access w/o password:

`ssh-copy-id -i ~/.ssh/id_ed25519.pub milan@192.168.1.236`

ssh client config:

```
Host hpmini01
  User milan
  HostName 192.168.1.236 
```

Now `ssh hpmini01` opens ssh session!

