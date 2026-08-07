

# Terraform plugins

https://developer.hashicorp.com/terraform/plugin/how-terraform-works

Two main components - Terraform Core and Terraform Plugins


## Terraform Core

- Go binary (`terraform` CLI command - entrypoint for anyone using Terrraform)
- responsibilities: IaC, Resource state management, Construct of the Resource Graph, Plan execution, Communication with plugins via RPC

## Terraform Plugins

- also in Go
- exposes an implementation for a specific service (e.g. AWS, Github)
- all _Providers_ and _Provisioners_ are _Plugins_

### Responsibilities

#### Provider Plugins

- init libraries used to make API calls
- authentication with Infrastructure Provider

#### Provisioner Plugins

- executing commands or scripts on the designated Resource after creating, or on destruction

---


# Purpose of Terraform State

https://developer.hashicorp.com/terraform/language/v1.12.x/state/purpose

Why is it required? Why not to query the real state on every run?


Performance

- quota in API calls (Github)
- by default it sync all resources, fine with small infra, slow for large infra (can use `-target` to narrow it down to a subset only)


Syncing

- by default the state is in current directory file `terraform.tfstate`
- recommended is [Remote state](https://developer.hashicorp.com/terraform/language/v1.12.x/state/remote) for team cooperation (e.g. HCP Terraform, S3 ...)



# Providers Overview

https://developer.hashicorp.com/terraform/language/v1.12.x/providers

- Plugins called Providers interacts with could providers and other APIs.
- Each provider adds a set of _resource types_ and/or _data_sources_.
- Marketplace at [Terraform Registry](https://registry.terraform.io/browse/providers?product_intent=terraform)


Usage - run `terraform init` - to install the specified provider first.


## Provider Tiers

Official, Partner Premium, Partner, Community, Archived

https://developer.hashicorp.com/terraform/language/v1.12.x/providers#how-to-find-providers

E.g. cloudflare is _Patner_ https://registry.terraform.io/providers/cloudflare/cloudflare/latest



---


# Manage Terraform versions


tutorial: https://developer.hashicorp.com/terraform/tutorials/configuration-language/versions

clone locally git clone https://github.com/hashicorp-education/learn-terraform-versions


```bash
cat terraform.tf
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_providers {
    aws = {
      version = "~> 5.52.0"
    }
    random = {
      version = "~> 3.6.2"
    }
  }

  required_version = "~> 1.1.9"
}
```

- `required_version`  allows patch version upgrades `1.1.x`, upgrade to `1.15.x` won't work
- `major.minor.patch`
- _minor_ and _patch_ versions are backward compatible

```bash
terraform version
Terraform v1.15.8
on darwin_arm64
```


```bash
milan@SPM-LN4K9M0GG7 ~/repos/learn-terraform-versions (main)
> terraform init
Initializing the backend...

╷
│ Error: Unsupported Terraform Core version
│
│   on terraform.tf line 14, in terraform:
│   14:   required_version = "~> 1.1.9"
│
│ This configuration does not support Terraform version 1.15.8. To proceed, either choose another supported Terraform version or update this version constraint. Version constraints
│ are normally set for good reason, so updating the constraint may lead to other errors or unexpected behavior.
╵
```


update:


```bash
> git diff
diff --git a/terraform.tf b/terraform.tf
index e3b78bf..2d9a9e7 100644
--- a/terraform.tf
+++ b/terraform.tf
@@ -11,5 +11,5 @@ terraform {
     }
   }

-  required_version = "~> 1.1.9"
+  required_version = "~> 1.15.8"
 }
milan@SPM-LN4K9M0GG7 ~/repos/learn-terraform-versions (main)
> terraform init
Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.52.0"...
- Finding hashicorp/random versions matching "~> 3.6.2"...
- Installing hashicorp/aws v5.52.0...
- Installed hashicorp/aws v5.52.0 (signed by HashiCorp)
- Installing hashicorp/random v3.6.3...
- Installed hashicorp/random v3.6.3 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```
