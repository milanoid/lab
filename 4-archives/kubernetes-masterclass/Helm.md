https://helm.sh/

The package manager for Kubernetes.

`brew install helm`

### Helm Chart

https://homarr.dev/ - app to be deployed using Helm Chart

- https://homarr.dev/docs/getting-started/installation/helm#traditional

#### Install

##### create a secret

```
kubectl -n homarr create secret generic db-secret --from-literal=db-encryption-key=7cc7957cb6584cae05fe276310de6baf7ca6470e36f4dff2a1d06356718bf7e1

```

#### Install the `homarr` Helm chart
```
helm repo add homarr-labs https://homarr-labs.github.io/charts/
helm repo update
helm install homarr homarr-labs/homarr --namespace homarr --create-namespace
```

#### Install the `homarr` Helm chart with `values.yaml`

```
helm install homarr homarr-labs/homarr --namespace homarr --create-namespace --values=values.yaml
```

#### Restart

`kubectl rollout restart deployment homarr`
#### Uninstall

`helm uninstall homarr --namespace homarr`

#### List Helm charts

- `helm ls -A` - in all namespaces

#### Help upgrade

Refresh the installation (e.g. after updating the `values.yaml`)

- `helm upgrade -n homarr homarr homarr-labs/homarr --values=values.yaml`


#### More Helm commands

- `helm repo list`
- `helm show values homarr-labs/homarr`
