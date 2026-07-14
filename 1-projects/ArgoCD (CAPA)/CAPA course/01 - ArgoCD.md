
# What is ArgoCD?

- a declarative, GitOps CD tool for Kuberenetes


### Key advantages

- Gitops
- CD - no need to for `kubectl apply` run manually
- Rollbacks - easy rollback if the new change goes "south"
- Multi-environment management - Dev, Stage, Prod, you name it
- UI and API


### ArgoCD Vocabulary

#### Configuration

- _CRD - Custom Resource Definition_ - a collection of K8s resources, primary interface for managing sw deployment by Argo CD
- _Application source type_ - Helm or Kustomize

#### States

- _Target State_ - the desired state, represented in a Git repo, serving as the source of truth
- _Live State_ - the current state of the application, indicating the deployed K8s resources

#### Statuses

- _Sync status_ - whether the live state aligns with the target state
- _Sync operation status_ -  status of the sync phase, failed or succeeded
- _Health status_ - well-being of the application

#### Actions

- _Refresh_ - act of comparing latest code in Git with the live state to identify any diffs
- _Sync_ - process of transitioning an application to the target state by applying changes in the K8s cluster

### Core Components

Controllers
- from Robotics - a control loop that keeps system in a desired state
- In K8s a Controller tracks 1 or more resource types, in K8s there is a Job controller

API Server
- central watch tower, enables Web UI, CLI, Events and CI/CD to interact with it
- other responsibilities - handles Git repo and K8s clusters
- also for authentication and SSO support
- enforces RBAC (Role-Based Access Control)

Repository Server
- connected to API server
- retrieves the desired state, packages it to a format K8s understands
- maintain a local git cache holding the application manifest


Application Controller
- compares the desired state of the application with the live state

![[Pasted image 20260714083448.png]]

### How Does the Argo CD Reconciliation Loop Work?

- loop known as [reconciling loop](https://argo-cd.readthedocs.io/en/stable/proposals/applicationset-plugin-generator/#reconciliation-logic)



![[Pasted image 20260714083634.png]]

With Helm
- monitors Git, employs Helm to generate Kubernetes manifest YAML through template execution
- if diff is detected (desired vs live state) `kubectl apply` is run (no `helm install`!)


### Synchronization Principles

- a customizable operation by using a _resource hooks_ and _sync waves_


#### Resource Hooks

5 definitions of when a resource hook can be run:

- _PreSync_ (e.g. create a backup before syncing)
- _Sync_
- _PostSync_ (e.g. run additional health checks after deployment)
- _Skip_
- _SyncFail_ (execute when _Sync_ fails)

Resource Hooks use the K8s kind _Job_ and are identified by an annotation. Official Doc https://argo-cd.readthedocs.io/en/stable/user-guide/sync-waves/


The following is an example for a database schema migration resource hook:

```yaml
apiVersion: batch/v1  
kind: Job  
metadata:  
  generateName: schema-migrate
  annotations:  
    argocd.argoproj.io/hook: PreSync
```


#### Sync Waves

- way to split and order to-be-synced manifests
- default wave 0

```yaml
metadata:  
  annotations:  
    argocd.argoproj.io/sync-wave: "5"
```


Both (RH and Waves) can be used simultaneously.

- by default 2 seconds delay between waves
- **ARGOCD_SYNC_WAVE_DELAY** - can be customized


### Simplifying Application Management

Argo CD simplifies the management of your applications in Kubernetes environments by utilizing Custom Resource Definitions (CRDs).

Key elements

- Application - ArgoCD CRD _Application_
- AppProject -  grouping apps
- Repository credentials - K8s secrets and ConfigMaps for accessing private Git repos
- Cluster credentials - when managing multiple K8s clusters



### Plugins

E.g. Notification plugin

- plugins are configured via _ConfigMap_


```yaml
apiVersion: v1  
kind: ConfigMap  
metadata:  
  name: argocd-notifications-cm  
data:  
  context: |  
    region: east  
    environmentName: staging

  template.a-slack-template-with-context: |  
    message: "Something happened in {{ .context.environmentName }} in the {{ .context.region }} data center!"
```

Plugins have a lifecycle (registration, init, execution)


Other plugins example

- [Image Updater Plugin](https://argocd-image-updater.readthedocs.io/en/stable/) (no need for Renovate to do that?)
- [ArgoCD Autopilot](https://github.com/argoproj-labs/argocd-autopilot) - management of Helm releases
- [ArgoCD Interlace](https://github.com/argoproj-labs/argocd-interlace) - extras for UI



### Securing Argo CD

- User RBAC - define roles in `argocd-rbac-cm` ConfigMap
	- assign roles to users or groups through _RoleBindings_ or _ClusterRoleBindings_

- Manage Secrets Securely
	- must not be exposed or logged
	- encryption at rest and in transit

- Regularly Update Argo CD


### Enhancing Deployment Efficiency with Helm and Kustomize

Helm - templating and package management
Kustomize - adds customization layer to deployments w/o changing base manifest


# Lab Exercise - install ArgoCD

- [x] done on Homelab
- [x] Rancher Desktop
- [ ] Ingress in RD ArgoCD so I don't have to do port-forward all the time


```bash
# namespace
kubectl create namespace argocd

# quick start manifest
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# check
kubectl get pods -n argocd
NAME                                              READY   STATUS    RESTARTS   AGE
argocd-application-controller-0                   1/1     Running   0          32s
argocd-applicationset-controller-8998bf8d-sqnkd   1/1     Running   0          32s
argocd-dex-server-755d44cc-hkrwj                  1/1     Running   0          32s
argocd-notifications-controller-c668fd67c-7n675   1/1     Running   0          32s
argocd-redis-78d7dccb7f-6rqfg                     1/1     Running   0          32s
argocd-repo-server-585ccc7645-v4fm5               1/1     Running   0          32s
argocd-server-57455cb49d-z6xcf                    1/1     Running   0          32s
```


### Accessing ArgoCD

#### UI

```bash
kubectl port-forward -n argocd svc/argocd-server 8080:443 --address 0.0.0.0
```

- build in admin user wth autogenerated password

```bash
# get pass
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

https://localhost:8080/


#### CLI

```bash
# login
argocd login localhost:8080 --username admin --password <pass>


# query
argocd cluster list
SERVER                          NAME        VERSION  STATUS   MESSAGE                                                  PROJECT
https://kubernetes.default.svc  in-cluster  1.31.5   Unknown  Cluster has no applications and is not being monitored.
```

cli access config in `~/.config/argocd/config`



##### extra - ingress

- set default ns `kubectl config set-context --current --namespace argocd`

```yaml
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd
spec:
  ingressClassName: traefik
  rules:
    # to be accessed from LAN/VPN only
    - host: capa-argocd.milanoid.net  # subdomain of my cloudflare domain
      http:
        paths:
          - backend:
              service:
                name: argocd-server
                port:
                  number: 80
            path: /
            pathType: Prefix
```