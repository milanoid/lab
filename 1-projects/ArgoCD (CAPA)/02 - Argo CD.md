

# Application

- spec https://argo-cd.readthedocs.io/en/stable/user-guide/application-specification/

```yaml
spec: 
	# The project the application belongs to. 
	project: default 
	# Source of the application manifests 
	source: repoURL: https://github.com/argoproj/argocd-example-apps.git # Can point to either a Helm chart repo or a git repo. 
	targetRevision: HEAD # For Helm, this refers to the chart version. 
	path: guestbook # This has no meaning for Helm charts pulled directly from a Helm repo instead of git.
```

- source can be git or [Helm Chart Repository](https://helm.sh/docs/topics/chart_repository/) 
- Helm Chart Repository can be hosted on Nexus



# ConfigMap

- spec https://argo-cd.readthedocs.io/en/stable/operator-manual/argocd-cm-yaml/

- 
