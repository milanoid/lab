Persistent Volume (PV) 
- piece of storage provisioned by admin or dynamically using Storage Classes

Persistent Volume Claim (PVC) 
- a request for storage by a user
- as a Pod consume node resources, PVC consumes PV resources
- PVC claims size and access mode

Task - add a PV to Mealie appp

Using files

- _service.yaml_
- _deployment.yaml_
- _namespace.yaml_
- _storage.yaml_  <- needs to be created


```yaml
# storage.yaml
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

- `kubectl apply --filename storage.yaml`

Then:
```bash
kubectl get persistentvolumeclaims
NAME          STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
mealie-data   Pending                                      local-path     <unset>                 29s
```

But:

```bash
kubectl get persistentvolume
No resources found
```
- because we have created a PVC but not yet the PV from where we can claim a space
- we need to update the _deployment_ and attach the volume there:

Once _deployment.yaml_ updated with volumes redeploy: `kubectl apply --filename deployment.yaml`.

before - PVC is Pending:
```bash
kubectl get pvc
NAME          STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
mealie-data   Pending                                      local-path     <unset>                 16m
```
after - PVC is bound:

```bash
kubectl get pvc
NAME          STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
mealie-data   Bound    pvc-37bde5cf-5d3b-4539-81e1-75be13310ba8   500Mi      RWO            local-path     <unset>                 18m
```

also `pods describe` says:

```yaml
Volumes:
  mealie-data:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  mealie-data
    ReadOnly:   false
``` 
Since now any data written by container to `/app/data` will be persistent, they will survive the Pod/Deployment deletion and recreation.

### Where from the Kubernetes provision the storage?

STORAGECLASS = local-path

```bash
kubectl get storageclasses.storage.k8s.io
NAME                   PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
local-path (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  8d
```

various storage classes (for VMWare, Azure ...)


### modes

ReadWriteOnce - R/W but one the same Node only
ReadWriteMany - R/W for all Nodes