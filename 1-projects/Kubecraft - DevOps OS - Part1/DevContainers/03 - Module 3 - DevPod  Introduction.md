
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

- [ ] todo

```bash
# this doesn't work, the devpod updates config and puts its config first?
Host *.devpod
  SetEnv TERM=xterm-256color
```