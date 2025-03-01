Setup
--
- Rancher Desktop https://rancherdesktop.io/
- `brew install kubectl k9s tmux vim`

```milan ~  $ kubectl get pods -A
NAMESPACE     NAME                                      READY   STATUS      RESTARTS   AGE
kube-system   coredns-ccb96694c-65zrz                   1/1     Running     0          12m
kube-system   helm-install-traefik-crd-tjfms            0/1     Completed   0          12m
kube-system   helm-install-traefik-gd8sg                0/1     Completed   2          12m
kube-system   local-path-provisioner-5cf85fd84d-rjl9j   1/1     Running     0          12m
kube-system   metrics-server-5985cbc9d7-tbn6t           1/1     Running     0          12m
kube-system   svclb-traefik-81a44c90-zmztt              2/2     Running     0          11m
kube-system   traefik-5d45fc8cc9-hfrrd                  1/1     Running     0          11m
```


- ~/.kube/config <- set up by the Rancher Desktop installation

- k9s (vim key binding)

- kubectl completion
	https://kubernetes.io/docs/tasks/tools/install-kubectl-macos/#enable-shell-autocompletion

- k alias for kubectl

- vim for editing .yaml files
	~/.vimrc setup

Rancher vs Docker Desktop

Replace the symlink for docker-buildx - will be overridden once Docker Desktop starts

```
rm ~/.docker/cli-plugins/docker-buildx
ln -s ~/.rd/bin/docker-buildx ~/.docker/cli-plugins/docker-buildx
ls -l ~/.docker/cli-plugins/docker-buildx
```

Replace the symlink for docker-compose
```
rm ~/.docker/cli-plugins/docker-compose
ln -s ~/.rd/bin/docker-compose ~/.docker/cli-plugins/docker-compose
ls -l ~/.docker/cli-plugins/docker-compose
```

TODO
- [ ] vim primer, most common key bindings
- [ ] vim with command line for reading and navigating help
- [ ] lab repo to store code

### VIM

`i` - insert mode
`:wq` - write and quit
`dd` - delete current line

#### Navigation

`j` - down
`k` - up
`g` - go to beginning
`/text` - look up for "text", `n` - next, `shift+n` - previous

#### Mark and Copy

`shift+v` - visual line (arrow keys up/down to highlight more lines)

