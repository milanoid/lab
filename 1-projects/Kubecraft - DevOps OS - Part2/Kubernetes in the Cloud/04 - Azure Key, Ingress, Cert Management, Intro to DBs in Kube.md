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

- replace values of keys `userAssignedIdentity` (get value from `terraform output`)
- and `tenantId` (from `az account list` -> it's the `homeTenantId`)

! the SecretProvider will sync the secrets from KV to cluster ONLY if the secrets are being mounted by at least on Pod.

https://docs.azure.cn/en-us/aks/csi-secrets-store-configuration-options


```bash
# restart entire deployement (e.g. in case of a change in configMap)
kubectl -n n8n rollout restart deployment/n8n
```


---

# Configuring Ingress & Cert Management

### install Traefik via Helm to the Azure cluster

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
# helm install traefik traefik/traefik

# install to n8n namespace
helm install --namespace n8n traefik traefik/traefik
```