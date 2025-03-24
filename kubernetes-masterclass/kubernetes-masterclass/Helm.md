https://helm.sh/

The package manager for Kubernetes.

`brew install helm`

### Helm Chart

https://homarr.dev/ - app to be deployed using Helm Chart

- https://homarr.dev/docs/getting-started/installation/helm#traditional

#### Install

##### create a secret

```
kubectl -n homarr create secret generic db-secret \
  --from-literal=username=myuser \
  --from-literal=password=mypassword \
  --from-literal=db-encryption-key=7cc7957cb6584cae05fe276310de6baf7ca6470e36f4dff2a1d06356718bf7e1

```

#### install the `homarr` itself
```
helm repo add homarr-labs https://homarr-labs.github.io/charts/
helm repo update
helm install homarr homarr-labs/homarr --namespace homarr --create-namespace
```

#### Restart

`kubectl rollout restart deployment homarr`
#### Uninstall

`helm uninstall homarr --namespace homarr`

