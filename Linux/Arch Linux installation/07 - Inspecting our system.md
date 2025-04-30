- `pstree` - shows all running processes
- `ps aux` - with `pid`

```
[milan@jantar /]$ pstree
systemd─┬─dbus-broker-lau───dbus-broker
        ├─login───bash───sudo───sudo───su───bash
        ├─sshd───sshd-session───sshd-session───bash───pstree
        ├─systemd───(sd-pam)
        ├─systemd-journal
        ├─systemd-logind
        ├─systemd-network
        ├─systemd-resolve
        ├─systemd-udevd
        └─systemd-userdbd───3*[systemd-userwor]
[milan@jantar /]$
```

`journalctl -b 0` - shows logs of the latest boot

`sudo pacman -Syu htop`

### issue with eth0

- after rebooting the system is missing eth0 (=no internet)
- asked in Kubecraft, decided the start over the entire installation (too messy now)

