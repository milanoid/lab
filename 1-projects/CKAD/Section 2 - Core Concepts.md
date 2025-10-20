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


# Services

- provides connectivity between various groups of pods (e.g. fronted & backend)
- another Kubernetes object 

## Use cases

### External communication

Scenario - kubernetes node running on my laptop

- laptop 192.168.1.10
- node    192.168.1.2
- pod with an application 10.244.0.2 (internal IP)

To access the webservice from my laptop, a Service is needed. The service can listen to a port on the node and forward the traffic to a pod with application - [NodePort](https://kubernetes.io/docs/concepts/services-networking/service/#type-nodeport) Service.

## Service Types

https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types

- NodePort
- ClusterIP - sets up a virtual IP address
- LoadBalencer

### NodePort

- Maps port on the node to a port on the pod
- Maps a port to a single Pod
	- _Target Port_ (on the Pod)
	- _Port_ (on the Service itself)
	- _Node Port_ (on the Node) - range 30000 - 32767

```bash
kubectl create service nodeport --tcp 80:80 my-service --dry-run=client -o yaml
```

`~/repos/ckad/section02-core-concepts`

```yaml
# service-definition.yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: my-service
  name: my-service
spec:
  ports:
  - name: 80-80
    port: 80
    targetPort: 80 # if not provided, defaults to value of `port`
    nodePort: 30008 # if not provided, a free port is auto-provided
  selector:
    app: myapp # this tells the service where to route the traffic
	type: front-end
  type: NodePort
```

```yaml
# pod-definition.yaml
apiVersion: v1
kind: Pod

metadata:
  name: myapp-pod
  labels:
    app: myapp
    type: front-end

spec:
  containers:
    - name: nginx-container
      image: nginx
```


```
kubectl apply -f pod-definition.yaml

kubectl apply -f service-definition.yaml

curl http://192.168.1.231:30008 (IP of my Node) -> Nginx welcome screen
```

### other use cases

1. A node with multiple Pods - the Service load balance the load across all the Pods
2. A multi Node cluster - the service spans over all the Nodes and distributes the load to Pods in the individual Nodes

### Cluster IP

https://kubernetes.io/docs/concepts/services-networking/cluster-ip-allocation/

- groups multiple Pods to one IP address

```yaml
apiVersion: v1
kind: Service
metadata:
  name: linkding
spec:
  ports:
    - port: 9090
      targetPort: 9090 # optional
  selector:
    app: linkding
  type: ClusterIP
```


# Certification Tip: Imperative Commands

- declarative way -> using definition .yaml files
- imperative way -> direct call to kubectl:

```bash
kubectl run nginx --image=nginx --dry-run=client -o yaml > nginx-pod.yaml
```

## Formating Output with kubectl

1. `-o json`Output a JSON formatted API object.
    
2. `-o name`Print only the resource name and nothing else.
    
3. `-o wide`Output in the plain-text format with any additional information.
    
4. `-o yaml`Output a YAML formatted API object.


https://kubernetes.io/docs/reference/kubectl/quick-reference/


### Explain command

`kubectl api-resources`

```
# man pages - top level only
kubectl explain pods

# doc on a specific field
kubectl explain pods.spec

# list all fields
kubectl explain pods --recursive
```

