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

agent up and connected

## Sample repo setup

- [x] connect to GitHub
- [ ] 

