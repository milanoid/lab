
Starting from fresh. The AKS cluster used in previous steps destroyed.
# 05.01 GitOps

`mercury-workflows/phase-5-gitops`


### Issue with devpod (resolved)

-> fix https://github.com/milanoid/mercury-workflows/pull/1

```bash
vscode ➜ /workspaces/mercury-workflows/phase-5-gitops $ git status 
warning: unable to access '.git/config': Permission denied fatal: unable to access '.git/config': Permission denied
```

after `devpod up . --recreate`

```bash
vscode ➜ /workspaces/mercury-workflows $ git status
fatal: detected dubious ownership in repository at '/workspaces/mercury-workflows'
To add an exception for this directory, call:

        git config --global --add safe.directory /workspaces/mercury-workflows
```


---

as usual start in devpod by logging in to Azure, then follow /phase-5-gitops/README.md

```bash
devpod up .
```

```bash
az login --use-device-code
```


```bash
# register (enable) a provider (takes time)
az provider register --namespace Microsoft.KubernetesConfiguration
Registering is still on-going. You can monitor using 'az provider show -n Microsoft.KubernetesConfiguration'


# generate ssh key
ssh-keygen -t ed25519 -f ~/.ssh/mercury -N "" -C "mercury-gitops-deploy-key"

# push the deploy key to my repo
gh repo deploy-key add ~/.ssh/mercury.pub \
	--repo milanoid/mercury-workflows \
	--title "flux-deploy-key" \
	--allow-write
✓ Deploy key added to milanoid/mercury-workflows


# update the main.tf
# 1. subscription id
# 2. gitops ulr to my repo


# then run
terraform init
terraform plan
terraform apply

```



Now the AKS is deployed, let's switch to `mercury-workflows/phase-5-gitops/mercury-gitops` to deploy resources to the cluster.


```bash
# update apps/staging/customer1/kustomization.yaml with terraform apply output alues -> patch /spec/parameters/userAssignedIdentityID

# example output
aks_keyvault_secrets_provider_client_id = "231f23e9-18a8-4481-9354-1ae00376496b" 
key_vault_name = "kv-mercury-staging" 
key_vault_uri = "https://kv-mercury-staging.vault.azure.net/"

# read `homeTenantId` from -> paste the value to patch path /spec/parameters/tenantId
az account list 
```

now with updated `/spec/parameters/userAssignedIdentityID` and `/spec/parameters/tenantId` in `mercury-workflows/phase-5-gitops/mercury-gitops/apps/staging/customer1/kustomization.yaml` :

connect to AKS cluster

```bash
# set subs
az account set --subscription ab577f05-79c6-4633-b730-0293419a9171

# setup .kube confit
az aks get-credentials --resource-group rg-cloud-course-aks --name mercury-staging --overwrite-existing
```

### issue - GitOps flux configuration non-compliant

![[Pasted image 20260413080420.png]]

```bash
milan@a11be00dcdf6:/workspaces/mercury-workflows/phase-5-gitops/mercury-gitops$ flux get kustomizations
NAME                                    REVISION        SUSPENDED       READY   MESSAGE
mercury-system-apps                                     False           False   dependency 'flux-system/mercury-system-infra-configs' is not ready
mercury-system-infra-configs                            False           False   dependency 'flux-system/mercury-system-infra-controllers' is not ready
mercury-system-infra-controllers                        False           False   kustomization path not found: stat /tmp/kustomization-1989834238/infrastructure/controllers/staging: no such file or directory
```