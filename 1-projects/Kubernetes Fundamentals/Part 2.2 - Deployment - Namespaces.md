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


