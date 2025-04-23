Issue:

After _reboot_ command (boot .img removed from virtual CD) I am getting only to 

"Reboot into Firmware Interface"


1. issue in `/boot/loader/entries/arch.conf`
   had a typo in `initrd /initramfs-linux.img` it was incorrectly set as `initrd /initramfs-linux=img`
2. the file had incorrect filename suffix `/boot/loader/entries/arch.linux` instead of `/boot/loader/entries/arch.conf`

Now it works!


#### Setup ssh

`systemctl status sshd`

`sudo pacman -Syu openssh`

as root: 
`systemctl enable sshd.service`
`systemctl start sshd.service`

### In VirtualBox with NAT network type

To be able to ssh into it you need:

1. enable Port Forwarding in VBOX (tcp, guest port 22, host port e.g. 2222)
2. connect from Mac `ssh -p 2222 milan@127.0.0.1`

##### enable bash completion

`sudo pacman -Syu bash-completion`
