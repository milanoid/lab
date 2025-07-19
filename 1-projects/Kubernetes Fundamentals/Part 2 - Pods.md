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


