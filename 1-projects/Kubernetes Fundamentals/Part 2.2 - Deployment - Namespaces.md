- logical grouping of resources within a single cluster
- for isolating groups in a single cluster
- e.g. team based namespace or application based

default namespace  - do not use on production

```bash
milan@jantar:~/repos/lab/kubecraft/kubernetes-fundamentals/Part 2 - Deployments (main)$ kubectl get namespaces
NAME              STATUS   AGE
default           Active   4d6h
kube-node-lease   Active   4d6h
kube-public       Active   4d6h
kube-system       Active   4d6h
```

### create a namespace

```bash
kubectl create namespace mealie
namespace/mealie created
```

### list namespaces

```bash
kubectl get namespaces
NAME              STATUS   AGE
default           Active   4d6h
kube-node-lease   Active   4d6h
kube-public       Active   4d6h
kube-system       Active   4d6h
mealie            Active   65s
```

### delete namespace

- if the namespace has resources, they will be deleted 

```bash
kubectl delete namespaces <namespace>
```

### generate namespace yaml

```bash
kubectl create namespace mealie --output yaml --dry-run=client > namespace.yaml
```

```bash
# now the namespace can be created from code:
kubectl apply -f namespace.yaml
```

### list resources in a specific namespace

```bash
# run a pod in default namespace
kubect run milan --image=nginx

# see it won't appear in the `mealie` namespace
kubectl get pods --namespace mealie

# run another pod in `mealie` namespace
kubectl run milan --image=nginx --namespace mealie

# see it is listed in the `mealie` namespace
kubectl get pods --namespace mealie
NAME    READY   STATUS    RESTARTS   AGE
milan   1/1     Running   0          101s
```

### setting a default namespace

```bash
kubectl config current-context
rancher-desktop

# update the current context to use a specific namespace
kubectl config set-context --current --namespace=mealie
Context "rancher-desktop" modified.
```