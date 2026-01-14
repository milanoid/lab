- 5 - 6 questions in 30 minutes
- click END EXAM
- pass 80 %


### Lightning lab 1

- [ ] https://uklabs.kodekloud.com/topic/lightning-lab-1-4/





- [x] Task 1 - Create PV and PVC and a Pod with the Volume

create a PV with PVC 

```yaml
#pv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: log-volume
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteMany
  capacity:
    storage: 1Gi
  hostPath:
    path: /opt/volume/nginx
```


```yaml
#pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: log-claim
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 200Mi
```

- How PV and PVC is matched? (read [doc](https://kubernetes.io/docs/concepts/storage/persistent-volumes/))
- the pvc was bounded but a misleading error

create a pod

```bash
kubectl run --image=nginx:alpine logger --dry-run=client -o yaml > pod.yaml
```

```yaml
# pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: logger
spec:
  containers:
  - image: nginx:alpine
    name: logger
    volumeMounts:
      - mountPath: "/var/www/nginx"
        name: log
  volumes:
    - name: log
      persistentVolumeClaim:
        claimName: log-claim
```

#### follow ups

1. how to pv and pvc binding works?
2. what are the methods to tell which pv to use by a pvc?

---

- [x] Task 2 - fix network policy

There are 2 pods - `webapp-color` and `secure-pod` and a service `secure-service`. Troubleshoot why incoming connections to `webapp-color` are not successful.  

```bash
# get to pod`s container shell
# and try the connection to secure-pod (via secure-service)
kubectl exec -it pods/webapp-color -- sh
wget http://secure-service
```

There is a network policy denying all Ingress traffic for all Pods within the namespace

```yaml
# kubectl get networkpolicies.networking.k8s.io --output yaml
# An empty selector matches all pods in the policy's namespace.

apiVersion: v1
items:
- apiVersion: networking.k8s.io/v1
  kind: NetworkPolicy
  metadata:
    creationTimestamp: "2026-01-05T12:31:09Z"
    generation: 1
    name: default-deny
    namespace: default
    resourceVersion: "4288"
    uid: f573c821-120c-40cd-835d-0053c4d5b27a
  spec:
    podSelector: {}
    policyTypes:
    - Ingress
kind: List
metadata:
  resourceVersion: ""
```

```bash
# get pod labels (for referencing in new policy)
kubectl get pods --show-labels
```

```yaml
# export the exxisting deny-all polic to a file
kubectl get netpol default-deny -o yaml > netpol.yaml

# update:
spec:
  podSelector:
    matchLabels:
	  - run: secure-pod
  policyTypes:
  - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              name: webapp-color
      ports:
        - protocol: TCP
          port: 80
```
---

- [x] Task 3 - create a pod running a command in a namespace

```bash
# pod with namespce
kubectl run time-check --image=busybox --dry-run=client --output yaml

# set namespace
kubectl config set-context --current --namespace dvl1987

# configmap
kubectl create configmap time-config --dry-run=client -o yaml --from-literal=TIME_FREQ=10

# volume for pod
# https://kubernetes.io/docs/concepts/storage/volumes/#emptydir
# https://kubernetes.io/docs/concepts/storage/volumes/#emptydir-configuration-example
```

```yaml
# full solution
apiVersion: v1
kind: Namespace
metadata:
  name: dvl1987
---
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: time-check
  name: time-check
  namespace: dvl1987
spec:
  containers:
  - image: busybox
    name: time-check
    command: ['sh', '-c', 'while true; do date; sleep $TIME_FREQ; done > /opt/time/time-check.log' ]
    envFrom:
      - configMapRef: 
          name: time-config
    volumeMounts:
    - mountPath: /opt/time
      name: time-volume
  volumes:
  - name: time-volume
    emptyDir:
---
apiVersion: v1
data:
  TIME_FREQ: "10"
kind: ConfigMap
metadata:
  name: time-config
```


- no need to create a PV
- use volume of type `emtpyDir` defined on the containers level and mount it
- `emptyDir` - lives as long as the Pod lives
- maybe not needed to put all in a yaml file (_declarative_ approach) E.g. creating a namespace and configMap via _imperative_ approach

---

- [x] Task 4 - Deployment with 4 replicas and rollback to a previous version

```bash
# base deployment
ubectl create deployment nginx-deploy --image=nginx:1.16 --replicas=4 --dry-run=cl
ient -oyaml
```


```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx-deploy
  name: nginx-deploy
spec:
  replicas: 4
  selector:
    matchLabels:
      app: nginx-deploy
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 2
  template:
    metadata:
      labels:
        app: nginx-deploy
    spec:
      containers:
      - image: nginx:1.16
        name: nginx
```


```bash
# update the image to 1.17
# a) by changing the deployement yaml file and apply (declaratove)
# b) via "set" (imperative)
kubectl set image deployment nginx-deploy nginx=nginx:1.17
```

```bash
# Rollback to the previous deployment
kubectl rollout undo deployment/nginx-deploy 
```

---

- [ ] Task 5 - Create a Redis Deployment


```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: redis
  name: redis
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis
  strategy: {}
  template:
    metadata:
      labels:
        app: redis
    spec:
      volumes:
        - emptyDir: {}
          name: data
      containers:
      - image: redis:alpine
        name: redis
        resources:
          requests:
            cpu: 200m
        ports:
          - containerPort: 6379
        volumeMounts:
          - name: data
            mountPath: /redis-master-data
        envFrom:
          - configMapRef: 
              name: redis-config
```

that seems OK but validation fails on that, their solution:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: redis
  name: redis
spec:
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      volumes:
      - name: data
        emptyDir: {}
      - name: redis-config
        configMap:
          name: redis-config
      containers:
      - image: redis:alpine
        name: redis
        volumeMounts:
        - mountPath: /redis-master-data
          name: data
        - mountPath: /redis-master
          name: redis-config
        ports:
        - containerPort: 6379
        resources:
          requests:
            cpu: "0.2"
```

Follow up

- [ ] diff between `envFrom` and `configMap` as volume

### Lightning lab 2

- [x] https://uklabs.kodekloud.com/topic/lightning-lab-2-2/



- [x] Task 1 - list pods across namespaces, identify the one not in ready state and troubleshoot, then add a probe


```bash
# switch to desired namespace
kubectl config set-context --current --namespace dev1401

# identify what's wrong
kubectl describe pod/nginx1401

  Warning  Unhealthy  61s (x36 over 6m9s)  kubelet            Readiness probe failed: Get "http://172.17.1.4:8080/": dial tcp 172.17.1.4:8080: connect: connection refused
  
  
# fix
kubectl edit pod/nginx1401

# save to a file, delete old pod and crete a new one
kubectl apply -f /tmp/kubectl-edit-3177094624.yaml 


# create livenessProbe
```

```yaml
livenessProbe:
      exec:
        command:
          - "ls"
          - "/var/www/html/file_check"
      initialDelaySeconds: 10
      periodSeconds: 60
      
      
# other syntax
# command: ["ls", "/var/www/html/file_check"]
```

#### Probes

https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes

- `livenessProbe` - is it alive? Restart if not
- `readinessProbe` - remove container from service endpoints

---

- [x] Task 2 - Create a cronjob

https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: dice
spec:
  concurrencyPolicy: Forbid
  schedule: '*/1 * * * *'
  jobTemplate:
    metadata:
      name: dice
    spec:
      backoffLimit: 25
	  activeDeadlineSeconds: 20
      template:
        spec:
          containers:
          - image: kodekloud/throw-dice
            name: dice
          restartPolicy: Never
```

follow up:

- `activeDeadlineSeconds` - 
- `backoffLimit` - 
- `restartPolicy` -

---

- [x] Task 3 - create a busybox pod which sleeps for 3600, mount existing secret, schedule to controlplane node only

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: my-busybox
  name: my-busybox
  namespace: dev2406
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
            - key: node-role.kubernetes.io/control-plane
              operator: Exists
  volumes:
    - name: secret-volume
      secret:
        secretName: dotfile-secret
  containers:
  - image: busybox
    name: my-busybox
    command: ["sh", "-c", "sleep"]
    args: ["3600"]
    volumeMounts:
    - name: secret-volume
      readOnly: true
      mountPath: "/etc/secret-volume"
```

---

- [x] Task 4 - ingress resource to route HTTP traffic to multiple hostnames

? is it fanout? https://kubernetes.io/docs/concepts/services-networking/ingress/#simple-fanout

```bash
# apperels-service & video-service
controlplane ~ ➜  kubectl get service
NAME               TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
apparels-service   ClusterIP   172.20.196.171   <none>        8080/TCP   76s
kubernetes         ClusterIP   172.20.0.1       <none>        443/TCP    16m
video-service      ClusterIP   172.20.134.196   <none>        8080/TCP   76s
```

- `video-service` should be accessible on `http://watch.ecom-store.com:30093/video`
- `apperels-service` should be accessible on `http://apparels.ecom-store.com:30093/wear`


video service

```bash
kubectl describe service video-service 
Name:                     video-service
Namespace:                default
Labels:                   <none>
Annotations:              <none>
Selector:                 app=webapp-video
Type:                     ClusterIP
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       172.20.134.196
IPs:                      172.20.134.196
Port:                     <unset>  8080/TCP
TargetPort:               8080/TCP
Endpoints:                172.17.0.8:8080
Session Affinity:         None
Internal Traffic Policy:  Cluster
Events:                   <none>
```

wear service

```bash
kubectl describe service apparels-service 
Name:                     apparels-service
Namespace:                default
Labels:                   <none>
Annotations:              <none>
Selector:                 app=webapp-apparels
Type:                     ClusterIP
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       172.20.196.171
IPs:                      172.20.196.171
Port:                     <unset>  8080/TCP
TargetPort:               8080/TCP
Endpoints:                172.17.0.9:8080
Session Affinity:         None
Internal Traffic Policy:  Cluster
Events:                   <none>
```



```bash
# generate the base yaml
kubectl create ingress ingress-vh-routing --rule=watch.ecom-store.com/video=video-service:30093 --rule=apparels.ecom-store.com/wear=apperels-service:30093 --dry-run=client -oyaml
```

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-vh-routing
spec:
  rules:
  - host: watch.ecom-store.com
    http:
      paths:
      - backend:
          service:
            name: video-service
            port:
              number: 30093
        path: /video
        pathType: Exact
  - host: apparels.ecom-store.com
    http:
      paths:
      - backend:
          service:
            name: apperels-service
            port:
              number: 30093
        path: /wear
        pathType: Exact
status:
  loadBalancer: {}
```


Ingress frequently uses annotations:

https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/

```bash
kubectl explain ingress.metadata.annotations
GROUP:      networking.k8s.io
KIND:       Ingress
VERSION:    v1

FIELD: annotations <map[string]string>


DESCRIPTION:
    Annotations is an unstructured key value map stored with a resource that may
    be set by external tools to store and retrieve arbitrary metadata. They are
    not queryable and should be preserved when modifying objects. More info:
    https://ku
```

```yaml
"metadata": {
  "annotations": {
    "key1" : "value1",
    "key2" : "value2"
  }
}
```

Final ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-vh-routing
  annotations: 
     nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: watch.ecom-store.com
    http:
      paths:
      - backend:
          service:
            name: video-service
            port:
              number: 8080
        path: /video
        pathType: Prefix
  - host: apparels.ecom-store.com
    http:
      paths:
      - backend:
          service:
            name: apparels-service
            port:
              number: 8080 
        path: /wear
        pathType: Prefix
status:
  loadBalancer: {}
```

---

- [x] Task 5 - Redirect warnings to file

```bash
# see the pod runs 3 containers

kubectl get pods dev-pod-dind-878516 
NAME                  READY   STATUS    RESTARTS   AGE
dev-pod-dind-878516   3/3     Running   0          2m59s

# details in
kubectl describe pods dev-pod-dind-878516 

# inspect logs of a specific container of the pod
kubectl logs pods/dev-pod-dind-878516 -c log-x

# log WARNINGS to a file
kubectl logs pods/dev-pod-dind-878516 -c log-x | grep WARNING > /opt/dind-878516_logs.txt
```