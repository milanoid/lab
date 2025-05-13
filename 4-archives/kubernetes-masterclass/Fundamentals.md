
### What is Kubernetes and Why do we need it
1. Kubernetes is the Operating System of the Cloud
2. Bunch of VMs, who are able to communicate with each other and to divide their workload

### Terminology

- Worker Node - VM running containers
- Control Plane

## Pods introduction

 - a pod is smallest element on Kubernetes cluster
 - a pod is not a single docker container, it is more than that
 - a pod can run one or more containers

_Initcontainer_ - e.g. a check of database access, if there is no access fail the pod

```
kubectl config current-context
kubectl config use-context rancher-desktop
kubectl get pods
kubectl get pods --all-namespaces
kubectl get namespaces
kubectl describe pod
kubectl get pods -o wide
```
#### Running a first pod in Kubernetes

```
kubectl run --help
k explain pods
k run nginx --image=nginx
k run httpd --image=httpd
```
## Pods as Code - YAML

pod manifest (yaml file)
```
k get pods nginx -o yaml
k edit pod nginx
```
Should not be edited manually, usually.

### creating a pod by crafting a YAML file

dry-run of run command and outputting as a yaml

```
k run nginx-yaml --image=nginx --dry-run=client -o yaml
k run nginx-yaml --image=nginx --dry-run=client -o yaml > nginx.yaml
```

`create` vs `apply`
- `create` - only creates a pod
- `apply` - also detects changes and modify

```
k apply -f nginx.yaml
```

### creating YAML from docs

- documentation on pods https://kubernetes.io/docs/concepts/workloads/pods/
- in VIM `:set paste` to keep indentation when copying from the docs (works for me out of the box)
## Interacting with pods

```
k get pods -o wide
k delete pod httpd
k exec -it nginx-docs -- /bin/bash # get into the shell of the container
```