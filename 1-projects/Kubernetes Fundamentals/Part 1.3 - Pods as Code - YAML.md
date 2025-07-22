### Get (Pod) manifest

Print the definition of a running pod in a format (can do more than just yaml) also called (Pod) manifest.
```bash
kubectl get pods --output yaml
```

### Edit (Pod) manifest

Edit the pod definition
```bash
# opens the default editor
kubectl edit pods/nginx
```
- one can edit resources on cluster
- not recommended but required in exam

### Creating yaml manifest from scratch

Options
- using an example definition and do adjustment
- running `kubectl get pods/nginx -o yaml` (verbose)
- using `kubectl run` with `dry-run` option to generate the base manifest

```bash
kubectl run nginx-yaml --image=nginx --dry-run=client -o yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx-yaml
  name: nginx-yaml
spec:
  containers:
  - image: nginx
    name: nginx-yaml
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```

```bash
# generate and update
kubectl run nginx-yaml --image=nginx --dry-run=client -o yaml > nginx.yaml
...
milan@jantar:$cat nginx.yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: nginx
    mehtod: fromcode
  name: nginx-yaml
spec:
  containers:
  - image: nginx
    name: nginx
```
#### Running the pod using the manifest

1. `create` - only creates
2. `apply` - detects changes

```bash
# at first it says `created` after a modification
# it detects the change and says `configured`
kubectl apply -f nginx.yaml
pod/nginx-yaml configured
```


