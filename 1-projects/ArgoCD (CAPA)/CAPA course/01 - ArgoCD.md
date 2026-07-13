
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

