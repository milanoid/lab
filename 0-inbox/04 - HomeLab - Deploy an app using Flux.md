The app: https://github.com/sissbruecker/linkding

https://fluxcd.io/flux/guides/repository-structure/

Repo structure:

```console
├── apps
│   ├── base
│   ├── production 
│   └── staging
├── infrastructure
│   ├── base
│   ├── production 
│   └── staging
└── clusters
    ├── production
    └── staging
```

`kustomization.yaml` 

- template, reads other files
- Flux looks up this file out of the box

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- gotk-components.yaml
- gotk-sync.yaml
```

`gotk` - GitOps ToolKit

Neovim goodies:

- `nvim .` - open current working directory as a project in Neovim
- `CTRL+W+H` - switch between window to left (H)
- `CTRL+W+L` - switch between window to right (L)
- `a` - (Neotree plugin) - creates a new file/directory
- `SHIFT+H`, `SHIFT+L` - switch between panels with opened files (left, right)

### creating the kustomization.yaml

#### Custom Resource

https://fluxcd.io/flux/concepts/#kustomization

```bash
milan@jantar:~$ kubectl get customresourcedefinitions.apiextensions.k8s.io | grep flux
alerts.notification.toolkit.fluxcd.io        2025-08-03T15:27:05Z
buckets.source.toolkit.fluxcd.io             2025-08-03T15:27:05Z
gitrepositories.source.toolkit.fluxcd.io     2025-08-03T15:27:05Z
helmcharts.source.toolkit.fluxcd.io          2025-08-03T15:27:05Z
helmreleases.helm.toolkit.fluxcd.io          2025-08-03T15:27:05Z
helmrepositories.source.toolkit.fluxcd.io    2025-08-03T15:27:05Z
kustomizations.kustomize.toolkit.fluxcd.io   2025-08-03T15:27:05Z
ocirepositories.source.toolkit.fluxcd.io     2025-08-03T15:27:05Z
providers.notification.toolkit.fluxcd.io     2025-08-03T15:27:05Z
receivers.notification.toolkit.fluxcd.io     2025-08-03T15:27:05Z
```

```bash
# print the Flux CD Custom Resource as yaml
milan@jantar:~$ kubectl get customresourcedefinitions.apiextensions.k8s.io kustomizations.kustomize.toolkit.fluxcd.io --output yaml
```

```bash
milan@jantar:~$ kubectl --namespace flux-system get gitrepositories.source.toolkit.fluxcd.io
NAME          URL                                             AGE   READY   STATUS
flux-system   ssh://git@github.com/milanoid/homelab-cluster   21h   True    stored artifact for revision 'main@sha1:7ae59ff75fe8cbfd3b2c427ac7dbcc95f6fb79c4'
```

- creating the monorepo structure following the Repository structure https://fluxcd.io/flux/guides/repository-structure/

```bash
milan@jantar:~/repos/homelab-cluster (main)$ tree
.
├── apps
│   ├── base
│   │   └── linkding
│   │       ├── deployment.yaml
│   │       ├── kustomization.yaml
│   │       └── namespace.yaml
│   └── staging
│       └── linkding
│           └── kustomization.yaml
└── clusters
    └── staging
        ├── apps.yaml
        └── flux-system
            ├── gotk-components.yaml
            ├── gotk-sync.yaml
            └── kustomization.yaml

9 directories, 8 files
```

Before
```bash
# befor commit and push - rev.7ae59ff7
milan@jantar:~/repos/homelab-cluster (main)$ flux get kustomizations
NAME            REVISION                SUSPENDED       READY   MESSAGE
flux-system     main@sha1:7ae59ff7      False           True    Applied revision: main@sha1:7ae59ff7
```
After

```bash
milan@jantar:~/repos/homelab-cluster (main)$ flux get kustomizations
NAME            REVISION                SUSPENDED       READY   MESSAGE
flux-system     main@sha1:7ae59ff7      False           Unknown Reconciliation in progress
```

```bash
milan@jantar:~/repos/homelab-cluster (main)$ flux get kustomizations                                                         NAME            REVISION                SUSPENDED       READY   MESSAGE                                                      apps            main@sha1:d404857a      False           True    Applied revision: main@sha1:d404857a
flux-system     main@sha1:d404857a      False           True    Applied revision: main@sha1:d404857a                         milan@jantar:~/repos/homelab-cluster (main)$ git log --oneline                                                               d404857 (HEAD -> main, origin/main, origin/HEAD) fix typo
```


```bash
milan@jantar:~/repos/homelab-cluster (main)$ kubectl get pods --namespace linkding
NAME                        READY   STATUS    RESTARTS   AGE
linkding-55fb4cbfd7-47vvc   1/1     Running   0          106s
```