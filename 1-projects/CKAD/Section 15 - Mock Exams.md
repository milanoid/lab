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


```bash
# after editing a rs scale 0 to zero and back to 4 to "restart"
kubectl scale replicaset rs-d33393 --replicas 0|4

# or delete all pods with a label
kubectl delete pod --label name=busybox-pod
```


```bash
# change color task
# instead of delete and create a pod, replace can be used
kubectl replace -f pod.yaml
```

```bash
# decode secrets
kubectl get secrets db-secret-xxdf -o jsonpath='{.da
ta}'
{"DB_Host":"c3FsMDE=","DB_Password":"cGFzc3dvcmQxMjM=","DB_User":"cm9vdA=="}
```

```bash
# creating a service via `expose`
kubectl expose deployment redis --name=redis --port=6379 --target-port=6379
```

```bash
# create a pod with 2 containers


```
---
# Mock exam 2

## Task 1/9 Deployment, Service

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

# or `expose`
kubectl expose deployment my-webapp --port=30083 --type NodePort --name front-end-service --target-port=80
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

## Task 2/9 Taint, Toleration

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

---

## Task 3/9 Node Label, Affinity

Apply a label `app_type=beta` to node `controlplane`. Create a new deployment called `beta-apps` with image: `nginx` and replicas: `3`. Set Node Affinity to the deployment to place the PODs on `controlplane` only.

NodeAffinity: `requiredDuringSchedulingIgnoredDuringExecution`


```bash
# apply label to Node
kubectl label nodes controlplane app_type=beta
node/controlplane labeled

# show labels
kubectl get nodes --show-labels
```

```bash
# deployment base
kubectl create deployment beta-apps --image=nginx --replicas=3 --dry-run=client -oyaml > depl.yaml
```



https://kubernetes.io/docs/tasks/configure-pod-container/assign-pods-nodes-using-node-affinity/
```yaml
# updated deployment
# kubectl explain pod.spec.affinity
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: beta-apps
  name: beta-apps
spec:
  replicas: 3
  selector:
    matchLabels:
      app: beta-apps
  strategy: {}
  template:
    metadata:
      labels:
        app: beta-apps
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                - key: app_type
                  operator: In
                  values:
                  - beta 
 
      containers:
      - image: nginx
        name: nginx
        resources: {}
status: {}

```

---

## Task 4/9 Ingress

Create a new Ingress Resource for the service `my-video-service` to be made available at the URL: `http://ckad-mock-exam-solution.com:30093/video`.

To create an ingress resource, the following details are: -  
  
- `annotation`: `nginx.ingress.kubernetes.io/rewrite-target: /`  
- `host`: `ckad-mock-exam-solution.com`  
- `path`: `/video`  
  
Once set up, the curl test of the URL from the nodes should be successful: `HTTP 200`

```bash
# service details
# note the Endpoints - its the IP where I can curl the app running in the Pod
kubectl describe service my-video-service 
Name:                     my-video-service
Namespace:                default
Labels:                   <none>
Annotations:              <none>
Selector:                 app=webapp-video
Type:                     ClusterIP
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       172.20.62.180
IPs:                      172.20.62.180
Port:                     <unset>  8080/TCP
TargetPort:               8080/TCP
Endpoints:                172.17.1.5:8080
Session Affinity:         None
Internal Traffic Policy:  Cluster
Events:                   <none>

# details wide
kubectl get service my-video-service -o wide
NAME               TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE     SELECTOR
my-video-service   ClusterIP   172.20.62.180   <none>        8080/TCP   3m35s   app=webapp-video


# curl to the app (172.17.1.5 is the IP in Endpoints)
curl http://172.17.1.5:8080
<!doctype html>
<title>Hello from Flask</title>
<body style="background: #30336b;">

<div style="color: #e4e4e4;
    text-align:  center;
    height: 90px;
    vertical-align:  middle;">
    <img src="https://res.cloudinary.com/cloudusthad/image/upload/v1547052431/video.jpg">

</div>

</body>
```



https://kubernetes.io/docs/concepts/services-networking/ingress/#the-ingress-resource
```yaml
# ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: minimal-ingress
  annotations: 
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: ckad-mock-exam-solution.com
    http:
      paths:
      - path: /video
        pathType: Prefix
        backend:
          service:
            name: my-video-service
            port:
              number: 8080 # <--- port of the service
```


```bash
# after appyl, success!
# no need to specify port 30093 anywhere
curl http://ckad-mock-exam-solution.com:30093/video
<!doctype html>
<title>Hello from Flask</title>
<body style="background: #30336b;">

<div style="color: #e4e4e4;
    text-align:  center;
    height: 90px;
    vertical-align:  middle;">
    <img src="https://res.cloudinary.com/cloudusthad/image/upload/v1547052431/video.jpg">

</div>

</body>
```


#### missing piece - port 30093

```bash
## The Missing Piece: NodePort or LoadBalancer

#The port 30093 is coming from **how the Ingress Controller itself is exposed**. #There are a few common ways this happens:
#Most Likely Scenario: Ingress Controller with NodePort

#Your NGINX Ingress Controller is probably exposed via a **NodePort Service**. If you run:

kubectl get svc -n ingress-nginx
NAME                                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)                      AGE
ingress-nginx-controller             NodePort    172.20.94.49   <none>        80:30093/TCP,443:31436/TCP   20m
ingress-nginx-controller-admission   ClusterIP   172.20.40.19   <none>        443/TCP    

```

Here's the complete path your request takes: 

``` 
	Browser (port 30093)
	↓
	Node IP:30093 (NodePort)
	↓
	Ingress Controller Service (port 80)
	↓
	Ingress Controller Pod (reads Ingress rules)
	↓ 
	my-video-service:8080 (ClusterIP)
	↓
	Pod (172.17.1.5:8080) with label app=webapp-video
```

---

## Task 5/9 - readinessProbe

We have deployed a new pod called `pod-with-rprobe`. This Pod has an initial delay before it is Ready. Update the newly created pod `pod-with-rprobe` with a `readinessProbe` using the given spec

- httpGet path: /ready  
- httpGet port: 8080

```bash
# save the pod spec to a file
kubectl get pods pod-with-rprobe -oyaml > pod.yaml

# update the file with probe
...
readinessProbe: 
  httpGet:
    path: /ready
    port: 8080
...

# cannot be applied, must delete and recreate
kubectl delete pods pod-with-rprobe

kubectl apply -f pod.yaml
```


## Task 6/9 - livenessProbe

Create a new pod called `nginx1401` in the `default` namespace with the image `nginx`. Add a livenessProbe to the container to restart it if the command `ls /var/www/html/probe` fails. This check should start after a delay of `10 seconds` and run `every 60 seconds`.

You may delete and recreate the object. Ignore the warnings from the probe.


```bash
# base spec
kubectl run nginx1401 --image=nginx --dry-run=client -oyaml > pod.yaml
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: nginx1401
  name: nginx1401
spec:
  containers:
  - image: nginx
    name: nginx1401
    livenessProbe:
      initialDelaySeconds: 10
      periodSeconds: 60
      exec:
        command: ["sh", "-c","ls", "/var/www/html/probe"]
```


## Task 7/9 - Job

Create a job called `whalesay` with image `busybox` and command `echo "cowsay I am going to ace CKAD!"`.  
  
- completions: `10`  
- backoffLimit: `6`  
- restartPolicy: `Never`

This simple job runs the popular cowsay game that was modifed by docker…



```bash
# crate base spec file
kubectl create job whalesay --image=busybox --dry-run=client -oyaml > job.yaml

# describe
kubectl explain jobs.spec | less
```

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: whalesay
spec:
  backoffLimit: 6
  completions: 10
  template:
    spec:
      containers:
      - image: busybox
        name: whalesay
        command: ["sh", "-c", "echo", "cowsay I am going to ace CKAD!"]
      restartPolicy: Never
```


## Task 8/9 - pod with 2 containers

Create a pod called `multi-pod` with two containers.  
  
Container 1:  name: `jupiter`, image: `nginx`  
Container 2:  name: `europa`, image: `busybox`  command: `sleep 4800`

Environment Variables:  
  
Container 1:  `type: planet`
Container 2:  `type: moon`


```bash
# base spec file
kubectl run multi-pod --image=nginx --dry-run=client -oyaml > multi.yaml
```


```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: multi-pod
  name: multi-pod
spec:
  containers:
  - image: nginx
    name: jupiter
    env:
      - name: type
        value: planet
  - image: busybox
    name: europa
    command: ["/bin/sh","-c","sleep 4800"]
    env:
      - name: type
        value: moon
```



```bash
kubectl logs -c europa pods/multi-pod 
BusyBox v1.37.0 (2024-09-26 21:31:42 UTC) multi-call binary.

Usage: sleep [N]...

Pause for a time equal to the total of the args given, where each arg can
have an optional suffix of (s)econds, (m)inutes, (h)ours, or (d)ays
```

## Task 9/9 -  PV

Create a PersistentVolume called `custom-volume` with size: 50MiB reclaim policy:`retain`, Access Modes: `ReadWriteMany` and hostPath: `/opt/data`

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: custom-volume
spec:
  capacity:
    storage: 50Mi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /opt/data
```


# Register for Certification


- Candidate Handbook https://docs.linuxfoundation.org/tc-docs/certification/lf-handbook2

## online exam by PSI

- proctoring
- quite and private room
- good lighting 
- valid ID needed (OP)
- check-in might take time
- HW compatibility check https://syscheck.bridge.psiexams.com/ (Fails in Firefox, Brave OK)
- [ ] main display iPhone mount point
- Linux Foundation portal https://trainingportal.linuxfoundation.org/learn/dashboard/
- Resources allowed: 
	- https://kubernetes.io/docs/
	- https://kubernetes.io/blog/
	- https://helm.sh/docs/



"We strongly advise test takers to **avoid using work-provided devices for their exams**"
- Selfservice make me admin should fix that?
- no company VPN connection


Process

"Milan: You're Pre-Approved! You are eligible to take this exam until 8/31/2026."

- [x] register for exam (since then 12 months to schedule and take the exam)
- [x] schedule the exam (up to 90 days in advance, 24h cancelation policy)
- [ ] after booking do Tutorial Test (3 attempts), install PSI's Secure Browser
	- [x] first run (SP MacBook, session started using Firefox than switch to Secure Browser)
	- [ ] second run
- [ ] Exam Simulator @ https://trainingportal.linuxfoundation.org/
	- [ ] first attempt
	- [ ] second attempt
- [ ] 


# Killercoda

- Firefox recommended
- https://killercoda.com/killer-shell-ckad

### vim setup for exam

```bash
# ~/.vimrc

# expandtab: use spaces for tab
set expandtab
# tabstop: amount of spaces used for tab
set tabstop=2
# shiftwidth: amount of spaces used during indentation
set shiftwidth=2
```

### SSH basics

During the exam you'll be provided with a command you need to run before every question to connect to a dedicated host.

### kubectl contexts

```bash
# list existing contexts
controlplane:~$ kubectl config get-contexts 
CURRENT   NAME                          CLUSTER      AUTHINFO           NAMESPACE
*         kubernetes-admin@kubernetes   kubernetes   kubernetes-admin   
          purple                        kubernetes   kubernetes-admin   purple
          yellow                        kubernetes   kubernetes-admin   yellow
          
# switch to a context
controlplane:~$ kubectl config use-context purple 
Switched to context "purple".
```

### Pod with resources

Create a new _Namespace_ `limit` .
In that _Namespace_ create a _Pod_ named `resource-checker` of image `httpd:alpine` .
The container should be named `my-container` .
It should request `30m` CPU and be limited to `300m` CPU.
It should request `30Mi` memory and be limited to `30Mi` memory.

```bash
# namespace
kubectl create namespace limit

# base yaml
kubectl run --image=httpd:alpine resource-checker --namespace limit -oyaml --dry-run=client > resource-checker.yaml

# explain pod limits
kubectl explain pods.spec.containers.resources | less


# pods
kubectl apply -f resource-checker.yaml

Error from server (BadRequest): error when creating "resource-checker.yaml": Pod in version "v1" cannot be handled as a Pod: unable to parse quantity's suffix
```

```yaml
# resource-checker.yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: resource-checker
  name: resource-checker
  namespace: limit
spec:
  containers:
  - image: httpd:alpine
    name: my-container
    resources:
      requests:
        cpu: "30m"
        memory: "30Mi" # typo "30mi"
      limits:
        cpu: "300m"
        memory: "30Mi" # typo "30mi"
```


### ConfigMap Access in Pods

1. Create a _ConfigMap_ named `trauerweide` with content `tree=trauerweide`
2. Create the _ConfigMap_ stored in existing file `/root/cm.yaml`

```bash
kubectl create configmap --from-literal=tree=trauerweide trauerweide --dry-run=client -oyaml

apiVersion: v1
data:
  tree: trauerweide
kind: ConfigMap
metadata:
  name: trauerweide
```

1. Create a _Pod_ named `pod1` of image `nginx:alpine`
2. Make key `tree` of _ConfigMap_ `trauerweide` available as environment variable `TREE1`
3. Mount all keys of _ConfigMap_ `birke` as volume. The files should be available under `/etc/birke/*`
4. Test env+volume access in the running _Pod_

```bash
# create base yaml
kubectl run pod1 --image=nginx:alpine -oyaml --dry-run=client > pod1.yaml

# explain env for pods
kubectl explain pods.spec.containers.envFrom | less
```

```yaml
# a lot of description reading
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: pod1
  name: pod1
spec:
  volumes:
    - name: birke
      configMap:
        name: birke
  containers:
  - image: nginx:alpine
    name: pod1
    env:
      - name: TREE1
        valueFrom:
          configMapKeyRef:
            key: tree
            name: trauerweide 
    volumeMounts:
      - name: birke
        mountPath: /etc/birke/ 
```

```bash
# check
kubectl exec -it pods/pod1 -- sh
set # to print envs

TREE1='trauerweide'

# ls -l /etc/birke/
total 0
lrwxrwxrwx    1 root     root            17 Jan 22 08:14 department -> ..data/department
lrwxrwxrwx    1 root     root            12 Jan 22 08:14 level -> ..data/level
lrwxrwxrwx    1 root     root            11 Jan 22 08:14 tree -> ..data/tree

```


### ReadinessProbe

Create a _Deployment_ named `space-alien-welcome-message-generator` of image `httpd:alpine` with one replica.

It should've a ReadinessProbe which executes the command `stat /tmp/ready` . This means once the file exists the _Pod_ should be ready.

The `initialDelaySeconds` should be `10` and `periodSeconds` should be `5` .

Create the _Deployment_ and observe that the _Pod_ won't get ready.


```bash
# create base yaml
kubectl create deployment --image=httpd:alpine space-alien-welcome-message-generator -oyaml --dry-run=client > depl.yaml
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: space-alien-welcome-message-generator
  name: space-alien-welcome-message-generator
spec:
  replicas: 1
  selector:
    matchLabels:
      app: space-alien-welcome-message-generator
  template:
    metadata:
      labels:
        app: space-alien-welcome-message-generator
    spec:
      containers:
      - image: httpd:alpine
        name: httpd
        readinessProbe:
          initialDelaySeconds: 10
          periodSeconds: 5
          exec:
            command: ["stat", "/tmp/ready"]
```

```bash
# probe fails, pod is not in READY state
controlplane:~$ kubectl get pods
NAME                                                     READY   STATUS    RESTARTS   AGE
space-alien-welcome-message-generator-66b7c9d6d5-hlf7v   0/1     Running   0          118s

# make it ready
kubectl exec pods/space-alien-welcome-message-generator-66b7c9d6d5-hlf7v -- touch /tmp/ready

# READY
controlplane:~$ kubectl get pods
NAME                                                     READY   STATUS    RESTARTS   AGE
space-alien-welcome-message-generator-66b7c9d6d5-hlf7v   1/1     Running   0          3m11s
```


### Build and run a Container

Create a new file `/root/Dockerfile` to build a container image from. It should:

- use `bash` as base
- run `ping killercoda.com`

Build the image and tag it as `pinger` .

Run the image (create a container) named `my-ping` .

```bash
cat Dockerfile 
FROM bash
CMD ping killercoda.com

# buld and tag
docker build /root/ --tag pinger

# man docker-run
man docker-run

# run
docker run --rm --name="my-ping" pinger
```

Tag the image, which is currently tagged as `pinger` , also as `local-registry:5000/pinger` .

Then push the image into the local registry.

```bash
# man docker-tag
docker tag pinger:latest local-registry:5000/pinger

# man
man docker-image-push

# push image (latest)
docker image push local-registry:5000/pinger

# push a specific image tag
docker image push local-registry:5000/pinger:v1
```

### Rollout Rolling

- default strategy
- invoked by e.g. changing image in a deployment

### Rollout Green-Blue

- having two deployments running alongside
- having one service which we can switch to use v1 vs v2 deployment

Existing deployment _wonderful-v1_ with image `httpd:alpine`. Switch it to `nginx:alpine`.

The switch should happen instantly. Meaning that from the moment of rollout, all new requests should hit the new image.

1. Create a new _Deployment_ `wonderful-v2` which uses image `nginx:alpine` with `4` replicas. It's _Pods_ should have labels `app: wonderful` and `version: v2`
    
2. Once all new _Pods_ are running, change the selector label of _Service_ `wonderful` to `version: v2`
    
3. Finally scale down _Deployment_ `wonderful-v1` to `0` replicas
   
```bash
kubectl scale deploy wonderful-v1 --replicas 0   
```

### Rollout Canary

The switch should not happen fast or automatically, but using the Canary approach:

- 20% of requests should hit the new image
- 80% of requests should hit the old image

For this create a new _Deployment_ `wonderful-v2` which uses image `nginx:alpine` .

The total amount of _Pods_ of both _Deployments_ combined should be 10.

```bash
# total pods 10
# 8 v1 (80 %)
# 2 v2 (20 %) 

# reduce # of replicas of v1 deployment
kubectl scale deployment wonderful-v1 --replicas=8 

# v2
controlplane:~$ cat /wonderful/v2.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: wonderful
  name: wonderful-v2
spec:
  replicas: 2
  selector:
    matchLabels:
      app: wonderful
  template:
    metadata:
      labels:
        app: wonderful
    spec:
      containers:
      - image: nginx:alpine
        name: nginx
```

### Custom Resource Definitions

Write the list of all installed CRDs into `/root/crds` .

Write the list of all _DbBackup_ objects into `/root/db-backups` .

```bash
# get CRDs
kubectl get customresourcedefinitions.apiextensions.k8s.io > /root/crds
kubectl get db-backups.stable.killercoda.com -A > /root/db-backups
```

The team worked really hard for months on a new Shopping-Items CRD which is currently in beta.

Install it from `/code/crd.yaml` .

Then create a _ShoppingItem_ object named `bananas` in _Namespace_ `default` . The `dueDate` should be `tomorrow` and the `description` should be `buy yellow ones` .

```bash
# install new CRD
kubectl apply -f /code/crd.yaml 
customresourcedefinition.apiextensions.k8s.io/shopping-items.beta.killercoda.com created

# CRD is
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: shopping-items.beta.killercoda.com
spec:
  group: beta.killercoda.com
  versions:
    - name: v1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              properties:
                description:
                  type: string
                dueDate:
                  type: string
  scope: Namespaced
  names:
    plural: shopping-items
    singular: shopping-i
    kind: ShoppingItem


# create CRD resoource bananas
apiVersion: "beta.killercoda.com/v1" # group/name ?
kind: ShoppingItem
metadata:
  name: bananas
spec:
  description: "buy yellow ones"
  dueDate: "tomorrow"
```


Delete the CRD and all _ShoppingItem_ objects again.

```bash
kubectl delete customresourcedefinitions.apiextensions.k8s.io shopping-items.beta.killercoda.com
```

### Helm

Write the list of all Helm releases in the cluster into `/root/releases` .

```bash
# list (mind the -A for all namespaces)
helm list -A
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART              APP VERSION
apiserver       team-yellow     1               2026-01-22 13:35:26.488787137 +0000 UTC deployed        apache-11.4.29     2.4.65     
webserver       team-blue       1               2026-01-22 13:35:13.700410951 +0000 UTC deployed        apache-11.4.29     2.4.65

# uninstall
helm uninstall -n team-blue webserver
release "webserver" uninstalled

# install a helm chart
# dev - user picked name for the release
helm install dev falcosecurity/falco -n team-yellow


# list again
helm ls -A
NAME    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART      APP VERSION
dev     team-yellow     1               2026-01-22 13:42:33.386476308 +0000 UTC deployed        falco-7.2.10.42.1  
```

### Ingress Create

There are two existing _Deployments_ in _Namespace_ `world` which should be made accessible via an _Ingress_.

First: create ClusterIP _Services_ for both _Deployments_ for port `80` . The _Services_ should have the same name as the _Deployments_.

```bash
# switch to ns
kubectl config set-context --current --namespace=world

# create service for each deployment
kubectl create service clusterip europe --tcp=80:80
kubectl create service clusterip asia --tcp=80:80

```

The Nginx Ingress Controller has been installed.

Create a new _Ingress_ resource called `world` for domain name `world.universe.mine` . The domain points to the K8s Node IP via `/etc/hosts` .

The _Ingress_ resource should have two routes pointing to the existing _Services_:

`http://world.universe.mine:30080/europe/`

and

`http://world.universe.mine:30080/asia/`

```bash
# check the setting of ingress-nginx controller
kubectl -n ingress-nginx get svc ingress-nginx-controller -oyaml

...
ports:
  - appProtocol: http
    name: http
    nodePort: 30080
    port: 80
    protocol: TCP
    targetPort: http
...

# nodePort: 30080

# find out the igressClassName with:
kubectl get ingressclasses.networking.k8s.io 
NAME    CONTROLLER             PARAMETERS   AGE
nginx   k8s.io/ingress-nginx   <none>       39m


kubectl create ingress world --rule=world.universe.mine/europe=europe:80 --rule=world.universe.mine/asia=asia:80 --class=nginx --annotation=nginx.ingress.kubernetes.io/rewrite-target=/


### tricky parts - ingressClassname, annotations
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: world
  namespace: world
  annotations:
    # this annotation removes the need for a trailing slash when calling urls
    # but it is not necessary for solving this scenario
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx # k get ingressclass
  rules:
  - host: "world.universe.mine"
    http:
      paths:
      - path: /europe
        pathType: Prefix
        backend:
          service:
            name: europe
            port:
              number: 80
      - path: /asia
        pathType: Prefix
        backend:
          service:
            name: asia
            port:
              number: 80
```

### NetworkPolicy Namespace Selector

There are existing _Pods_ in _Namespace_ `space1` and `space2` .

We need a new _NetworkPolicy_ named `np` that restricts all _Pods_ in _Namespace_ `space1` to only have outgoing traffic to _Pods_ in _Namespace_ `space2` . Incoming traffic not affected.

The _NetworkPolicy_ should still allow all outgoing DNS traffic on port `53` TCP and UDP.

```yaml
controlplane:~$ cat np.yaml 
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: np
  namespace: space1
spec:
  podSelector: {}
  policyTypes:
  - Egress
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          # use `k get ns --show-labels`
          kubernetes.io/metadata.name: space2
  - ports:
    - protocol: TCP
      port: 53
    - protocol: UDP
      port: 53

```


```bash
# should work
# [service].[namespace].svc.cluster.local
k -n space1 exec app1-0 -- curl -m 1 microservice1.space2.svc.cluster.local
k -n space1 exec app1-0 -- curl -m 1 microservice2.space2.svc.cluster.local
k -n space1 exec app1-0 -- nslookup tester.default.svc.cluster.local
k -n space1 exec app1-0 -- nslookup killercoda.com

# these should not work
k -n space1 exec app1-0 -- curl -m 1 tester.default.svc.cluster.local
k -n space1 exec app1-0 -- curl -m 1 killercoda.com
```

### Admission Controllers

- a code which intercepts kubectl API server, modifies requests (e.g. to restrict a certain operation)

```bash
# We can check the kube-apiserver manifest:
cat /etc/kubernetes/manifests/kube-apiserver.yaml

# Or the running process:
ps aux | grep kube-apiserver


##
cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep admission-plugins
    - --enable-admission-plugins=NodeRestriction,LimitRanger,Priority
      
# enabled are: NodeRestriction,LimitRanger,Priority
```


### Api Deprecations

```bash
kubectl version
Client Version: v1.34.3
Kustomize Version: v5.7.1
Server Version: v1.34.3


```


# 10  mistakes

1. switch context (there are multiple clusters)
2. don't type, copy'n'paste (CTRL+SHIFT+V)
3. basic linux commands (pipe, grep, redirect)
4. vague tasks 
5. vim (cut'n'paste, `set paste` command - to keep formatting)
6. using wrong tools to troubleshoot (`describe`, `k get events -n namespace`, `logs`)
7. don't write yaml from scratch (copy'n'paste from doc or use imparative command)
8. double check if time left
9. don't aim for 100%, skip some questions if necessary (q are weighted)
10. better to answer 50 % of a question than skip it (partial points)


Find which pod consumes the most resources

```bash
kubectl top pod --containers
POD                               NAME          CPU(cores)   MEMORY(bytes)
bazarr-6c4dcc6db8-vj8hz           bazarr        5m           234Mi
prowlarr-b667bf985-pzdnb          prowlarr      2m           237Mi
radarr-d44fb4744-4r9fx            radarr        2m           199Mi
sonarr-6c8bb8c585-wzrcw           sonarr        2m           250Mi
torrent-client-6c8dc987f4-nkpb7   qbittorrent   38m          728Mi
```

---
### Exam Simulator (#1)

38 / 113 (11/22 questions)

1. deployment undo: "rollout undo"

2. vim indent multiple lines https://stackoverflow.com/questions/235839/indent-multiple-lines-quickly-in-vi (visual, select lines, `<` or `>`, `.` to indent again )
3. enable line numbers in vim?
4. copy'n'paste - extra space? - left click only!


```bash
# ~/.vimrc
set expandtab
set tabstop=2
set shiftwidth=2
set paste
set number
```

run a command in a temp pod
	`kubectl run --image=nginx -it --rm temp -- curl http://some-address`


 set default namespace
 
	`kubectl config set-context --current --namespace <desired-namespace>`