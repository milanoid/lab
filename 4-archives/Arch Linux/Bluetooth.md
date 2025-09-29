[[Linux]]

`bluetoothctl` - console frontend

configuration in `/etc/bluetooth/main.conf`

### Keyboard Logitech K480

-> PROBLEM with bonding (persistent pairing), also makes bluetoothd sometimes crash
-> do not use as it would require pairing everytime

position 3 - `34:88:5D:BE:ED:A2`

Issue resolved - disable bonding requirement in `/etc/bluetooth/input.conf`:

```
ClassicBondedOnly=false
```

issue with connecting, bluetoothd

1. unable to connect
   
 
```
May 23 13:41:00 jantar bluetoothd[1917]: profiles/input/device.c:hidp_add_connection() Rejected connection from !bonded device /org/bluez/hci0/dev_34_88_5D_BE_ED_A2
```
 
2. bluetoothd crash

```
May 23 13:54:36 jantar systemd-coredump[2277]: [🡕] Process 2238 (bluetoothd) of user 0 dumped core.

                                               Stack trace of thread 2238:
                                               #0  0x00005d721cdf5360 n/a (/usr/lib/bluetooth/bluetoothd + 0xb3360)
                                               #1  0x00005d721cdf59cc n/a (/usr/lib/bluetooth/bluetoothd + 0xb39cc)
                                               #2  0x00005d721cd7ea6f n/a (/usr/lib/bluetooth/bluetoothd + 0x3ca6f)
                                               #3  0x00005d721cd7f7ba n/a (/usr/lib/bluetooth/bluetoothd + 0x3d7ba)
                                               #4  0x00005d721cd9f330 n/a (/usr/lib/bluetooth/bluetoothd + 0x5d330)
                                               #5  0x000078a70d06a87d n/a (libglib-2.0.so.0 + 0x5e87d)
                                               #6  0x000078a70d06bcd7 n/a (libglib-2.0.so.0 + 0x5fcd7)
                                               #7  0x000078a70d06c097 g_main_loop_run (libglib-2.0.so.0 + 0x60097)
                                               #8  0x00005d721cd4c154 n/a (/usr/lib/bluetooth/bluetoothd + 0xa154)
                                               #9  0x000078a70ccc26b5 n/a (libc.so.6 + 0x276b5)
                                               #10 0x000078a70ccc2769 __libc_start_main (libc.so.6 + 0x27769)
                                               #11 0x00005d721cd4d335 n/a (/usr/lib/bluetooth/bluetoothd + 0xb335)
                                               ELF object binary architecture: AMD x86-64
```

3. on service start

```
Failed to set privacy: Rejected (0x0b)
```


### Mouse Logitech M590 

OK
position 2 - EC:40:13:29:3A:60


### Keyboard Satechi

OK 

`CB:AF:7F:B4:02:3F`

