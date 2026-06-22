# Jenkins on Proxmox LXC

Jenkins `2.387.3` with plugins pinned to match the work golden image:
- github 1.45.0

This is a personal sandbox for testing pipeline configs you can't safely test on production Jenkins at work — not part of the K3s homelab GitOps repo, and not exposed publicly.

---

## 1. Create LXC in Proxmox

- vmid = `204`

In the Proxmox UI:

| Setting | Value |
|---|---|
| Template | Ubuntu 24.04 |
| RAM | 2048 MB |
| CPU | 2 vCPUs |
| Disk | 20 GB |
| Features | `nesting=1` (required for Docker) |

Or via CLI on the Proxmox host:

```bash
# fetch
pveam update
pveam available | grep ubuntu-24
pveam download local ubuntu-24.04-standard_24.04-2_amd64.tar.zst
```

```bash
pct create <VMID> local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst \
  --hostname jenkins \
  --memory 2048 \
  --cores 2 \
  --rootfs local-lvm:20 \
  --net0 name=eth0,bridge=vmbr0,ip=dhcp \
  --features nesting=1 \
  --unprivileged 1

pct start <VMID>
pct enter <VMID>
```

---

## 2. Configure the LXC (run inside the container)

### Install Docker

```bash
apt-get update && apt-get install -y curl
curl -fsSL https://get.docker.com | sh
```

---

## 3. Create project directory

```bash
mkdir -p /opt/jenkins
cd /opt/jenkins
```

---

## 4. Pin plugin versions via a custom image

Jenkins plugins are baked in at build time (rather than dropped in as jars) using `jenkins-plugin-cli`, so create a small `Dockerfile`:

```bash
cat > /opt/jenkins/Dockerfile <<'EOF'
FROM jenkins/jenkins:2.387.3-lts

RUN jenkins-plugin-cli --plugins \
    "github:1.45.0"
EOF
```

> Add more `--plugins "<name>:<version>"` lines here as you match more of the work golden image.

---

## 5. Create `docker-compose.yml`

```bash
cat > /opt/jenkins/docker-compose.yml <<'EOF'
services:
  jenkins:
    build: .
    container_name: jenkins
    environment:
      JAVA_OPTS: -Djenkins.install.runSetupWizard=true
    volumes:
      - jenkins_home:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
    ports:
      - "8080:8080"
      - "50000:50000"
    restart: unless-stopped

volumes:
  jenkins_home:
EOF
```

> The Docker socket bind-mount lets Jenkins agents run `docker build` directly on the Proxmox host's Docker daemon — drop that volume line if you don't need container builds from pipelines.

---

## 6. Build and start

```bash
cd /opt/jenkins
docker compose up -d --build
```

Check logs:

```bash
docker compose logs -f jenkins
```

Jenkins is ready when you see `Jenkins is fully up and running` in the logs (takes ~30–60 seconds).

---

## 7. First login

Open `http://<lxc-ip>:8080` in a browser.

```bash
# get IP
pct exec <VMID> -- ip addr show eth0 | grep 'inet '
```

```bash
# get initial admin password
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

- Skip "Install suggested plugins" (already pinned via the Dockerfile) — choose "Select plugins to install" and select none, or just continue past it
- Create your admin user when prompted

---

## Notes

- Plugin versions are baked into the image at build time via `jenkins-plugin-cli` — to bump a version, edit the `Dockerfile` and `docker compose up -d --build` again
- Take a Proxmox snapshot before any risky pipeline experiment or version bump: `pct snapshot <VMID> pre-change`
- `jenkins_home` is a named Docker volume, so plugin/job state survives container rebuilds

### Extras

Assign a static IP in your router for the LXC:

```bash
# get MAC
pct exec <VMID> -- ip link show eth0
```

Optional Cloudflare/internal DNS (LAN-only, no public tunnel needed for a personal sandbox):

`http://jenkins.milanoid.net:8080/`

- [ ] Configure GitHub plugin (webhook/credentials) once IP/DNS is set
- [ ] Take initial "post-setup" snapshot before first experimental pipeline run
