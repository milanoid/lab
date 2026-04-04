# Claude Code on Proxmox

> Persistent Claude Code assistant running on Proxmox LXC, accessible via SSH from any terminal and via Telegram from iPhone using the official Claude Code Channels feature.

## Overview

| Property | Value |
|---|---|
| VMID | 201 |
| Hostname | claude-code |
| MAC | `02:CC:CC:00:02:01` |
| IP | `192.168.1.202` |
| OS | Debian 12 |
| CPU | 2 cores |
| RAM | 2 GB + 512 MB swap |
| Disk | 64 GB (local-lvm, thin provisioned) |
| NAS mount | `192.168.1.36:/volume1/homes/milan` → `/mnt/nas-documents` (read-only) |
| Auth | Claude Pro (OAuth) |
| Access | SSH + tmux, Telegram (Channels) |

---

## Step 1: DHCP Reservation (DONE)

Assigned in DHCP server:
- MAC `02:CC:CC:00:02:01` → IP `192.168.1.202`, hostname `claude`

---

## Step 2: Create LXC Container

```bash
ssh proxmox
```

### Download the Debian 12 container template

```bash
pveam download local debian-12-standard_12.12-1_amd64.tar.zst
```

> **Why:** Proxmox uses pre-built OS templates for LXC containers. This downloads the official Debian 12 template to local storage.

### Create the container

```bash
pct create 201 local:vztmpl/debian-12-standard_12.12-1_amd64.tar.zst \
  --hostname claude-code \
  --cores 2 \
  --memory 2048 \
  --swap 512 \
  --storage local-lvm \
  --rootfs local-lvm:64 \
  --net0 name=eth0,bridge=vmbr0,ip=dhcp,hwaddr=02:CC:CC:00:02:01 \
  --unprivileged 1 \
  --features nesting=1 \
  --start 1 \
  --onboot 1
```

> **Why each flag:**
> - `201` — VMID, next after jellyfin (200)
> - `--hostname claude-code` — container hostname
> - `--cores 2 --memory 2048 --swap 512` — lightweight: Claude Code is mostly network I/O (API calls to Anthropic), not CPU/RAM heavy
> - `--storage local-lvm --rootfs local-lvm:64` — 64 GB root disk on the LVM thin pool (thin provisioned — only uses actual written space)
> - `--net0 ...,ip=dhcp,hwaddr=02:CC:CC:00:02:01` — bridge networking with DHCP; MAC matches our reservation for IP 192.168.1.202
> - `--unprivileged 1` — security: container runs without root privileges on the host
> - `--features nesting=1` — allows running systemd inside the container
> - `--start 1` — start immediately after creation
> - `--onboot 1` — auto-start when Proxmox boots

### Enter the container

```bash
pct enter 201
```

---

## Step 3: Install Dependencies

### System packages

```bash
apt update && apt upgrade -y
apt install -y curl git tmux build-essential python3 openssh-server nfs-common
```

> **Why each package:**
> - `curl` — downloading install scripts
> - `git` — version control (Claude Code uses it heavily)
> - `tmux` — persistent terminal sessions that survive SSH disconnects
> - `build-essential` — C compiler toolchain, needed by some npm packages with native addons
> - `python3` — used by some build tools (node-gyp)
> - `openssh-server` — allows SSH access into the container
> - `nfs-common` — NFS client tools, needed to mount Synology NAS shares

### Node.js 22 LTS

```bash
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt install -y nodejs
```

> **Why:** Claude Code CLI is a Node.js application. Version 22 is the current LTS.

### Bun

```bash
curl -fsSL https://bun.sh/install | bash
```

> **Why:** The official Claude Code Telegram Channels plugin requires Bun as its runtime.

### Claude Code CLI

```bash
npm install -g @anthropic-ai/claude-code
```

> **Why:** The core tool. Installed globally so it's available as the `claude` command. Needs version >= 2.1.80 for Channels support.

---

## Step 3b: Mount NAS Documents

```bash
mkdir -p /mnt/nas-documents
echo "192.168.1.36:/volume1/homes/milan /mnt/nas-documents nfs nfsvers=4.1,ro,noatime,hard 0 0" >> /etc/fstab
mount /mnt/nas-documents
```

> **Why:** Mounts your Synology NAS home directory into the container so Claude can read your documents. Key mount options:
> - `ro` — read-only: Claude can read but not modify or delete files on the NAS
> - `nfsvers=4.1` — NFSv4.1 for better performance and security
> - `noatime` — don't update access timestamps (reduces NFS traffic)
> - `hard` — retry indefinitely if NAS is temporarily unreachable
> - Added to `/etc/fstab` so it auto-mounts on container boot

---

## Step 4: Create User & Workspace

```bash
useradd -m -s /bin/bash claude
su - claude
mkdir -p ~/workspace
ln -s /mnt/nas-documents ~/documents
```

> **Why:** Run Claude Code as a dedicated non-root user for security. `~/workspace` is where Claude Code will create and edit files. The symlink `~/documents` gives Claude easy access to your NAS files (e.g., "read ~/documents/notes/...").

---

## Step 5: Authenticate Claude Code

As the `claude` user:

```bash
claude auth login
```

> **Why:** Authenticates with your Claude Pro account via OAuth. Since this is a headless server, it uses the device code flow — displays a URL and code to enter on any device (iPhone or Mac browser). One-time step; the session token is cached locally.

---

## Step 6: SSH Access

### Set up SSH keys

On the container (as root):

```bash
mkdir -p /home/claude/.ssh
echo "<your-ssh-public-key>" > /home/claude/.ssh/authorized_keys
chown -R claude:claude /home/claude/.ssh
chmod 700 /home/claude/.ssh
chmod 600 /home/claude/.ssh/authorized_keys
```

> **Why:** Key-based SSH auth — more secure than passwords and allows passwordless login.

### Configure SSH on your Mac

Add to `~/.ssh/config`:

```
Host claude-code
    HostName 192.168.1.202
    User claude
    ProxyJump proxmox
```

> **Why:** `ProxyJump proxmox` means SSH first connects to the Proxmox host, then hops into the container. No need to expose the container's SSH port directly.

### Usage

```bash
ssh claude-code        # connect
tmux new -s cc         # create persistent session
claude                 # start Claude Code TUI
# Ctrl+B, D to detach — session stays alive
# Later: ssh claude-code && tmux a  — reconnect
```

---

## Step 7: Create Telegram Bot

### 7a. Create the bot

1. Open **Telegram** on your iPhone
2. Search for **@BotFather** and open a chat
3. Send `/newbot`
4. Enter a **display name** (e.g., `Claude Code Assistant`)
5. Enter a **username** ending in `bot` (e.g., `milan_claude_code_bot`)
6. BotFather replies with a **bot token** (format: `123456789:ABCdef...`) — save it

### 7b. (Optional) Customize the bot

1. Send `/setdescription` to BotFather → select your bot → enter a description
2. Send `/setuserpic` to BotFather → select your bot → upload a profile photo

### 7c. Get your Telegram user ID

1. Search for **@userinfobot** on Telegram and open a chat
2. Send any message — it replies with your numeric user ID
3. Save this ID — used to restrict the bot so only you can use it

---

## Step 8: Install & Configure Telegram Channel

As the `claude` user on the container:

### Install the official plugin

```bash
cd ~
git clone https://github.com/anthropics/claude-plugins-official.git
cd claude-plugins-official/external_plugins/telegram
bun install
```

> **Why:** Anthropic's official Telegram plugin for Claude Code Channels. Bridges Telegram messages into a Claude Code session with full agentic capabilities (file editing, bash, git). No custom bot code needed.

### Start Claude Code with Telegram

```bash
export TELEGRAM_BOT_TOKEN="<your-bot-token>"
claude --channel telegram
```

> **Why:** The `--channel telegram` flag activates the Channels feature. Uses long-polling (outbound connections only — no incoming ports needed on your network).

---

## Step 9: Make It Persistent

### Option A: tmux (simple, manual restart after reboot)

```bash
tmux new -s claude
export TELEGRAM_BOT_TOKEN="<token>"
claude --channel telegram
# Ctrl+B, D to detach
```

> **Why:** tmux keeps the session alive when you disconnect SSH. Simple but needs manual restart after a Proxmox reboot.

### Option B: systemd service (auto-start on boot)

Create `/etc/systemd/system/claude-code.service` as root:

```ini
[Unit]
Description=Claude Code with Telegram Channel
After=network.target

[Service]
Type=simple
User=claude
WorkingDirectory=/home/claude/workspace
Environment=TELEGRAM_BOT_TOKEN=<your-bot-token>
ExecStart=/usr/local/bin/claude --channel telegram
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

```bash
systemctl daemon-reload
systemctl enable --now claude-code
```

> **Why:** systemd ensures Claude Code starts automatically on boot and restarts if it crashes. `RestartSec=10` avoids rapid failure loops.

---

## Security Notes

- **Unprivileged LXC** — container processes can't escalate to Proxmox host
- **SSH key-only** — no password authentication
- **OAuth** — no API keys stored in plaintext files
- **Telegram restricted** — bot only responds to your user ID
- **No open ports** — Telegram uses outbound long-polling, SSH goes through ProxyJump

---

## Verification

1. `ssh claude-code` → `claude --version` → confirm >= 2.1.80
2. `tmux new -s cc` → `claude` → interactive TUI works
3. Send a Telegram message to your bot → get a response with agentic capabilities
4. Reboot Proxmox → verify container + service auto-start
5. Telegram still works after reboot
