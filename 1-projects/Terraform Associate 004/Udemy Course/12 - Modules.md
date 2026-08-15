
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