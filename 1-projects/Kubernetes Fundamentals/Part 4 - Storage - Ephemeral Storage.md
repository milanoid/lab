### emptyDir

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
  name: nginx-storage
spec:
  containers:
    - image: nginx
      name: nginx
      volumenMounts:
        - mountPath: /scratch
          name: scratch-volume
  volumes:
    - name: scratch-volume
      emptyDir:
        sizeLimit: 500Mi

```

- see file `nginx-pod.yaml`
- the `volumes` is on a pod level -> the volume is attached to a Pod (not to a container in Pod)
- volumes are either created before, or dynamically provisioned
- `emptyDir` - empty directory, ephemeral, gets deleted when Pods gets deleted
- in running Pod the container filesystem will have `/scratch` directory available

- start the pod: `kubectl apply --filename nginx-pod.yaml`
- get into shell of the container in Pod: `kubectl exec -it pods/nginx-storage -- bash`
- and see the file system has `/scratch` directory

Note: the `describe` now shows the `scratch-volume`:

```yaml
Volumes:
  scratch-volume:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:
    SizeLimit:  500Mi
```


#### sharing storage among 2 container in a Pod

