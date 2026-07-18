

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



# Example Apps

https://github.com/argoproj/argocd-example-apps