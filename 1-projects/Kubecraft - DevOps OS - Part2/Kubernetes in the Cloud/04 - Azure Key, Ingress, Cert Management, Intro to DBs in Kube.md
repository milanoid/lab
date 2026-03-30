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