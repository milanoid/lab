# Introduction

- the front-end to your dev env
- a development environment setup tool
- https://mise.jdx.dev/


## Components

### Dev Tools

- what binaries I need (python, brew etc.)

### Environments

- acts as [`direnv`](https://direnv.net/)
	- `direnv` loads and unloads env vars depending on current directory (sdkman)
	- ? set env var from Apple Keychain (Passwords)
### Tasks

- task runner (linters etc.)
- similar to https://taskfile.dev/


---

# Installing our first package with Mise

We want to install Mise tool in the devpod container:

```
.devcontainer/devcontainer.json

{
  "build": {
    "context": "..",
    "dockerfile": "Dockerfile"
  }
}
```


```
.devcontainer/Dockerfile

FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

COPY --from=jdxcode/mise /usr/local/bin/mise /usr/local/bin/

# make sure mise is activated in both zsh and bash. Might be overridden by a user's dotfiles.
RUN echo 'eval "$(mise activate bash)"' >> /home/vscode/.bashrc && \
    echo 'eval "$(mise activate zsh)"' >> /home/vscode/.zshrc
```


```
# Reads the Dockerfile, pulls base image and Mise image
# also pulls my dotfiles (this has been set as default)
devpod up . --recreate
devpod ssh

# mise available
vscode ➜ /workspaces/module3code $ which mise
/usr/local/bin/mise
```


## `mise use`

- https://mise.jdx.dev/dev-tools/#mise-use
- install the tool's plugin if needed
- install the specified version
- set the version as active
- update the current config file (`mise.toml` or `.tool-versions`)

```bash
# problems?
> mise doctor

1 problem found:

1. mise is not activated, run mise help activate or
   read documentation at https://mise.jdx.dev for activation instructions.
   Alternatively, add the shims directory ~/.local/share/mise/shims to PATH.
   Using the shims directory is preferred for non-interactive setups.
   
> mise help activate

Examples:

    $ eval "$(mise activate bash)"
    $ eval "$(mise activate zsh)"
    $ mise activate fish | source
    $ execx($(mise activate xonsh))
    $ (&mise activate pwsh) | Out-String | Invoke-Expression
    

# chezmoi is installed but not in path yet
vscode ➜ /workspaces/module3code $ chezmoi
bash: chezmoi: command not found

# let's install chezmoi using mise
vscode ➜ /workspaces/module3code $ mise use chezmoi
chezmoi@2.69.4  extract chezmoi_2.69.4_linux_arm64.tar.gz                                                                                                     ✔
mise ERROR failed write: /workspaces/module3code/mise.toml
mise ERROR Permission denied (os error 13)
mise ERROR Run with --verbose or MISE_VERBOSE=1 for more information

```


### fix permission issue

There is a UID mismatch between the macOS host and the container.

- The Dockerfile is built on my Mac under user `milan`:

```bash
id -u
501
```

- The workspace directory `/workspaces/module3code` is mounted from the host and owned by UID 501 (the macOS user's UID)


After fix

```bash
vscode ➜ /workspaces/module3code $ mise use chezmoi
chezmoi@2.69.4  extract chezmoi_2.69.4_linux_arm64.tar.gz                                                                                                     ✔
mise /workspaces/module3code/mise.toml tools: chezmoi@2.69.4


vscode ➜ /workspaces/module3code $ cat mise.toml
[tools]
chezmoi = "latest"
```


```bash
# activate mise
eval "$(mise activate bash)"

# check
mise doctor

No problems found

# now I can use chezmoi
chezmoi cd

# and edit the dot_bashrc file
vscode ➜ ~/.local/share/chezmoi (main) $ vi dot_bashrc

# add the activate command (taken from examples of mise help activate)
# eval "$(mise activate bash)" 

vscode ➜ ~/.local/share/chezmoi (main) $ chezmoi diff
diff --git a/.bashrc b/.bashrc
index ae1c34c2e7a8b2aa800f0301d6407685e4cc05ab..fcbc74e4f1d105922f90d84fc0fe3d2c324de860 100664
--- a/.bashrc
+++ b/.bashrc
@@ -161,3 +161,4 @@ export EDITOR="$VISUAL"
 set -o vi
 export VISUAL=vi
 export EDITOR="$VISUAL"
+eval "$(mise activate bash)"

# apply (writes the change to tracked ~/.bashrc)
vscode ➜ ~/.local/share/chezmoi (main) $ chezmoi apply


# commit the change manually
# this can be done automatically too - see https://www.chezmoi.io/user-guide/daily-operations/#automatically-commit-and-push-changes-to-your-repo
vscode ➜ ~/.local/share/chezmoi (main) $ git add .
vscode ➜ ~/.local/share/chezmoi (main) $ git commit -m "add mise activation"
vscode ➜ ~/.local/share/chezmoi (main) $ git push

```

### Install another tool (kubectl)

```bash
# see rgistry
mise registry | grep kubectl

# install kubect
mise use kubectl
```

- [ ] another issue (or my fault)? 

There are 2 `mise.toml` file now:

```bash
vscode ➜ ~/.local/share/chezmoi (main) $ cat mise.toml
[tools]
kubectl = "latest"


vscode ➜ /workspaces/module3code $ cat mise.toml
[tools]
chezmoi = "latest"

# running mise use again from:
vscode ➜ /workspaces/module3code $ mise use kubectl

# now
vscode ➜ /workspaces/module3code $ cat mise.toml
[tools]
chezmoi = "latest"
kubectl = "latest"

# the other is
vscode ➜ /workspaces/module3code $ cat ~/.local/share/chezmoi/mise.toml
[tools]
kubectl = "latest"
```

# Learning about Mise Trust

- `mise trust --help` - mark a config file as trusted

A directory with `mise.toml` must be set as trusted, otherwise it errors with:

```bash
vscode ➜ /workspaces/module3code $ mkdir -p /tmp/mischa
vscode ➜ /workspaces/module3code $ ls
main.py  mise.toml
vscode ➜ /workspaces/module3code $ cp mise.toml /tmp/mischa/
vscode ➜ /workspaces/module3code $ cd /tmp/mischa/
\mise ERROR error parsing config file: /tmp/mischa/mise.toml
mise ERROR Config files in /tmp/mischa/mise.toml are not trusted.
Trust them with `mise trust`. See https://mise.jdx.dev/cli/trust.html for more information.
mise ERROR Run with --verbose or MISE_VERBOSE=1 for more information
```

On build time it can create issues. We need to make sure it is trusted:

```bash
vscode ➜ /workspaces/module3code $ cat .devcontainer/devcontainer.json
{
  "build": {
    "context": "..",
    "dockerfile": "Dockerfile"
  },
  # see syntax https://containers.dev/implementors/json_reference/#formatting-string-vs-array-properties
  "postCreateCommand": {
    "fixOwnerShip": "sudo chown -R vscode:vscode /workspaces",
    "fixMiseTrust": "scripts/setup"
  }
}

```

```bash
#!/bin/bash
/usr/local/bin/mise trust /workspaces/$DEVPOD_WORKSPACE_ID/mise.toml && /usr/local/bin/mise install
```


```bash
# check it works
chmod +x scripts/setup
bash scripts/setup
mise trusted /workspaces/module3code
mise all tools are installed

```

vim trick:

- run command and paste the output in

`:r! which mise`



Now let's rebuild the container

```bash
devpod up . --recreate

...
08:08:16 info Run command fixMiseTrust: scripts/setup...
08:08:16 warn mise trusted /workspaces/module3code
08:08:17 warn mise kubectl@1.35.2  [1/2] install
08:08:17 warn mise chezmoi@2.69.4  [1/3] install
08:08:17 warn mise kubectl@1.35.2  [1/2] download kubectl
08:08:18 warn mise chezmoi@2.69.4  [1/3] download chezmoi_2.69.4_linux_arm64.tar.gz
08:08:20 warn mise chezmoi@2.69.4  [2/3] checksum chezmoi_2.69.4_linux_arm64.tar.gz
08:08:20 warn mise chezmoi@2.69.4  [3/3] extract chezmoi_2.69.4_linux_arm64.tar.gz
08:08:20 warn mise chezmoi@2.69.4 ✓ installed
08:08:54 warn mise kubectl@1.35.2  [2/2] checksum kubectl
08:08:54 warn mise kubectl@1.35.2  [2/2] extract kubectl
08:08:54 warn mise kubectl@1.35.2 ✓ installed
08:08:54 done Successfully ran command fixMiseTrust: scripts/setup
08:08:54 info Run command fixOwnerShip: sudo chown -R vscode:vscode /workspaces...
08:08:54 done Successfully ran command fixOwnerShip: sudo chown -R vscode:vscode /workspaces
...

```


```bash
# in devpod

vscode ➜ /workspaces/module3code $ mise trust --show
/workspaces/module3code: trusted
```


# Installing Mise with Chezmoiexternals

