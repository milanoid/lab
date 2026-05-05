# SonarQube CE on Proxmox LXC

SonarQube Community Edition `24.12.0.100206-community` with plugins matching the internal golden image:
- sonar-groovy-plugin 1.8
- sonar-cxx-plugin 2.2.0
- sonarqube-community-branch-plugin 1.23.0

---

## 1. Create LXC in Proxmox

In the Proxmox UI:

| Setting | Value |
|---|---|
| Template | Ubuntu 24.04 |
| RAM | 4096 MB |
| CPU | 2 vCPUs |
| Disk | 30 GB |
| Features | `nesting=1` (required for Docker) |

Or via CLI on the Proxmox host:

```bash
pct create <VMID> local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst \
  --hostname sonarqube \
  --memory 4096 \
  --cores 2 \
  --rootfs local-lvm:30 \
  --net0 name=eth0,bridge=vmbr0,ip=dhcp \
  --features nesting=1 \
  --unprivileged 1

pct start <VMID>
pct enter <VMID>
```

---

## 2. Configure the LXC (run inside the container)

### Kernel parameter for Elasticsearch

```bash
echo 'vm.max_map_count=262144' > /etc/sysctl.d/99-sonarqube.conf
sysctl --system
```

### Install Docker

```bash
apt-get update && apt-get install -y curl
curl -fsSL https://get.docker.com | sh
```

---

## 3. Create project directory

```bash
mkdir -p /opt/sonarqube/plugins
cd /opt/sonarqube
```

---

## 4. Download plugins

```bash
cd /opt/sonarqube/plugins

curl -LO https://github.com/Inform-Software/sonar-groovy/releases/download/1.8/sonar-groovy-plugin-1.8.jar
curl -LO https://github.com/SonarOpenCommunity/sonar-cxx/releases/download/cxx-2.2.0/sonar-cxx-plugin-2.2.0.1110.jar
curl -LO https://github.com/mc1arke/sonarqube-community-branch-plugin/releases/download/1.23.0/sonarqube-community-branch-plugin-1.23.0.jar

# Rename branch plugin — version suffix removed so JAVA_OPTS reference stays stable
mv sonarqube-community-branch-plugin-1.23.0.jar sonarqube-community-branch-plugin.jar

chown -R 1000:1000 /opt/sonarqube/plugins
chmod -R 700 /opt/sonarqube/plugins
```

---

## 5. Create `.env` file

```bash
cat > /opt/sonarqube/.env <<'EOF'
SONAR_DB_PASSWORD=changeme
EOF
chmod 600 /opt/sonarqube/.env
```

> Change `changeme` to a strong password before starting.

---

## 6. Create `docker-compose.yml`

```bash
cat > /opt/sonarqube/docker-compose.yml <<'EOF'
services:
  sonarqube:
    image: sonarqube:24.12.0.100206-community
    container_name: sonarqube
    depends_on:
      - db
    environment:
      SONAR_JDBC_URL: jdbc:postgresql://db:5432/sonar
      SONAR_JDBC_USERNAME: sonar
      SONAR_JDBC_PASSWORD: ${SONAR_DB_PASSWORD}
      SONAR_WEB_JAVAADDITIONALOPTS: -javaagent:./extensions/plugins/sonarqube-community-branch-plugin.jar=web
      SONAR_CE_JAVAADDITIONALOPTS: -javaagent:./extensions/plugins/sonarqube-community-branch-plugin.jar=ce
    volumes:
      - sonarqube_data:/opt/sonarqube/data
      - sonarqube_logs:/opt/sonarqube/logs
      - sonarqube_extensions:/opt/sonarqube/extensions
      - ./plugins:/opt/sonarqube/extensions/plugins
    ports:
      - "9000:9000"
    ulimits:
      nofile:
        soft: 65536
        hard: 65536
    restart: unless-stopped

  db:
    image: postgres:16
    container_name: sonarqube-db
    environment:
      POSTGRES_USER: sonar
      POSTGRES_PASSWORD: ${SONAR_DB_PASSWORD}
      POSTGRES_DB: sonar
    volumes:
      - postgresql_data:/var/lib/postgresql/data
    restart: unless-stopped

volumes:
  sonarqube_data:
  sonarqube_logs:
  sonarqube_extensions:
  postgresql_data:
EOF
```

---

## 7. Start

```bash
cd /opt/sonarqube
docker compose up -d
```

Check logs:

```bash
docker compose logs -f sonarqube
```

SonarQube is ready when you see `SonarQube is operational` in the logs (takes ~1–2 minutes).

---

## 8. First login

Open `http://<lxc-ip>:9000` in a browser.

- Default credentials: `admin` / `admin`
- Change password on first login when prompted

---

## Notes

- The `community-branch-plugin` **requires** the `-javaagent` JVM flags (`SONAR_WEB_JAVAADDITIONALOPTS` + `SONAR_CE_JAVAADDITIONALOPTS`) — dropping the JAR alone is not enough
- Take a Proxmox snapshot before upgrading SonarQube versions: `pct snapshot <VMID> pre-upgrade`
- Plugins are bind-mounted from `./plugins/` so they survive container recreation without rebuilding an image
