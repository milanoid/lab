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

