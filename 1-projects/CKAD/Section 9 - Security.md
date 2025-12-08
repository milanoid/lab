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

- Validating - `NamespaceExists` - rejects request if the namespace does not exist
- Mutating - `DefaultStorageClass` - a PVC request w/o StorageClass specified defaults to a default StorageClass, mutates - changes the request

### setting up my own Admission Webhooks (Dynamic Admission Control)

Can create my own - both types - _Mutating Adminission Webhook_ and _Validating Admission Webhook_.

1. deploy Admission Webhook Server 
   - not part of the Kubernetes, a custom code e.g. Python
   - can be deployed on the cluster or hosted elsewhere
1. configure Webhook in Kubernetes



```yaml
piVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
metadata:
  name: "pod-policy.example.com"
webhooks:
- name: "pod-policy.example.com"
  rules:
  - apiGroups:   [""]
    apiVersions: ["v1"]
    operations:  ["CREATE"]
    resources:   ["pods"]
    scope:       "Namespaced"
  clientConfig:
    service:
      namespace: "example-namespace"
      name: "example-service"
    caBundle: <CA_BUNDLE>
  admissionReviewVersions: ["v1"]
  sideEffects: None
  timeoutSeconds: 5
```


Lab: 


```yaml
# /root/pod-with-conflict.yaml 

# A pod with a conflicting securityContext setting: it has to run as a non-root
# user, but we explicitly request a user id of 0 (root).
# Without the webhook, the pod could be created, but would be unable to launch
# due to an unenforceable security context leading to it being stuck in a
# 'CreateContainerConfigError' status. With the webhook, the creation of
# the pod is outright rejected.
apiVersion: v1
kind: Pod
metadata:
  name: pod-with-conflict
  labels:
    app: pod-with-conflict
spec:
  restartPolicy: OnFailure
  securityContext:
    runAsNonRoot: true
    runAsUser: 0
  containers:
    - name: busybox
      image: busybox
      command: ["sh", "-c", "echo I am running as user $(id -u)"]
```


```bash
# webhook kicks in:

kubectl apply -f /root/pod-with-conflict.yaml 
Error from server: error when creating "/root/pod-with-conflict.yaml": admission webhook "webhook-server.webhook-demo.svc" denied the request: runAsNonRoot specified, but runAsUser set to 0 (the root user)
```

# API Versions

- GA - Generally Available (version)
- Alpha 
  - first developed and released
  - not enabled by default
  - may lack e2e tests
  - can be buggy and without support
- Beta
  - enabled by default
  - with e2e tests
  - minor bugs
  - it might be moved to GA later


`/apis/apps` can support multiple versions

There is _preferred_  and _storage.

- _preferred_ - default version
- _storage_ - version in which the Kubernetes object is stored

```bash

# with proxy
kubectl proxy
Starting to serve on 127.0.0.1:8001


curl -k http://localhost:8001/apis/batch
{
  "kind": "APIGroup",
  "apiVersion": "v1",
  "name": "batch",
  "versions": [
    {
      "groupVersion": "batch/v1",
      "version": "v1"
    }
  ],
  "preferredVersion": {
    "groupVersion": "batch/v1",
    "version": "v1"
  }
```

Getting storage version - need to query etcd directly.

# API Deprecations

- rule #1 - API elements can only be removed by incrementing the version of the API group
- rule #2 - API objects must be able to round-trip between API versions in a given release w/o information loss
- rule #4a older API version must be supported: 
  - GA: 12 months or 3 releases
  - Beta: 9 months or 3 releases
  - Alpha: 0 releases

https://kubernetes.io/releases/


### Kubectl Convert

- when old API gets removed the existing manifest files to a new version


```
kubectl convert -f <old-file> --output-version <new-api>
```

- may not be installed https://kubernetes.io/docs/tasks/tools/install-kubectl-macos/


Lab

- get short names: `kubectl api-resources`
- see the API group a `job` is part of: `kubectl explain job`
- get preferred version: 
  ```
    kubectl proxy 8001&
    
    curl http://localhost:8001/apis/authorization.k8.io
    ```

- enable `alpha`
  
  ```bash
    # backup first than edit
    vi /etc/kubernetes/manifests/kube-apiserver.yaml
    
    ...
    --runtime-config=rbac.authorization.k8s.io/v1alpha1
    ...
    
    ```


# Custom Resource Definition

