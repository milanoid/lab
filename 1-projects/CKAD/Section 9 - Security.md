# Kubernetes Security Primitives

- `kube-apiserver` - access by `kubectl` or via API directly

Security - who access the `kube-apiserver` and what can do.

 Authentication mechanism (who)
 - certs
 - Service Accounts
 - external - LDAP

Authorization (what)
- RBAC
- ABAC
- Node Authorization
- Webhook Mode

## Authentication

- Admins, Developers, End Users, Bots

Focus on Admins, Developers, Bots.

- Kubernetes does not store accounts natively
- but can create _serviceaccount_
- authentication done by _kube-apiserver_


### Auth mechanism

- Static Token File
- Certificates
- 3rd party Identity (LDAP)


##### Static Token File

- a csv file 
- not recommended

# KubeConfig

- not part of the CKAD exam

- `~/.kube/config`
- has 3 parts - Clusters, Contexts, Users


```yaml
cat ~/.kube/config
apiVersion: v1
clusters:
- cluster:
contexts:
- context
users:
- user
```

To show what config is used:

- `kubectl config view`
- `kubectl config view -kubeconfig=my-custom-config`

Switch context

- `kubectl config use-context prod-user@production`