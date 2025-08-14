### Git Repository

https://github.com/milanoid/homelab-cluster

PAT - Personal Access Token - `for-github-cli-arch` valid 90 days since 3rd August 2025
#### setting up Github CLI
- done on Lenovo laptop, might need to do the same on the hpmini01 too

```bash
sudo pacman -Syu github-cli
```

```bash
gh auth login
# follow wizard, ssh key already installed, using PAT to authenticate
```

```bash
# crate homelab repo from GH cli
gh repo create
```

### Flux

https://fluxcd.io/

Get Started: https://fluxcd.io/flux/get-started/

- PAT for Flux - `flux` - no expiration
- storing in env variable (client machine)

```bash
export GITHUB_TOKEN=<your-token>
export GITHUB_USER=<your-username>
```


#### Install Flux CLI (on client machine)

- https://fluxcd.io/flux/installation/#install-the-flux-cli

```bash
# install FLux cli on Arch Lenovo laptop
yay -S flux-bin

# check
flux check --pre

###
milan@jantar:~/repos/homelab-cluster$ flux check --pre
► checking prerequisites
✔ Kubernetes 1.33.3+k3s1 >=1.31.0-0
✔ prerequisites checks passed
```

#### Install Flux on cluster

- it installs the Controller and connects to GH repo and commits the Flux configuration in
- the repo might hold more than one cluster - hence the `path` set to `staging` to mimic a production workflow
- run this command on the client machine

```bash
flux bootstrap github \
  --owner=$GITHUB_USER \
  --repository=homelab-cluster \
  --branch=main \
  --path=./clusters/staging \
  --personal
```

```bash
# GH repo content after Flux install
milan@jantar:~/repos/homelab-cluster (main)$ ls
Permissions Size User  Date Modified Name
drwxr-xr-x     - milan  3 Aug 17:35   clusters
milan@jantar:~/repos/homelab-cluster (main)$ tree
.
└── clusters
    └── staging
        └── flux-system
            ├── gotk-components.yaml
            ├── gotk-sync.yaml
            └── kustomization.yaml

4 directories, 3 files
```


? Mischa mentioned the Helm controller installed by Flux, maybe I should skip this Helm installation while installing K3s? Now I see two Helm controllers:


```bash
milan@jantar:~/repos/homelab-cluster$ kubectl get pods -A
NAMESPACE     NAME                                       READY   STATUS      RESTARTS   AGE
flux-system   helm-controller-5c898f4887-hl8l6           1/1     Running     0          4m20s                                flux-system   kustomize-controller-7bcf986f97-xbf9d      1/1     Running     0          4m20s
flux-system   notification-controller-5f66f99d4d-kf6pl   1/1     Running     0          4m20s                                flux-system   source-controller-54bc45dc6-t9mxk          1/1     Running     0          4m19s
kube-system   coredns-5688667fd4-kwbsm                   1/1     Running     0          23h
kube-system   helm-install-traefik-crd-dmqqx             0/1     Completed   0          23h
kube-system   helm-install-traefik-xlbcc                 0/1     Completed   1          23h                                  kube-system   local-path-provisioner-774c6665dc-ct8pw    1/1     Running     0          23h
kube-system   metrics-server-6f4c6675d5-ftbqh            1/1     Running     0          23h
kube-system   svclb-traefik-818aeded-9j2nr               2/2     Running     0          23h
kube-system   traefik-c98fdf6fb-pcrtp                    1/1     Running     0          23h
```
