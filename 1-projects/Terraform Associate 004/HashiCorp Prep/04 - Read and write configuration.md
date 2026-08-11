
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