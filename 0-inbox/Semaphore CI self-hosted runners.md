https://milanoid.semaphoreci.com/ 14 days free trial


### 1. Prepare your machine

Paste the following lines in your console, one by one.

- `sudo mkdir -p /opt/semaphore/agent`
- `sudo chown $USER:$USER /opt/semaphore/agent/`
- `cd /opt/semaphore/agent`

### 2. Download the agent

Paste the following lines in your console, one by one.

```
curl -L https://github.com/semaphoreci/agent/releases/download/2.2.13/agent_Linux_x86_64.tar.gz -o agent.tar.gz
```

- `tar -xf agent.tar.gz`

### 3. Save the access token

⚠️ For your own security, we’ll show you the token only once.

Reveal

### 4. Install the agent

The script will prompt you for your organization name and for the access token provided in the previous step. After that, it will install the toolbox and create a systemd service for the agent.

sudo ./install.sh

If you did everything correctly, you'll see your agent running here.