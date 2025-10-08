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


## ReplicaSet scenarios

### bad update

The deployment is updated with a new image version of an app. While doing the rolling update (or when it is done) the app does not work as expected.

quick roll back:

```bash
kubectl rollout undo deployment/webhosting
```

note - as I am using FluxCD and git driven GitOps approach, after the rollout it gets back to the version specified in git. The rollout in my case would be the create a PR and merge that to the monitored branch `main`.



# Deployments

rolling update (default)


### Hierarchy of Kubernetes objects

1. Deployment
2. ReplicaSet
3. Pod

Deployment creates a ReplicaSet which creates Pod(s).

```bash
# all command to show them all
milan@SPM-LN4K9M0GG7 ~ $ kubectl get all
NAME                               READY   STATUS    RESTARTS   AGE
pod/cloudflared-6fc569995f-59k22   1/1     Running   0          2d14h
pod/cloudflared-6fc569995f-77ktv   1/1     Running   0          2d14h
pod/webhosting-558ccf9bcd-7shf9    1/1     Running   0          15m
pod/webhosting-558ccf9bcd-94gqn    1/1     Running   0          15m

NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/webhosting   ClusterIP   10.43.168.46   <none>        80/TCP    2d14h

NAME                          READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/cloudflared   2/2     2            2           2d14h
deployment.apps/webhosting    2/2     2            2           2d14h

NAME                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/cloudflared-6fc569995f   2         2         2       2d14h
replicaset.apps/webhosting-558ccf9bcd    2         2         2       57m
replicaset.apps/webhosting-587c779d5f    0         0         0       2d14h
replicaset.apps/webhosting-7bd86f9db9    0         0         0       43h
```


# Namespaces

- to isolate resources


created automatically:

- `default`
- `kube-system`
- `kube-public`


### referring the resources across namespaces

`<service-name>.<namespace>.svc.cluster.local`

e.g.

`db-service.dev.svc.cluster.local` 

- where `cluster.local` is a default DNS name of the cluster


vs within the namespace just use the `<service-name>`


### switching the config to use a namespace permanently

`kubectl config set-context --current --namespace=linkding` 


### ResourceQuota 

- limits resources in a namespace (CPU, pods ... etc)
