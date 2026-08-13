
## Define infrastructure with Terraform resources

https://developer.hashicorp.com/terraform/tutorials/certification-004/associate-study-004#read-and-write-configuration


tutorial https://developer.hashicorp.com/terraform/tutorials/configuration-language/resource

In this tutorial, you will create an EC2 instance that runs a PHP web application. You will then refer to documentation in the Terraform Registry to create a security group to make the application publicly accessible.



## Query data source (tutorial)


https://developer.hashicorp.com/terraform/tutorials/configuration-language/data-sources

```bash
# export so the terrafor.tf doesn't need to be changed
export TF_CLOUD_ORGANIZATION="milanvojnovic-org"


...
terraform apply -var aws_region=eu-central-1
```

There are 2 states:

1. `learn-terraform-data-sources-vpc` (networking, infra)
2. `learn-terraform-data-sources-app` (app/ec2)


In HCP Terraform each is having its own workspace.

- state (e.g. outputs) can be shared among HCP TF workspaces
- must be explicitly enabled (in UI - workspace - settings - Remote State Sharing)
- _vpc_ must enable access for _app_ workspace

When shared the app can refer to state outputs of the VPC, e.g.  `aws_region`:

```yaml
provider "aws" {
  region = data.terraform_remote_state.vpc.outputs.aws_region
}
```


- requires `data` block with reference to the remote state of `vpc`
```bash
data "terraform_remote_state" "vpc" {
  backend = "remote"

  config = {
    organization = "milanvojnovic-org"
    workspaces = {

      name = "learn-terraform-data-sources-vpc"
    }
  }
}
```


---

## Create resource dependencies (tutorial)

https://developer.hashicorp.com/terraform/tutorials/configuration-language/dependencies

- dependencies between resources and modules
- inter resources dependencies are most of the time resolved automatically
- in rare cases we need to specify it explicitly - `depends_on` argument

```bash
git clone https://github.com/hashicorp-education/learn-terraform-dependencies
export TF_CLOUD_ORGANIZATION="milanvojnovic-org"

terraform init
```


#### Manage implicit dependencies

- the Elastic IP address (`aws_eip`) can be assigned only the EC2 which
- so the order must be - create EC2 first than assign Elastic IP
- this is implicit -> TF knows that
- TF creates instance A and instance B in parallel - only then EIP

```terraform
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "aws" {
  region = var.aws_region
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "example_a" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
}

resource "aws_instance" "example_b" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
}

resource "aws_eip" "ip" {
  vpc      = true
  instance = aws_instance.example_a.id
}
```

- TF automatically infers (CZ: usuzuje) the order - it knows that thanks to this referrence:
`
```bash
# this creates the implicit dependecy
resource "aws_eip" "ip" {
  vpc      = true
  instance = aws_instance.example_a.id
}
```


```bash
aws_instance.example_b: Creating...
aws_instance.example_a: Creating...
aws_instance.example_a: Still creating... [10s elapsed] aws_instance.example_b: Still creating... [10s elapsed]
aws_instance.example_a: Creation complete after 13s [id=i-0bb3df5bb0974c6cd]
aws_eip.ip: Creating...
aws_instance.example_b: Creation complete after 13s [id=i-0c5c789d42e0bb67e]
aws_eip.ip: Creation complete after 2s [id=eipalloc-0751c0ffcc8e36bd1]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
```


#### Manage explicit dependencies


- for those deps which are not "visibile to TF
- e.g. EC2 that expects to use a specific S3 bucket 
- this dep is defined inside the app (TF can't see that)



```bash
# add this to `main.tf`

resource "aws_s3_bucket" "example" { }

resource "aws_instance" "example_c" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  depends_on = [aws_s3_bucket.example]
}

module "example_sqs_queue" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "3.3.0"

  depends_on = [aws_s3_bucket.example, aws_instance.example_c]
}

```

- added a new module dep - need to run `terraform get` to install the module


```bash
terraform appy

aws_s3_bucket.example: Creating...
aws_s3_bucket.example: Creation complete after 1s [id=terraform-20260812065806621800000001]
aws_instance.example_c: Creating...
aws_instance.example_c: Still creating... [10s elapsed]
aws_instance.example_c: Creation complete after 13s [id=i-074cba09462693602]
module.example_sqs_queue.aws_sqs_queue.this[0]: Creating...
module.example_sqs_queue.aws_sqs_queue.this[0]: Still creating... [10s elapsed] module.example_sqs_queue.aws_sqs_queue.this[0]: Still creating... [20s elapsed]
module.example_sqs_queue.aws_sqs_queue.this[0]: Creation complete after 26s [id=https://sqs.us-west-1.amazonaws.com/268091806187/terraform-20260812065821141500000003]
module.example_sqs_queue.data.aws_arn.this[0]: Refreshing...
module.example_sqs_queue.data.aws_arn.this[0]: Refresh complete after 0s [id=arn:aws:sqs:us-west-1:268091806187:terraform-20260812065821141500000003]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
```

- creates the S3 bucket first as defined via `depends_on` attribute


Both implicit and explicit deps affect the order when running `destroy` too.



## Target resources (tutorial)

https://developer.hashicorp.com/terraform/tutorials/state/resource-targeting

- In a typical Terraform workflow, you apply the entire plan at once. Occasionally you may want to apply only part of a plan
- `-target` option


```bash
git clone https://github.com/hashicorp-education/learn-terraform-resource-targeting


```


### Target the S3 bucket name

main.tf

```
 resource "random_pet" "bucket_name" {
-  length    = 3
+  length    = 5
   separator = "-"
   prefix    = "learning"
 }
```

- running `terraform plan` -> would _replace_ all the resources ( AWS can't rename S3 bucket )

vs

`terraform plan -target="random_pet.bucket_name"` 

- will modify just the bucket name

`terraform plan -target="module.s3_bucket"`


### Target specific bucket objects


- modify the `content` of the "objects" - then plan/apply to some only:

```bash
terraform apply -target="aws_s3_object.objects[2]" -target="aws_s3_object.objects[3]"
```

- updates the selected buckets only


### Target bucket object names


main.tf - remove `prefix`

```
 resource "random_pet" "object_names" {
   count = 4

   length    = 5
   separator = "_"
-  prefix    = "learning"
 }
```

`terraform apply -target="aws_s3_object.objects[2]"`

- TF updates all five object names - not just the one targetted


### Destroy your infrastructure

- also supports targeting

```bash
terraform destroy -target="aws_s3_object.objects"
```

- destroy all S3 bucket objects (files)



---

## Customize Terraform configuration with variables (tutorial)

https://developer.hashicorp.com/terraform/tutorials/configuration-language/variables


- simple values - _string_, _number_, _bool_
- collection value - _list_, _map_, _set_

List - a sequence of values of the same type, `list(string`

Map - A lookup table, matching keys to values, all of the same type

Set - An unordered collection of unique values, all of the same type


`slice()` - function to get a subset of these lists

### terraform console

- interactive console for evaluating _expressions_

https://developer.hashicorp.com/terraform/cli/commands/console

```bash
# a cli - can query the variables
> terraform console

> var.private_subnet_cidr_blocks
tolist([
  "10.0.101.0/24",
  "10.0.102.0/24",
  "10.0.103.0/24",
  "10.0.104.0/24",
  "10.0.105.0/24",
  "10.0.106.0/24",
  "10.0.107.0/24",
  "10.0.108.0/24",
])

```


```bash
> echo 'split(",", "foo,bar,baz")' | terraform console 
tolist([ 
	"foo", 
	"bar", 
	"baz", 
])
```