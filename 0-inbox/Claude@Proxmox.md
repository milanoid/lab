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
apt install -y curl git tmux build-essential python3 openssh-server nfs-common unzip locales
```

> **Why each package:**
> - `curl` — downloading install scripts
> - `git` — version control (Claude Code uses it heavily)
> - `tmux` — persistent terminal sessions that survive SSH disconnects
> - `build-essential` — C compiler toolchain, needed by some npm packages with native addons
> - `python3` — used by some build tools (node-gyp)
> - `openssh-server` — allows SSH access into the container
> - `nfs-common` — NFS client tools, needed to mount Synology NAS shares
> - `unzip` — required by Bun installer
> - `locales` — fixes `setlocale` warnings in the container

### Fix locale

```bash
sed -i 's/# en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen && locale-gen
```

> **Why:** Debian minimal image doesn't generate locales, causing `setlocale` warnings on every command.

### Node.js 22 LTS

```bash
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt install -y nodejs
```

> **Why:** Claude Code CLI is a Node.js application. Version 22 is the current LTS.

### Bun

> **Important:** Bun must be installed per-user, not as root. Install it in Step 4 after creating the `claude` user. If installed as root, the `claude` user won't have access to it.

### Claude Code CLI

```bash
npm install -g @anthropic-ai/claude-code
```

> **Why:** The core tool. Installed globally so it's available as the `claude` command. Needs version >= 2.1.80 for Channels support.

---

## Step 3b: Mount NAS Documents (DONE)

On the **Proxmox host** (not inside the container):

### 1. Enable NFS export on Synology NAS

In Synology DSM → Control Panel → Shared Folders → select the `homes` share → Edit → NFS Permissions → add a rule for `192.168.1.0/24`.

### 2. Mount NFS on the host and persist in fstab

```bash
mkdir -p /mnt/nas-milan
echo "192.168.1.36:/volume1/homes/milan /mnt/nas-milan nfs nfsvers=4.1,ro,noatime,hard 0 0" >> /etc/fstab
mount /mnt/nas-milan
```

> **Why mount on host:** Unprivileged LXC containers lack `CAP_SYS_ADMIN` needed for NFS mounts. Mount on the Proxmox host first, then bind-mount into the container.

### 3. Bind-mount into the container

```bash
pct stop 201
pct set 201 --mp0 /mnt/nas-milan,mp=/mnt/nas-documents,ro=1
pct start 201
```

> **Why `ro=1`:** Read-only access — Claude can read but not modify your files.

---

## Step 4: Create User & Workspace

```bash
useradd -m -s /bin/bash claude
su - claude
mkdir -p ~/workspace
```

### Install Bun (as the claude user)

```bash
curl -fsSL https://bun.sh/install | bash
echo 'export PATH=$HOME/.bun/bin:$PATH' >> ~/.profile
echo 'export PATH=$HOME/.bun/bin:$PATH' >> ~/.bash_profile
source ~/.bashrc
```

> **Why:** Bun is installed per-user (to `~/.bun/bin/`). Adding to `~/.profile` and `~/.bash_profile` ensures it's in PATH for both interactive and non-interactive shells. The Telegram Channels plugin requires Bun as its runtime.

> **Why run as `claude` user:** Dedicated non-root user for security. `~/workspace` is where Claude Code will create and edit files.

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
  User claude
  Hostname 192.168.1.202
```

> **Why:** Container has its own IP on the LAN (192.168.1.202), so direct SSH works — no ProxyJump needed.

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

### Install the plugin (inside a Claude Code session)

Start Claude Code first, then use these slash commands:

```
/plugin install telegram@claude-plugins-official
/reload-plugins
```

> **Why:** Installs Anthropic's official Telegram plugin via Claude Code's plugin system. The plugin is cached at `~/.claude/plugins/cache/claude-plugins-official/telegram/`.

### Save the bot token

```bash
mkdir -p ~/.claude/channels/telegram
echo 'TELEGRAM_BOT_TOKEN=<your-bot-token>' > ~/.claude/channels/telegram/.env
chmod 600 ~/.claude/channels/telegram/.env
```

> **Why:** The plugin reads the token from this `.env` file at startup. `chmod 600` protects the token — it's a credential.

### Start Claude Code with the Telegram channel

```bash
export PATH=$HOME/.bun/bin:$PATH
claude --channels plugin:telegram@claude-plugins-official
```

> **Why:** The `--channels` flag activates the Channels feature and loads the Telegram plugin. The plugin uses long-polling (outbound connections only — no incoming ports needed on your network). Bun must be in PATH as the plugin runs on Bun.

### Pair with your Telegram account

1. DM your bot on Telegram — it replies with a 6-character pairing code
2. In the Claude Code session: `/telegram:access pair <code>`
3. Lock it down: `/telegram:access policy allowlist`

> **Why:** Pairing captures your Telegram user ID. Switching to `allowlist` policy ensures only you can use the bot — strangers won't even get a pairing code reply.

---

## Step 9: Make It Persistent (DONE)

### systemd service (auto-start on boot)

Create `/etc/systemd/system/claude-code.service` as root:

```ini
[Unit]
Description=Claude Code with Telegram Channel
After=network.target

[Service]
Type=forking
User=claude
WorkingDirectory=/home/claude/workspace
Environment=PATH=/home/claude/.bun/bin:/usr/local/bin:/usr/bin:/bin
ExecStart=/usr/bin/tmux new-session -d -s claude -e PATH=/home/claude/.bun/bin:/usr/local/bin:/usr/bin:/bin /bin/claude --channels plugin:telegram@claude-plugins-official
ExecStop=/usr/bin/tmux kill-session -t claude
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

> **Why `Type=forking` + tmux:** Claude Code needs a TTY to run in interactive/channels mode. Without one, it falls into `--print` mode which exits immediately. Wrapping in `tmux new-session -d` provides a pseudo-TTY. `Type=forking` tells systemd the process forks (tmux server detaches). `ExecStop` cleanly kills the tmux session.

> **Why `/bin/claude` not `/usr/local/bin/claude`:** On this Debian 12 container, `npm install -g` puts the binary at `/bin/claude`. Always verify with `which claude`.

```bash
systemctl daemon-reload
systemctl enable --now claude-code
```

> **Why:** systemd ensures Claude Code starts automatically on boot and restarts if it crashes. `RestartSec=10` avoids rapid failure loops. The `PATH` includes Bun's location since systemd doesn't source shell profiles.

### Mark workspace as trusted (skip prompt on restart)

```bash
mkdir -p ~/.claude/projects/-home-claude-workspace
echo true > ~/.claude/projects/-home-claude-workspace/.trust
```

> **Why:** On first launch, Claude Code asks "Do you trust this folder?" which blocks the automated start. Writing a `.trust` file skips this prompt. The directory name is the working directory path with `/` replaced by `-`.

### Attach to the running session

```bash
ssh claude-code
tmux attach -t claude
# Ctrl+B, D to detach without stopping
```

---

## Security Notes

- **Unprivileged LXC** — container processes can't escalate to Proxmox host
- **SSH key-only** — no password authentication
- **OAuth** — no API keys stored in plaintext files
- **Telegram allowlist** — bot only responds to your user ID (110919235), pairing disabled
- **No open ports** — Telegram uses outbound long-polling, SSH is direct on LAN

---

## Verification

1. `ssh claude-code` → `claude --version` → confirm >= 2.1.80
2. `tmux new -s cc` → `claude` → interactive TUI works
3. Send a Telegram message to your bot → get a response with agentic capabilities
4. Reboot Proxmox → verify container + service auto-start
5. Telegram still works after reboot
