### What is a pod?

- a smallest deployable unit
- a group of one (or more) containers
- share the same network and storage resources
- ephemeral - they come and go as needed, they get assigned IP dynamically
- a pod is a collection of container(s) + other resources

A nice summary gives the _explain_ command:

```bash
kubectl explain pods

DESCRIPTION:
    Pod is a collection of containers that can run on a host. This resource is
    created by clients and scheduled onto hosts.
```

### Running a pod

```bash
milan@jantar:~/repos$ kubectl run nginx --image=nginx
pod/nginx created
```


#### How does a pod ends up on a node?

API server running at port 6443

```bash
milan@jantar:~$ cat .kube/config
apiVersion: v1
kind: Config
clusters:
  - name: rancher-desktop
    cluster:
      server: https://127.0.0.1:6443
```

API server talks to Scheduler which is responsible for scheduling the pod to a node.
Both API server and Scheduler are part of the Control Plane.

Init container - checks the requirements, e.g. database connection

### describe

Show details of a specific resource or group of resources.

```bash
milan@jantar:~$ kubectl describe pods/nginx
Name:             nginx
Namespace:        default
Priority:         0
Service Account:  default
Node:             lima-rancher-desktop/192.168.5.15
Start Time:       Tue, 22 Jul 2025 10:37:11 +0200
Labels:           run=nginx
Annotations:      <none>
Status:           Running
IP:               10.42.0.9
IPs:
  IP:  10.42.0.9
Containers:
  nginx:
    Container ID:   docker://7ba8d8e99b4d4172d4613ead53752b21ed13fe133c96c571d247102e35125f04
    Image:          nginx
    Image ID:       docker-pullable://nginx@sha256:84ec966e61a8c7846f509da7eb081c55c1d56817448728924a87ab32f12a72fb
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Tue, 22 Jul 2025 10:37:23 +0200
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-ln2g6 (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       True
  ContainersReady             True
  PodScheduled                True
Volumes:
  kube-api-access-ln2g6:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  10m   default-scheduler  Successfully assigned default/nginx to lima-rancher-desktop                      Normal  Pulling    10m   kubelet            Pulling image "nginx"
  Normal  Pulled     10m   kubelet            Successfully pulled image "nginx" in 9.949s (9.949s including waiting). Image size: 192231837 bytes.
  Normal  Created    10m   kubelet            Created container: nginx
  Normal  Started    10m   kubelet            Started container nginx
```

```bash
milan@jantar:~$ kubectl get pods -o wide
NAME    READY   STATUS    RESTARTS   AGE   IP          NODE                   NOMINATED NODE   READINESS GATES
nginx   1/1     Running   0          31m   10.42.0.9   lima-rancher-desktop   <none>           <none>
```

### pause container (also called infrastructure container)

```bash
milan@jantar:~$ docker ps | grep nginx
7ba8d8e99b4d   nginx                        "/docker-entrypoint.…"   17 minutes ago   Up 17 minutes             k8s_nginx_nginx_default_8dd4f629-e0c6-4886-9788-e8ceeaa65f23_0
9ebefe925b71   rancher/mirrored-pause:3.6   "/pause"                 17 minutes ago   Up 17 minutes             k8s_POD_nginx_default_8dd4f629-e0c6-4886-9788-e8ceeaa65f23_0
```

- feature of Kuberentes
- the _pause_ container provides infrastructure for entire Pod
- starts first and stops last
- provides network namespace (owns IP addresses, shares them with containers in Pod)
- manages lifecycle of shared volumes
- uses minimal resources (a few KB in memory)

### Init container

- user defined
- a container starting before container with application
- runs init tasks (could be database migration, configuration setup etc.)