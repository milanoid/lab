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

