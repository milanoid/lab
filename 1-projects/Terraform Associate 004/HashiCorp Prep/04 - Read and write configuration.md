
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


- simple - _string_, _number_, _bool_
- collection - _list_, _map_, _set_
- structural - _tuple_, _object_

List - a sequence of values of the same type, `list(string`

Map - A lookup table, matching keys to values, all of the same type

Set - An unordered collection of unique values, all of the same type


`slice()` - function to get a subset of these lists

#### terraform console

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

- that doesn't work when having the state remote (HCP Terraform), even tried that with `terraform console -plan`


```bash
> echo 'split(",", "foo,bar,baz")' | terraform console 
tolist([ 
	"foo", 
	"bar", 
	"baz", 
])
```

```bash
> cidrnetmask("172.16.0.0/12")
"255.240.0.0"
```

There default functions

- Numerical (`max()`...)
- String ( `endswith()` ...)
- Collection ( `alltrue([true, true])`)
- Encoding functions
- Filesystem functions
- Data and time
- Hash and crypto
- IP network
- Type conversion
- Terraform specific

- functions available: https://developer.hashicorp.com/terraform/language/functions


#### Assigning a value to a variable

1. command line flag: `terraform apply -var ec2_instance_type=t2.micro`
2. with a file `*.auto.tfvars` - TF loads such files

### Interpolate variables in strings

- inserting the output of an expression into a string

```bash
name = "lb-${random_string.lb_id.result}-${var.resource_tags["project"]}-${var.resource_tags["environment"]}"
```


### Validate variables

```bash
variable "resource_tags" {
  description = "Tags to set for all resources"
  type        = map(string)
  default     = {
    project     = "my-project",
    environment = "dev"
  }

  validation {
    condition     = length(var.resource_tags["project"]) <= 16 && length(regexall("[^a-zA-Z0-9-]", var.resource_tags["project"])) == 0
    error_message = "The project tag must be no more than 16 characters, and only contain letters, numbers, and hyphens."
  }

  validation {
    condition     = length(var.resource_tags["environment"]) <= 8 && length(regexall("[^a-zA-Z0-9-]", var.resource_tags["environment"])) == 0
    error_message = "The environment tag must be no more than 8 characters, and only contain letters, numbers, and hyphens."
  }
}
```



```bash
$ terraform apply -var='resource_tags={project="my-project",environment="development"}'
random_string.lb_id: Refreshing state... [id=CVB]
data.aws_availability_zones.available: Reading...
data.aws_availability_zones.available: Read complete after 1s [id=us-west-2]

Planning failed. Terraform encountered an error while generating this plan.

╷
│ Error: Invalid value for variable
│
│   on variables.tf line 72:
│   72: variable "resource_tags" {
│     ├────────────────
│     │ var.resource_tags["environment"] is "development"
│
│ The environment tag must be no more than 8 characters, and only contain
│ letters, numbers, and hyphens.
│
│ This was checked by the validation rule at variables.tf:85,3-13.

```




## Variables docs

https://developer.hashicorp.com/terraform/language/v1.12.x/values/variables

- `sensitive = true` - value won't be displayed in CLI output
- `ephemeral = true` - value omit from state and plan files

On how to manage sensitive data https://developer.hashicorp.com/terraform/language/v1.12.x/manage-sensitive-data





## Output data from Terraform (tutorial)


https://developer.hashicorp.com/terraform/tutorials/configuration-language/outputs


1. create infrastructure

```bash
git clone https://github.com/hashicorp-education/learn-terraform-outputs
```


```bash
# outputs.tf
output "vpc_id" {
  description = "ID of project VPC"
  value       = module.vpc.vpc_id
}

output "vpc_name" {
  description = "The name of the VPC"
  value       = module.vpc.name
}


output "lb_url" {
  # uses string interpolation
  description = "URL of load balancer"
  value       = "http://${module.elb_http.elb_dns_name}/"
}

output "web_server_count" {
  # uses length functon to count instances
  description = "Number of web servers provisioned"
  value       = length(module.ec2_instances.instance_ids)
}
```


```bash
# terraform apply
# ....

Outputs:
web_server_count = 4
lb_url = "http://lb-ZMn-project-alpha-dev-786610010.us-east-1.elb.amazonaws.com/"
vpc_id = "vpc-097f73de93fec0cb6"
vpc_name = null
```

### Query outputs

```bash
# after creating the outputs
> terraform output 
lb_url = "http://lb-ZMn-project-alpha-dev-786610010.us-east-1.elb.amazonaws.com/" 
vpc_id = "vpc-097f73de93fec0cb6" 
vpc_name = "" 
web_server_count = 4
```

query an individual output

```bash
# string in quotes by default
> terraform output lb_url
"http://lb-ZMn-project-alpha-dev-786610010.us-east-1.elb.amazonaws.com/"


# unquote - for machine-readable format
> terraform output -raw lb_url
http://lb-ZMn-project-alpha-dev-786610010.us-east-1.elb.amazonaws.com/
```


### Redact sensitive outputs


- for sensitive data
- not printed when planning, applying, or destroying
- printed though when queried by name and in some other cases too

```bash
output "db_username" {
  description = "Database administrator username"
  value       = aws_db_instance.database.username
  sensitive   = true
}

output "db_password" {
  description = "Database administrator password"
  value       = aws_db_instance.database.password
  sensitive   = true
}
```


```bash
# tarraform apply
# ...

vpc_name = null
web_server_count = 4
db_password = (sensitive value)
db_username = (sensitive value)
lb_url = "http://lb-ZMn-project-alpha-dev-786610010.us-east-1.elb.amazonaws.com/"
vpc_id = "vpc-097f73de93fec0cb6"
```


```bash
# visible when queried by name
> terraform output db_password 
"notasecurepassword"
```

pull remote state file from HCP Terraform

```bash
> terraform state pull > terraform.tfstate
> grep --after-context=10 outputs terraform.tfstate
  "outputs": {
    "db_password": {
      "value": "notasecurepassword",
      "type": "string",
      "sensitive": true
    },
    "db_username": {
      "value": "admin",
      "type": "string",
      "sensitive": true
    }
```


Generate machine-readable output

```bash
> terraform output -json
{
  "db_password": {
    "sensitive": true,
    "type": "string",
    "value": "notasecurepassword"
  },
  "db_username": {
    "sensitive": true,
    "type": "string",
    "value": "admin"
  },
  "lb_url": {
    "sensitive": false,
    "type": "string",
    "value": "http://lb-ZMn-project-alpha-dev-786610010.us-east-1.elb.amazonaws.com/"
  },
  "vpc_id": {
    "sensitive": false,
    "type": "string",
    "value": "vpc-097f73de93fec0cb6"
  },
  "vpc_name": {
    "sensitive": false,
    "type": "string",
    "value": ""
  },
  "web_server_count": {
    "sensitive": false,
    "type": "number",
    "value": 4
  }
}
```


-  ? - Claude says it's OK - the ENI is owner by AWS not me, TF tries to destroy it explicitly to speed up destroy of the ELB

```bash
> terraform destroy


│ Warning: cleaning up ELB Classic Load Balancer (lb-ZMn-project-alpha-dev) ENIs: detaching EC2 Network Interface (eni-0642bb5e6730affb3/eni-attach-0ff3cbb695f4ef641): AuthFailure: You do not have permission to access the specified resource.
│       status code: 400, request id: 5b8f7487-8d1e-4c43-b292-5086eaf23d76
│ detaching EC2 Network Interface (eni-0239ebd937a363aed/eni-attach-04a396f7b3bd6ab52): AuthFailure: You do not have permission to access the specified resource.
│       status code: 400, request id: 1237113a-6a1c-472c-bce3-22df3461963b
│
│
╵
╷
│ Warning: EC2 Default Network ACL (acl-02d1f7fdf63263d8b) not deleted, removing from state
│
│
╵

Apply complete! Resources: 0 added, 0 changed, 49 destroyed.
```



## Perform dynamic operations with functions (tutorial)

https://developer.hashicorp.com/terraform/tutorials/configuration-language/functions

```bash
git clone https://github.com/hashicorp-education/learn-terraform-functions
```

### Use templatefile to dynamically generate a script

Used in SP Jenkins controller TF


```bash
resource "aws_instance" "web" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.subnet_public.id
  vpc_security_group_ids      = [aws_security_group.sg_8080.id]
  associate_public_ip_address = true
  user_data                   = templatefile("user_data.tftpl", { department = var.user_department, name = var.user_name })
}
```

- `templatefile` https://developer.hashicorp.com/terraform/language/functions/templatefile
- `templatefile(path, vars)`

### Create infrastructure

```bash
> terraform apply
Apply complete! Resources: 7 added, 0 changed, 0 destroyed.

Outputs:
web_public_address = "54.211.3.35:8080"
web_public_ip = "54.211.3.35"
```

http://54.211.3.35:8080/ - tetris game! :)

```bash
# get instance_id
TARGET=$(aws ec2 --region='us-east-1' describe-instances --profile milanoid --filters Name=instance-state-name,Values=running --query "Reservations[*].Instances[*].InstanceId" --output text)
i-0b905467894dde3ef


# access the instance
aws ssm start-session --region us-east-1 --target $TARGET --profile milanoid
aws: [ERROR]: An error occurred (TargetNotConnected) when calling the StartSession operation: i-0b905467894dde3ef is not connected. 
```

Doesn't work because 'DHMC is not enabled and IAM instance profile is not attached': https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-getting-started-instance-profile.html

But can connect via AWS Console - EC2 Instance Connect if ssh port 22 inbound connections is allowed - update `aws_security_group`

```bash
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
```

Once applied the EC2 Instance Connect works.

When a user data script is processed, it is [copied to and run from ](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html)``/var/lib/cloud/instances/`instance-id`/``. The script is not deleted after it is run.



### Use `lookup` function to select AMI

https://developer.hashicorp.com/terraform/tutorials/configuration-language/functions#use-lookup-function-to-select-ami

`lookup` - https://developer.hashicorp.com/terraform/language/functions/lookup

`lookup(map, key, default)` - returns a single element - `key` - from a map, fallback to `defautl`

```bash
> lookup({a="ay", b="bee"}, "a", "what?")
ay
> lookup({a="ay", b="bee"}, "c", "what?")
what?
```





### Use the `file` function

https://developer.hashicorp.com/terraform/language/v1.12.x/functions/file

- reads the contents of a file at the given path and returns them as a string.


In this section, you will create a new security group to allow SSH ingress traffic to your instance and configure the instance with an SSH key.

#### Create an SSH key and a security group resource

```bash
ssh-keygen -C "your_email@example.com" -f ssh_key
```


```bash
# main.tf
resource "aws_security_group" "sg_22" {
  name = "sg_22"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port = 22
    to_port  = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "ssh_key" {
  key_name = "ssh_key"
  public_key = file("ssh_key.pub")
}

```