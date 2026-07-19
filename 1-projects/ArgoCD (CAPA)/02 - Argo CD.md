
- example apps https://github.com/argoproj/argocd-example-apps

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
- OutOfSync - live state DOES not match desired state
- Progressing - undergoing sync operation

They Sync status (green checkmark) is displayed only on components managed by Application. E.g. _Service_ and _Deployment_ has a sync status but _ReplicaSet_ does not (as it is managed by _Deployment):

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
- uses `helm template`


No need for plain Kubernetes manifests (Deployment, Service). These are encapsulated in the Helm Chart. E.g. https://github.com/argoproj/argocd-example-apps/tree/master/helm-guestbook/templates


## Overriding Chart Values

- multiple locations of the Helm Chart Values
	- Chart's default Values file
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


---

# Advanced Sync and Automation

- https://argo-cd.readthedocs.io/en/latest/user-guide/auto_sync/

- _automated_ - any change in tracked Git repo synced automatically (3 mins default)
- _prune_ - whether to delete resources
- _selfHeal_ - fix the drift (e.g. a manual change on cluster) back to desired state in Git




