
### home directory was missing

`userdel` + `useradd -m`

### missing packages

`sudo pacman -S polkit rtkit`

### enable systemd service `seatd`

`sudo systemctl enable seatd.service`
`sudo systemctl start seatd.service`

### add user to video mode

`sudo usermod -aG video milan`

### set up /home in /etc/fstab

### fix boot loader menu to 3 seconds

`vim /boot/loader/loader.conf`

```
timeout 2
default arch.conf
console-mode max
editor no
```

`man 5 loader.conf`

## 1st Hyprland start

Start by `Hyprland`

Crash log file in `~/.cache/hyprland/`

```
--------------------------------------------
   Hyprland Crash Report
--------------------------------------------
This was an accident, I swear!

Hyprland received signal 6(ABRT)
Version: 29e2e59fdbab8ed2cc23a20e3c6043d5decb5cdc
Tag: v0.48.1
Date: Fri Mar 28 16:16:07 2025
Flags:

System info:
	System name: Linux
	Node name: jantar
	Release: 6.14.4-arch1-2
	Version: #1 SMP PREEMPT_DYNAMIC Tue, 29 Apr 2025 09:23:13 +0000

GPU:
	00:02.0 VGA compatible controller [0300]: VMware SVGA II Adapter [15ad:0405] (prog-if 00 [VGA controller])
	Subsystem: VMware SVGA II Adapter [15ad:0405]


os-release:
	NAME="Arch Linux"
	PRETTY_NAME="Arch Linux"
	ID=arch
	BUILD_ID=rolling
	ANSI_COLOR="38;2;23;147;209"
	HOME_URL="https://archlinux.org/"
	DOCUMENTATION_URL="https://wiki.archlinux.org/"
	SUPPORT_URL="https://bbs.archlinux.org/"
	BUG_REPORT_URL="https://gitlab.archlinux.org/groups/archlinux/-/issues"
	PRIVACY_POLICY_URL="https://terms.archlinux.org/docs/privacy-policy/"
	LOGO=archlinux-logo
Backtrace:
	# | Hyprland(_Z12getBacktracev+0x61) [0x5f80370ed4c1]
		getBacktrace()
		??:?
	#1 | Hyprland(_ZN14NCrashReporter18createAndSaveCrashEi+0x111f) [0x5f8037049b4f]
		NCrashReporter::createAndSaveCrash(int)
		??:?
	#2 | Hyprland(+0x2074d8) [0x5f8036fc04d8]
		CCompositor::getMonitorFromCursor()
		??:?
	#3 | /usr/lib/libc.so.6(+0x3def0) [0x792a59a4def0]
		??
		??:0
	#4 | /usr/lib/libc.so.6(+0x9774c) [0x792a59aa774c]
		??
		??:0
	#5 | /usr/lib/libc.so.6(gsignal+0x20) [0x792a59a4ddc0]
		??
		??:0
	#6 | Hyprland(_ZN15CHyprOpenGLImpl7initEGLEb+0x2e7) [0x5f80373adad7]
		CHyprOpenGLImpl::initEGL(bool)
		??:?
	#7 | Hyprland(_ZN15CHyprOpenGLImplC1Ev+0xd60) [0x5f80373b1710]
		CHyprOpenGLImpl::CHyprOpenGLImpl()
		??:?
	#8 | Hyprland(_ZN11CCompositor12initManagersE18eManagersInitStage+0x1123) [0x5f8036fc4ce3]
		CCompositor::initManagers(eManagersInitStage)
		??:?
	#9 | Hyprland(_ZN11CCompositor10initServerENSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEi+0xed3) [0x5f8036fc64e3]
		CCompositor::initServer(std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >, int)
		??:?
	#1 | Hyprland(main+0x875) [0x5f8036f657d5]
		main
		??:?
	#11 | /usr/lib/libc.so.6(+0x276b5) [0x792a59a376b5]
		??
		??:0
	#12 | /usr/lib/libc.so.6(__libc_start_main+0x89) [0x792a59a37769]
		??
		??:0
	#13 | Hyprland(_start+0x25) [0x5f8036fbb635]
		_start
		??:?


Log tail:
[LOG] Running on DRMFD: 27
[LOG] wl_display_add_socket for wayland-1 succeeded with 0
[LOG] Creating the CHyprOpenGLImpl!
[LOG] Supported EGL extensions: (16) EGL_EXT_device_base EGL_EXT_device_enumeration EGL_EXT_device_query EGL_EXT_platform_base EGL_KHR_client_get_all_proc_addresses EGL_EXT_client_extensions EGL_KHR_debug EGL_EXT_platform_device EGL_EXT_explicit_device EGL_EXT_platform_wayland EGL_KHR_platform_wayland EGL_EXT_platform_x11 EGL_KHR_platform_x11 EGL_EXT_platform_xcb EGL_MESA_platform_gbm EGL_KHR_platform_gbm EGL_MESA_platform_surfaceless
[LOG] eglDeviceFromDRMFD: Using device /dev/dri/card0
[ERR] [EGL] Command eglInitialize errored out with EGL_NOT_INITIALIZED (0x12289): DRI2: failed to create screen
[ERR] [EGL] Command eglInitialize errored out with EGL_NOT_INITIALIZED (0x12289): DRI2: failed to create screen
[ERR] [EGL] Command eglInitialize errored out with EGL_NOT_INITIALIZED (0x12289): DRI2: failed to create screen
[ERR] [EGL] Command eglInitialize errored out with EGL_NOT_INITIALIZED (0x12289): eglInitialize
[CRITICAL]
==========================================================================================
ASSERTION FAILED!

EGL: failed to initialize a platform display

at: line 130 in OpenGL.cpp
```

According Claude AI I should:

```
sudo pacman -S virtualbox-guest-utils mesa vulkan-swrast
sudo modprobe -a vboxguest vboxsf vboxvideo
echo -e "vboxguest\nvboxsf\nvboxvideo" | sudo tee /etc/modules-load.d/virtualbox.conf
```

 - edit your Hyprland configuration file (`~/.config/hypr/hyprland.conf`):

```bash
# VirtualBox specific settings
env = WLR_NO_HARDWARE_CURSORS,1
env = WLR_RENDERER,vulkan
env = LIBGL_ALWAYS_SOFTWARE,1
env = __GLX_VENDOR_LIBRARY_NAME,mesa
```

But still without 3D enabled it won't work. Whenever I enable 3D video in VBox the VM crashes.

### Fluxbox

Asking Claude

- trying another Window manager

`sudo pacman -S fluxbox xorg xorg-xinit`
`echo "exec startfluxbox" > ~/.xinitrc`


than `startx` - it works!

`sudo pacman -S fluxbox firefox alacritty`

`~/.fluxbox/usermenu`:

```
[begin] (Fluxbox Menu)
    [exec] (Firefox) {firefox} </usr/share/icons/hicolor/48x48/apps/firefox.png>
    [exec] (Terminal) {xterm} </usr/share/pixmaps/xterm-color_48x48.xpm>
    [separator]
    [submenu] (System) {}
        [exec] (Restart Fluxbox) {fluxbox-remote restart}
        [exec] (Logout) {fluxbox-remote exit}
    [end]
[end]
```

TODO - configure fluxbox to have terminal and Firefox.