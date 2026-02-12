~~https://milanoid.semaphoreci.com/ 14 days free trial~~

https://milanoid-gitlab.semaphoreci.com/

- auth via my gitlab account

---
# Installing self-hosted agent

### 1. Prepare your machine

Paste the following lines in your console, one by one.

- `sudo mkdir -p /opt/semaphore/agent`
- `sudo chown $USER:$USER /opt/semaphore/agent/`
- `cd /opt/semaphore/agent`

### 2. Download the agent

Paste the following lines in your console, one by one.

```bash
# arm (VirtualBox@MacBook)
curl -L https://github.com/semaphoreci/agent/releases/download/v2.4.0/agent_Linux_arm64.tar.gz -o agent.tar.gz

# amd64

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
- [x] wibe code sample RoR app




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


## checkout

toolbox checkouts to home folder

```bash
#/home/milan/sample-ror-app/
/home/semahphore/sample-ror-app/
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



# running agent directly on VirtualBox VM on MacBook

- _after testing - not good, it's a different architecture and Semaphore Toolbox does not work 100% - e.g. the `cache` command and maybe more_
- _also when running a docker container this must be arm-based (Semaphore convenience images are not)_


```bash
checkout Running 12:06:00

Performing shallow clone with depth: 5000:00

Cloning into 'sample-ror-app'...00:00

The authenticity of host 'github.com (140.82.121.3)' can't be established.00:01

ED25519 key fingerprint is SHA256:+DiY3wvvV6TuJJhbpZisF/zLDA0zPMSvHdkr4UvCOqU.00:01

This key is not known by any other names.00:01

Are you sure you want to continue connecting (yes/no/[fingerprint])?
```

fix

```bash
ssh-keyscan -t ed25519,rsa github.com >> ~/.ssh/known_hosts
```

### ruby

```bash
# Install dependencies  
sudo apt update  
sudo apt install -y git curl libssl-dev libreadline-dev zlib1g-dev autoconf bison build-essential libyaml-dev libreadline-dev libncurses5-dev libffi-dev libgdbm-dev  
  
# Install rbenv  
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash  
  
# Add rbenv to PATH (add to ~/.bashrc)  
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc  
echo 'eval "$(rbenv init -)"' >> ~/.bashrc  
source ~/.bashrc  
  

# Install Ruby 3.4.8 
rbenv install 3.4.8  
rbenv global 3.4.8
  
# Verify  
ruby --version
```


```bash
milan@runner01:~/sample-ror-app$ ruby -v
rbenv: version `ruby-3.2.10` is not installed (set by /home/milan/sample-ror-app/.ruby-version)

# install required version
rbenv install 3.2.10
rbenv global 3.2.10
```


### GG ruby version

```bash
rbenv install 3.4.8
rbenv global 3.4.8
```

## agent groups

Does it support agent groups?
How it falls back if an agent is not available?



# Kubernetes controller


https://github.com/renderedtext/helm-charts/tree/main/charts/controller



# Installing agent on Acer notebook


OS: `Ubuntu 24.04.3 LTS`

### Prerequisites

#### docker

```bash
# Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update
```

```bash
# install
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# check
sudo docker run hello-world

# to run docker without sudo
sudo groupadd docker
# repeat with all users which need to run docker commands ('semaphore')
sudo usermod -aG docker $USER

# activate changes
newgrp docker

# test
docker run hello-world
```

#### erl

```bash
sudo apt-get update  
sudo apt-get install erlang # 800 MB!
```


### Create user with sudo permissions to run the agent service

```bash
# create user (password as username)
sudo adduser semaphore
sudo adduser semaphore sudo
# sudo adduser semaphore sudo

# login as the user
su - semaphore
```


### Prepare the machine

```bash
sudo mkdir -p /opt/semaphore/agent
sudo chown $USER:$USER /opt/semaphore/agent/
cd /opt/semaphore/agent
```


### Download the agent packages

- find the [latest release](https://github.com/semaphoreci/agent/releases/) for your platform and architecture

```bash
curl -L https://github.com/semaphoreci/agent/releases/download/v2.4.0/agent_Linux_x86_64.tar.gz -o agent.tar.gz
tar -xf agent.tar.gz
```


### Install the agent

```bash
sudo ./install.sh
Enter organization: milanoid-gitlab
Enter registration token: <YOUR TOKEN>
Enter user [milan]: semaphore
Toolbox was already installed at /home/semaphore/.toolbox. Overriding it...
Downloading toolbox from https://github.com/semaphoreci/toolbox/releases/latest/download/self-hosted-linux.tar...
[sudo] password for semaphore:
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
Erlang version: 25
when installed
Installing the sem-context CLI
sem-context installed
Creating agent config file at /opt/semaphore/agent/config.yaml...
Creating /etc/systemd/system/semaphore-agent.service...
systemd service already exists at /etc/systemd/system/semaphore-agent.service. Overriding it...
Restarting semaphore-agent service...
Done.
```


### check the agent is running

```bash
# restart
sudo systemctl restart semaphore-agent

# check
sudo systemctl status semaphore-agent
```


#### Configure  Git Providers

```bash
### 1. Add GitHub SSH fingerprints
sudo mkdir -p /home/$USER/.ssh
sudo chown -R $USER:$USER /home/$USER/.ssh

curl -sL https://api.github.com/meta | jq -r ".ssh_keys[]" | sed 's/^/github.com /' | tee -a /home/$USER/.ssh/known_hosts

chmod 700 /home/$USER/.ssh
chmod 600 /home/$USER/.ssh/known_hosts

# I run just 
# ssh-keyscan -t ed25519,rsa github.com >> ~/.ssh/known_hosts



### 2. Add your SSH private keys into the ~/.ssh/folder
# - not needed for my test public repo, might needed for private ones


### 3. Tesh SSH to GitHub
ssh -T git@github.com


### 4. Restart the agent service
sudo systemctl restart semaphore-agent
```


### Dependencies specific for GG/RoR app


#### Ruby

- [[Semaphore CI self-hosted runners#ruby]]


#### nvm

```bash
# Install NVM for the semaphore user:
sudo -u semaphore bash -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash'

# Add to ~/.bashrc for the semaphore user:
#sudo -u semaphore bash -c 'cat >> ~/.bashrc << EOF  
#export NVM_DIR="\$HOME/.nvm"  
#[ -s "\$NVM_DIR/nvm.sh" ] && \. "\$NVM_DIR/nvm.sh"  
#EOF'

####### - the installer did that, including code completion
=> Compressing and cleaning up git repository

=> Appending nvm source string to /home/semaphore/.bashrc
=> Appending bash_completion source string to /home/semaphore/.bashrc
=> Close and reopen your terminal to start using nvm or run the following to use it now:

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
########


# Install stable Node.js:
sudo -u semaphore bash -c 'source ~/.nvm/nvm.sh && nvm install stable'
```


##### nvm Issue (shell function not working in non-interactive shell)

- the nvm is a shell function not invoked by non-interactive shell the service uses


in interactive shell

```bash
nvm --version
0.40.1
```

in non-interactive (invoked by semaphore-agent )

```bash
bash: nvm: command not found
```

fix attempt #1 - by updating the service - does not work

```bash
sudo systemctl edit semaphore-agent

### Editing /etc/systemd/system/semaphore-agent.service.d/override.conf
### Anything between here and the comment below will become the contents of the drop-in file

[Service]
Environment="NVM_DIR=/home/semaphore/.nvm"
ExecStartPre=/bin/bash -c 'source /home/semaphore/.nvm/nvm.sh'

sudo systemctl edit semaphore-agent
Successfully installed edited file '/etc/systemd/system/semaphore-agent.service.d/override.conf'.
```

fix attempt #2 by updating the `.semaphore/semaphore.yml` (that works)

- source the `nvm.sh`

instead `nvm use stable`

use `source ~/.nvm/nvm.sh && nvm use stable`



##### Your bundle only supports platforms ["aarch64-linux"] but your local platform is
x86_64-linux

- the bundle was run locally on my Mac first (arm)
- the CI is now x86_64

```bash
gem install bundler -v 2.7.2
Fetching bundler-2.7.2.gem
Successfully installed bundler-2.7.2
1 gem installed
bundle config set --local deployment 'true'
bundle config set --local path 'vendor/bundle'
bundle install
Bundler 2.7.2 is running, but your lockfile was generated with 2.4.19. Installing Bundler 2.4.19 and restarting using that version.
Fetching gem metadata from https://rubygems.org/.
[32mFetching bundler 2.4.19[0m
[32mInstalling bundler 2.4.19[0m
[31mYour bundle only supports platforms ["aarch64-linux"] but your local platform is
x86_64-linux. Add the current platform to the lockfile with
`bundle lock --add-platform x86_64-linux` and try again.[0m
```

fix
```bash
bundle lock --add-platform x86_64-linux  
git add Gemfile.lock  
git commit -m "Add x86_64-linux platform to Gemfile.lock"  
git push origin ruby-update
```


##### bundler: command not found: yarn


```bash
[32mBundle complete! 23 Gemfile dependencies, 124 gems now installed.[0m
[32mBundled gems are installed into `./vendor/bundle`[0m
[32mPost-install message from solid_queue:[0m
Upgrading from Solid Queue < 1.0? Check details on breaking changes and upgrade instructions
--> https://github.com/rails/solid_queue/blob/main/UPGRADING.md
1 installed gem you directly depend on is looking for funding.
  Run `bundle fund` for details
bundle exec yarn install --check-files
[31mbundler: command not found: yarn[0m
[33mInstall missing gem executables with `bundle install`[0m
```

fix 

```bash
semaphore@acer:~$ npm install -g yarn

added 1 package in 2s
npm notice
npm notice New minor version of npm available! 11.8.0 -> 11.9.0
npm notice Changelog: https://github.com/npm/cli/releases/tag/v11.9.0
npm notice To update run: npm install -g npm@11.9.0
npm notice
```



# Run in a docker container

