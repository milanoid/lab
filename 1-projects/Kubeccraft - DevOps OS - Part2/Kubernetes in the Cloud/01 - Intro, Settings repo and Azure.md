Course starts with Kubernetes deployment on MS Azure first. Only later we do the same with AWS. However Mischa teach it the vendor agnostic way.

Not just watch! Hands on!

At the end we will act as company providing managed N8N (low code tool) service.


## Resources - Course repo

- `~/repos/mercury-workflows` (mercury - the company name)
- uses _devcontainers - [[00 - Intro]]
- My repo  https://github.com/milanoid/mercury-workflows/



### course repo in Devpod

- fallback - also one can open IDEA too

```bash
# creates devpod and clones my dotfiles into it
~/repos/mercury-workflows (master)
> devpod up .
> 
```

- dotfiles in https://github.com/milanoid/dotfiles-demo


_Approach_

- use plain `vi` in the Devpod
- config `vi` along the way, only if needed



#### issues in devpod

- [ ] port forward `3008` not working

```bash
09:28:39 info Error port forwarding 3008: accept tcp 127.0.0.1:3008: use of closed network connection
09:28:39 info Error tunneling to container: wait: remote command exited without exit status or exit signal
09:28:40 info Done setting up dotfiles into the devcontainer
```


- [x] git files ownership issue
- [x] not just git cannot create a file (user `vscode` on mac it's `milan`)

- maybe something I've resolved in [[05 - Module 5 - Mise#fix permission issue]]

```bash
vscode ➜ /workspaces/mercury-workflows $ git status
fatal: detected dubious ownership in repository at '/workspaces/mercury-workflows'
To add an exception for this directory, call:

        git config --global --add safe.directory /workspaces/mercury-workflows
```


## MS Azure Free Account


- [x] create a `@outlook.com` email account first (e.g. `milan.kubecraft@outlook`)
- [x] Azure account


# Clouds are APIs

- Organization has 1 or more Subscriptions
- Subscription contains Resource Groups



## exercise - create a VM using Azure Portal

Wizard

- added my public ssh key, then can connect `ssh azureuser@<IP-address>`

Azure Resources in JSON

```json
{
    "apiVersion": "2025-04-01",
    "id": "/subscriptions/ab577f05-79c6-4633-b730-0293419a9171/resourceGroups/test01/providers/Microsoft.Compute/virtualMachines/test01",
    "name": "test01",
    "type": "microsoft.compute/virtualmachines",
    "location": "polandcentral",
    "zones": [
        "1"
    ],
    "properties": {
        "hardwareProfile": {
            "vmSize": "Standard_B2ts_v2"
        },
        "provisioningState": "Succeeded",
        "vmId": "f8a8c56d-ae7e-47c6-856e-031fc27efd45",
        "additionalCapabilities": {
            "hibernationEnabled": false
        },
        "storageProfile": {
            "imageReference": {
                "publisher": "canonical",
                "offer": "ubuntu-24_04-lts",
                "sku": "server",
                "version": "latest",
                "exactVersion": "24.04.202603120"
            },
            "osDisk": {
                "osType": "Linux",
                "name": "test01_OsDisk_1_d72d2e5b68ba47d5823bfac0cb03a502",
                "createOption": "FromImage",
                "caching": "ReadWrite",
                "managedDisk": {
                    "storageAccountType": "StandardSSD_LRS",
                    "id": "/subscriptions/ab577f05-79c6-4633-b730-0293419a9171/resourceGroups/test01/providers/Microsoft.Compute/disks/test01_OsDisk_1_d72d2e5b68ba47d5823bfac0cb03a502"
                },
                "deleteOption": "Delete",
                "diskSizeGB": 30
            },
            "dataDisks": [],
            "diskControllerType": "SCSI"
        },
        "osProfile": {
            "computerName": "test01",
            "adminUsername": "azureuser",
            "linuxConfiguration": {
                "disablePasswordAuthentication": true,
                "ssh": {
                    "publicKeys": [
                        {
                            "path": "/home/azureuser/.ssh/authorized_keys",
                            "keyData": "ssh-rsa xxxxx"
                        }
                    ]
                },
                "provisionVMAgent": true,
                "patchSettings": {
                    "patchMode": "ImageDefault",
                    "assessmentMode": "ImageDefault"
                }
            },
            "secrets": [],
            "allowExtensionOperations": true,
            "requireGuestProvisionSignal": true
        },
        "networkProfile": {
            "networkInterfaces": [
                {
                    "id": "/subscriptions/ab577f05-79c6-4633-b730-0293419a9171/resourceGroups/test01/providers/Microsoft.Network/networkInterfaces/test01979_z1",
                    "properties": {
                        "deleteOption": "Detach"
                    }
                }
            ]
        },
        "diagnosticsProfile": {
            "bootDiagnostics": {
                "enabled": true
            }
        },
        "priority": "Spot",
        "evictionPolicy": "Deallocate",
        "billingProfile": {
            "maxPrice": -1
        },
        "timeCreated": "2026-03-14T15:48:44.882Z"
    },
    "etag": "\"1\""
}
```


### Azure Resource Manager

https://learn.microsoft.com/en-us/rest/api/resources/

- a REST API 
- can use to create the same VM as above


---

# 01.03 Introduction to Infrastructure as Code

Create Budget! (30 euro with 50 % and 75 %  alerts)

### Terraform by Hashicorp

- cloud agnostic
- [providers](https://registry.terraform.io/browse/providers) (plugins) - they do the talking via API to a service (e.g. AWS, Azure ...)
- multiple use cases
- HCL language
- a provider need to keep up with changes in the service (e.g. Azure) - can drift


E.g. RouterOS - a provider for Microtik routers https://github.com/terraform-routeros/terraform-provider-routeros

### [Bicep](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview?tabs=bicep) by Microsoft

- DSL to create infrastructure in Azure
- always compatible with Azure
- easier to learn than Terraform (+ no state file)

### [Pulumi](https://www.pulumi.com/)

- uses a programming lang (e.g. Python)
- not much adaption

### [Crossplane](https://www.crossplane.io/)

- IaaC with Kubernetes as a Control Plane
- yaml manifest -> my kubernetes cluster talks to MS Azure and creates the infrastructure
- one use case -> creating yaml Kubernetes manifest to manage Cloud infra

### [Cloudformation](https://aws.amazon.com/cloudformation/)

- like Bicep but for AWS


# Iaac with Terraform


## Install Terraform

Mischa installs terraform in devpod (`mise use terraform`). Meanwhile I'll use `terraform` on my Mac.

- [x] todo fix devpod

```bash
mise use terraform

mise ERROR failed write: /workspaces/mercury-workflows/mise.toml
mise ERROR Permission denied (os error 13)
mise ERROR Run with --verbose or MISE_VERBOSE=1 for more information
```


```bash
> terraform version 
Terraform v1.9.0 on darwin_arm64 Your version of Terraform is out of date! The latest version is 1.14.7. You can update by downloading from https://www.terraform.io/downloads.html
```

## Install and setup Azure CLI

- again I'm using my Mac's `az`

```bash
> az version 
{ 
 "azure-cli": "2.84.0", 
 "azure-cli-core": "2.84.0", 
 "azure-cli-telemetry": "1.1.0", 
 "extensions": {} 
}
```


```bash
# login
az login

# in env w/o browser (e.g. devpod)
az login --use-device-code
```


## Neovim 

- install Terraform language server via `LazyExtras`
- `x` + `space` -> then `x` to see Terraform validation error, `ctrl` + `w` + `j` opens the window

    registry.terraform.io/hashicorp/azurerm: there is no package for registry.terraform.io/hashicorp/azurerm 4.51.0 cached in .terraform/providers - terraform validate  [1, 1]


## Install Terraform provider

To install the provider run:

```bash
milan@SPM-LN4K9M0GG7 ~/repos/mercury-workflows/phase-1-vm
> terraform init
```

- installs the provider
- creates `.terraform` directory and `.terraform.lock.hcl` (hashes of the provider)


## `~/repos/mercury-workflows/phase-1-vm/vm.tf`

Starting simple, comment all but the Resource Groups


```bash
# plan
terraform plan

...


# apply runs the plan again too
terraform apply
```


```bash
milan@SPM-LN4K9M0GG7 ~/repos/mercury-workflows/phase-1-vm (master)
> terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # azurerm_resource_group.demo_state will be created
  + resource "azurerm_resource_group" "demo_state" {
      + id       = (known after apply)
      + location = "westeurope"
      + name     = "rg-state-demo"
    }

  # azurerm_resource_group.main will be created
  + resource "azurerm_resource_group" "main" {
      + id       = (known after apply)
      + location = "westeurope"
      + name     = "rg-terraform-demo"
    }

Plan: 2 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

azurerm_resource_group.main: Creating...
azurerm_resource_group.demo_state: Creating...
azurerm_resource_group.main: Still creating... [10s elapsed]
azurerm_resource_group.demo_state: Still creating... [10s elapsed]
azurerm_resource_group.demo_state: Creation complete after 11s [id=/subscriptions/ab577f05-79c6-4633-b730-0293419a9171/resourceGroups/rg-state-demo]
azurerm_resource_group.main: Creation complete after 12s [id=/subscriptions/ab577f05-79c6-4633-b730-0293419a9171/resourceGroups/rg-terraform-demo]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```

- creates `terraform.tfstate` - this MUST NOT be in GIT (can contain credentials etc.)
- in real world the state file will be in cloud backend (e.g. S3 bucket in SP)


On `apply` issue


```bash
rosoft.Network/networkInterfaces/nic-demo|/subscriptions/ab577f05-79c6-4633-b730-0293419a9171/resourceGroups/rg-terraform-demo/providers/Microsoft.Network/networkSecurityGroups/nsg-demo]
╷
│ Error: creating Linux Virtual Machine (Subscription: "ab577f05-79c6-4633-b730-0293419a9171"
│ Resource Group Name: "rg-terraform-demo"
│ Virtual Machine Name: "vm-demo"): performing CreateOrUpdate: unexpected status 409 (409 Conflict) with error: SkuNotAvailable: The requested VM size for resource 'Following SKUs have failed for Capacity Restrictions: Standard_B2s' is currently not available in location 'westeurope'. Please try another size or deploy to a different location or different zone. See https://aka.ms/azureskunotavailable for details.
│
│   with azurerm_linux_virtual_machine.main,
│   on vm.tf line 91, in resource "azurerm_linux_virtual_machine" "main":
│   91: resource "azurerm_linux_virtual_machine" "main" {
│
╵
```

List all available VMs

`az vm list-skus --location centralus --size Standard_B --all --output table`


Tear down: `terraform desroy`


- [ ] fix the ssh pub key (do not use the Mac's anymore, use one in devcontainer)
