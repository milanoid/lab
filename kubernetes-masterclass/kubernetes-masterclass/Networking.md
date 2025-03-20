## Introduction to Kubernetes Networking


#### Pods

list pods including IPs
`k get pods -A -o wide`

- each pod has its own IP address
- each pod can be default communicate with other pods on all nodes
- each container within a pod can communicate with other containers through `localhost`

#### CNI Plugin

Container Networking Interface

- provides networking connectivity to containers
- asigness IP addresses and set ups routes -> IP Tables on nodes
- Implemented by CNI Plugins `Cilium`, `Calico`, `Flannel`

##### Finding out what CNI is used in Rancher Desktop

`rdctl` - Rancher Desktop `ctl`

`rdctl shell bash` - connects to Rancher Desktop VM shell

```
/etc/cni $ tree
.
└── net.d
    └── 10-flannel.conflist

1 directories, 1 files
```


## Services

- offers a consistent address to access a set of pods

### Why we need services

- Pods are ephemeral
- Pods are constantly changing and moved across nodes
- Service is grouping pods (E.g. grouping like `database`, `backend`, `frontend` etc.)

`k get services`

`k get services -o wide`

#### Creating a new service

Usually via code, but there is also an `expose` command.

`k expose --help | less`

`k expose deployment frontend --port 8080`

#### Types of services

- ClusterIP - default
- NodePort
- LoadBalancer - for cloud providers (EKS)

#### Exposing Mealie app

##### Exposing deployment and port forwarding on service level 

`k expose deployment mealie --port 9000`
`k port-forward services/mealie 9000`

##### Exposing via code

`k get service mealie -o yaml > service.yaml`



## Ingress
