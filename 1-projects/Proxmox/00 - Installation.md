- Version `9.1-1` https://www.proxmox.com/images/download/pve/iso/proxmox-ve_9.1-1.torrent
- downloaded to `NAS/images`
- installation media SanDisk on [Ventoy](https://www.ventoy.net/en/index.html)


## HW

- i3-8100T (35W)
- 2x 8 GB DDR4 RAM
- NVMe 480 GB + SSD 480 GB
## Docs

https://pve.proxmox.com/pve-docs/chapter-sysadmin.html


### Installer


- Disk: `/dev/nvme0n1`
- FDQN: `pve.milanoid.net`
- IP: 192.168.1.200 (static, set on router)
- GW: 192.168.1.1
- DNS: 192.168.1.232 (Pihole)

### post-install steps

https://192.168.1.200:8006

Dismiss the "No valid subscription" popup

```bash
echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" > /etc/apt/sources.list.d/pve-no-subscription.list

apt update && apt dist-upgrade -y
```



```bash
# Disable enterprise Ceph repo
echo "# disabled" > /etc/apt/sources.list.d/ceph.sources

# Fix the PVE no-subscription repo to use correct Debian version
echo "deb http://download.proxmox.com/debian/pve trixie pve-no-subscription" > /etc/apt/sources.list.d/pve-no-subscription.list

# Also disable pve-enterprise.sources (the .sources format file, separate from the .list you edited)
echo "# disabled" > /etc/apt/sources.list.d/pve-enterprise.sources
```


### setup 2nd disk - sda

```bash
root@pve:~# lsblk
NAME               MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
sda                  8:0    0 447.1G  0 disk
nvme0n1            259:0    0 447.1G  0 disk
├─nvme0n1p1        259:1    0  1007K  0 part
├─nvme0n1p2        259:2    0     1G  0 part /boot/efi
└─nvme0n1p3        259:3    0   446G  0 part
  ├─pve-swap       252:0    0     8G  0 lvm  [SWAP]
  ├─pve-root       252:1    0    96G  0 lvm  /
  ├─pve-data_tmeta 252:2    0   3.3G  0 lvm
  │ └─pve-data     252:4    0 319.5G  0 lvm
  └─pve-data_tdata 252:3    0 319.5G  0 lvm
    └─pve-data     252:4    0 319.5G  0 lvm
```