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