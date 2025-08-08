Excercise:

- Try adding a PersistentVolumeClaim to your GitOps configuration with the name linkding-data-pvc.
- Don't specify a storageclass, and use size 1Gi.
- Next, add the persistentVolumeClaim to your Deployment manifest.
- Need a refresh? Check out the storage modules in the Kubernetes Fundamentals course.

Bonus:

- Describe the pod and exec into the container to verify that the storage has been mounted.
---
https://github.com/milanoid/homelab-cluster/pull/1

- but with a lot of typos and merge conflicts
- ? how to try out the changes in PR? Seems the only way is to merge to main :(

---

Mischa tips

- install `kubectx` - a tool for managing contexts

```bash
sudo pacman -S kubectx
```
switching namespace:

`kubens` - for kube-name-space

---
### Configuring Linkding app

```bash
# get the container cmd
kubectl exec -it linkding-9d9796bdd-lj7rm -- bash
# or run the command directly
kubectl exec -it linkding-9d9796bdd-lj7rm -- python manage.py createsuperuser --username=milan --email=milan@example.com
```
LinkDing user: milan

`storage.yaml` file - does not need to configure a storage class, there is only one in K3s:

```yaml
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: linkding-data-pvc
  namespace: linkding
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```


```bash
kubectl get storageclasses.storage.k8s.io
NAME                   PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
local-path (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  6d
```