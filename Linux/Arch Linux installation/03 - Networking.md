The system does not have packages to handle networking. One way would be to install a network manager. But going the hard way - using `systemd` and `networkd` instead.

### `systemd`

Is a modern `initd` process. Supersedes `SysV init`. It is a Swiss army knife - does many things which kind of violates the Linux philosophy of having a small program doing one thing and doing it well.

To interact with `systemd` use `systemctl` command. `systemd` uses concept of `units`. A `unit` is anything managed by `systemd`.

- `pstree` - show all running processes - see all of them are children of the `systemd`
- `systemd` is a moder `initd`
- to interact with it use `systemctl`
- `systemd` units -> anything managed by `systemd`

POST -> BIOS -> boot loader -> OS -> `init`

![[Pasted image 20250407140038.png]]

- `systemctl enable systemd-networkd.service` - enables them but does not start! 
- `systemctl status|start systemd-networkd.service` - "Running in chroot, ignoring command"
- `systemctl enable systemd-resolved.service`
- `ip link` - show all NIC

As I am having ethernet wired connection only I do not need to bother with wifi.

```bash
/etc/systemd/network/20-wired.network

[Match]
Name=en*

[Link]
RequiredForOnline=routable

[Network]
DHCP=yes
```

Setting up the hostname

`vim /etc/hostname` "jantar"