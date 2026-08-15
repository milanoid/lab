
_or how to handle secrets_


## The Problem

Terraform needs secrets to manage infrastructure, but those secrets can be exposed in multiple places. Secrets are stored as plaintext in State.

Secrets shared across teams. Remote backends make state accessible to multiple people and lags and outputs are captured.


Where Sensitive Data Can End Up

1. State
2. Logs & Console output (CI/CD)
3. Version Control
4. Plan Files (output files) - often in CI/CD


## Protecting Secrets in Configuration


1. mark it as `sensitive = true` (hide values in output and logs) - also works for `output`
2. use environment variables (keeps secrets out of VCS)
3. external secret sources

All can work together.



## Keeping Secrets Out of VCS

- never commit .tfvars files with hardcoded secrets
- use environment variables:

`export TF_VAR_db_password=MyP@ssw0rd!`

- TF pickups that automatically
- perfect for CI/CD
- still in State



## Reading Secrets from External Sources


AWS Secrets Manager
Azure Keyvault
Hashicorp Vault
...

Terraform retrieve Secrets from external system.

- centralized rotation and access control
- one source of truth for secrets

### Reading Secrets from AWS Secrets Manager

(i) for homelab too expensive, AWS SSM Parameter Store is better (free)

- [ ] AWS SSM Param Store for my secrets
- enabler for running TF in GHA

```bash
# Read the secret from AWS Secrets Manager
deta "aws_secretsmanager_secret_version" "db_pass" {
  secret_id = "production/database/password"
}


# Use it in resource
resource "aws_db_instance" "main" {
  engine   = "postgres"
  username = "admin"
  # secret is fetched at apply time
  password = data.aws_secretsmanager_secret_version.db_pass.secret_string
}
```

- still ends up in State (which can be encrypted)



## Securing State Files


#### Configuring Encrypted Remote State

```bash
terraform {
  backend "s3" {
    bucket       = "terraform-state"
    key          = "prod/terraform.tfstate"
    region       = "eu-central-1"
    use_lockfile = true
    encrypt      = true       # server side encryption
    kms_key_id   = "<kms_id>" # kms key encryption
  }
}
```

- can be added later on
- [ ] my S3 bucket with state file under TF management




## Keeping Secrets Out of State with Ephemeral Values and Write-only Arguments


or how to keep secrets completely out of state

### Ephemeral Values

- only in memory
- never written to State or Plan files
- introduced in `v1.10`
- `ephmeral = true` (variable or output)


! `ephemeral` variable cannot be used in a `resource` block



### Ephemeral Resources

- fetches data at runtime and stored in memory
- open and closed during execution


When to use

- fetching secrets from Vault (or other Secret Manager)
- reading temporary credentials
- retrieving dynamic tokens

Depends on provider - not all resource have `ephemeral` equivalent. 



## Write-Only Arguments


```bash
resource "aws_db_instance" "test" {
  instance_class      = "db.t3.micro"
  password_wo         = "old-password-here"
  password_wo_version = 1
}
```

`wo` - never read them back



## Working with HashiCorp Vault for Dynamic Credentials


- short-lived credentials (2,3,5,10,15 minutes)
- generated on demand
- usually limited scope


