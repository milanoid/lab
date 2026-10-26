
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

- [x] OS: Ubuntu Server 26.04 lts
- [x] removing/disabling not needed services


ssh pubkey only access

```bash
ssh llmbox # 192.168.1.235
```


---

# Hermes agent with local llm

https://hermes-agent.nousresearch.com/

```bash
#  1. System prerequisites (sudo)
sudo apt update
sudo apt install -y git libatomic1 mesa-vulkan-drivers libvulkan1 vulkan-tools tmux
sudo usermod -aG render,video milan
exit   # log out and SSH back in so the new groups apply
```


```bash
#  2. Verify the GPU is usable via Vulkan
groups                       # must include render video
vulkaninfo --summary | grep -E "deviceName|driverName"
# expect: AMD Radeon 8060S Graphics (RADV STRIX_HALO), driverName = radv
```


```bash
# Stage 3: install Hermes:

curl -fsSL https://hermes-agent.nousresearch.com/install.sh -o /tmp/hermes-install.sh
less /tmp/hermes-install.sh      # skim it before running
bash /tmp/hermes-install.sh --skip-computer-use --skip-browser
source ~/.bashrc
hermes doctor

# --skip-browser leaves out Hermes' built-in browser, which needs Chromium libraries this minimal install doesn't have. You can add it later with hermes pm install chromium.
```


hermes-install output
```bash
┌─────────────────────────────────────────────────────────┐
│             ☤ Hermes Agent Installer                    │
├─────────────────────────────────────────────────────────┤
│  An open source AI agent by Nous Research.              │
└─────────────────────────────────────────────────────────┘

✓ prerequisites ok (git, curl)
→ Installing the latest stable release (v0.22.5); --channel main follows every commit
  Cloning https://github.com/NousResearch/hermes-agent.git (main) into /home/milan/.hermes/h
✓ Hermes Agent cloned
→ Downloading uv 0.13.5 (linux-x64)
✓ uv ready (uv 0.13.5 (x86_64-unknown-linux-gnu))
✓ bootstrap Python ready; PM prepares the dependency environment
✓ uv ready (uv 0.13.5 (x86_64-unknown-linux-gnu))
✓ dependencies installed
✓ config prepared in /home/milan/.hermes
✓ uv ready (uv 0.13.5 (x86_64-unknown-linux-gnu))
✓ added ~/.local/bin to PATH in /home/milan/.bashrc
✓ app products and hermes command ready

┌─────────────────────────────────────────────────────────┐
│             ☤ Hermes Agent Setup Wizard                │
├─────────────────────────────────────────────────────────┤
│  Let\'s configure your Hermes Agent installation.       │
│  Press Ctrl+C at any time to exit.                     │
└─────────────────────────────────────────────────────────┘

    Skipped (keeping current)



◆ Nous Portal
  One subscription, 300+ models, plus the Tool Gateway:
    web search, image generation, TTS, browser automation.
  Sign up: https://portal.nousresearch.com/manage-subscription

Not logged into Nous Portal. Starting login...

Starting Hermes login via Nous Portal...
Portal: https://portal.nousresearch.com

To continue:
  1. Open: https://portal.nousresearch.com/manage-subscription?user_code=KDHC-977M
  2. If prompted, enter code: KDHC-977M
Waiting for approval (polling every 1s)...

Could not sign in: Hermes could not reach portal.nousresearch.com. Check your internet connection or proxy, then run `hermes portal` again.
  Details: timed out
Sign-in did not complete; run `hermes portal` to try again.

◆ Terminal Backend                                                                             Choose where Hermes runs shell commands and code.
  This affects tool execution, file access, and isolation.
     Guide: https://hermes-agent.nousresearch.com/docs/user-guide/configuration#terminal-backend-configuration

    Skipped (keeping current)

  Keeping current backend: local
✓ Applied recommended defaults:
    Max iterations: 150
    Compression threshold: 0.50
    Run `hermes setup agent` later to customize.


Installing user systemd service to: /home/milan/.config/systemd/user/hermes-gateway.service
Created symlink '/home/milan/.config/systemd/user/default.target.wants/hermes-gateway.service' → '/home/milan/.config/systemd/user/hermes-gateway.service'.

✓ User service installed and enabled!
                                                        Next steps:
  hermes gateway start              # Start the service                                        hermes gateway status             # Check status
  journalctl --user -u hermes-gateway -f  # View logs
Enabling linger so the gateway survives SSH logout...                                        ✓ Linger enabled — gateway will persist after logout
✓ User service started                                                                       ✓ Gateway service running (cron jobs + messaging platforms).

                                 ✓ Setup complete! You\'re ready to go.

                                                            Configure all settings:    hermes setup                                                      Connect Telegram/Discord:  hermes setup gateway

                                          ⚠ No inference provider is configured — Hermes cannot chat yet.                                  Finish this one step with either of:                                                           hermes model            (pick any provider/model)                                            hermes setup --portal   (Nous Portal OAuth, no API key)

                                ◆ Tool Availability Summary                                                                    4/10 tool categories available:
   ✗ Vision (image analysis) (missing run 'hermes setup' to configure)                          ✗ Web Search & Extract (missing EXA_API_KEY, PARALLEL_API_KEY, FIRECRAWL_API_KEY/FIRECRAWL_API_URL, TAVILY_API_KEY, PERPLEXITY_API_KEY, KEENABLE_API_KEY, or SEARXNG_URL)                 ✗ Browser Automation (missing hermes pm install agent-browser)
   ✗ Image Generation (missing FAL_KEY or OPENAI_API_KEY)                                       ✓ Text-to-Speech (Edge TTS)
   ✗ Speech-to-Text (Local Whisper — not installed) (missing run 'hermes tools' → Speech-to-Text)
   ✗ Skills Hub (GitHub) (missing GITHUB_TOKEN)                                                 ✓ Terminal/Commands
   ✓ Task Planning (todo)                                                                       ✓ Skills (view, create, edit)
                                                             ⚠ Some tools are disabled. Run 'hermes setup tools' to configure them,
⚠ or edit ~/.hermes/.env directly to add the missing API keys.

┌─────────────────────────────────────────────────────────┐
│              ✓ Setup Complete!                          │                                  └─────────────────────────────────────────────────────────┘

📁 All your files are in ~/.hermes/:

   Settings:  /home/milan/.hermes/config.yaml
   API Keys:  /home/milan/.hermes/.env
   Data:      /home/milan/.hermes/cron/, sessions/, logs/

────────────────────────────────────────────────────────────

📝 To edit your configuration:

   hermes setup          Re-run the full wizard
   hermes setup model    Change model/provider
   hermes setup terminal Change terminal backend
   hermes setup gateway  Configure messaging
   hermes setup tools    Configure tool providers

   hermes config         View current settings
   hermes config edit    Open config in your editor
   hermes config set <key> <value>
                          Set a specific value

   Or edit the files directly:
   nano /home/milan/.hermes/config.yaml
   nano /home/milan/.hermes/.env

────────────────────────────────────────────────────────────

🚀 Ready to go!

   hermes              Start chatting
   hermes gateway      Start messaging gateway
   hermes doctor       Check for issues

✓ Shared metrics off. Change it any time with `hermes setup telemetry`.
✓ Gateway service already installed
✓ Hermes Agent install complete. Run: hermes
→ Reload your shell to use hermes: open a new terminal, or run: source ~/.bashrc
```




```bash
# Stage 4: let Hermes pick and run a model:
hermes config set local_runtime.backend vulkan   # use the GPU; don't fall back to CPU
hermes model                                      # choose "Local models", then the ★ model
# Hermes installs its own llama.cpp, downloads the model (Ctrl+C pauses, picking it again resumes) and makes it the default.

# local -> picked Qwen3.8 Flash Next (91.9 GB)
```


# Daily use

```bash
# from Mac
ssh -t llmbox 'tmux new -A -s hermes ~/.local/bin/hermes'

# new -A -s hermes reconnects to the session named "hermes" if it exists, or creates it if it doesn't. The same command works for starting and for coming back.
```


```bash
# The tmux keys you need:
┌───────────────────┬────────────────────────────────────────────────────────┐
│       Keys        │                         Action                         │
├───────────────────┼────────────────────────────────────────────────────────┤
│ Ctrl-b then d     │ Detach: leave Hermes running and drop back to your Mac │
├───────────────────┼────────────────────────────────────────────────────────┤
│ Ctrl-b then [     │ Scroll back through output (press q to exit)           │
├───────────────────┼────────────────────────────────────────────────────────┤
│ Ctrl-b then c / n │ Open a new window / switch to the next one             │
└───────────────────┴────────────────────────────────────────────────────────┘
```


```bash
# make it one word
echo "alias hermes='ssh -t llmbox \"tmux new -A -s hermes ~/.local/bin/hermes\"'" >> ~/.bash_profile
source ~/.bash_profile
```


```bash
hermes                      # interactive chat
hermes --continue           # resume the last session
hermes -z "summarize ~/notes.txt"   # one-shot prompt, prints the answer and exits
hermes --in ~/myproject     # start working in a specific folder
hermes model                # switch model or provider
hermes status / hermes doctor       # health checks
```
---



TODOS

- [ ] make Claude my milanoid-labs repos github pr reviewer
- [ ] open a first PR by Hermes - gh tool access setup?



---

Personality

---

Here is who you are going to be. Update any file, including your SOUL.md, to reflact this going foward:

You are DevOps Guru, an expert on DevOps, Infrastructure as a code, Kubernetes, CI/CD, Linux. You know a lot, but prefer to read manuals and official documentation before guessing. You are honest, if you don't know something or you are unsure, admit it. You are comfortible with reading my repositories, suggesting changes to make them better and open to discuss various options. When debugging an issue you are open to my follow up questions. Your main mission is to teach me and guide me the become better DevOps Engineer.

---