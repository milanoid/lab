
are containers of related resources that are used together

- improves organization
- easier collaboration
- consistent patterns

## Child vs Parent Module

Parent (also Calling, Root) Module references and configures other modules.

E.g. a Web Application (Parent Module) -> references WebServer, LoadBalancer, SecurityGroups ... (these are Child Modules)

The Child Modules can be pulled from:

- Registry
- a GItHub repo
- local filesystem



## Module Versioning and Version Constraints



## Understanding Variable Scope in Modules


![[Pasted image 20260815162004.png]]

- to use a Child Module variable in Root Module, it must be passed explicitly

### Passing variables (data) from Root to Child Module (-->)

- we have `environment` variable in Root Module
- in Child Module it become `var.env` (an input variable)

`env = var.environment` ---> `var.env` 


```bash
module "jenkins" {
  source = "git@github.com:org/tf-child-module.git?ref=2.1.0"
  env                                   = var.environment
```


### Passing variables (data) from Child to Root Module (<--)


Child Module must have `output` block 

```bash
output "child_module_output" {
  value = a_value
}

```

then in Root Module reference by:

```bash
module.jenkins.child_module_output
```


## Using Modules from Terraform Registry


e.g. https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest

I don't have to write a `resource` block for a S3 bucket. I can use create a `module` block with `source` of that module. And let the Child Module do the heavy lifting.


```bash
module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "my-s3-bucket"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }
}
```

the module code: https://github.com/terraform-aws-modules/terraform-aws-s3-bucket

- [x] exercise - create S3 bucket using the official module:


```bash
milan@SPM-LN4K9M0GG7 ~/repos/milanoid-labs-terraform/playground/s3-official-module-usage (main)
> tofu fmt
milan@SPM-LN4K9M0GG7 ~/repos/milanoid-labs-terraform/playground/s3-official-module-usage (main)
> tofu validate
╷
│ Error: Module not installed
│
│   on main.tf line 3:
│    3: module "s3-bucket" {
│
│ This module is not yet installed. Run "tofu init" to install all modules required by this configuration.
╵
milan@SPM-LN4K9M0GG7 ~/repos/milanoid-labs-terraform/playground/s3-official-module-usage (main)
> tofu init

Initializing the backend...
Initializing modules...
Downloading registry.opentofu.org/terraform-aws-modules/s3-bucket/aws 5.15.4 for s3-bucket...
- s3-bucket in .terraform/modules/s3-bucket

Initializing provider plugins...
- Finding hashicorp/aws versions matching ">= 6.42.0, 6.60.0"...
- Installing hashicorp/aws v6.60.0...
- Installed hashicorp/aws v6.60.0 (signed, key ID 0C0AF313E5FD9F80)

Providers are signed by their developers.
If you'd like to know more about provider signing, you can read about it here:
https://opentofu.org/docs/cli/plugins/signing/

OpenTofu has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that OpenTofu can guarantee to make the same selections by default when
you run "tofu init" in the future.

OpenTofu has been successfully initialized!

You may now begin working with OpenTofu. Try running "tofu plan" to see
any changes that are required for your infrastructure. All OpenTofu commands
should now work.

If you ever set or change modules or backend configuration for OpenTofu,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.


> tofu plan
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

s3_bucket_arn = "arn:aws:s3:::terraform-a3f3e628cad83189f2aa0faefc"
```