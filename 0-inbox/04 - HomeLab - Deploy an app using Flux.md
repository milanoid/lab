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