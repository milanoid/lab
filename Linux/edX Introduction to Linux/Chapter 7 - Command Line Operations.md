
_"graphical user interfaces make easy tasks easier, while command line interfaces make difficult tasks possible"_

- `terminal emulator` - emulates terminal within a window on the desktop


### Basic Utilities

- `cat` - type out a file
- `head` - show first few lines of a file
- `tail` - show last few lines of a file
- `man` - documentation

### The Command Line

`ls -l /home/user`

- Command - `ls`
- Options or Switches - `-l`
- Argument `/home/user`

### sudo

- allows to run a command using security privileges of another user, generally `root`
- if not set up and enabled the following steps are needed
	- `$ su` (switch user) - type in `root` password
	- `#` - the prompt changed from `$` to `#`
	- create a user file in `/etc/sudoers.d/`, e.g. `/etc/sudoers.d/student`
	- `chmod 440 /etc/sudoers.d/student`


### Virtual Terminals

- console sessions that use the entire display and keyboard outside of a graphical environment
- one virtual terminal (usually VT 1 or VT 7) is reserved for the graphical environment
- switching using e.g.  `CTRL-ALT-F6` for VT 6

### Turning Off the GUI

- `sudo systemctl stop gdm`
- or `sudo telinit 3`

### Basic Operations

- `shutdown -h` (also `halt` or `poweroff`)
- `shutdown -r` (also `reboot`)
- `which` - locates where on the filesystem resides a program
- `whereis` - alternative to `which` if that one does not find anything
- `cd` - change directory, `cd -` change to previous working directory
- `pushd`, `popd` - push and retrieve a directory
- `tree` - traversing filesystem

#### Absolute vs Relative path

- absolute always starts with `/` - e.g. `/home/user`
- relative starts from current working directory, never starts with `/`, e.g. `home/user`

### Hard Links, Soft Links

- utility `ln`
- `ln -s` - soft link also known as symbolic link
	- hard link - `ls -i` prints unique quantity, if two files having the same it is the hard link
	- soft link - can point to objects even on different filesystems, partitions, and/or disks




