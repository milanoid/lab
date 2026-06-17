# Nexus Repository Manager on Proxmox LXC

Sonatype Nexus Repository Manager 3 (OSS) running via Docker Compose in an unprivileged LXC container on Proxmox.

---

## 1. Create LXC in Proxmox

- vmid = 203
- IP assigned on router to 192.168.1.204 (f#%#%#!!!)

```bash
pct create <VMID> local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst \
  --hostname nexus \
  --memory 4096 \
  --cores 2 \
  --rootfs local-lvm:50 \
  --net0 name=eth0,bridge=vmbr0,ip=dhcp \
  --features nesting=1 \
  --unprivileged 1

pct start <VMID>
pct enter <VMID>
```

> 50 GB disk — Nexus stores artifacts so it needs more headroom than a typical service container.

---

## 2. Install Docker

```bash
apt update && apt install -y curl
curl -fsSL https://get.docker.com | sh
```

---

## 3. Create Directory Structure

```bash
mkdir -p /opt/nexus/nexus-data
chown -R 200:200 /opt/nexus/nexus-data
chmod -R 700 /opt/nexus/nexus-data
```

> Nexus runs as UID 200 inside the container.

---

## 4. Docker Compose

`/opt/nexus/docker-compose.yml`:

```yaml
services:
  nexus:
    image: sonatype/nexus3
    container_name: nexus
    ports:
      - "8081:8081"
    volumes:
      - ./nexus-data:/nexus-data
    restart: unless-stopped
    ulimits:
      nofile:
        soft: 65536
        hard: 65536
```

No separate database needed — Nexus uses embedded storage.

---

## 5. Start Nexus

```bash
cd /opt/nexus
docker compose up -d
docker compose logs -f nexus
```

Wait for: `Started Sonatype Nexus OSS`

---

## 6. Initial Admin Password

```bash
docker exec nexus cat /nexus-data/admin.password
```

Login at `http://<lxc-ip>:8081` as `admin` with the retrieved password, then set a new one.



---

## 7. Static IP & DNS

```bash
# Get MAC address for router static IP binding
pct exec <VMID> -- ip link show eth0
```

- Bind MAC to static IP in Asus router
- Cloudflare DNS: `nexus.milanoid.net` → static IP (port 8081)


http://nexus.milanoid.net:8081/#/login



## Post-install setup

### user/role

- created Nexus Role `ci-deployer` with the following privileges
- created user `github-actions` assigned the role

```
nx-apikey-all
nx-repository-view-*-*-add
nx-repository-view-*-*-browse
nx-repository-view-*-*-edit
nx-repository-view-*-*-read
```

### pypi repository

```
  You need three repositories (same pattern as your NuGet setup):

  ┌─────────────┬────────┬───────────────────────────────────────────┐
  │    Name     │  Type  │                  Purpose                  │
  ├─────────────┼────────┼───────────────────────────────────────────┤
  │ pypi-proxy  │ proxy  │ mirrors PyPI.org, caches packages locally │
  ├─────────────┼────────┼───────────────────────────────────────────┤
  │ pypi-hosted │ hosted │ stores your own private Python packages   │
  ├─────────────┼────────┼───────────────────────────────────────────┤
  │ pypi-group  │ group  │ single URL combining both above           │
  └─────────────┴────────┴───────────────────────────────────────────┘
```


```toml
# ~/.config/uv/uv.toml
[[index]]
name = "nexus-milanoid"
url = "http://github-actions@nexus.milanoid.net:8081/repository/pypi-group/simple/"
```

```bash
# stored the credentials in OS secure store
uv auth login http://nexus.milanoid.net:8081/repository/pypi-group/simple/ \
   --username github-actions --password -
```