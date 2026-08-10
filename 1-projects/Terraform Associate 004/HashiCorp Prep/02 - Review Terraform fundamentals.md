

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


### update the tf


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


To run the plan, configure the AWS access

```bash
export AWS_PROFILE=milanoid
terraform plan

...
Plan: 2 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + application_url = (known after apply)
  + domain_name     = (known after apply)
```

or setup the profile in the profile attribute:


```bash
> git diff
diff --git a/main.tf b/main.tf
index 7fdf70c..498fa9a 100644
--- a/main.tf
+++ b/main.tf
@@ -2,7 +2,8 @@
 # SPDX-License-Identifier: MPL-2.0

 provider "aws" {
-  region = "us-west-2"
+  region  = "us-west-2"
+  profile = "milanoid"
 }
```


then apply

```bash
terraform apply

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

application_url = "ec2-35-94-56-12.us-west-2.compute.amazonaws.com/index.php"
domain_name = "ec2-35-94-56-12.us-west-2.compute.amazonaws.com"
```

### Inspect the Terraform state file


```bash
grep -e '"version"' -e '"terraform_version"' terraform.tfstate
  "version": 4,
  "terraform_version": "1.15.8",
```


- it's a plaintext file
- tf version specified
- may hold secrets, do not push to cvs


---


# Lock and upgrade provider version


https://developer.hashicorp.com/terraform/tutorials/configuration-language/provider-versioning


There are 2 ways how to manage provider versions

1. specify the version in `terraform` block
2. use the _dependency_lock_file


test repo: https://github.com/hashicorp-education/learn-terraform-provider-versioning
#### Initialize and apply the configuration

- notice the aws and random provider version are take from the lock file `.terraform.lock.hcl`
- when `terraform init` it downloads the aws `4.5.0` although there is a newer version `6.x.x` and the constraint says simply `>= 4.5.0`
- without the lock file it would download the latest

```bash
# init the tf
milan@SPM-LN4K9M0GG7 ~/repos/learn-terraform-provider-versioning (main)
> git diff
diff --git a/main.tf b/main.tf
index 6487cb1..017437c 100644
--- a/main.tf
+++ b/main.tf
@@ -2,7 +2,8 @@
 # SPDX-License-Identifier: MPL-2.0

 provider "aws" {
-  region = "us-west-2"
+  region  = "eu-central-1"
+  profile = "milanoid"
 }

 resource "random_pet" "petname" {
milan@SPM-LN4K9M0GG7 ~/repos/learn-terraform-provider-versioning (main)
> terraform init
Initializing the backend...

Initializing provider plugins...
- Reusing previous version of hashicorp/aws from the dependency lock file
- Reusing previous version of hashicorp/random from the dependency lock file
- Installing hashicorp/aws v4.5.0...
- Installed hashicorp/aws v4.5.0 (signed by HashiCorp)
- Installing hashicorp/random v3.1.0...
- Installed hashicorp/random v3.1.0 (signed by HashiCorp)


Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```


- the lock file informs terraform to **always** install the same provider version

#### upgrade the AWS provider version

`-upgrade` flag will upgrade all providers to the latest version consistent within the version constraints

```bash
# uphrades the aws to v6
terrafrom init -upgrade

Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/aws versions matching ">= 4.5.0"...
- Finding hashicorp/random versions matching "3.1.0"...
- Installing hashicorp/aws v6.58.0...
- Installed hashicorp/aws v6.58.0 (signed by HashiCorp)
- Using previously-installed hashicorp/random v3.1.0

Terraform has made some changes to the provider dependency selections recorded
in the .terraform.lock.hcl file. Review those changes and commit them to your
version control system if they represent changes you intended to make.

Terraform has been successfully initialized!

```


my own excercise - use the HCP Terraform backend

```terraform.tf

terraform {
  cloud {
    organization = "milanvojnovic-org"
    workspaces {
      name = "learn-terraform-provider-versioning"
    }
  }

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.5.0"
    }
  }

  required_version = "~> 1.2"
}
```

authenticate to HCP Terraform (formerly Terraform Cloud)

```bash
terraform login
```

```bash
terraform init
Initializing HCP Terraform...

Initializing provider plugins...
- Reusing previous version of hashicorp/random from the dependency lock file
- Reusing previous version of hashicorp/aws from the dependency lock file
- Using previously-installed hashicorp/random v3.1.0
- Using previously-installed hashicorp/aws v6.58.0


HCP Terraform has been successfully initialized!
```

Now state is in HCP Terraform https://app.terraform.io/app/milanvojnovic-org/workspaces/learn-terraform-provider-versioning


Running `plan` - its executed remotely:

```bash
terraform plan
Running plan in HCP Terraform. Output will stream here. Pressing Ctrl-C
will stop streaming the logs, but will not stop the plan running remotely.

Preparing the remote plan...

To view this run in a browser, visit:
https://app.terraform.io/app/milanvojnovic-org/learn-terraform-provider-versioning/runs/run-Ayseceiabd1dywxb

Waiting for the plan to start...

Terraform v1.15.8
on linux_amd64
Initializing plugins and modules...
╷
│ Error: failed to get shared config profile, milanoid
│
│   with provider["registry.terraform.io/hashicorp/aws"],
│   on main.tf line 4, in provider "aws":
│    4: provider "aws" {
│
```

- error - it doesn't know my aws profile (it runs on their cloud!)

In HCP Terraform UI I need to add variables for the AWS access to my account:

- Settings -> Organization Settings -> [Variable sets](https://developer.hashicorp.com/terraform/tutorials/cloud-get-started/cloud-create-project)
- create `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`

![[Pasted image 20260807153404.png]]

Now the plan running remotely works:

```bash
terraform plan
Running plan in HCP Terraform. Output will stream here. Pressing Ctrl-C
will stop streaming the logs, but will not stop the plan running remotely.

Preparing the remote plan...

To view this run in a browser, visit:
https://app.terraform.io/app/milanvojnovic-org/learn-terraform-provider-versioning/runs/run-hbp67WWtraa5CKpy

Waiting for the plan to start...

Terraform v1.15.8
on linux_amd64
Initializing plugins and modules...

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.sample will be created
  + resource "aws_s3_bucket" "sample" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = (known after apply)
      + bucket_domain_name          = (known after apply)
      + bucket_namespace            = (known after apply)
      + bucket_prefix               = (known after apply)
      + bucket_region               = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + object_lock_enabled         = (known after apply)
      + policy                      = (known after apply)
      + region                      = "eu-central-1"
      + request_payer               = (known after apply)
      + tags                        = {
          + "public_bucket" = "false"
        }
      + tags_all                    = {
          + "public_bucket" = "false"
        }
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + cors_rule (known after apply)

      + grant (known after apply)

      + lifecycle_rule (known after apply)

      + logging (known after apply)

      + object_lock_configuration (known after apply)

      + replication_configuration (known after apply)

      + server_side_encryption_configuration (known after apply)

      + versioning (known after apply)

      + website (known after apply)
    }

  # random_pet.petname will be created
  + resource "random_pet" "petname" {
      + id        = (known after apply)
      + length    = 5
      + separator = "-"
    }

Plan: 2 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Cost Estimation:

Resources: 0 of 0 estimated
           $0.0/mo +$0.0

─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
```

---

# terraform `block` reference

https://developer.hashicorp.com/terraform/language/v1.12.x/block/terraform


---

# Provider Requirements

https://developer.hashicorp.com/terraform/language/v1.12.x/providers/requirements

- each has source and version
- each has two identifiers - source and _local name_ (used everywhere else in a Terraform module)

```terraform
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.5.0"
    }
  }
```

- `aws` - is _local name_
- _local name_ can be anything but there is a provider _preferred local name_
- (For example, resources from `hashicorp/aws` all begin with `aws`, like `aws_instance` or `aws_security_group`.)

```terraform
# usage example

provider "aws" {
  region = "eu-central-1"
}

resource "aws_s3_bucket" "sample" {
  bucket = "bucket-unique-name"

  tags = {
    public_bucket = false
  }
}
```

#### Handling Local Name Conflicts

https://developer.hashicorp.com/terraform/language/v1.12.x/providers/requirements#handling-local-name-conflicts


- use preferred local name (usually the _type_) when possible
- otherwise combine providers namespace with its _type_

```
terraform {
  required_providers {
    # In the rare situation of using two providers that
    # have the same type name -- "http" in this example --
    # use a compound local name to distinguish them.
    hashicorp-http = {
      source  = "hashicorp/http"
      version = "~> 2.0"
    }
    mycorp-http = {
      source  = "mycorp/http"
      version = "~> 1.0"
    }
  }
}

# References to these providers elsewhere in the
# module will use these compound local names.
provider "mycorp-http" {
  # ...
}

data "http" "example" {
  provider = hashicorp-http
  #...
}

```


### Build-in Providers

- providers are distributed as plugins
- but there is one which is built-in
- it's _terraform_remote_state_ - to fetch latest state of snapshot in  a remote state


### In-houser Providers


- either hosted locally without publishing to Terraform Registry
- or - via a filesystem mirrors
  
  
```
provider_installation {
  filesystem_mirror {
    path    = "/usr/share/terraform/providers"
    include = ["example.com/*/*"]
  }
  direct {
    exclude = ["example.com/*/*"]
  }
}

```


---

# Dependency Lock File

https://developer.hashicorp.com/terraform/language/v1.12.x/files/dependency-lock

external deps

1. Providers
2. Modules


- a file that belongs to the configuration as a whole, rather than to each separate module in the configuration
- name is always: `.terraform.lock.hcl`
- created/updated on every `terraoform init` command
- should be in VCS


## Dependency Installation Behaviour

https://developer.hashicorp.com/terraform/language/v1.12.x/files/dependency-lock#dependency-installation-behavior

What version is installed depends on version constraint in configuration AND what's in the lock file. The lock file version takes precedence - even there is a new version available and it satisfy the version constraint it won't be automatically updated. Can be override by `-upgrade` option.

## Checksum verification

- at least one checksum of a previously recorded in lock file must match
- so called a [trust on first use](https://en.wikipedia.org/wiki/Trust_on_first_use) (TOFU)

```bash
# example of error on non-matching checksum
Error: Failed to install provider

Error while installing hashicorp/azurerm v2.1.0: the current package for
registry.terraform.io/hashicorp/azurerm 2.1.0 doesn't match any of the
checksums previously recorded in the dependency lock file.
```



## Understanding Lock File Changes

As the lock file is in VCS, there might be changes in a PR affecting the lockfile.

### Dependency on a new provider

- if a new provider is added it's checksum is added

The lock file contains:

- `version`
- `constraint`
- `hashes`


### New version of an existing provider

- after running `terraform init -upgrade`


### New provider package checksums

- a new checksum w/o module/plugin change
- represents Terraform gradually transitioning between _hashing schemes_


- `h1:` vs `zh:` schema
```bash
--- .terraform.lock.hcl 2020-10-07 17:24:23.397892140 -0700
+++ .terraform.lock.hcl 2020-10-07 17:24:57.423130253 -0700
@@ -10,6 +10,7 @@
   version     = "2.1.0"
   constraints = "~> 2.1.0"
   hashes = [
+    "h1:1xvaS5D8B8t6J6XmXxX8spo97tAzjhacjedFX1B47Fk=",
     "h1:EOJImaEaVThWasdqnJjfYc6/P8N/MRAq1J7avx5ZbV4=",
     "zh:0015b491cf9151235e57e35ea6b89381098e61bd923f56dffc86026d58748880",
     "zh:4c5682ba1e0fc7e2e602d3f103af1638f868c31fe80cc1a884a97f6dad6e1c11",

```


- `zh:` - "zip hash" - legacy
- `h1:` - "hash schema 1" - current

### Providers that are no longer required

- when removing a dep the lock file record is removed as well


