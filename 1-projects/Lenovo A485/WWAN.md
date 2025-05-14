Lenovo A485
WWAN Fibicom L850-GL LTE 4G

ModemManager

 - is a systeam daemon which controls WWAN devices and connections

	sudo pacman -Syu modemmanager usb_modeswitch

	systemctl --now enable ModemManager.service

but:

```
[milan@jantar lab]$ systemctl status ModemManager.service
● ModemManager.service - Modem Manager
     Loaded: loaded (/usr/lib/systemd/system/ModemManager.service; enabled; preset: disabled)
     Active: active (running) since Wed 2025-05-14 11:04:26 CEST; 1h 34min ago
 Invocation: 9b1728847a0a417786133cdb191c1dfc
   Main PID: 31652 (ModemManager)
      Tasks: 4 (limit: 8032)
     Memory: 2.6M (peak: 2.9M)
        CPU: 91ms
     CGroup: /system.slice/ModemManager.service
             └─31652 /usr/bin/ModemManager

May 14 11:04:28 jantar ModemManager[31652]: <msg> [wwan0at1/probe] probe step: AT close port
May 14 11:04:28 jantar ModemManager[31652]: <msg> [wwan0at1/probe] probe step: done
May 14 11:04:30 jantar ModemManager[31652]: <msg> [base-manager] couldn't check support for device '/sys/devices/pci0000:00/0000:00:01.2/0>
May 14 11:04:30 jantar ModemManager[31652]: <msg> [base-manager] couldn't check support for device '/sys/devices/pci0000:00/0000:00:01.4/0>
May 14 11:04:30 jantar ModemManager[31652]: <msg> [base-manager] couldn't check support for device '/sys/devices/pci0000:00/0000:00:01.6/0>
May 14 11:04:30 jantar ModemManager[31652]: <msg> [base-manager] couldn't check support for device '/sys/devices/pci0000:00/0000:00:08.1/0>
May 14 11:04:46 jantar ModemManager[31652]: <msg> [wwan0at0/probe] probe step: AT close port
May 14 11:04:46 jantar ModemManager[31652]: <msg> [wwan0at0/probe] probe step: done
May 14 11:04:46 jantar ModemManager[31652]: <msg> [device /sys/devices/pci0000:00/0000:00:01.5/0000:04:00.0] creating modem with plugin 'I>
May 14 11:04:46 jantar ModemManager[31652]: <wrn> [base-manager] couldn't create modem for device '/sys/devices/pci0000:00/0000:00:01.5/00>
l
```

output of `lspci` (utility for displaying info about PCI busus)

```
[milan@jantar lab]$ lspci -nnd 8086:7360
04:00.0 Wireless controller [0d40]: Intel Corporation XMM7360 LTE Advanced Modem [8086:7360] (rev 01)
```

There is Arch Wiki page for that modem https://wiki.archlinux.org/title/Xmm7360-pci

## TODO

According the article there is no official driver. There is only an alpha stage driver, written in Python [https://github.com/xmm7360/xmm7360-pci](https://github.com/xmm7360/xmm7360-pci). Also it seems the modem must be first activated under Windows. 

1. backup current Arch Linux installation using Clonezila
2. dual boot Windows 10 installation (key in BIOS) https://wiki.archlinux.org/title/Dual_boot_with_Windows#Linux_before_Windows
### CloneZilla

backup destination is Synogy NAS with over NFS (Network File System):

host: 192.168.1.36
address: /volume1/images

Synology NFS rule on the "images" directory:

![[Pasted image 20250514145051.png]]