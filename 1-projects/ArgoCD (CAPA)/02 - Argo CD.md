
- example apps https://github.com/argoproj/argocd-example-apps

# The Argo CD Components

In namespace `argocd`

- API Server
	  - UI and `argocd` CLI or gRPC/REST
- Repository Server
	  - interacts with Git Repo, keeps local cache
	- generates final Kubernetes manifest files
- Application Controller
  - monitors desired vs actual state of the application
	- monitors _Lifecycle Hooks_

# Application CRD

- spec https://argo-cd.readthedocs.io/en/stable/user-guide/application-specification/

Main questions it addresses:

- Where the application code is? - `source`
- Where it should be deployed? - `destination`
- How it should be synced? - `syncPolicy`

```yaml
spec: 
	# The project the application belongs to. 
	project: default 
	# Source of the application manifests 
	source: repoURL: https://github.com/argoproj/argocd-example-apps.git # Can point to either a Helm chart repo or a git repo. 
	targetRevision: HEAD # For Helm, this refers to the chart version. 
	path: guestbook # This has no meaning for Helm charts pulled directly from a Helm repo instead of git.
```

- `source` can be Git Repository or [Helm Chart Repository](https://helm.sh/docs/topics/chart_repository/) 
- Helm Chart Repository can be hosted on Nexus



# ConfigMap

- spec https://argo-cd.readthedocs.io/en/stable/operator-manual/argocd-cm-yaml/


As my Argo CD in homelab is installed via a Helm chart the `argocd-cm` is using Helm Chart default values **but** with overrides in [release.yaml](https://github.com/milanoid-labs/homelab-cluster/blob/main/infrastructure/controllers/base/argocd/release.yaml#L26) e.g. the `ui.bannercontent`.



# Sync and Health Status

### Sync status

- Synced - live state matches desired state
- OutOfSync - live state DOES NOT match desired state
- Progressing - undergoing sync operation

They Sync status (green checkmark) is displayed only on components managed directly by Argo CD. E.g. _Service_ and _Deployment_ has a sync status but _ReplicaSet_ does not (as it is managed by _Deployment):

![[Pasted image 20260718205608.png]]

The Sync status doesn't say anything about the health of the application.

### Health status

- Healthy or Degraded 
- checked through probes


#### Argo _tracking-id_ annotation

How does Argo know which manifests are managed by Argo? 

By default through the `tracking-id` annotation:

```yaml
metadata:
	annotations:
		argocd.argoproj.io/tracking-id: guestbook:apps/Deployment:guestbook/guestbook-ui
```

- Kind: _Deployment_
- Namespace: _guestbook_
- Name: _guestbook-ui_

If such annotation is not in the manifest than Argo is not managing it.



# Working with Helm Charts

- does not run `helm install` or `helm upgrade`
- it treats Helm as a template engine, generates the K8s manifest and `kubectl apply`
- uses `helm template` (generates K8s manifests from Helm Chart + Values)


No need for plain Kubernetes manifests (Deployment, Service). These are encapsulated in the Helm Chart. E.g. https://github.com/argoproj/argocd-example-apps/tree/master/helm-guestbook/templates


## Overriding Chart Values

- multiple locations of the Helm Chart Values
	- Chart's own default Values file
	- _Application_ manifest: _valueFiles_ (lowest priority)
	- _Application_ manifest: _values_
	- _Application_ manifest: _valuesObject_
	- _Application_ manifest: _parameters_ (highest priority)

https://argo-cd.readthedocs.io/en/latest/user-guide/helm/#helm-value-precedence


### _valueFiles_
```yaml
# the last one wins
valueFiles: 
  - values-file-2.yaml 
  - values-file-1.yaml 

# In this case, values-file-1.yaml will override values from values-file-2.yaml.
```


- best practice for using a public Helm Charts -> have my own Git repo with my Values


# Deploying Public Helm Charts

- Helm Charts marketplace e.g. Headlamp https://artifacthub.io/packages/helm/headlamp/headlamp
- not a git repo, must use `chart`
```yaml
chart: chart-name  # Set this when pulling directly from a Helm repo. DO NOT set for git-hosted Helm charts.  
```


---

# Advanced Sync and Automation

- https://argo-cd.readthedocs.io/en/latest/user-guide/auto_sync/

- _automated_ - any change in tracked Git repo synced automatically (3 mins default)
- _prune_ - whether to delete resources
- _selfHeal_ - fix the drift (e.g. a manual change on cluster) back to desired state in Git

https://github.com/milanoid-labs/homelab-cluster/blob/main/apps/argocd/devops-study-app.yaml#L18


```yaml
# it's spec.syncPolicy.automated.enabled|prune|selfHeal
spec:
  syncPolicy:
    automated:
      enabled: true
      prune: true
      selfHeal: true
```

---

# Private Repositories

If application manifests are located in private repository then repository credentials have to be configured. Argo CD supports both HTTPS and SSH Git credentials.

https://argo-cd.readthedocs.io/en/latest/user-guide/private-repositories/

- The _Application_ CRD is the same, but we need to create K8s Secrets with credentials
- note the _label_ value


```yaml
---
apiVersion: v1 
kind: Secret 
metadata:
  name: git-private-repo 
  namespace: argocd 
  labels: argocd.argoproj.io/secret-type: repository 
stringData: 
  type: git 
  url: https://contoso@dev.azure.com/my-projectcollection/my-project/_git/my-repo 
  useAzureWorkloadIdentity: "true"
```


Deploy Key - a _public_ key with read-only access to repo so Argo CD can clone it and read

Deploy Key is a GitHub legacy approach. Preferred is GitHub App.


# Orchestrating Applications


## Argo CD Projects and Multi-Tenancy

### Project

- provide a logical grouping of applications, which is useful when Argo CD is used by multiple teams
- https://argo-cd.readthedocs.io/en/stable/user-guide/projects/
- if not specified -> _default_ project (can be modified, but not deleted)
- central point of RBAC

```yaml
# very permissive default project
spec: 
  sourceRepos: 
    - '*'
  destinations: 
    - namespace: '*' 
      server: '*' 
  clusterResourceWhitelist: 
    - group: '*' 
      kind: '*'
```

example of a non-default project manifest:

```yaml
spec:
  destinations:
  # Do not allow any app to be installed in `kube-system`  
  - namespace: '!kube-system'
    server: '*'
  # Or any cluster that has a URL of `team1-*`   
  - namespace: '*'
    server: '!https://team1-*'
    # Any other namespace or server is fine though.
  - namespace: '*'
    server: '*'
```


### Propagation Policies

Pods (owned by) - ReplicaSet (owned by) - Deployment (Owner)

- it's about the policy by which the resources are deleted

#### Foreground

- owner enters "Deletion in progress"
- garbage collector deletes all dependents first
- than the owner

#### Background (default)

- owner is deleted first
- garbage collector then cleans the rest

#### Orphan

- owner object deleted
- dependents object kept -> they become _orphans_



## Sync Phases and Hooks


- allows to run a custom code during Argo CD sync operation

Sync is not an atomic action, it consists of phases, each can run a Job with appropriated annotation:

1. _PreSync_ -  `argocd.argoproj.io/hook: Presync`
   - could lead to either _Sync_ or _SyncFail_ phase
2. _Sync_ phase - `argocd.argoproj.io/hook: Sync`
3. _SyncFail_  - `argocd.argoproj.io/hook: SyncFail`
4. _PostSync_ -  `argocd.argoproj.io/hook: PostSync`

Additional Argo CD hooks:

- _Skip_ - skip application of the manifest
- _PostDelete_ - execute after all resources are deleted



## Sync Waves


- way how to explicitly set the order of creating resources within _Sync_
- e.g. create namespace first
- `argocd.argoproj.io/sync-wave: 0|1|2|3|-1`, `-1` the very first, `0` is default
- after each wave it checks the health status, only continues if a previous wave succeeded

Can combine Sync Waves and Hooks!

