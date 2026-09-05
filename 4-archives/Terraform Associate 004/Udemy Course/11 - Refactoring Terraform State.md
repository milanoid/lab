
## Refactoring Terraform State

Common scenarios:

- you renamed a resource in your code
- you're reorganizing modules
- you need to adopt existing infrastructure
- you want to stop managing a resource but keep it running

-> Without refactoring tools, Terraform thinks you're destroying old resources and creating new ones


`terraform state mv|rm`, `terraform import` - the old way via CLI

new way - configuration blocks: `moved`, `removed`, `import`
 - can be tester before applying


### `moved` 

- rename or relocate resources

```bash
moved {
  from = azurerm_subnet.subnet1
  to.  = azurerm_subnet.prod_private
}
```


### `removed`

- stop managing but keep it running

```bash
removed {
  from = aws_instance.production_db
  
  lifecycle {
     destroy = true
  }
}
```


### `import`

- adopt existing infrastructure into TF


```bash
import {
  to = aws_s3_bucket.terraform_state
  id = "terraform_state_bucket"
}
```

- needs to have a `resource` block created:

```bash
resource "aws_s3_bucket" "terraform_state" {
  description = "Terraform State bucket"
}
```



```bash
terraform plan -generate-config-out=PATH
```

- or, terraform can create `resource` block for me


Exercise:

- [x] create a new repo in milanoid-org and import it https://github.com/milanoid-labs/milanoid-labs-terraform/pull/25


```bash
# import.tf
import {
  to = github_repository.import-me-tofu
  id = "milanoid-labs/import-me-tofu"
}
```

```bash
> tofu plan
╷
│ Error: Configuration for import target does not exist
│
│   on import.tf line 1:
│    1: import {
│
│ The configuration for the given import github_repository.import-me-tofu does not exist. All target instances must have an associated configuration to be
│ imported.
╵
```

- the `id` - is only the repo name (without org, which is already specified elsewhere)


apply failed:


```bash
  Enter a value: yes

github_repository.this["import-me-tofu"]: Importing... [id=import-me-tofu]
github_repository.this["import-me-tofu"]: Import complete [id=import-me-tofu]
github_repository.this["import-me-tofu"]: Modifying... [id=import-me-tofu]
github_repository.this["import-me-tofu"]: Modifications complete after 6s [id=import-me-tofu]
github_repository_file.codeowners["import-me-tofu"]: Creating...
╷
│ Warning: Value derived from a deprecated source
│
│   with github_repository_file.codeowners["import-me-tofu"],
│   on codeowners.tf line 8, in resource "github_repository_file" "codeowners":
│    8: resource "github_repository_file" "codeowners" {
│
│ This value is derived from github_repository.this.default_branch, which is deprecated.
╵
╷
│ Error: unexpected status code: 404 Not Found
│
│   with github_repository_file.codeowners["import-me-tofu"],
│   on codeowners.tf line 8, in resource "github_repository_file" "codeowners":
│    8: resource "github_repository_file" "codeowners" {
│
╵
milan@SPM-LN4K9M0GG7 ~/repos/milanoid-labs-terraform (tofu-import-excercise)
```

- need to declare dependency `depends_on` ?
- not even re-plan/re-apply didn't help
- [x] why it fails? - the repo was empty - had to git init and push a first commit


```bash
> git clone git@github.com:milanoid-labs/import-me-tofu.git
Cloning into 'import-me-tofu'...
warning: You appear to have cloned an empty repository.
```

