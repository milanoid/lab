 Block Types

- `provider` - connection to cloud platforms
- `resource` - infra (e.g. VMs)
- `data` - retrieve info on existing resources
- `variable` - make code reusable
- `outputs` - display or share information about resources after deployment
- `terraform` - settings, e.g. Terraform version
- `module` - reusable configs that groups together related resources
- `import` - pull existing resources into TF management


## Provider Block - aws example

- usually in file `provider.tf`
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs

```yaml
provider "aws" {
  region = "eu-central-1"
}
```


### aws provider credentials

1. environment variables
2. `profile` argument
3. shared configuration and credential files
4. ... others

```bash
# env vars
% export AWS_ACCESS_KEY_ID="anaccesskey"
% export AWS_SECRET_ACCESS_KEY="asecretkey"
% export AWS_REGION="us-west-2"
% terraform plan
```


```yaml
provider "aws" {
  shared_config_files      = ["/Users/tf_user/.aws/conf"]
  shared_credentials_files = ["/Users/tf_user/.aws/creds"]
  profile                  = "customprofile"
}
```

- providers live on GitHub but listed in Terraform Registry, can be self-hosted too


Using `alias`:

```yaml
provider "aws" {
  profile = "customprofile-eu"
  region  = "eu-central-1"
  alias   = "eu"
}

provider "aws" {
  profile = "customprofile-us"
  region  = "us-west-1" 
  alias   = "us"
}

resource "aws_s3_bucket" "eu_bucket" {
  provider = aws.eu
  bucket   = "my-eu-bucket"
}

```

