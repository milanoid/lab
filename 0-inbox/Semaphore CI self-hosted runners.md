https://milanoid.semaphoreci.com/ 14 days free trial


### 1. Prepare your machine

Paste the following lines in your console, one by one.

- `sudo mkdir -p /opt/semaphore/agent`
- `sudo chown $USER:$USER /opt/semaphore/agent/`
- `cd /opt/semaphore/agent`

### 2. Download the agent

Paste the following lines in your console, one by one.

```
curl -L https://github.com/semaphoreci/agent/releases/download/v2.4.0/agent_Linux_arm64.tar.gz -o agent.tar.gz
```

- `tar -xf agent.tar.gz`

### 3. Save the access token

⚠️ For your own security, we’ll show you the token only once.

Lastpass -> Semaphore CI

### 4. Install the agent

The script will prompt you for your organization name and for the access token provided in the previous step. After that, it will install the toolbox and create a systemd service for the agent.

sudo ./install.sh

If you did everything correctly, you'll see your agent running here.


---

```bash
milan@runner01:/opt/semaphore/agent$ sudo ./install.sh
Enter organization: milanoid
Enter registration token: xxxxxxxxx
Enter user [milan]:
Downloading toolbox from https://github.com/semaphoreci/toolbox/releases/latest/download/self-hosted-linux-arm.tar...
[sudo] password for milan:
Installing the cache CLI
cache installed
Installing the artifacts CLI
artifacts installed
Installing the test results CLI
test-results installed
Installing retry
retry installed
Installing the SPC CLI
spc installed
Installing the when CLI
/home/milan/.toolbox/install-toolbox: line 78: erl: command not found
Erlang version:
mv: cannot stat '/home/milan/.toolbox/when_otp_': No such file or directory
chmod: cannot access '/usr/local/bin/when': No such file or directory
Error installing when at /usr/local/bin/when
Installing the sem-context CLI
sem-context installed
Creating agent config file at /opt/semaphore/agent/config.yaml...
Creating /etc/systemd/system/semaphore-agent.service...
Starting semaphore-agent service...
Done.
```


### fix for errors on installing toolbox

1. missing dep `erl`

```bash
/home/milan/.toolbox/install-toolbox: line 78: erl: command not found
```

```bash
sudo apt-get update  
sudo apt-get install erlang
```

https://github.com/semaphoreci/toolbox

https://github.com/semaphoreci/toolbox/releases/download/v1.41.0/self-hosted-linux.tar

## Sample repo setup

- [x] connect to GitHub
- [ ] wibe code sample RoR app




# Agent

- running as systemd `semaphore-agent.service`

```bash
systemctl status semaphore-agent.service
● semaphore-agent.service - Semaphore agent
     Loaded: loaded (/etc/systemd/system/semaphore-agent.service; disabled;
preset: enabled)
     Active: active (running) since Fri 2026-02-06 20:12:43 UTC; 20h ago
   Main PID: 1536 (agent)
      Tasks: 23 (limit: 9367)
     Memory: 14.1M (peak: 16.4M)
        CPU: 7.797s
     CGroup: /system.slice/semaphore-agent.service
             ├─1536 /opt/semaphore/agent/agent start --config-file /opt/semaphore/agent/config.yaml
             └─1543 /opt/semaphore/agent/agent start --config-file /opt/semaphore/agent/config.yaml

Feb 07 16:27:48 runner01 agent[1543]: Feb  7 16:27:48.554 6TGOv4i4UTgv9R0IgL-y : Waiting 4.252s for next sync...
Feb 07 16:27:52 runner01 agent[1543]: Feb  7 16:27:52.811 6TGOv4i4UTgv9R0IgL-y : SYNC request (state: waiting-for-jobs)
Feb 07 16:27:52 runner01 agent[1543]: Feb  7 16:27:52.921 6TGOv4i4UTgv9R0IgL-y : SYNC response (action: continue)
Feb 07 16:27:52 runner01 agent[1543]: Feb  7 16:27:52.921 6TGOv4i4UTgv9R0IgL-y : Waiting 4.885s for next sync...
Feb 07 16:27:57 runner01 agent[1543]: Feb  7 16:27:57.811 6TGOv4i4UTgv9R0IgL-y : SYNC request (state: waiting-for-jobs)
Feb 07 16:27:57 runner01 agent[1543]: Feb  7 16:27:57.929 6TGOv4i4UTgv9R0IgL-y : SYNC response (action: continue)
Feb 07 16:27:57 runner01 agent[1543]: Feb  7 16:27:57.930 6TGOv4i4UTgv9R0IgL-y : Waiting 5.201s for next sync...
Feb 07 16:28:03 runner01 agent[1543]: Feb  7 16:28:03.137 6TGOv4i4UTgv9R0IgL-y : SYNC request (state: waiting-for-jobs)
Feb 07 16:28:03 runner01 agent[1543]: Feb  7 16:28:03.257 6TGOv4i4UTgv9R0IgL-y : SYNC response (action: continue)
Feb 07 16:28:03 runner01 agent[1543]: Feb  7 16:28:03.258 6TGOv4i4UTgv9R0IgL-y : Waiting 4.613s for next sync...
```


```bash
#cat /etc/systemd/system/semaphore-agent.service
[Unit]
Description=Semaphore agent
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=60
User=milan
WorkingDirectory=/opt/semaphore/agent
ExecStart=/opt/semaphore/agent/agent start --config-file /opt/semaphore/agent/config.yaml
Environment=SEMAPHORE_AGENT_LOG_FILE_PATH=/opt/semaphore/agent/agent.log

[Install]
WantedBy=multi-user.target
```

## Config file

```bash
milan@runner01:/opt/semaphore/agent$ cat config.yaml
endpoint: "milanoid-gitlab.semaphoreci.com"
token: "xxxxxxxxx"
no-https: false
shutdown-hook-path: ""
disconnect-after-job: false
disconnect-after-idle-timeout: 0
env-vars: []
files: []
fail-on-missing-files: false
```

## Log files

- _/opt/semaphore/agent/agent.log_

### enable debug logging

```bash
# update systemd service file
vim /etc/systemd/system/semaphore-agent.service

# add
Environment=SEMAPHORE_AGENT_LOG_LEVEL=debug

# reload
sudo systemctl daemon-reload
sudo systemctl restart semaphore-agent
```

## `agent` binary

lives in _/opt/semaphore/agent_

```bash
milan@runner01:/opt/semaphore/agent$ ./agent version
v2.4.0
```


# semaphore-cli

https://docs.semaphore.io/reference/semaphore-cli


```bash
# install
brew install semaphoreci/tap/sem

# auth (API_TOKEN != agent token)
sem connect milanoid-gitlab.semaphoreci.com <API_TOKEN>
connected to milanoid-gitlab.semaphoreci.com

# get agents
sem get agents
NAME                   TYPE          STATE             AGE
OsB7NP0u1idQKXIhflxJ   s1-runner01   waiting_for_job   40m
```


# semaphore container registry

https://docs.semaphore.io/using-semaphore/containers/container-registry


## convenience images

```bash
# base ruby
docker pull registry.semaphoreci.com/ruby:3.2.0

# with browsers
docker pull registry.semaphoreci.com/ruby:3.2.0-node-browsers
```