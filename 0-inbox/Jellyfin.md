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

## 6. Mount NAS media storage

```bash
# Install NFS client
pct exec 200 -- apt-get install -y nfs-common

# Check available NFS exports from NAS
pct exec 200 -- showmount -e nas.milanoid.net

# Create mount point and mount the video share
pct exec 200 -- bash -c '
  mkdir -p /media/movies && \
  mount -t nfs nas.milanoid.net:/volume1/video /media/movies
'

# Make mount persistent across reboots (soft mount with 15s timeout)
pct exec 200 -- bash -c '
  echo "nas.milanoid.net:/volume1/video /media/movies nfs defaults,soft,timeo=150 0 0" >> /etc/fstab
'

# Mount second movie collection from /volume1/k8s/movies
pct exec 200 -- bash -c '
  mkdir -p /media/k8s-movies && \
  mount -t nfs nas.milanoid.net:/volume1/k8s/movies /media/k8s-movies
'
pct exec 200 -- bash -c '
  echo "nas.milanoid.net:/volume1/k8s/movies /media/k8s-movies nfs defaults,soft,timeo=150 0 0" >> /etc/fstab
'
```

## 7. Fix GPU permissions (renderD128 GID mismatch)

The host's `render` group GID (993) differs from the container's (104).
Bind-mounted `/dev/dri/renderD128` keeps the host GID, so the jellyfin user can't access it.

```bash
# Fix ownership now
pct exec 200 -- chgrp render /dev/dri/renderD128

# Make it persistent across reboots via udev rule
pct exec 200 -- bash -c '
cat > /etc/udev/rules.d/99-gpu.rules <<EOF
KERNEL=="renderD128", GROUP="render", MODE="0660"
KERNEL=="card0", GROUP="video", MODE="0660"
EOF
'

# Restart Jellyfin to pick up the fix
pct exec 200 -- systemctl restart jellyfin

# Verify VAAPI works as jellyfin user
pct exec 200 -- su -s /bin/bash -c "vainfo --display drm --device /dev/dri/renderD128" jellyfin
```

## 8. Cloudflare Tunnel (remote access via jf.milanoid.net)

```bash
# Install cloudflared from official Cloudflare apt repo
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg -o /usr/share/keyrings/cloudflare-main.gpg
echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main" > /etc/apt/sources.list.d/cloudflared.list
apt-get update && apt-get install -y cloudflared
```

```bash
# Authenticate with Cloudflare — opens a URL, select milanoid.net zone
cloudflared tunnel login
```

```bash
# Create a named tunnel (generates UUID + credentials JSON)
cloudflared tunnel create jellyfin
```

```bash
# Write tunnel config: route jf.milanoid.net → Jellyfin on localhost:8096
# Replace <UUID> with the tunnel ID from the previous command
cat > /root/.cloudflared/config.yml <<'EOF'
tunnel: <UUID>
credentials-file: /root/.cloudflared/<UUID>.json

ingress:
  - hostname: jf.milanoid.net
    service: http://localhost:8096
  - service: http_status:404
EOF
```

```bash
# Create DNS CNAME record pointing jf.milanoid.net to the tunnel
cloudflared tunnel route dns jellyfin jf.milanoid.net
```

```bash
# Install cloudflared as a systemd service so it starts on boot
cloudflared service install
systemctl enable --now cloudflared
```

```bash
# Verify tunnel is running and reachable
systemctl status cloudflared
curl -s -o /dev/null -w "%{http_code}" https://jf.milanoid.net
```

## TODO

- [x] Complete Jellyfin setup wizard in browser
- [x] Enable VAAPI hardware transcoding in Dashboard > Playback > Transcoding
- [ ] Replace `<UUID>` in config.yml with actual tunnel ID after `cloudflared tunnel create`
