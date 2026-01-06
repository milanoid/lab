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

### Lightning lab 2

- [ ] https://uklabs.kodekloud.com/topic/lightning-lab-2-2/




