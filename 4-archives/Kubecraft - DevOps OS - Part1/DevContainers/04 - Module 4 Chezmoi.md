# Chezmoi introduction

https://www.chezmoi.io/

- a dot file manager
- able to run scripts

# Installing Chezmoi + Adding our first file

inside the Devpod

```bash
# install oneliner
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin

vscode ➜ /workspaces/module3code $ which chezmoi
/home/vscode/.local/bin/chezmoi
```


Quick start

https://www.chezmoi.io/quick-start/

```bash
chezmoi init
```

```bash
vscode ➜ /workspaces/module3code $ ls ~/.local/
bin
vscode ➜ /workspaces/module3code $ chezmoi init
vscode ➜ /workspaces/module3code $ ls ~/.local/
bin  share
```


```bash
chezmoi add ~/.bashrc
```

```bash
vscode ➜ ~/.local $ tree
.
├── bin
│   └── chezmoi
└── share
    └── chezmoi
        └── dot_bashrc

3 directories, 2 files
```


```bash
# switch to dotfiles dir
chezmoi cd


vscode ➜ ~/.local $ chezmoi cd
vscode ➜ ~/.local/share/chezmoi (master) $
```


```bash
# chezmoi copied the ~/.bashrc to `dot_bashrc`
vscode ➜ ~/.local/share/chezmoi (master) $ tree
.
└── dot_bashrc

0 directories, 1 file
```


```bash
# detect a change in dotfiles
chezmoi diff

# I've modified ~/.bashrc - chezmoi detects it
vscode ➜ ~/.local/share/chezmoi (master) $ chezmoi diff
diff --git a/.bashrc b/.bashrc
index df87240e0d4f7f740135a78d5c416a18454cebe1..ae1c34c2e7a8b2aa800f0301d6407685e4cc05ab 100644
--- a/.bashrc
+++ b/.bashrc
@@ -158,3 +158,6 @@ fi
 set -o vi
 export VISUAL=vi
 export EDITOR="$VISUAL"
+set -o vi
+export VISUAL=vi
+export EDITOR="$VISUAL"


# apply the change
chezmoi apply
```



It's a git repo (chezmoi uses `master`) must fix it:

```bash
# set remote
git remote add origin git@github.com:milanoid/dotfiles-demo.git

# update branch
git pull
git switch main

# push
git add .
git commit -m "chezmoi - add bashrc"
git push
```


# Automatically Setting Up Dotfiles with Chezmoi

a bit messy, with the new setup script (see below) we are:
- cloning the dotfiles twice
- only the clone in `~/.local/share/chezmoi/` is the place where to change dotfiles
- do not change `chezmoi` managed dotfiles directly, e.g. do not edit `~/.bashrc` but rather `~/.local/share/chezmoi/dot_bashrc`


in container:

```bash (setup script)
#!/bin/bash

set -euo pipefail

if ! command -v chezmoi >/dev/null; then
    sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply git@github.com:milanoid/dotfiles-demo.git
fi

exit 0
```


```bash
> devpod up . --recreate
08:03:00 info Workspace module3code already exists
08:03:00 info Creating devcontainer...
08:03:00 info Found existing local image vsc-module3_code-dc033:devpod-237aec96dd39c8dbc59f6ea040ec63e3
08:03:00 info Deleting devcontainer...
08:03:01 info Inspecting image vsc-module3_code-dc033:devpod-237aec96dd39c8dbc59f6ea040ec63e3
08:03:01 info 0955ce08b2be422585f42ac0d82735c4af7ed378717d1620bb632e83e75cba7d
08:03:03 info Setup container...
08:03:03 info Chown workspace...
08:03:03 info Run 'ssh module3code.devpod' to ssh into the devcontainer
08:03:03 info Dotfiles git repository git@github.com:milanoid/dotfiles-demo specified
08:03:05 info Cloning dotfiles git@github.com:milanoid/dotfiles-demo
08:03:06 info Failed to make install script ./install.sh executable: install script ./install.sh not found: exit status 1
08:03:06 info Failed to make install script ./install executable: install script ./install not found: exit status 1
08:03:06 info Failed to make install script ./bootstrap.sh executable: install script ./bootstrap.sh not found: exit status 1
08:03:06 info Failed to make install script ./bootstrap executable: install script ./bootstrap not found: exit status 1
08:03:06 info Failed to make install script ./script/bootstrap executable: install script ./script/bootstrap not found: exit status 1
08:03:06 info Failed to make install script ./setup.sh executable: install script ./setup.sh not found: exit status 1
08:03:07 info info found chezmoi version 2.69.4 for latest/linux/arm64
08:03:08 info info installed bin/chezmoi
08:03:08 info Cloning into '/home/vscode/.local/share/chezmoi'...
08:03:09 info Error tunneling to container: wait: remote command exited without exit status or exit signal
08:03:10 info Done setting up dotfiles into the devcontainer
```


## Flow of `devpod up`

1. process `devcontainer.json` - installs what's in it
2. clone my dotfiles to `~/dotfiles` (this I set as default)
3. now it search for `setup` (or `setup.sh` ...) and runs it
4. it runs (but not installs `chezmoi`)

```bash
# chezmoi not installed
vscode ➜ ~/dotfiles (main) $ chezmoi
bash: chezmoi: command not found

# but can be called like this
vscode ➜ ~/dotfiles (main) $ ./bin/chezmoi --version
chezmoi version v2.69.4, commit c4c669c9f2f329233a85802014d26fba3c58a4a4, built at 2026-02-11T08:59:37Z, built by goreleaser

# because it was curled while at this ~/dotfiles dir - see the bin dir
vscode ➜ ~/dotfiles (main) $ ls -la
total 12
drwxr-xr-x. 4 vscode vscode   60 Feb 18 07:03 .
drwxr-xr-x. 1 vscode vscode  124 Feb 18 07:03 ..
drwxr-xr-x. 7 vscode vscode  147 Feb 18 07:03 .git
drwxr-xr-x. 2 vscode vscode   21 Feb 18 07:03 bin
-rw-r--r--. 1 vscode vscode 5742 Feb 18 07:03 dot_bashrc
-rwxr-xr-x. 1 vscode vscode  196 Feb 18 07:03 setup
```

5. the setup runs `chezmoi` and clones dotfiles again to `~/.local/share/chezmoi`
   
```bash
vscode ➜ ~/dotfiles (main) $ ls -la ~/.local/share/chezmoi/
total 12
drwxr-xr-x. 3 vscode vscode   49 Feb 18 07:03 .
drwxr-xr-x. 3 vscode vscode   21 Feb 18 07:03 ..
drwxr-xr-x. 7 vscode vscode  147 Feb 18 07:03 .git
-rw-r--r--. 1 vscode vscode 5742 Feb 18 07:03 dot_bashrc
-rwxr-xr-x. 1 vscode vscode  196 Feb 18 07:03 setup
```

- this it the correct dir to change dotfiles now (this only is managed by `chezmoi`)

