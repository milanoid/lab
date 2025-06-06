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

### Steps according to Arch Wiki article

1. preparation
`sudo pacman -Syu linux-headers base-devel acpi_call python-pyroute2 python-configargparse`

2.  install
   
```
$ git clone https://github.com/xmm7360/xmm7360-pci.git
$ cd xmm7360-pci
$ make && make load
# python3 rpc/open_xdatachannel.py --apn apn.url
# echo "nameserver 1.1.1.1" >> /etc/resolv.conf
# ip link set wwan0 up
```

but `make`

```
milan@jantar ~/repos/xmm7360-pci(master) $ make
make -C /lib/modules/6.14.9-arch1-1/build M=/home/milan/repos/xmm7360-pci modules
make[1]: Entering directory '/usr/lib/modules/6.14.9-arch1-1/build'
make[2]: Entering directory '/home/milan/repos/xmm7360-pci'
  CC [M]  xmm7360.o
xmm7360.c:656:5: warning: no previous prototype for ‘xmm7360_cdev_open’ [-Wmissing-prototypes]
  656 | int xmm7360_cdev_open(struct inode *inode, struct file *file)
      |     ^~~~~~~~~~~~~~~~~
xmm7360.c:664:5: warning: no previous prototype for ‘xmm7360_cdev_release’ [-Wmissing-prototypes]
  664 | int xmm7360_cdev_release(struct inode *inode, struct file *file)
      |     ^~~~~~~~~~~~~~~~~~~~
xmm7360.c:670:9: warning: no previous prototype for ‘xmm7360_cdev_write’ [-Wmissing-prototypes]
  670 | ssize_t xmm7360_cdev_write(struct file *file, const char __user *buf,
      |         ^~~~~~~~~~~~~~~~~~
xmm7360.c:684:9: warning: no previous prototype for ‘xmm7360_cdev_read’ [-Wmissing-prototypes]
  684 | ssize_t xmm7360_cdev_read(struct file *file, char __user *buf, size_t size,
      |         ^~~~~~~~~~~~~~~~~
xmm7360.c: In function ‘xmm7360_irq0’:
xmm7360.c:1191:13: warning: the comparison will always evaluate as ‘true’ for the address of ‘td_ring’ will never be NULL [-Waddress]
 1191 |         if (xmm->td_ring) {
      |             ^~~
xmm7360.c:225:24: note: ‘td_ring’ declared here
  225 |         struct td_ring td_ring[16];
      |                        ^~~~~~~
xmm7360.c: At top level:
xmm7360.c:1342:18: error: initialization of ‘ssize_t (*)(struct tty_struct *, const u8 *, size_t)’ {aka ‘long int (*)(struct tty_struct *, const unsigned char *, long unsigned int)’} from incompatible pointer type ‘int (*)(struct tty_struct *, const unsigned char *, int)’ [-Wincompatible-pointer-types]
 1342 |         .write = xmm7360_tty_write,
      |                  ^~~~~~~~~~~~~~~~~
xmm7360.c:1342:18: note: (near initialization for ‘xmm7360_tty_ops.write’)
xmm7360.c:1281:12: note: ‘xmm7360_tty_write’ declared here
 1281 | static int xmm7360_tty_write(struct tty_struct *tty,
      |            ^~~~~~~~~~~~~~~~~
xmm7360.c:1445:6: warning: no previous prototype for ‘xmm7360_dev_init_work’ [-Wmissing-prototypes]
 1445 | void xmm7360_dev_init_work(struct work_struct *work)
      |      ^~~~~~~~~~~~~~~~~~~~~
make[4]: *** [/usr/lib/modules/6.14.9-arch1-1/build/scripts/Makefile.build:207: xmm7360.o] Error 1
make[3]: *** [/usr/lib/modules/6.14.9-arch1-1/build/Makefile:1992: .] Error 2
make[2]: *** [/usr/lib/modules/6.14.9-arch1-1/build/Makefile:251: __sub-make] Error 2
make[2]: Leaving directory '/home/milan/repos/xmm7360-pci'
make[1]: *** [Makefile:251: __sub-make] Error 2
make[1]: Leaving directory '/usr/lib/modules/6.14.9-arch1-1/build'
make: *** [Makefile:9: default] Error 2
```

but `sudo python3 rpc/open_xdatachannel.py --apn apn.url`:

```
DEBUG:pyroute2.netlink.core:message {'attrs': [('NLMSGERR_ATTR_UNUSED', None)], 'header': {'length': 64, 'type': 2, 'flags': 0, 'sequence_number': 259, 'pid': 7712, 'errmsg': {'attrs': [('RTA_PRIORITY', 1000), ('RTA_OIF', 8)], 'header': {'length': 44, 'type': 24, 'flags': 1541, 'sequence_number': 259, 'pid': 7712}, 'family': 0, 'dst_len': 0, 'src_len': 0, 'tos': 0, 'table': 254, 'proto': 4, 'scope': 0, 'type': 1, 'flags': 0}, 'error': NetlinkError(95, 'Operation not supported')}, 'error': -95, 'event': 'NLMSG_ERROR'}
Traceback (most recent call last):
  File "/home/milan/repos/xmm7360-pci/rpc/open_xdatachannel.py", line 107, in <module>
    ipr.route('add',
    ~~~~~~~~~^^^^^^^
              dst='default',
              ^^^^^^^^^^^^^^
              priority=cfg.metric,
              ^^^^^^^^^^^^^^^^^^^^
              oif=idx)
              ^^^^^^^^
  File "/usr/lib/python3.13/site-packages/pyroute2/netlink/core.py", line 754, in _run_with_cleanup
    return self.asyncore.event_loop.run_until_complete(
           ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^
        func(*argv, **kwarg)
        ^^^^^^^^^^^^^^^^^^^^
    )
    ^
  File "/usr/lib/python3.13/asyncio/base_events.py", line 719, in run_until_complete
    return future.result()
           ~~~~~~~~~~~~~^^
  File "/usr/lib/python3.13/site-packages/pyroute2/iproute/linux.py", line 2723, in collect_op
    return await symbol(*argv, **kwarg)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/usr/lib/python3.13/site-packages/pyroute2/iproute/linux.py", line 2395, in route
    return [x async for x in request.response()]
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/usr/lib/python3.13/site-packages/pyroute2/netlink/nlsocket.py", line 640, in response
    async for msg in self.sock.get(
    ...<14 lines>...
        yield msg
  File "/usr/lib/python3.13/site-packages/pyroute2/netlink/core.py", line 541, in get
    raise error
pyroute2.netlink.exceptions.NetlinkError: (95, 'Operation not supported')
```

anyway, not it complains on sim-missing

```
● ModemManager.service - Modem Manager
     Loaded: loaded (/usr/lib/systemd/system/ModemManager.service; enabled; preset: disabled)
     Active: active (running) since Fri 2025-06-06 12:22:15 CEST; 1h 29min ago
 Invocation: f9724ae594d44e8b99c26e56616c2a2e
   Main PID: 771 (ModemManager)
      Tasks: 4 (limit: 8032)
     Memory: 9.6M (peak: 10.1M)
        CPU: 136ms
     CGroup: /system.slice/ModemManager.service
             └─771 /usr/bin/ModemManager

Jun 06 13:45:45 jantar ModemManager[771]: <msg> [base-manager] running setup for device '/sys/devices/pci0000:00/0000:00:01.5/0000:04:00.0'...
Jun 06 13:45:46 jantar ModemManager[771]: <msg> [modem0] state changed (unknown -> locked)
Jun 06 13:45:46 jantar ModemManager[771]: <wrn> [modem0] modem couldn't be initialized: Couldn't check unlock status: SIM not inserted
Jun 06 13:45:46 jantar ModemManager[771]: <msg> [modem0] state changed (locked -> failed)
Jun 06 13:45:52 jantar ModemManager[771]: <wrn> [modem0] port ttyXMM2 timed out 2 consecutive times
Jun 06 13:45:55 jantar ModemManager[771]: <wrn> [modem0] port ttyXMM2 timed out 3 consecutive times
Jun 06 13:45:58 jantar ModemManager[771]: <wrn> [modem0] port ttyXMM2 timed out 4 consecutive times
Jun 06 13:46:01 jantar ModemManager[771]: <wrn> [modem0] port ttyXMM2 timed out 5 consecutive times
Jun 06 13:46:04 jantar ModemManager[771]: <wrn> [modem0] port ttyXMM2 timed out 6 consecutive times
Jun 06 13:46:04 jantar ModemManager[771]: <wrn> [device /sys/devices/pci0000:00/0000:00:01.5/0000:04:00.0] error initializing: Modem in failed state: sim-missing
```

```
milan@jantar ~/repos/xmm7360-pci(lenovo-a485@kernel-6.14.9-arch) $ mmcli -L
    /org/freedesktop/ModemManager1/Modem/0 [Fibocom] L850 LTE Module","L850
```

bring wifi down and up

`sudo ip link set wlan0 down`

`sudo ip link set wlan0 up`


ModemManager open issue https://gitlab.freedesktop.org/mobile-broadband/ModemManager/-/issues/612
```
milan@jantar ~/repos/xmm7360-pci(lenovo-a485@kernel-6.14.9-arch) $ mmcli -m 0
  -----------------------------
  General  |              path: /org/freedesktop/ModemManager1/Modem/0
           |         device id: 927e5e8706a0532ff8f4d02ea8deaf31707e349f
  -----------------------------
  Hardware |      manufacturer: Fibocom
           |             model: L850 LTE Module","L850
           | firmware revision: 18500.5001.00.05.27.30
           |         supported: gsm-umts, lte
           |           current: gsm-umts, lte
           |      equipment id: 015987001484584
  -----------------------------
  System   |            device: /sys/devices/pci0000:00/0000:00:01.5/0000:04:00.0
           |           physdev: /sys/devices/pci0000:00/0000:00:01.5/0000:04:00.0
           |           drivers: xmm7360
           |            plugin: generic
           |      primary port: ttyXMM2
           |             ports: ttyXMM1 (at), ttyXMM2 (at), wwan0 (net)
  -----------------------------
  Status   |             state: failed
           |     failed reason: sim-missing
           |       power state: low
  -----------------------------
  Modes    |         supported: allowed: 3g, 4g; preferred: none
           |           current: allowed: 3g, 4g; preferred: none
  -----------------------------
  3GPP     |              imei: 015987001484584
```