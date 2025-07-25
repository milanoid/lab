
### create a deployment

- `deployement` has alias `deploy`
- by default it creates 1 replica
```bash
milan@jantar:~$ kubectl create deployment test --image=httpd --replicas=3
```

### get deployment

```bash
milan@jantar:~$ kubectl get deployments.apps
NAME   READY   UP-TO-DATE   AVAILABLE   AGE
test   3/3     3            3           6m3s
```

### describe deployment

- outputs deployment description in human readable format
- read only, for troubleshooting, checking status and viewing events
```bash
milan@jantar:~$ kubectl describe deployments.apps test
```

### edit deployment

- opens yaml (or json) resource definition in default editor
- actual Kubernetes API object specification
- for making changes to existing resource
- applies changes on save

```bash
milan@jantar:~$ kubectl edit deployments.apps test
```

### delete deployment

- deletes the deployment with its underlying resources (pods and others)

```bash
milan@jantar:~$ kubectl delete deployments.apps test
deployment.apps "test" deleted
```
## create a deployment from code

1. generate the yaml config using `--dry-run=client --output yaml` flags
2. make modifications, git
3. apply the deployment using the yaml file

```bash
# generate yaml for deployment
milan@jantar:~/repos/lab (main)$ kubectl create deployment test --image=httpd --replicas=3 --dry-run=client --output yaml > deploy.yaml
```
- `deploy.yaml` in [[Kubernetes Fundamentels - Part 2 - Deployments]]

```bash
kubectl apply -f deploy.yaml
deployment.apps/test created
```

#### Replica set

- basic scaling and self-healing
- no update strategy
- resource should not be managed by users

Deployment -> Replica Set -> Pods

deployment adds:
- rolling updates and rollbacks
- update strategies (RollingUpdate, Recreate)
- revision history
- declarative updates

```bash
kubectl get replicasets.apps
NAME              DESIRED   CURRENT   READY   AGE
test-6546ccdcf9   3         3         3       4h49m
```

tip: pipe the documentation to vim:

- note the trailing dash character
```bash
kubectl create deployment -h | nvim -
```


#### Strategy

- specifies the strategy to replace old Pods with new ones
- _Recreate_ (all get killed first) vs _RollingUpdate_ (one by one)

tip: use `watch` command to monitor the strategy in action

```bash
# teminal 1 - watch
watch kubectl get pods
```

```bash
# terminal 2 - trigger the update strategy
kubectl apply --filename deploy.yaml
deployment.apps/test configured
# in case of no chaange detected:
# deployment.apps/test unchanged
```

##### Rolling Update

- `maxUnavailable: 1` - how many Pods can be terminated from the value set in `replicas`
- `maxSurge: 1` - how many extra Pods can be created over the value set in `replicas`
