- reusable piece of code
- test code in https://github.com/milanoid/mercury-workflows/tree/main/phase-2-modules

Components

1. variables defined in `variables.tf`
2. outputs (e.g. ssh to a created VM) in `outputs.tf`


```terraform
# creating a module "cato"
# source `.modules/customer-infrastructure/main.tf`

module "cato" {
  source = ".modules/customer-infrastructure"
}
```