`sshd` is running out of the box 

`systemctl status sshd.service` -> active (running)

`passwd`: to allow ssh access set the root password (otherwise the ssh login does not work)

root/root


### 1.6 Verify the boot mode
```
root@archiso ~ # cat /sys/firmware/efi/fw_platform_size
64
```

UEFI vs BIOS

### 1.8 Update the system clock

`timedatectl`