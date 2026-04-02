# 04.01 Syncing Secrets from Azure Key Vaults


- setting up Kubernetes infra (on the cluster)
- syncing Secrets from Azure Key Vault
- access the app using FQDN instead IP

### Key Vault

- keys, certificates and other secrets
- can generate, rotate
- can use as secret store for my homelab (free)

phase4: 

1. `/phase-4-k8s-infra` - deployed cluster 

- need to note the terraform output (also can use `terraform output` command):
   
```
terraform output 
aks_keyvault_secrets_provider_client_id = "eb46e57f-b9e9-4d8f-ac8b-6df7c196738c" 
db_host = "psql-n8n-01-mercury.postgres.database.azure.com" db_name = "n8n" 
db_user = "n8nadmin" key_vault_name = "kv-n8n-mercury" key_vault_uri = "https://kv-n8n-mercury.vault.azure.net/"
```
   
   
2. deploy n8n from `/mercury-workflows/phase-4-k8s-infra/manifests-v2/n8n`

`secrets.yaml`- SecretProviderClass, provider azure, generates Kubernetes secrets

- replace values of keys `userAssignedIdentityID` (get value from `terraform output`)
- and `tenantId` (from `az account list` -> it's the `homeTenantId`)

! the SecretProvider will sync the secrets from KV to cluster ONLY if the secrets are being mounted by at least on Pod.

https://docs.azure.cn/en-us/aks/csi-secrets-store-configuration-options


```bash
# restart entire deployement (e.g. in case of a change in configMap)
kubectl -n n8n rollout restart deployment/n8n
```


---

# Configuring Ingress & Cert Management

### Install Traefik via Helm to the Azure cluster

The Azure AKS must run first -> `terraform plan` @ `/phase4-k8s-infra

(on Mac in devpod)

https://doc.traefik.io/traefik/getting-started/install-traefik/#use-the-helm-chart

```bash
vscode ➜ /workspaces/mercury-workflows (main) $ helm version

version.BuildInfo{Version:"v4.1.3", GitCommit:"c94d381b03be117e7e57908edbf642104e00eb8f", GitTreeState:"clean", GoVersion:"go1.25.8", KubeClientVersion:"v1.35"}
```

```bash
vscode ➜ /workspaces/mercury-workflows (main) $ helm repo add traefik https://traefik.github.io/charts
"traefik" has been added to your repositories

helm repo update

# install to default namespace
helm install traefik traefik/traefik

# install to n8n namespace
# helm install --namespace n8n traefik traefik/traefik


# ingress Treafik is running
vscode ➜ /workspaces/mercury-workflows/phase-4-k8s-infra (main) $ kubectl get ingressclass -A
NAME      CONTROLLER                      PARAMETERS   AGE
traefik   traefik.io/ingress-controller   <none>       44s
```


### Install cert-manager

[https://cert-manager.io/docs/tutorials/getting-started-aks-letsencrypt/](https://cert-manager.io/docs/tutorials/getting-started-aks-letsencrypt/#install-cert-manager)

```bash
helm install \
  cert-manager oci://quay.io/jetstack/charts/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.20.0 \
  --set crds.enabled=true
  
  
cert-manager v1.20.0 has been deployed successfully!
```

```bash
vscode ➜ /workspaces/mercury-workflows/phase-4-k8s-infra (main) $ kubectl -n cert-manager get all
NAME                                           READY   STATUS    RESTARTS   AGE
pod/cert-manager-585588555-gbcd9               1/1     Running   0          54s
pod/cert-manager-cainjector-5575b99886-rgfpm   1/1     Running   0          54s
pod/cert-manager-webhook-54cf8c85bc-j5w4q      1/1     Running   0          54s

NAME                              TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)            AGE
service/cert-manager              ClusterIP   10.0.201.155   <none>        9402/TCP           55s
service/cert-manager-cainjector   ClusterIP   10.0.72.112    <none>        9402/TCP           55s
service/cert-manager-webhook      ClusterIP   10.0.91.191    <none>        443/TCP,9402/TCP   55s

NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/cert-manager              1/1     1            1           55s
deployment.apps/cert-manager-cainjector   1/1     1            1           54s
deployment.apps/cert-manager-webhook      1/1     1            1           54s

NAME                                                 DESIRED   CURRENT   READY   AGE
replicaset.apps/cert-manager-585588555               1         1         1       54s
replicaset.apps/cert-manager-cainjector-5575b99886   1         1         1       54s
replicaset.apps/cert-manager-webhook-54cf8c85bc      1         1         1       54s
```

### Let's encrypt

- to provision SSL/TLS certificates

See `/phase-4-k8s-infra/manifests-v2/cert-manager/cluster-issuer.yaml` 

- there is a staging (issues certificate which is not valid - for testing)
- and there is a prod (limited)

```bash
vscode ➜ .../mercury-workflows/phase-4-k8s-infra/manifests-v2/cert-manager (main) $ kubectl apply -f cluster-issuer.yaml
clusterissuer.cert-manager.io/letsencrypt-staging created
clusterissuer.cert-manager.io/letsencrypt-prod created


vscode ➜ .../mercury-workflows/phase-4-k8s-infra/manifests-v2/cert-manager (main) $ kubectl get clusterissuers
NAME                  READY   AGE
letsencrypt-prod      True    47s
letsencrypt-staging   True    47s
```


### Now let's deploy n8n

```bash
vscode ➜ .../mercury-workflows/phase-4-k8s-infra/manifests-v2/n8n (main) $ kubectl apply -k .
```


Now there is _acme-solver_ running:
```bash
vscode ➜ .../mercury-workflows/phase-4-k8s-infra/manifests-v2/n8n (main) $ kubectl get ingress -A
NAMESPACE   NAME                        CLASS     HOSTS                                    ADDRESS        PORTS     AGE
n8n         cm-acme-http-solver-jmjkj   <none>    customer1.mercury.mischavandenburg.net   20.105.98.28   80        2m12s
n8n         n8n-ingress                 traefik   customer1.mercury.mischavandenburg.net   20.105.98.28   80, 443   2m14s
```

A cert being requested?

```bash
vscode ➜ .../mercury-workflows/phase-4-k8s-infra/manifests-v2/n8n (main) $ kubectl get certificaterequests -A
NAMESPACE   NAME             APPROVED   DENIED   READY   ISSUER             REQUESTER                                         AGE
n8n         n8n-tls-prod-1   True                False   letsencrypt-prod   system:serviceaccount:cert-manager:cert-manager   3m30s
```


```bash
vscode ➜ .../mercury-workflows/phase-4-k8s-infra/manifests-v2/n8n (main) $ kubectl get certificates.cert-manager.io -A
NAMESPACE   NAME           READY   SECRET         AGE
n8n         n8n-tls-prod   False   n8n-tls-prod   4m26s
```


```bash
vscode ➜ .../mercury-workflows/phase-4-k8s-infra/manifests-v2/n8n (main) $ kubectl describe certificaterequests -A

...

Status:
  Conditions:
    Last Transition Time:  2026-03-25T13:40:40Z
    Message:               Certificate request has been approved by cert-manager.io
    Reason:                cert-manager.io
    Status:                True
    Type:                  Approved
    Last Transition Time:  2026-03-25T13:40:40Z
    Message:               Waiting on certificate issuance from order n8n/n8n-tls-prod-1-2160677862: "pending"
    Reason:                Pending
    Status:                False
    Type:                  Ready
Events:
  Type    Reason              Age    From                                                Message
  ----    ------              ----   ----                                                -------
  Normal  WaitingForApproval  5m51s  cert-manager-certificaterequests-issuer-acme        Not signing CertificateRequest until it is Approved
  Normal  WaitingForApproval  5m51s  cert-manager-certificaterequests-issuer-ca          Not signing CertificateRequest until it is Approved
  Normal  WaitingForApproval  5m51s  cert-manager-certificaterequests-issuer-selfsigned  Not signing CertificateRequest until it is Approved
  Normal  WaitingForApproval  5m51s  cert-manager-certificaterequests-issuer-vault       Not signing CertificateRequest until it is Approved
  Normal  WaitingForApproval  5m51s  cert-manager-certificaterequests-issuer-venafi      Not signing CertificateRequest until it is Approved
  Normal  cert-manager.io     5m51s  cert-manager-certificaterequests-approver           Certificate request has been approved by cert-manager.io
  Normal  OrderCreated        5m51s  cert-manager-certificaterequests-issuer-acme        Created Order resource n8n/n8n-tls-prod-1-2160677862
```


```bash
vscode ➜ .../mercury-workflows/phase-4-k8s-infra/manifests-v2/n8n (main) $ kubectl get orders -A
NAMESPACE   NAME                        STATE     AGE
n8n         n8n-tls-prod-1-2160677862   pending   7m9s
```


```bash
vscode ➜ .../mercury-workflows/phase-4-k8s-infra/manifests-v2/n8n (main) $ kubectl describe orders -A

Events:
  Type    Reason   Age    From                 Message
  ----    ------   ----   ----                 -------
  Normal  Created  7m42s  cert-manager-orders  Created Challenge resource "n8n-tls-prod-1-2160677862-2204777294" for domain "customer1.mercury.mischavandenburg.net"
```



```bash
vscode ➜ .../mercury-workflows/phase-4-k8s-infra/manifests-v2/n8n (main) $ kubectl get challenges -A
NAMESPACE   NAME                                   STATE     DOMAIN                                   AGE
n8n         n8n-tls-prod-1-2160677862-2204777294   pending   customer1.mercury.mischavandenburg.net   8m57s
```


The problem: _failed to perform self check GET request_ :

```bash
vscode ➜ .../mercury-workflows/phase-4-k8s-infra/manifests-v2/n8n (main) $ kubectl describe challenges -A

Status:
  Presented:   true
  Processing:  true
  Reason:      Waiting for HTTP-01 challenge propagation: failed to perform self check GET request 'http://customer1.mercury.mischavandenburg.net/.well-known/acme-challenge/rpZX_cdNNRnKcZhWlNwwgyWGlFZRi58yVtcfPdri3Ug': Get "http://customer1.mercury.mischavandenburg.net/.well-known/acme-challenge/rpZX_cdNNRnKcZhWlNwwgyWGlFZRi58yVtcfPdri3Ug": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
  State:       pending
Events:
  Type    Reason     Age    From                     Message
  ----    ------     ----   ----                     -------
  Normal  Started    9m37s  cert-manager-challenges  Challenge scheduled for processing
  Normal  Presented  9m37s  cert-manager-challenges  Presented challenge using HTTP-01 challenge mechanism
```

- the hostname `customer1.mercury.mischavandenburg.net` must resolve to our cluster
- this is not happening (yet)

```bash
# on systemd machines
resolvectl query customer1.mercury.mischavandenburg.net

# already resolves to an IP (20.105.96.204) (Mischa's Cloudflare homelab)
```



- we need to point the address `customer1.mercury.mischavandenburg.net` to our cluster in Cloudflare
- I might need to use a different hostname - probably `customer1.mercury.milanoid.net`

1. get my public IP address (IP of LoadBalancer)

```bash
kubectl get services
NAME         TYPE           CLUSTER-IP    EXTERNAL-IP     PORT(S)                      AGE
kubernetes   ClusterIP      10.0.0.1      <none>          443/TCP                      39m
traefik      LoadBalancer   10.0.171.35   20.105.119.90   80:31856/TCP,443:31561/TCP   33m
```

2. set that IP `20.105.119.90` to my Cloudflare

- Type: `A`
- Name: `*.mercury`
- IPv4: `20.105.119.90`

Once done the cert manager should retry and succeeded. Might take some time (DNS propagate)

```bash
kubectl describe challenges -A
```

Now the address `customer1.mercury.mischavandenburg.net` (resp. ``customer1.mercury.milanoid.net`) should have valid TLS/SSL cert.

https://customer1.mercury.milanoid.net

-> getting a bit messy, later it will be all GitOps way, but now set up Database Operator

---

# 04.03 Intro to Databases in Kubernetes

Postgres - almost everywhere, solid choice


### cloudnative-pg
- https://cloudnative-pg.io/ 
- Run Postgres the Kubernetes way
- Open source / community version operator

### EDB Postgres AI

- https://www.enterprisedb.com/docs/postgres_for_kubernetes/latest/
- Enterprise paid version based on cloudnative-pg


Always start with Quickstart instead of going deep down to docs.

## Quick start

https://cloudnative-pg.io/docs/1.29/installation_upgrade

```bash
kubectl apply --server-side -f \
  https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.29/releases/cnpg-1.29.0.yaml
```

```bash
kubectl get all
NAME                                           READY   STATUS    RESTARTS   AGE
pod/cnpg-controller-manager-7cb7b548b8-zbqh8   1/1     Running   0          4m40s

NAME                           TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/cnpg-webhook-service   ClusterIP   10.0.131.222   <none>        443/TCP   4m41s

NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/cnpg-controller-manager   1/1     1            1           4m41s

NAME                                                 DESIRED   CURRENT   READY   AGE
replicaset.apps/cnpg-controller-manager-7cb7b548b8   1         1         1       4m40s
```

Now the operator is deployed.


Operators - control loops to allow custom resources to be deployed to my cluster

Now we also have `cluster` custom resource:

```bash
k explain clusters
GROUP:      postgresql.cnpg.io
KIND:       Cluster
VERSION:    v1

DESCRIPTION:
    Cluster defines the API schema for a highly available PostgreSQL database
    cluster
    managed by CloudNativePG.
```


## Now let's create the Postgres cluster

https://cloudnative-pg.io/docs/1.29/quickstart#part-3-deploy-a-postgresql-cluster



```yaml
# /workspaces/mercury-workflows/phase-4-k8s-infra/manifests-v2/cluster-example.yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: cluster-example
spec:
  instances: 3

  storage:
    size: 1Gi
```

In operator logs we can see it registers the cluster.

```bash
k get clusters
NAME              AGE    INSTANCES   READY   STATUS                     PRIMARY
cluster-example   3m5s   3           3       Cluster in healthy state   cluster-example-1
```


### cnpg plugin

CloudNativePG provides a plugin for `kubectl` to manage a cluster in Kubernetes.

https://cloudnative-pg.io/docs/1.29/kubectl-plugin


```bash
# install
curl -sSfL \
  https://github.com/cloudnative-pg/cloudnative-pg/raw/main/hack/install-cnpg-plugin.sh | \
  sudo sh -s -- -b /usr/local/bin
  
# check
k cnpg status

```


Added to the scripts/setup devcontainer.


#### issues with installer checksum

```bash
curl -sSfL   https://github.com/cloudnative-pg/cloudnative-pg/raw/main/hack/install-cnpg-plugin.sh |   sudo sh -s -- -b /usr/local/bin
cloudnative-pg/cloudnative-pg info checking GitHub for latest tag
cloudnative-pg/cloudnative-pg info found version: 1.29.0 for v1.29.0/linux/arm64
cloudnative-pg/cloudnative-pg err hash_sha256_verify checksum for '/tmp/tmp.VzWveEvwCq/kubectl-cnpg_1.29.0_linux_arm64.tar.gz' did not verify 86bf9f01673190a26970cff4b2405e5fc0f45bc4311602371c945285f685b7c0
f7698594fd89fadba047336ac2765ef75b5683c2d1fa5caab1829afe3d15127b vs 86bf9f01673190a26970cff4b2405e5fc0f45bc4311602371c945285f685b7c0
```

GH Issue https://github.com/cloudnative-pg/cloudnative-pg/issues/10402

Workaround

```bash
curl -L https://github.com/cloudnative-pg/cloudnative-pg/releases/download/v1.29.0/kubectl-cnpg_1.29.0_linux_x86_64.tar.gz -o kubectl-cnpg.tar.gz
tar xzf kubectl-cnpg.tar.gz
sudo mv kubectl-cnpg /usr/local/bin/
```


```bash
vscode ➜ /workspaces/mercury-workflows $ kubectl cnpg version 
Build: {Version:1.29.0 Commit:23eae00cd Date:2026-04-01}
```


PROFIT!

```bash
vscode ➜ /workspaces/mercury-workflows $ k cnpg status cluster-example
Cluster Summary
Name                     default/cluster-example
System ID:               7624055896381489171
PostgreSQL Image:        ghcr.io/cloudnative-pg/postgresql:18.3-system-trixie
Primary instance:        cluster-example-1
Primary promotion time:  2026-04-02 07:11:22 +0000 UTC (14m57s)
Status:                  Cluster in healthy state
Instances:               3
Ready instances:         3
Size:                    144M
Current Write LSN:       0/8000000 (Timeline: 1 - WAL File: 000000010000000000000008)

Continuous Backup not configured

Streaming Replication status
Replication Slots Enabled
Name               Sent LSN   Write LSN  Flush LSN  Replay LSN  Write Lag  Flush Lag  Replay Lag  State      Sync State  Sync Priority  Replication Slot
----               --------   ---------  ---------  ----------  ---------  ---------  ----------  -----      ----------  -------------  ----------------
cluster-example-2  0/8000000  0/8000000  0/8000000  0/8000000   00:00:00   00:00:00   00:00:00    streaming  async       0              active
cluster-example-3  0/8000000  0/8000000  0/8000000  0/8000000   00:00:00   00:00:00   00:00:00    streaming  async       0              active

Instances status
Name               Current LSN  Replication role  Status  QoS         Manager Version  Node
----               -----------  ----------------  ------  ---         ---------------  ----
cluster-example-1  0/8000000    Primary           OK      BestEffort  1.29.0           aks-default-15231464-vmss000000
cluster-example-2  0/8000000    Standby (async)   OK      BestEffort  1.29.0           aks-default-15231464-vmss000000
cluster-example-3  0/8000000    Standby (async)   OK      BestEffort  1.29.0           aks-default-15231464-vmss000000
```

Operator can auto backup the database too.

We have a mess though - some components installe by Helm, others manually applied a manifest ...

Next - we will boostrap the k cluster from scratch the proper way.

