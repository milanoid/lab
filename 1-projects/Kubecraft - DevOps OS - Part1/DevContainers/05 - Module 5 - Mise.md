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