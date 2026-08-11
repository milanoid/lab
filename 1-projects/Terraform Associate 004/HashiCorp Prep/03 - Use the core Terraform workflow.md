- writing configuration
- initializing a workspace
- planning changes
- applying changes

Also Terraform CLI offers validation and format.


## Core Terraform Workflow Overview

https://developer.hashicorp.com/terraform/intro/v1.12.x/core-workflow

1. Write
2. Plan
3. Apply

### Working as an Individual Practitioner

Write
- `init`
- `vim main.tf`
- `terraform plan` - to check for syntax errors

Plan
- `git commit`
- `terraform apply` - also displays a plan for confirmation (`yes`)


Apply
- type `yes` to confirm the `terraform apply`
- at this point push to git remote



### Working as a Team

- new steps must be added
- number of sensitive input vars (API Keys, SSL Cert Pairs...) grows with the team
- to avoid burden of each developer arranging the sensitive inputs locally migrate to CI
- read [Running Terraform in Automation](https://developer.hashicorp.com/terraform/tutorials/automation/automate-terraform?utm_source=WEBSITE&utm_medium=WEB_IO&utm_offer=ARTICLE_PAGE&utm_content=DOCS) guide (ex. CircleCI, GitHub Actions)

Write
- save the changes to git branches to avoid collision


Plan
- show in PR

Apply
- Do we expect any service disruption from this change? Is there any part of this change that is high risk?

### The Core Workflow Enhanced by HCP Terraform 

- CI by Hashicorp
- securely stores sensitive input variables and state
- when running `terraform plan|apply` it can run either locally or remotely
- team members needs HCP Terraform API Key


```
terraform {
  cloud {
    organization = "my-org"
    hostname = "app.terraform.io" # Optional; defaults to app.terraform.io

    workspaces {
      tags = {
        layer = "networking"
        source = "cli"
      }
      
      # For terraform versions below 1.10, you must specify key-only tags
      # using a list of strings. Example:
      # tags = ["networking", "source:cli"]
    }
  }
}
```

---

# Initialize Terraform configuration

https://developer.hashicorp.com/terraform/tutorials/cli/init

init - init workspace, configure backend, install providers and modules, creates lock file

tutorial

```bash
git clone https://github.com/hashicorp-education/learn-terraform-init

terraform init
```

- defaults to _local_ backend
- detects local module `modules/aws-ec2-instance`
- detects remote module `hello`
- creates lock file `.terraform.local.hcl`



```bash
> terraform validate

Success! The configuration is valid.
```


`.terraform` - dir with project's providers and modules

- do not check in to VCS


```bash
> tree .terraform
.terraform
├── modules
│   ├── hello
│   │   ├── random.tf
│   │   └── README.md
│   └── modules.json
└── providers
    └── registry.terraform.io
        └── hashicorp
            ├── aws
            │   └── 6.2.0
            │       └── darwin_arm64
            │           ├── LICENSE.txt
            │           └── terraform-provider-aws_v6.2.0_x5
            └── random
                └── 3.6.0
                    └── darwin_arm64
                        └── terraform-provider-random_v3.6.0_x5

12 directories, 6 files
```


Update provider and modules versions


```bash
> terraform validate
╷
│ Error: Module version requirements have changed
│
│   on main.tf line 38, in module "hello":
│   38:   source  = "joatmon08/hello/random"
│
│ The version requirements have changed since this module was installed and the installed version (4.0.0) is no longer acceptable. Run "terraform init" to install all modules
│ required by this configuration.
╵
```

- because I updated the version I need to reinitialize the project `terraform init -upgrade`
---

#### terraform fmt/validat command

- `terrafrom fmt`
- `terraform validate` - does not validate remote services (remote state, API)



---

# Create a Terraform plan

https://developer.hashicorp.com/terraform/tutorials/cli/plan


tutorial

```bash
git clone https://github.com/hashicorp-education/learn-terraform-plan
```


`terraform plan -out tfplan`

- export the plan to a file `tfplan`
- when applying we are 100 % sure only the changes in the plan file are applied
- best practices for automation

`terraform apply` - if no plan file passed, then TF will create a plan and prompt

- plan file is a binary file - use `terraform show "tfplan"`

`terraform show -json "tfplan" | jq > tfplan.json`

- convert to json (nice for automation)

Never commit plans to VCS!


Review the plan

```
jq '.terraform_version, .format_version' tfplan.json
jq '.configuration.provider_config' tfplan.json
```


#### Apply a saved plan


```bash
# will NOT ask me for approve
terraform apply "tfplan"
```


#### Modify configuration


```bash
# add to variables.tf
variable "secret_key" {
  type        = string
  sensitive   = true
  description = "Secret key for hello module"
}
```

create a `terraform.tfvars`

```bash
secret_key="TOPSECRET"
```

- NEVER `.tfvars` to VCS!

referrence the input var in main.tf


```bash
some_key = var.secret_key
```


#### Destroy

```bash
terraform plan -destroy -out "tfplan-destroy"

terraform apply "tfplan-destroy"
```



Apply Tutorial

https://developer.hashicorp.com/terraform/tutorials/cli/apply


```bash
git clone https://github.com/hashicorp-education/learn-terraform-apply

```