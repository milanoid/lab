
Instead of using VS Code we can interact with devcontainers using


1. DevPod https://devpod.sh
2. Dev Container CLI https://github.com/devcontainers/cli 



# DevPod

```bash
# install
curl -L -o devpod "https://github.com/loft-sh/devpod/releases/latest/download/devpod-darwin-arm64" && sudo install -c -m 0755 devpod /usr/local/bin && rm -f devpod
```

## Providers

https://devpod.sh/docs/managing-providers/what-are-providers

- docker (default)
- kubernetes 
- ssh
- aws - e.g. can create a VM to test something
- gcloud
- azure
- digitalocean

## Personalizing a Workspace

https://devpod.sh/docs/developing-in-workspaces/dotfiles-in-a-workspace

Using a dotfiles repo (remote or local)

I have a dotfile repo https://github.com/milanoid/dotfiles but it uses Stow. Probably can't be used.

- [x] todo create another dotfiles repo `dotfiles-demo` a temporary, than after course create a proper one

- https://github.com/milanoid/dotfiles-demo



# Running our first Devpod Workspace

- run the following commands in the directory `./module3_code`

```bash
# run - the `none` is important
devpod up . --ide none --dotfiles git@github.com:milanoid/dotfiles-demo

# list running devpods
> devpod ls

# connect to a devpod - shows which to use
> devpod ssh
┃ Please select a workspace from the list below
┃ > module3code


# now inside the container
> devpod ssh
vscode ➜ /workspaces/module3code $


# stop
devpod stop
```

## issues

### missing default provider

```bash
# no provider specified
> devpod up . --ide none --dotfiles git@github.com:milanoid/dotfiles-demo
08:28:35 error Try using the --debug flag to see a more verbose output
08:28:35 fatal prepare workspace client: no default provider found. Please make sure to run 'devpod provider use'
```

#### Fix

Using Podman UI setup (docker) provider. Can be setup via cli too.

### missing `docker` in path (I'm using podman)

- I have the `alias docker=podman` in my `~/.bashrc` but that's not used by Devpod.

#### Fix 

create a symlink

```bash
# Already having a link (to non-existing docker)
> ls -la /usr/local/bin/docker
lrwxr-xr-x  1 root  wheel  54 Jan 18  2025 /usr/local/bin/docker -> /Applications/Docker.app/Contents/Resources/bin/docker

# Remove old Docker link
sudo rm /usr/local/bin/docker

# Create new link pointing to Podman
sudo ln -s /opt/podman/bin/podman /usr/local/bin/docker
```


### in `ghostty` in devpod I can't delete

```bash
vscode ➜ /workspaces/module3code $ clear
'xterm-ghostty': unknown terminal type.
```

#### fix


```bash
# ~/Library/Application\ Support/com.mitchellh.ghostty/config
term = xterm-256color
```




# Using the Setup Script


- Devpod started with `--dotfiles` switch:
- `devpod up . --ide none --dotfiles git@github.com:milanoid/dotfiles-demo`
- the imported dotfiles are in home dir (in Devpod)
- note the dir name is `dotfiles` although the git repo is `dotfiles-demo`

```bash
# /home/vscode/dotfiles (it's a git repo)
vscode ➜ ~/dotfiles (main) $
```


## Experiment - configuration example

within the Devpod

### create a setup script

```bash
#!/bin/bash
echo "Hello World" > /tmp/hello
# enable vi mode in shell
echo "set -o vi" >> ~/.bashrc
# set vi as default editor
echo 'export VISUAL=vi' >> ~/.bashrc
echo 'export EDITOR="$VISUAL"' >> ~/.bashrc
```

### push it to my dotfiles-demo repo


still within the pod

```bash
git add .
git commit -m "Initial commit - setup script"
git push
```

### recreate the Devpod container

```bash
# note the flag --recreate
devpod up . --ide none --dotfiles git@github.com:milanoid/dotfiles-demo --recreate
```

done, the setup script has been applied


# System Defaults

supported editors

- VS Code
- `openvscode` - in browser Open VS Code Server


```bash
> devpod up . --ide openvscode --dotfiles git@github.com:milanoid/dotfiles-demo --recreate

07:54:28 info Done setting up dotfiles into the devcontainer
07:54:28 info Starting vscode in browser mode at http://localhost:10800/?folder=/workspaces/module3code
07:54:28 info Setting up backhaul SSH connection
07:54:33 done Successfully opened http://localhost:10800/?folder=/workspaces/module3code
```


Setting default editor

```bash
# so I don't have to run --ide none when starting the devpod
devpod ide use none

# list all supported ides
> devpod ide list

         NAME       | DEFAULT
  ------------------+----------
    clion           | false
    codium          | false
    cursor          | false
    dataspell       | false
    fleet           | false
    goland          | false
    intellij        | false
    jupyternotebook | false
    none            | true
    openvscode      | false
    phpstorm        | false
    positron        | false
    pycharm         | false
    rider           | false
    rstudio         | false
    rubymine        | false
    rustrover       | false
    vscode          | false
    vscode-insiders | false
    webstorm        | false
    zed             | false
```

set default dotfiles repo

```bash
devpod context set-options -o DOTFILES_URL=git@github.com:milanoid/dotfiles-demo
```

# On macOS with Apple Silicon

Unlike Linux, Apple and Windows can't containers natively. They need an extra layer - a VM running a Linux. 

- `Amd64` - PC Intel/Amd architecture
- `Arm` - Apple Silicon

There are problems if one is using `brew` to install packages within the Devpod setup scripts.
It works on Linux but the same container setup fails on Mac (different architecture).

That's the reason Mischa use `Mise` package manager.

### workaround

- Devpod providers (VM in Azure), not free
- or GitHub Codespaces



