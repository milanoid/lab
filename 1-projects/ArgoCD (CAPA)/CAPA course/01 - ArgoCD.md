
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




