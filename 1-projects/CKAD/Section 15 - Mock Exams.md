real like exams

https://uklabs.kodekloud.com/topic/mock-exam-1-5/

# Mock exam 1

## create a service

imperative command to create a service:

Create a service `messaging-service` to expose the `redis` deployment in the `marketing` namespace within the cluster on port `6379`.

- Use imperative commands
- Service: messaging-service
- Port: 6379
- Use the right type of Service
- Use the right labels

```bash
kubectl expose deployment redis --port=6379 --name=messaging-service --namespace=marketing
```


```bash
# with same name instead of delete then apply we can run `replace`
kubectl replace -f webapp-color.yaml --force
```

## create a deployment

Create a `redis` deployment using the image `redis:alpine` with `1 replica` and label `app=redis`. Expose it via a ClusterIP service called `redis` on port 6379. Create a new `Ingress Type` NetworkPolicy called `redis-access` which allows only the pods with label `access=redis` to access the deployment.

- Image: redis:alpine
- Deployment created correctly?
- Service created correctly?
- Network Policy allows the correct pods?
- Network Policy applied on the correct pods?



- [x] how to `explain` with details on e.g. pod's `.spec`?

```bash
kubectl explain pods.spec.hostname
KIND:       Pod
VERSION:    v1

FIELD: hostname <string>


DESCRIPTION:
    Specifies the hostname of the Pod If not specified, the pod's hostname will
    be set to a system-defined value.
```

---
# Mock exam 2

https://uklabs.kodekloud.com/topic/mock-exam-2-5/

Create a deployment called `my-webapp` with image: `nginx`, label `tier:frontend` and `2` replicas. Expose the deployment as a NodePort service with name `front-end-service` , port: `80` and NodePort: `30083`


Deployment

```yaml
# crate base deployment
#kubectl create deployment my-webapp --image=nginx --replicas=2 --dry-run=client -oyaml > deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: my-webapp
  name: my-webapp
spec:
  replicas: 2
  selector:
    matchLabels:
      app: my-webapp
  strategy: {}
  template:
    metadata:
      labels:
        app: my-webapp
    spec:
      containers:
      - image: nginx
        name: nginx
        resources: {}
status: {}
```



```yaml
# kubectl apply -f deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: my-webapp
    tier: frontend
  name: my-webapp
spec:
  replicas: 2
  selector:
    matchLabels:
      app: my-webapp
  template:
    metadata:
      labels:
        app: my-webapp
    spec:
      containers:
      - image: nginx
        name: nginx
```

Service

```bash
kubectl create service nodeport front-end-service --node-port=30083 --tcp=80  --dry-run=client -oyaml > service.yaml
```


```yaml
# kubectl apply -f service.yaml 
apiVersion: v1
kind: Service
metadata:
  labels:
    app: front-end-service
  name: front-end-service
spec:
  ports:
  - name: "80"
    nodePort: 30083
    port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: front-end-service # should it be my-webapp?
  type: NodePort
```



```
External Traffic (from outside cluster)
    |
    | (HTTP request to NodeIP:30083)
    |
    v
┌─────────────────────────────────────────────┐
│         Kubernetes Node                     │
│                                             │
│   NodePort: 30083                           │
│        |                                    │
│        v                                    │
│   ┌──────────────────────────────┐          │
│   │  Service: front-end-service  │          │
│   │  port: 80                    │◄─────────┼─── Internal cluster traffic
│   │  (Service's listening port)  │          │    (other pods call 
│   └──────────────┬───────────────┘          │     front-end-service:80)
│                  |                          │
│                  | (forwards to)            │
│                  v                          │
│         targetPort: 80                      │
│                  |                          │
│     ┌────────────┴────────────┐             │
│     |                          |            │
│     v                          v            │
│  ┌──────┐                  ┌──────┐         │
│  │ Pod1 │                  │ Pod2 │         │
│  │ :80  │                  │ :80  │         │
│  │      │                  │      │         │
│  │ app: │                  │ app: │         │
│  │front-│                  │front-│         │
│  │ end  │                  │ end  │         │
│  └──────┘                  └──────┘         │
│  (Your actual application containers)       │
└─────────────────────────────────────────────┘
```

**Traffic paths:**

1. **External → NodePort (30083) → Service port (80) → targetPort (80) → Pod**
    - Used by users accessing from outside the cluster
2. **Internal Pod → Service port (80) → targetPort (80) → Pod**
    - Used by other pods inside the cluster

The key insight: The Service acts as a load balancer that listens on `port: 80` and distributes traffic to the `targetPort: 80` on any pod matching the selector `app: front-end-service`

---

# Mock exam 3

Add a taint to the node `node01` of the cluster. Use the specification below:

key: `app_type`, value: `alpha` and effect: `NoSchedule`  
  
Create a pod called `alpha`, image: `redis` with toleration to `node01`.



```bash
# taint
kubectl taint node node01 app_type=alpha:NoSchedule
node/node01 tainted

# check
kubectl describe nodes node01 
...
Taints:             app_type=alpha:NoSchedule
...


```


```bash
# Pod base yaml
kubectl run --image=redis alpha --dry-run=client -oyaml > pod.yaml


# explain
kubectl explain pod.spec.tolerations | less
```


```yaml
# pod with toleration
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: alpha
  name: alpha
spec:
  containers:
  - image: redis
    name: alpha
  tolerations:
  - key: app_type
    value: alpha
    effect: NoSchedule     
```