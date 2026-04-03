# Jellyfin LXC Setup on Proxmox

Host: `ssh proxmox` (192.168.1.200), Proxmox 9.1.7, Intel i3-8100T, UHD 630 iGPU
Container: ID 200, Debian 12, IP 192.168.1.201 (DHCP reserved via MAC)

## 1. Download LXC template

```bash
# Download Debian 12 template to local storage
pveam download local debian-12-standard_12.12-1_amd64.tar.zst
```

## 2. Create LXC container

```bash
# Create privileged container: 4 cores, 4GB RAM, 32GB disk, DHCP with pre-assigned MAC
pct create 200 local:vztmpl/debian-12-standard_12.12-1_amd64.tar.zst \
  --hostname jellyfin \
  --cores 4 \
  --memory 4096 \
  --swap 512 \
  --storage local-lvm \
  --rootfs local-lvm:32 \
  --net0 name=eth0,bridge=vmbr0,hwaddr=BC:24:11:DE:AD:01,ip=dhcp \
  --unprivileged 0 \
  --features nesting=1 \
  --onboot 1 \
  --ssh-public-keys /path/to/key.pub \
  --password jellyfin
```

## 3. Configure iGPU passthrough

```bash
# Add Intel UHD 630 GPU device permissions and bind mounts to LXC config
# Major 226 = DRM subsystem; minor 0 = card0, 128 = renderD128
cat >> /etc/pve/lxc/200.conf <<'EOF'

# Intel UHD 630 iGPU passthrough for hardware transcoding
lxc.cgroup2.devices.allow: c 226:0 rwm
lxc.cgroup2.devices.allow: c 226:128 rwm
lxc.mount.entry: /dev/dri/card0 dev/dri/card0 none bind,optional,create=file
lxc.mount.entry: /dev/dri/renderD128 dev/dri/renderD128 none bind,optional,create=file
EOF
```

## 4. Start container and install Jellyfin

```bash
# Start the container
pct start 200

# Install Jellyfin using official install script (adds repo + installs packages)
pct exec 200 -- bash -c '
  apt-get update && \
  apt-get install -y curl gnupg && \
  curl -fsSL https://repo.jellyfin.org/install-debuntu.sh | bash
'

# Grant jellyfin user access to GPU devices for VAAPI hardware transcoding
pct exec 200 -- bash -c '
  usermod -aG render jellyfin && \
  usermod -aG video jellyfin && \
  systemctl restart jellyfin
'
```

## 5. Verify

```bash
# Confirm GPU device is visible inside the container
pct exec 200 -- ls -la /dev/dri/renderD128

# Confirm VAAPI is listed as available hardware acceleration
pct exec 200 -- /usr/lib/jellyfin-ffmpeg/ffmpeg -v quiet -hwaccels

# Test web UI is responding (expect 302 redirect to setup wizard)
curl -s -o /dev/null -w "%{http_code}" http://192.168.1.201:8096
```

## Access

Web UI: http://192.168.1.201:8096
SSH: `ssh root@192.168.1.201` (password: `jellyfin`)
Console: `pct enter 200` from Proxmox host

## TODO

- [ ] Complete Jellyfin setup wizard in browser
- [ ] Enable VAAPI hardware transcoding in Dashboard > Playback > Transcoding
- [ ] Mount media storage (Synology NAS NFS share) into the container
