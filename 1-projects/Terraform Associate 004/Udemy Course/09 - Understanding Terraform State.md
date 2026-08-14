
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
# verfy the state
tofu plan


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