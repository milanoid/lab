
## OS and BIOS settings

- [x] BIOS VRAM to the minimum (512 MB) and let the GPU use system RAM through GTT instead

```bash
# BIOS: set iGPU memory / UMA to minimum, then:
sudo vim /etc/default/grub

GRUB_CMDLINE_LINUX_DEFAULT="ttm.pages_limit=31457280 ttm.page_pool_size=31457280 amdgpu.gttsize=122880"
# 31457280 × 4 KiB pages = 120 GiB max GPU allocation (a ceiling, not reserved)

sudo update-grub && sudo reboot
# verify:
cat /sys/class/drm/card1/device/mem_info_gtt_total
```

GPU can dynamically allocate up to 120GB of memory

- [x] OS: Ubuntu Server 26.04 lts
- [x] removing/disabling not needed services



---

# Hermes agent with local llm

https://hermes-agent.nousresearch.com/

```bash
#  1. System prerequisites (sudo)
sudo apt update
sudo apt install -y git libatomic1 mesa-vulkan-drivers libvulkan1 vulkan-tools tmux
sudo usermod -aG render,video milan
exit   # log out and SSH back in so the new groups apply
```


```bash
#  2. Verify the GPU is usable via Vulkan
groups                       # must include render video
vulkaninfo --summary | grep -E "deviceName|driverName"
# expect: AMD Radeon 8060S Graphics (RADV STRIX_HALO), driverName = radv
```


```bash
# Stage 3: install Hermes:

curl -fsSL https://hermes-agent.nousresearch.com/install.sh -o /tmp/hermes-install.sh
less /tmp/hermes-install.sh      # skim it before running
bash /tmp/hermes-install.sh --skip-computer-use --skip-browser
source ~/.bashrc
hermes doctor

# --skip-browser leaves out Hermes' built-in browser, which needs Chromium libraries this minimal install doesn't have. You can add it later with hermes pm install chromium.
```