# Labels, Selectors and Annotations


- L. and S. used to group and select object
- once label assigned we can filter, e.g. `kubectl get pods --selector app=App1`

```bash
# get all object matching a selector

kubectl get all  --selector env=dev
NAME              READY   STATUS    RESTARTS   AGE
pod/app-1-d69fw   1/1     Running   0          99s
pod/app-1-pvhd8   1/1     Running   0          99s
pod/app-1-tshrq   1/1     Running   0          99s
pod/db-1-mxh5j    1/1     Running   0          99s
pod/db-1-n4dm5    1/1     Running   0          99s
pod/db-1-v8nc2    1/1     Running   0          99s
pod/db-1-xrxhd    1/1     Running   0          99s

NAME                    DESIRED   CURRENT   READY   AGE
replicaset.apps/app-1   3         3         3       99s
replicaset.apps/db-1    4         4         4       99s
```


```bash
kubectl get pods --selector env=prod --selector bu=fi
nance --selector tier=frontend
NAME          READY   STATUS    RESTARTS   AGE
app-1-d69fw   1/1     Running   0          3m10s
app-1-pvhd8   1/1     Running   0          3m10s
app-1-tshrq   1/1     Running   0          3m10s
app-1-zzxdf   1/1     Running   0          3m10s
app-2-s4hjq   1/1     Running   0          3m10s
```

Annotations - to record other details (e.g. contact, build number etc.)


# Rolling Updates & Rollbacks in Deployments

`kubectl rollout status deployment/my-app-deployment`


```bash
# get rollout history

kubectl rollout history deployment --namespace downloaders
deployment.apps/bazarr
REVISION  CHANGE-CAUSE
1         <none>
2         <none>

deployment.apps/prowlarr
REVISION  CHANGE-CAUSE
1         <none>
2         <none>

deployment.apps/radarr
REVISION  CHANGE-CAUSE
1         <none>
2         <none>

deployment.apps/sonarr
REVISION  CHANGE-CAUSE
1         <none>
2         <none>

deployment.apps/torrent-client
REVISION  CHANGE-CAUSE
1         <none>
2         <none>
3         <none>


# get by revision
kubectl rollout history deployment nginx --revision=1
```

Deployment Strategies

1. destroy existing ones before starting the new -> _Recreate_
2. destroy and start a new one one by one -> _RollingUpdate_ (default)

How to upgrade:

1. `kubect apply -f`
2. `kubectl set image deployment/my-app nginx=nginx:1.9.1`

```bash
kubectl get replicasets.apps --namespace downloaders
NAME                        DESIRED   CURRENT   READY   AGE
bazarr-6c4dcc6db8           1         1         1       12d
bazarr-8d9bcd744            0         0         0       12d
prowlarr-6675f87cdf         0         0         0       12d
prowlarr-b667bf985          1         1         1       12d
radarr-5c785788c            0         0         0       12d
radarr-d44fb4744            1         1         1       12d
sonarr-64df6f54d7           0         0         0       12d
sonarr-6c8bb8c585           1         1         1       12d
torrent-client-6d96657cbd   1         1         1       38h
torrent-client-8577d648d6   0         0         0       12d
torrent-client-f9885444d    0         0         0       12d
```

How to rollback

`kubectl rollout undo deployment my-app-deployment`

# Deployment Strategy - Blue Green

- old - blue
- new - green

New (green) is deployed but 100 % traffic is still routed to old (blue) until all tests pass. Then we switch to new (green). Best with service mesh like [Istio](https://istio.io/latest/about/service-mesh/).

In practice

- Uses `labels` and `selector` to distinguish green vs blue
- Service exposes the blue deployment
- after tests on green pass, we can re-route the Service to green by changing the `seletor`

# Deployment Strategy - Canary Updates

- small percentage, e.g. 5 % (canary), is deployed and traffic routed to for testing
- if passed - raise the ratio to 100 %

In practice

- Service binded to both deployments (canary and primary)
- only 5 % is routed to canary
- uses common label - e.g. `app:front-end` (so it routes it equally 50/50)
- uses `version: v1` (primary) and `version: v2` (canary)
- 50/50 -> 5/100 can be achieved by reducing the number of canary pods

There is a limited way how to achieve this with pure Kubernetes. So there are specialized services - e.g. [Istion](https://istio.io/latest/about/service-mesh/
) mesh.


# Jobs

Types of Workloads

- web app
- database
- ... these are meant to run all the time

but there are other workloads (analytics, batch processing ... ) meant to run a task (job) and then finish -> `Jobs`

### In Docker/Podman

```bash
podman run ubuntu expr 3 + 2
5

podman ps -a | grep "expr"
d694daa86f82  docker.io/library/ubuntu:latest                                   expr 3 + 2            About a minute ago  Exited (0) About a minute ago              amazing_archimedes
```
- container stops after finishing the task
- not the `Exited (0)` status

### In Kubernetes

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: math-pod
spec:
  containers:
  - name: math-add
    image: ubuntu
    command: ['expr`, `3`, `+`, `2`]
```

or `kubectl run math-pod --image=ubuntu --command -- expr 3 + 2`

- that would restart the pod as it goes to `Completed` state
- Kubernetes tries to recreate it again and again:
  
```
Events:
  Type     Reason     Age                 From               Message
  ----     ------     ----                ----               -------
  Normal   Scheduled  112s                default-scheduler  Successfully assigned homarr/math-pod to hpmini02
  Normal   Pulled     111s                kubelet            Successfully pulled image "ubuntu" in 910ms (910ms including waiting). Image size: 29734095 bytes.
  Normal   Pulled     109s                kubelet            Successfully pulled image "ubuntu" in 921ms (921ms including waiting). Image size: 29734095 bytes.
  Normal   Pulled     93s                 kubelet            Successfully pulled image "ubuntu" in 867ms (867ms including waiting). Image size: 29734095 bytes.
  Normal   Pulled     64s                 kubelet            Successfully pulled image "ubuntu" in 923ms (923ms including waiting). Image size: 29734095 bytes.
  Normal   Pulling    21s (x5 over 111s)  kubelet            Pulling image "ubuntu"
  Normal   Created    20s (x5 over 110s)  kubelet            Created container: math-pod
  Normal   Pulled     20s                 kubelet            Successfully pulled image "ubuntu" in 929ms (929ms including waiting). Image size: 29734095 bytes.
  Normal   Started    19s (x5 over 110s)  kubelet            Started container math-pod
  Warning  BackOff    4s (x9 over 108s)   kubelet            Back-off restarting failed container math-pod in pod math-pod_homarr(c5b2dd6a-d8ac-4e2c-9c6e-e191b4513258)
```

`Job` - is set to run a set of Pods to done a task

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: math-add-job
spec:
  completions: 3
  template:
    spec:
      containers:
        - name: math-add
          image: ubuntu
          command: ['expr', '3', '+', '2']
      restartPolicy: Never
```

- 3 pods are created sequentially
- can be set to run in parallel - `parallelism: 3`

```bash
kubectl logs jobs/math-add-job
5

# delete - deletes job AND 3 pods created to run the job (completions: 3)
kubectl delete jobs.batch math-add-job
job.batch "math-add-job" deleted
```

# CronJobs

Job - runs instantly 
CronJob - on schedule 

```yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: reporting-cron-job
spec:
  schedule: "*/1 * * * *"
  jobTemplate:
    spec:
	  completions: 3
	  template:
	    spec:
	      containers:
	        - name: math-add
	          image: ubuntu
	          command: ['expr', '3', '+', '2']
	      restartPolicy: Never
```