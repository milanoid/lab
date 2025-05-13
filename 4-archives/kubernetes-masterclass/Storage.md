## Ephemeral Storage


`k describe pod mealie-6d9455c57-tdwkc`

```
Volumes:
  kube-api-access-kmblg:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
```

### EmptyDir
- `nginx-pod.yaml`
- https://kubernetes.io/docs/concepts/storage/volumes/#emptydir

switching into a container
`k exec -it nginx-storage -- bash`

switching to a specific container (for multi container pods)

- use `-c`

`k exec -it nginx-storage -c nginx -- bash`

Understanding the syntax errors

`k apply -f nginx-pod.yaml
```
Error from server (BadRequest): error when creating "nginx-pod.yaml": Pod in version "v1" cannot be handled as a Pod: strict decoding error: unknown field "spec.containers[0].arg"
```
https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#Container

## Persistent Storage

### Persistent volumes vs persistent volume claims

https://kubernetes.io/docs/concepts/storage/persistent-volumes/

Persistent volume - a huge HDD
Persistent claim - just a part of the HDD

#### create a PersistentVolumeClaim aka `pvc`
```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mealie-data
  namespace: mealie
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
```

`k apply -f storage.yaml`

`k get persistentvolumeclaims mealie-data`

```
NAME          STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
mealie-data   Pending                                      local-path     <unset>                 90s
```

- It is Pending because we have not attached it to our pod yet.

`k get pvc`

#### attach a PersistentVolumeClaim

- to have the status `Bound` and actually used by the pod we need to attach it:

```
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: mealie
  name: mealie
  namespace: mealie
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mealie
  template:
    metadata:
      labels:
        app: mealie
    spec:
      containers:
      - image: ghcr.io/mealie-recipes/mealie:v2.7.1
        name: mealie
        ports:
          - containerPort: 9000
        volumeMounts:
          - mountPath: /app/data
            name: mealie-data
      volumes:
        - name: mealie-data
          persistentVolumeClaim:
            claimName: mealie-data
```

#### Storage classes

`k get storageclasses.storage.k8s.io`

https://kubernetes.io/docs/concepts/storage/storage-classes/

- `local-path`

#### Access modes

https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes