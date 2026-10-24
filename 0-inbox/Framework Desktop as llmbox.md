
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

- [x] OS: Ubuntu Server 26 lts
- [x] removing/disabling not needed services



---

# Hermes

https://hermes-agent.nousresearch.com/