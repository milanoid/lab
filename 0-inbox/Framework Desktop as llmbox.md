
- [x] BIOS VRAM to the minimum (512 MB) and let the GPU use system RAM through GTT instead

```bash
# BIOS: set iGPU memory / UMA to minimum, then:
sudo vim /etc/default/grub
# GRUB_CMDLINE_LINUX_DEFAULT="ttm.pages_limit=32505856 ttm.page_pool_size=32505856 amdgpu.gttsize=126976"
#   (32505856 × 4 KiB pages = 124 GiB; leaves ~4 GB for the OS)
sudo update-grub && sudo reboot
# verify:
cat /sys/class/drm/card1/device/mem_info_gtt_total
```

- [x] OS: Ubuntu Server 26 lts
- [ ] 