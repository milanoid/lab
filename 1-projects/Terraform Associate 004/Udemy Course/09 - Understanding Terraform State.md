
## Remote State Configuration - S3

The S3 bucket must exists first (chicken-egg problem?)

- general purpose
- disable public access
- encryption: AWS Key Management Service (DSSE-KMS)

```bash
terraform {
  backend "s3" {
    bucket       = "bucket-with-state"
    key          = "prod/terraform.tfstate"
    region       = "eu-central-1"
    use_lockfile = true
  }
}
```

- auth to AWS required (env vars, aws cli profile ...)

	## Migration Local State to a Remote State



1. setup the backup configuration in `terraform.tf`
2. `terraform init -migrate-state`
3. will be prompted whether to migrate existing state to a new backend
	- `yes` - copy the state to new backend
	- `no` - keep the new backend fresh/empty
4. remove/delete the local state files



- [ ] migrate my https://github.com/milanoid-labs/milanoid-labs-terraform
---
I'm using `tofu` (a Linux Foundation fork of Terraform), basically the same

- S3 bucket name `milanoid-labs-terraform-tofu-state`

```bash
# version
> tofu version 
OpenTofu v1.12.5

# verfy the state
> tofu plan

# migrate
> tofu init -migrate-state
Initializing the backend...

OpenTofu detected that the backend type changed from "local" to "s3".
Do you want to copy existing state to the new backend?
  Pre-existing state was found while migrating the previous "local" backend to the
  newly configured "s3" backend. No existing state was found in the newly
  configured "s3" backend. Do you want to copy this state to the new "s3"
  backend? Enter "yes" to copy and "no" to start with an empty state.

  Enter a value: yes


Successfully configured the backend "s3"! OpenTofu will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Reusing previous version of integrations/github from the dependency lock file
- Using previously-installed integrations/github v6.12.1

OpenTofu has been successfully initialized!

You may now begin working with OpenTofu. Try running "tofu plan" to see
any changes that are required for your infrastructure. All OpenTofu commands
should now work.

If you ever set or change modules or backend configuration for OpenTofu,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

```

---


## State Inspection

using the Terraform CLI

1. `terraform state list` - list all resources in the TF state
2. `terraform state show` - display state or plan details


`terrorm state show [planfile]`

when to use it:

- see all attributes of your resources
- review planned changes in detail
- inspect computed current recorded state
- prints everything

`terraform state show [resources]` - prints details of a specific resource only

Pro Tip: use `terraform state list` to get exact address, then `terraform state show` to inspect it


Legacy commands

- still working, but replaced with block `moved`, `removed`

```bash
terraform state mv
terraform state rm
terraform state pull|push
```


## State Drift


State file doesn't match the actual configuration. E.g. by manual modification on the running resource.

Can be either accepted or rejected on the next `terraform plan/apply`.

`terraform apply -refresh-only` - accept the actual config and update the state


## What happens if I lose state


1. in case of S3 bucket with versioning - restore
2. use `import` block to import it to state back
3. or use `terraform import` command

## Understanding Terraform Workspaces

https://developer.hashicorp.com/terraform/language/state/workspaces

- there is always `default` workspace
- isolates the state files for each environment

```bash
> terraform workspace list 
* learn-terraform-expressions
```

```bash
my-terraform
|
|- main.tf
|- terraform.tfstate <- default workspace
|- terraform.tfstate.d/
   |- dev/
   |- testing/
```
- dev and testing workspaces
- each having its own state file

```bash
terraform workspace list
terraform workspace new
terraform workspace select # change the workspace
terraform workspace show # display current workspace
```