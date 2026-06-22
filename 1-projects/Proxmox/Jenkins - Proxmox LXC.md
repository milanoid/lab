# Jenkins on Proxmox LXC

Jenkins `2.387.3` with plugins pinned to match the work golden image:
- github 1.37.1 (not 1.45.0 — that version requires Jenkins core ≥2.504.1, incompatible with 2.387.3. 1.37.1 is the github plugin version that was actually current when 2.387.3 was the LTS, so it's what work's instance likely runs)

This is a personal sandbox for testing pipeline configs you can't safely test on production Jenkins at work — not part of the K3s homelab GitOps repo, and not exposed publicly.

---

## 1. Create LXC in Proxmox

- vmid = `204`

In the Proxmox UI:

| Setting | Value |
|---|---|
| Template | Ubuntu 24.04 |
| RAM | 3072 MB |
| Swap | 1024 MB |
| CPU | 2 vCPUs |
| Disk | 20 GB |
| Features | `nesting=1` (required for Docker) |

> Originally provisioned at 2048MB RAM / 512MB swap, but the Jenkins JVM (default heap sizing) used ~96% of that and pushed the full swap into use, causing the UI to lag. Bumped to 3072MB / 1024MB via `pct set 204 --memory 3072 --swap 1024` (applies live, no restart). Proxmox host has plenty of headroom for this (6.5Gi available at time of writing).

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
  --memory 3072 \
  --swap 1024 \
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

Jenkins plugins are baked in at build time (rather than dropped in as jars) using `jenkins-plugin-cli`, so create a small `Dockerfile`. `jenkins-plugin-cli` always resolves *transitive* dependencies against today's latest plugin versions regardless of the requested plugin version — which breaks against an old pinned core like 2.387.3. The fix is to pin every transitive dependency explicitly too, using the exact versions that were valid when github 1.37.1 was released (cross-checked against [updates.jenkins.io's plugin-versions.json](https://updates.jenkins.io/current/plugin-versions.json) for `requiredCore` compatibility):

```bash
cat > /opt/jenkins/Dockerfile <<'EOF'
FROM jenkins/jenkins:2.387.3-lts

RUN jenkins-plugin-cli --plugins \
    "github:1.37.1" \
    "apache-httpcomponents-client-4-api:4.5.13-138.v4e7d9a_7b_a_e61" \
    "bouncycastle-api:2.26" \
    "caffeine-api:2.9.3-65.v6a_47d0f4d1fe" \
    "commons-lang3-api:3.12.0-36.vd97de6465d5b_" \
    "credentials:1189.vf61b_a_5e2f62e" \
    "credentials-binding:523.vd859a_4b_122e6" \
    "display-url-api:2.3.7" \
    "git:5.0.0" \
    "git-client:4.0.0" \
    "github-api:1.303-400.v35c2d8258028" \
    "instance-identity:142.v04572ca_5b_265" \
    "jackson2-api:2.13.2-260.v43d711474c77" \
    "jakarta-activation-api:2.0.0-2" \
    "jakarta-mail-api:2.0.0-5" \
    "jsch:0.1.55.61.va_e9ee26616e7" \
    "mailer:438.v02c7f0a_12fa_4" \
    "okhttp-api:4.9.3-108.v0feda04578cf" \
    "plain-credentials:143.v1b_df8b_d3b_e48" \
    "scm-api:631.v9143df5b_e4a_a" \
    "script-security:1228.vd93135a_2fb_25" \
    "snakeyaml-api:1.29.1" \
    "ssh-credentials:305.v8f4381501156" \
    "structs:324.va_f5d6774f3a_d" \
    "token-macro:321.vd7cc1f2a_52c8" \
    "trilead-api:2.84.v72119de229b_7" \
    "workflow-scm-step:400.v6b_89a_1317c9a_" \
    "workflow-step-api:639.v6eca_cd8c04a_a_"
EOF
```

> If you add another plugin later and hit the same "requires a greater version of Jenkins" error, resolve its dependency closure the same way: walk `plugin-versions.json` recursively from the target plugin/version, keeping the *highest* version requested for each dependency name across the whole tree (a naive depth-first pick of the first-seen version can leave older sub-dependencies that conflict with a different branch's requirement).

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

Open `http://192.168.1.205:8080` or `http://jenkins.milanoid.net:8080` in a browser.

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

Static IP: `192.168.1.205`. Internal DNS (LAN-only, no public tunnel needed for a personal sandbox): `http://jenkins.milanoid.net:8080/`

- [x] Configure GitHub plugin (webhook/credentials)
- [ ] Take initial "post-setup" snapshot before first experimental pipeline run
- [x] If still laggy after the RAM/swap bump, consider capping the JVM heap explicitly (e.g. `JAVA_OPTS: -Xmx1536m` in `docker-compose.yml`) instead of growing the container further
