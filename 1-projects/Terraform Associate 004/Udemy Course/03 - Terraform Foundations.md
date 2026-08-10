
## HCL - HashiCorp Configuration Language

- declarative language (order a food in restaurant, not step-by-step procedure for a chef)


### Syntax

```hcl
# single comment
block_type "block_label" "block_label" {
	first_agument = expression or value
	second
	third
}

attribute_1 = "value1"
attribute_2 = "value2"
```

example

```hcl
# retrieve the list of AZs in the current AWS region
data "aws_availability_zones" "available" {}
data "aws_region" "current" {}

# define the VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  
  tags = {
    Name        = var.vpc_name
    Environment = "demo"
    Terraform   = "true"
  }
}
```


- `data` blocks - to retrieve data on existing resources
- `resource` blocks - representation of a cloud resource (e.g. EC2)
- `resource` blocks have `arguments` (e.g. tags)
- `#` - single line comments


#### Block

- Type of block   = `resource`
- Resource Type = `"aws_vpc"`
- Name (Label?)  = `"vpc"`


```
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  
  tags = {
    Name        = var.vpc_name
    Environment = "demo"
    Terraform   = "true"
  }
}
```

- delineated by `{}`
- starts with a keyword
- have named values

#### HCL Style Guide

- snake_case - e.g. `"block_label"`
- indention: 2 spaces (not tabs)
- equal `=` lines aligned
- newline to separate groups of arguments in a block
- `terraform fmt`


#### Resource Referencing


Create More Dynamic Configurations

- no (much) hardcoding values
- can reference value of a one resource to another


Automatic Dependency Mapping

- TF determines the order of resource creation


Resource Identifiers

- by type and name




#### HCL Basics

