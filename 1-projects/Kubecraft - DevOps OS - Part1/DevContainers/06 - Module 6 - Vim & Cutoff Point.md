
At this point we have it all set up. Time to configure the tools managed by chezmoi/mise/devpod.


```bash
# in devpod
vscode ➜ /workspaces/module3code $ mise use vim

...


# fails on missing dep
checking for linking with ncurses library...
plugin:vim      clone https://github.com/mise-plugins/mise-vim.git                                                                                            ✔
vim@9.2.0136    checking for linking with ncurses library...                                                                                                  ◠
mise ERROR Failed to install asdf:vim@latest: ~/.local/share/mise/plugins/vim/bin/install exited with non-zero status: exit code 1
mise ERROR Run with --verbose or MISE_VERBOSE=1 for more information
```


Ways to solve this:

1. _install the missing dep (ncurses-dev) using `apt` - that would completely missed the point of our entire setup which should be fully automated and repeatable
2. install it via project specific script (if I am not collaborating with others)
   
```bash
vscode ➜ /workspaces/module3code $ cat scripts/setup
#!/bin/bash
/usr/local/bin/mise trust /workspaces/$DEVPOD_WORKSPACE_ID/mise.toml && /usr/local/bin/mise install

## add:
sudo apt update && sudo apt install vim -y
```

```bash
# then run
bash script/setup
```
   
3. use dotfiles repo script 


Vim doesn't work with mise (?) but Neovim does. We will move the Neovim later.


# Learning vim and How long should I stay?

- _Only change config if you feel you need to solve A PROBLEM_
- _limit plugin usage_
- _use plain vim for a longer period of time_ (with fallback to VSCode or similar if stuck)

Mischa's basic Vim config

```bash
# .vimrc
" Ensure Vim uses filetype plugins
filetype plugin on

" Enable indentation
filetype indent on

" Set the default indentation to 2 spaces for all files
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab

" Highlight trailing whitespace in all files
autocmd BufRead,BufNewFile * match Error /\s\+$/

" Enable auto-indentation
set autoindent

" Turn on syntax highlighting
syntax on

" Set backspace so it acts more intuitively
set backspace=indent,eol,start
```


# Bash

[https://mischavandenburg.com/zet/back-to-bashics/](https://mischavandenburg.com/zet/back-to-bashics/ "https://mischavandenburg.com/zet/back-to-bashics/")

[https://www.youtube.com/watch?v=N08ul4PaDCg](https://www.youtube.com/watch?v=N08ul4PaDCg "https://www.youtube.com/watch?v=N08ul4PaDCg")

[https://starship.rs](https://starship.rs "https://starship.rs")


#  Zsh - Why I switched to Zshell


The goal of our DevContainers setup is to have multiple environments tailored for a specific project.

E.g. 
1. homelab cluster project (with even _kubectl_ in devcontainer)
2. a work (client) project 
3. ...

Benefits

- after a project with client is finished it's just matter of deleting a particular devpod. No leftover packages and tooling and setup on host machine
- (Mischa) can expect zsh everywhere (?)


## Reasons to move to zsh

- completion (more interactive and verbose, ideal for cli tools) makes the work faster







