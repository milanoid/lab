
think of it as a package manager

## Concepts

Helm Chart

- yaml files with deployment, secret, pv, pvc converted to templates (with vars `{{ Values.image}}`)
- `values.yaml`

templates + values.yaml = Helm Chart

`Chart.yaml`

https://artifacthub.io/

### Helm Chart installation

`helm install [release-name] [chart-name]`

```bash
# install local chart
helm install release-4 ./wordpress
```

```bash
# add repo
helm repo add bitnami https://charts.bitnami.com/bitnami
```

- `helm search hub wordpress`
- `helm list`
- `helm uninstall`
- `helm pull --untar`
