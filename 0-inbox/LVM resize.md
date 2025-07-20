
When installing the Arch I made the /home too small. Let's resize that. It requires umount of /home. To be on safe side lets boot to Rescuzilla and do the resizing from there.

```bash
milan@jantar:~$ lsblk
NAME              MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINTS
sda                 8:0    0 238.5G  0 disk
├─sda1              8:1    0     1G  0 part  /boot
├─sda2              8:2    0   137G  0 part
│ └─svarog        253:0    0   137G  0 crypt
│   ├─svarog-swap 253:1    0     8G  0 lvm   [SWAP]
│   ├─svarog-root 253:2    0   100G  0 lvm   /
│   └─svarog-home 253:3    0  14.5G  0 lvm   /home
├─sda3              8:3    0    16M  0 part
├─sda4              8:4    0    53G  0 part
└─sda5              8:5    0  47.5G  0 part
```

### resize with unallocated free space within existing LVM volume group

```bash
# check for free space available
milan@jantar:~$ sudo vgs svarog
[sudo] password for milan:
  VG     #PV #LV #SN Attr   VSize   VFree
  svarog   1   3   0 wz--n- 136.98g 14.49g
```


```bash
# check current logical volume sizes
milan@jantar:~$ sudo lvs
  LV   VG     Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  home svarog -wi-ao---- <14.49g
  root svarog -wi-ao---- 100.00g
  swap svarog -wi-ao----   8.00g
```