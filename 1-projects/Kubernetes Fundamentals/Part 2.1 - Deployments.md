
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