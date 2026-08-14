
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

- [ ] create a new repo in milanoid-org and import it


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