`sudo pacman -Syu tmux bash-completion kubectl k9s pass`

`~/.bashrc`

```
### Kubernetes Fundamentals
alias k='kubectl'

# Use bash-completion, if available
[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && \
    . /usr/share/bash-completion/bash_completion

source <(kubectl completion bash)
complete -o default -F __start_kubectl k
```

```
milan@jantar ~ $ cat ~/.vimrc
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

### Rancher Desktop

https://docs.rancherdesktop.io/getting-started/installation/#linux

The docs refers to debian, ubuntu and other distros but Arch. Seems the install path is the AppImage.

I skipped the `pass` configuration part as not needed now.

It creates `~/.kube/config`

Test the connection

`kubectl get pods -A`

```
milan@jantar ~ $ kubectl get pods -A
NAMESPACE     NAME                                      READY   STATUS      RESTARTS       AGE
kube-system   coredns-697968c856-g4sfb                  1/1     Running     3 (2d1h ago)   2d1h
kube-system   helm-install-traefik-crd-8zmpn            0/1     Completed   0              2d1h
kube-system   helm-install-traefik-j6nrk                0/1     Completed   2              2d1h
kube-system   local-path-provisioner-774c6665dc-ql7nj   1/1     Running     3 (2d1h ago)   2d1h
kube-system   metrics-server-6f4c6675d5-cksbb           1/1     Running     3 (2d1h ago)   2d1h
kube-system   svclb-traefik-bd77c3aa-qbqqp              2/2     Running     6 (2d1h ago)   2d1h
kube-system   traefik-c98fdf6fb-ktjjt                   1/1     Running     3 (2d1h ago)   2d1h
```
