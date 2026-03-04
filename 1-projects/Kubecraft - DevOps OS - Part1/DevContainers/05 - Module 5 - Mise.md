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

We have Mise installed in the devpod container. Now we want to have that on my main machine (Mac) as well.

We want to install Mise from within my dotfiles (repo).

Enter https://www.chezmoi.io/reference/special-files/chezmoiexternal-format/

```bash
# enter dotfiles repo dir
vscode ➜ /workspaces/module3code $ chezmoi cd
vscode ➜ ~/.local/share/chezmoi (main) $

# 
vscode ➜ ~/.local/share/chezmoi (main) $ mkdir .chezmoiexternals
vi .chezmoiexternals/mise.toml

```

```bash
# .chezmoiexternals/mise.toml
[".local/bin/mise"]
type = "file"
executable = true
url = "https://mise.jdx.dev/mise-latest-{{.chezmoi.os}}-{{.chezmoi.arch}}"
```


```bash
vscode ➜ ~/.local/share/chezmoi (main) $ cd /workspaces/module3code/
vscode ➜ /workspaces/module3code $ chezmoi apply
```


The mise is installed only for this project and available only if I am in the project.

```bash
vscode ➜ /workspaces/module3code $ cat mise.toml
[tools]
chezmoi = "latest"
kubectl = "latest"
```

Now we want to install it global.

# NOTE WHEN USING MACOS

When using this setup for setting up the dotfiles on your Mac natively, you'll have to install mise using brew and turn this mise.toml into a mise.toml.tmpl file, with the following template:

```
❯ cat .chezmoiexternals/mise.toml.tmpl 
───────┬─────────────────────────────────────────────────────────────────────────
       │ File: .chezmoiexternals/mise.toml.tmpl
───────┼────────────────────────────────────────────────────────────────────────
   1   │ {{ if ne .chezmoi.hostname "mac-beast" }}
   2   │ [".local/bin/mise"]
   3   │ type = "file"
   4   │ executable = true
   5   │ url = "https://mise.jdx.dev/mise-latest-{{.chezmoi.os}}-{{.chezmoi.arch}}"
   6   │ {{ end }}
   7   │ 
───────┴─────────────────────────────────────────────────────────────────────────
```

As you see, I'm using my hostname to prevent this from running if I'm on MacOS.


# Installing Mise Globally

```bash
vscode ➜ /workspaces/module3code $ chezmoi cd
vscode ➜ ~/.local/share/chezmoi (main) $
```

## XDG_CONFIG_HOME

A convention of `$XDG_CONFIG_HOME`. Spec [here](https://specifications.freedesktop.org/basedir/latest/).

`XDG_CONFIG_HOME` is ==an environment variable defining the base directory for user-specific configuration files==, defaulting to `~/.config` if unset.


Likewise we want to have it in Chezmoi.

```bash
# while in vscode ➜ ~/.local/share/chezmoi (main) $
mkdir -p dot_config/mise

vi dot_config/mise/config.toml

[tools]
bat = "latest"
chezmoi = "latest"

# https://www.chezmoi.io/user-guide/use-scripts-to-perform-actions/
mkdir .chezmoiscripts
vi  .chezmoiscripts/run_onchange_after_install_packages.sh.tmpl


#!/bin/bash
# packages hash: {{ include "dot_config/mise/config.toml" | sha256sum }}
$HOME/.local/bin/mise trust $HOME/.config/mise/config.toml && $HOME/.local/bin/mise install


# git push changes to my dot files repo
# on Mac I also edited a file mise.toml which causes this issue:
```

- [x] after editing mise.toml file on Mac the recreate fails
      
      fix: chmod 755 mise.toml

```bash
# exit the devpod and recreate
milan@SPM-LN4K9M0GG7 ~/repos/lab/1-projects/Kubecraft - DevOps OS - Part1/DevContainers/module3_code (main)
> devpod up . --recreate
08:47:35 info Workspace module3code already exists
08:47:35 info Creating devcontainer...
08:47:35 info Found existing local image vsc-module3_code-dc033:devpod-eacfd2f463485cace78e0f48ed82032e
08:47:35 info Deleting devcontainer...
08:47:36 info Inspecting image vsc-module3_code-dc033:devpod-eacfd2f463485cace78e0f48ed82032e
08:47:36 info 27e4d9b4d4d5b56d9ac1f99e68dca34e1ea435771250349c7092df67769f5707
08:47:38 info Setup container...
08:47:39 info Chown workspace...
08:47:40 info Run command fixMiseTrust: scripts/setup...
08:47:40 error Error loading settings file: failed read_to_string: /workspaces/module3code/mise.toml
08:47:40 error Error loading settings file: failed read_to_string: /workspaces/module3code/mise.toml
08:47:40 warn mise trusted /workspaces/module3code
08:47:40 error Error loading settings file: failed read_to_string: /workspaces/module3code/mise.toml
08:47:40 error Error loading settings file: failed read_to_string: /workspaces/module3code/mise.toml
08:47:40 error mise ERROR error parsing config file: /workspaces/module3code/mise.toml
08:47:40 error mise ERROR failed read_to_string: /workspaces/module3code/mise.toml
08:47:40 error mise ERROR Permission denied (os error 13)
08:47:40 error mise ERROR Run with --verbose or MISE_VERBOSE=1 for more information
08:47:40 info lifecycle hooks: failed to run: scripts/setup, error: exit status 1
08:47:40 info devcontainer up: run agent command: Process exited with status 1
08:47:40 error Try using the --debug flag to see a more verbose output
08:47:40 fatal run agent command: Process exited with status 1

```

```bash
# profit - chezmoi avaliable everywhere - even in /tmp
vscode ➜ /tmp $ chezmoi --version
chezmoi version v2.69.4, commit c4c669c9f2f329233a85802014d26fba3c58a4a4, built at 2026-02-11T08:59:37Z, built by goreleaser
```

Note:

```bash
# kubectl is available in the project
vscode ➜ /workspaces/module3code $ which kubectl
/home/vscode/.local/share/mise/installs/kubectl/1.35.2/kubectl

# but not outside
vscode ➜ /workspaces/module3code $ cd /tmp/
vscode ➜ /tmp $ which kubectl
vscode ➜ /tmp $
```

`kubectl` is available in the project dir because it's set in:

```bash
vscode ➜ /workspaces/module3code $ cat mise.toml
[tools]
kubectl = "latest"
```

But `chezmoi` we have installed globally and is available everywhere (in th devpod).


# .chezmoiignore

