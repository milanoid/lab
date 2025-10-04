- `~/repos/ckad/section02-core-concepts`
### containerd

https://containerd.io/

### Pod (hejno)

- usually has a 1 container
- but can have more (sidecar/helper container)

`kubectl run nginx --image nginx` - deploys _pod_



## KodeKloud

https://learn.kodekloud.com/user/dashboard

- [x] account created
- [x] course (free) enrolled

Use `dry-run=client` to generate the Pod metadata. Can be used to save to a file.

```bash
# generate the pod nanifest
kubectl run redis --image=redis --dry-run=client -o yaml > redis-pod.yaml

# run the pod
kubectl apply -f redis-pod.yaml

# possible to edit a pod (only a few properties can be changed)
kubectl edit pod <pod-name>
```

### ReplicaSets

- Replication Controller - one of the typo of Controllers
- A Controller is the brain of the Kubernetes - monitors and controls the resources (e.g. Pods)
- Provides Load Balancing and Scaling
- Replication Controller can span over multiple Nodes
- Replication Controller vs ReplicaSet (same purpose but not the same!)

#### Replication Controller

- legacy https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller/
- older, replaced by ReplicaSet

```yaml -rc-definition.yaml
---
apiVersion: v1
kind: ReplicationController
metadata:
  name: myapp-rc
  labels:
    app: myapp
    type: front-end
spec:
  template:
    metadata:
      name: myapp-pod
      labels:
        app: myapp
        type: front-end
    spec:
      containers:
        - name: nginx-container
          image: nginx

replicas: 3
```

```bash
# apply
kubectl apply -f rc-definition.yaml
```

```bash
kubectl get replicationcontrollers
NAME       DESIRED   CURRENT   READY   AGE
myapp-rc   3         3         3       3m22s
```


#### ReplicaSet

- newer, recommended to use
- https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/
- Usually, you define a Deployment and let that Deployment manage ReplicaSets automatically.
- use a Deployment instead, and define your application in the spec section


- unlinke replicationcontroller it requires `selector`
- using the `selector` it can manage even pods NOT created via the ReplicaSet
```yaml replicaset-definition.yaml
---
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: myapp-replicaset
  labels:
    app: myapp
    type: front-end

spec:
  template:
    metadata:
      name: myapp-pod
      labels:
        app: myapp
        type: front-end
    spec:
      containers:
        - name: nginx-container
          image: nginx

  replicas: 3
  selector:
    matchLabels:
      type: front-end
```


```bash
kubectl apply -f replicaset-definition.yaml
```

```bash
kubectl get replicasets.apps
```


#### Labels and Selectors

There might be a lot of Pods running. We need to label them so the ReplicaSet can (via Selector) know which Pods to monitor.

- Pod - uses _label_
- ReplicaSet - uses _selector_


#### Scale

1. change the number of `replicas` in the definition yaml file
2. use `kubectl scale --replicas=6 -f replicaset-definition.yaml` - using def. file
3. or `kubectl scale --replicas=6 replicaset myapp-replicaset` - using the replicaset

The `scale` command change is manual change. The definition file is kept untouched.
