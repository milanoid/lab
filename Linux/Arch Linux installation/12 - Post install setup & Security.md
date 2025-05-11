
https://wiki.archlinux.org/title/General_recommendations

For laptop specific post install setup (ACPI etc.) follow https://wiki.archlinux.org/title/Laptop


### Sound

#### Installation

- ALSA should be enough
- By default, ALSA has all channels muted. Those have to be unmuted manually.

`sudo pacman -Syu alsa-utils alsa-lib sof-firmware`

```
$ amixer sset Master unmute
$ amixer sset Speaker unmute
$ amixer sset Headphone unmute
```


#### Troubleshooting


https://wiki.archlinux.org/title/Advanced_Linux_Sound_Architecture#Cards_and_modules

Had to set default sound card (the system shows 2) https://www.alsa-project.org/wiki/Setting_the_default_device

1. `cat /proc/asound/cards` - shows 2 (one probably HDMI)
2. `sudo vim /etc/asound.conf`:
   ```
   defaults.pcm.card 1
   defaults.ctl.card 1
   ```

Volume settings can be done via `alsamixer`
## Security

https://wiki.archlinux.org/title/Security

#### Uncomplicated firewall

https://wiki.archlinux.org/title/Uncomplicated_Firewall

`sudo pacman -Syu ufw`

`systemctl enable ufw.service` && `systemctl start ufw.service`

Simple settings

```
# ufw default deny
# ufw allow from 192.168.1.0/24
# ufw allow Deluge
# ufw limit ssh
```

then `sudo ufw enable`

get settings `sudo ufw status`

##### arch-audit

`sudo pacman -Syu arch-audit`

query package `sudo pacman -Ql <packangename>`