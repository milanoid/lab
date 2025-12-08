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


# API Groups

- `/api` - core api
- `/apis` - named api
- `/version`

- /apis/apps
- /apis/storage

```bash
# auth required
curl -k https://localhost:6443
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {},
  "status": "Failure",
  "message": "Unauthorized",
  "reason": "Unauthorized",
  "code": 401
}

# either pass cert
curl -k https://localhost:6443 \
--key admin.key \
--cert admin.crt \
--cacert ca.crt

# or start proxy server
kubectl proxy
Starting to serve on 127.0.0.1:8001

# then
curl http://localhost:8001/version
{
  "major": "1",
  "minor": "33",
  "emulationMajor": "1",
  "emulationMinor": "33",
  "minCompatibilityMajor": "1",
  "minCompatibilityMinor": "32",
  "gitVersion": "v1.33.3+k3s1",
  "gitCommit": "236cbf257332b293f444abe6f24d699ff628173e",
  "gitTreeState": "clean",
  "buildDate": "2025-07-26T02:08:27Z",
  "goVersion": "go1.24.4",
  "compiler": "gc",
  "platform": "linux/amd64"
}
```

# Authorization

- Node - Node Authorizer
- ABAC - Attribute Based Authorization
- RBAC - Role Based Authorization
- Webhook

Modes - Always Allow vs Always Deny

Can have multiple modes set (Node, RBAC, Webhook) - each is evaluated:
- if Denied it checks the next mode specified
- if Allowed - no other is checked

# RBAC

https://kubernetes.io/docs/reference/access-authn-authz/rbac/#privilege-escalation-prevention-and-bootstrapping

1. object apiVersion `rbac.authorization.k8s.io/v1`, Kind `Role`
2. object apiVersion  `rbac.authorization.k8s.io/v1`, Kind `RoleBinding`

- applied to per-namespace 


```bash
kubectl get role -A
NAMESPACE     NAME                                             CREATED AT
arc-runners   arc-runner-set-754b578d-listener                 2025-12-02T14:21:44Z
arc-runners   arc-runner-set-gha-rs-manager                    2025-12-02T14:21:42Z
arc-systems   arc-gha-rs-controller-listener                   2025-12-02T14:18:20Z
kube-public   system:controller:bootstrap-signer               2025-08-02T15:32:08Z
kube-system   extension-apiserver-authentication-reader        2025-08-02T15:32:08Z
kube-system   system::leader-locking-kube-controller-manager   2025-08-02T15:32:08Z
kube-system   system::leader-locking-kube-scheduler            2025-08-02T15:32:08Z
kube-system   system:controller:bootstrap-signer               2025-08-02T15:32:08Z
kube-system   system:controller:cloud-provider                 2025-08-02T15:32:08Z
kube-system   system:controller:token-cleaner                  2025-08-02T15:32:08Z
monitoring    kube-prometheus-stack-grafana                    2025-08-24T16:48:33Z

# rolebinding
kubectl get rolebindings.rbac.authorization.k8s.io -A
NAMESPACE     NAME                                                 ROLE                                                  AGE
arc-runners   arc-runner-set-754b578d-listener                     Role/arc-runner-set-754b578d-listener                 4d22h
arc-runners   arc-runner-set-gha-rs-manager                        Role/arc-runner-set-gha-rs-manager                    4d22h
arc-systems   arc-gha-rs-controller-listener                       Role/arc-gha-rs-controller-listener                   4d22h
kube-public   system:controller:bootstrap-signer                   Role/system:controller:bootstrap-signer               126d
kube-system   k3s-cloud-controller-manager-authentication-reader   Role/extension-apiserver-authentication-reader        126d
kube-system   metrics-server-auth-reader                           Role/extension-apiserver-authentication-reader        126d
kube-system   system::extension-apiserver-authentication-reader    Role/extension-apiserver-authentication-reader        126d
kube-system   system::leader-locking-kube-controller-manager       Role/system::leader-locking-kube-controller-manager   126d
kube-system   system::leader-locking-kube-scheduler                Role/system::leader-locking-kube-scheduler            126d
kube-system   system:controller:bootstrap-signer                   Role/system:controller:bootstrap-signer               126d
kube-system   system:controller:cloud-provider                     Role/system:controller:cloud-provider                 126d
kube-system   system:controller:token-cleaner                      Role/system:controller:token-cleaner                  126d
monitoring    kube-prometheus-stack-grafana                        Role/kube-prometheus-stack-grafana                    104d

```

### checking access

```bash
$ kubectl auth can-i create deployments
yes

# as an Admin I can inpersonate user
kubectl auth can-i create deployements --as dev-user
```

Practice

Get authorization settings:

`kubectl get pod/kube-apiserver-controlplane --namespace kube-system --output=yaml`

Get users (defined in kubeconfig)

```bash
kubectl config get-users 
NAME
dev-user
kubernetes-admin
```

```bash
kubectl auth can-i get pod --as dev-user
no
```


# Cluster Roles

- cluster wide
- A Node cannot be isolated within a namespace (as it is cluster scoped)


_Namespace scope_

- Pods, Jobs, Services, ConfigMaps, Secrets, PVC ...
- list: `kubectl api-resources --namespaced=true`

_Cluster scope_ 
- Nodes, PV, cluster roles, namespaces ...


# Admission Controllers

extra rules, more granular, e.g.:

- do not allow `:latest` tag for images
- allow only internal image registry
- do not allow `runAs root`
- ...

default Admission Controller 
- `AlwaysPullImages=true`
- `NamespeceExists` (do not allow create a resource in a non-existent namespace)

Viewing Enabled Admission Controllers

```bash
kube-apiserver -h | grep enable-admission-plugins
# for adm based systems
kubectl exec kube-apiserver-controlplane -n kube-system -- kube-apiserver -h | grep enable-admission-plugins
```

# Validating and Mutating Admission Controllers

