## Theory

 [_Kubernetes_](https://en.wikipedia.org/wiki/Kubernetes) also known as _K8s_ - from Greek:
 
 - "governor" - guverner
 - "helmsman" - kormidelnik
 - "pilot" - pilot

Story

1. originally a group of VMs each running 1 or 2 applications
2. ~ 2013 - start of containerization using Docker, each VM running a few Docker containers - less maintenance as less VMs were used
3. multiple VMs (each with multiple docker containers), provisioned by [Ansible](https://docs.ansible.com/ansible/latest/index.html)
4. a loadbalancer ([HAPROXY](https://www.haproxy.org/)) sitting in front of all VMs and routing traffic to containers

![[Pasted image 20250608183559.png]]

### Kubernetes

- solves the problem of having so many VMs and containers
- operating system of Cloud
- bunch of VMs communication each other
- instead of HAPROXY it has _Control Plane_
- VM -> is now _worker node_


#### Kubernetes Terminology

- Cluster - a group of Nodes with Control Plane
- Node - a group of one or more Pods
- Pod - a group of one or more Containers
- Control Plane
- Control Plane - Scheduler
- Control Plane - API Server
- Namespace
- Context