The package manager for Kubernetes https://helm.sh/

- manages Kubernetes application - Helm Charts
- connects to Kubernetes cluster and perform actions (kubectl create|apply ... etc.) 

### installation

`sudo pacman -Syu helm`

### demo - installing Homarr Helm Chart

- https://artifacthub.io/packages/helm/homarr-labs/homarr
- https://homarr-labs.github.io/charts/charts/homarr/
- https://github.com/homarr-labs/homarr

```bash
# traditional way (vs OCI?)
helm repo add homarr-labs https://homarr-labs.github.io/charts/
helm repo update
helm install homarr homarr-labs/homarr
```

```bash
# list existing repositories
helm repo list
NAME            URL
homarr-labs     https://homarr-labs.github.io/charts/
```

```bash
# by default installs to current namespace, unless specified otherwise
helm install homarr homarr-labs/homarr --namespace homarr --create-namespace
NAME: homarr
LAST DEPLOYED: Fri Aug  1 15:16:58 2025
NAMESPACE: homarr
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace homearr -l "app.kubernetes.io/name=homarr,app.kubernetes.io/instance=homarr" -o jsonpath="{.items[0].metadata.name}")
  export CONTAINER_PORT=$(kubectl get pod --namespace homarr $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl --namespace homarr port-forward $POD_NAME 8080:$CONTAINER_PORT
```

what has been created by the Helm Chart:

```bash
kubectl get all --namespace homarr
NAME                          READY   STATUS                       RESTARTS   AGE
pod/homarr-7f48c9f57b-cfw8h   0/1     CreateContainerConfigError   0          3m24s

NAME             TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
service/homarr   ClusterIP   10.43.10.117   <none>        7575/TCP   3m24s

NAME                     READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/homarr   0/1     1            0           3m25s

NAME                                DESIRED   CURRENT   READY   AGE
replicaset.apps/homarr-7f48c9f57b   1         1         0       3m25s
```


but the Pods is not running:

```bash
│   Warning  Failed     13s (x7 over 76s)  kubelet            Error: secret "db-secret" not found                           │
```

to fix that create the secret:

```bash
kubectl create secret generic db-secret --from-literal=db-encryption-key=$(openssl rand -hex 32) --namespace homarr
```

port forward (SHIFT+F in K9s) and access the app at http://localhost:7575


#### customize the configuration

concept of a values file
- value file allows to pass parameters to installation
- https://github.com/homarr-labs/charts/blob/dev/charts/homarr/values.yaml

e.g. overwrite default value of 1 for _replicaCount_ - create my values file:

```bash
cat values.yaml
replicaCount: 2
```

```bash
#  uninstall
helm uninstall homarr
```

```bash
# install and pass my values file
helm install homarr homarr-labs/homarr --namespace homarr --create-namespace --values values.yaml
```

after updating the values file - run this to apply:

```bash
helm upgrade homarr homarr-labs/homarr --values values.yaml
```
show Helm Chart's default values:

```bash
helm show values homarr-labs/homarr
```