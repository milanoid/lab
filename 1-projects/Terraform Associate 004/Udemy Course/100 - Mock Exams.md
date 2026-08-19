https://statsperform.udemy.com/course/terraform-associate-004-practice-exams/learn/quiz/7202495#overview


course practice exam https://statsperform.udemy.com/course/hashicorp-certified-terraform-associate-004/learn/quiz/7371931/results?expanded=1795941787#overview



focus - Modules


```bash
module "vpc" {
	# proper registry module syntax of `NAMESPACE/NAME/PROVIDER`
	source = "hashicorp/vpc/aws"
	# ... other arguments
}
```


---

- [x] Test 1 89 %

Q: Your team is discussing why Terraform maintains a state file. Which of the following are valid reasons why Terraform requires state? (select three)

A: 1 - improve performance by caching resource attributes
A: 2 - map real-world resources to your Terraform configuration
A:3 - track metadata such as resource dependencies

---

Q: Your organization manages a Google Cloud project with 50 resources across multiple services. You need to **decommission** only the Cloud SQL database instance and its backup policy while keeping all other infrastructure running. What is the most appropriate approach?

A: Remove the database and backup `resource` blocks from your configuration, then run `terraform apply`.

---

Q: You've decided to change your backend configuration from S3 to HCP Terraform. After updating the `backend` block, you run `terraform init`. Which flag should you use to reconfigure the backend without copying the existing state?

A: `terraform init -reconfigure`


---

Q: Why should users not commit the `terraform.tfstate` file to version control? (select two)

A: 1 -VCS provides no state locking, so concurrent runs can cause conflicting commits and corrupt state.
A: 2 - State can include plaintext secrets and detailed resource data and commit history can expose them.

---

Q: Which of the following statements is the most accurate about the Terraform language?

A: Terraform is an immutable, declarative Infrastructure as Code language based on HashiCorp Configuration Language or JSON.

---

Q: You are deploying virtual machines across multiple cloud regions. Since images are assigned a unique ID per region, you need to create a variable that looks up the correct ID based on the region name. Which code snippet uses the variable type that is most appropriate for this use case?

A: Using a `set(string)` variable type is not the most appropriate choice for this use case because sets do not allow duplicate values.

```bash
variable "image" {
   type = set(string)
   ...
}
```


- [x] Test 2 85 %


Q: True or False? After successfully applying a `moved` block to refactor your resources, you should immediately remove the `moved` block from your configuration to keep your code clean.

A: False

---

Q: In HCP Terraform, what scope levels are available for providing variables to workspaces? (select three)

A: 1 - A single workspace by defining variables directly in that workspace.
A: 2 - All current and future workspaces and Stacks within a project using a variable set.
A: 3 - Multiple workspaces with a variable set

---

Q: You maintain an existing Terraform configuration that uses a public module pinned to a specific version. A new minor version `5.3.0` of the module is available, and you want your configuration to use it. What steps are required to update the module version safely? (select two)


```bash
 module "compute" {
   source  = "azure/compute/azurerm"
   version = "5.2.0"
   # …module inputs…
 }
```

A: 1 - update the `version` argument to allow `5.3.0` using `version = "~> 5.3.0"`
A: 2 - run `terraform init -upgrade` to download the new module version

---

Q: You have an existing Google Cloud Storage bucket that was created manually. You want to bring it under Terraform management using a modern config-driven approach, so you add the following configuration:

```bash
 import {
   to = google_storage_bucket.data_lake
   id = "bk-existing-bucket"
 }

 resource "google_storage_bucket" "data_lake" {
   name     = "bk-existing-bucket"
   location = "US"
 }
```

A: run `terraform plan` followed by `terraform apply` to import the resource


---

Q: Your team wants to enforce consistent formatting across all Terraform files before merging code into the main branch. You're setting up a CI/CD pipeline and need a command that checks whether files are properly formatted without making changes. Which command should you use?

A: `terraform fmt -check`

---

Q: Your organization wants to ensure that third-party security scanning tools can review Terraform plans before any infrastructure changes are applied. Which HCP Terraform feature allows you to integrate external tools into the workflow between the plan and apply phases?

A: run tasks

---

Q: You're deploying a GCP Compute Engine instance and want to verify that the instance receives a public IP address after creation. If it doesn't, you want Terraform to fail with an error. Which validation mechanism should you use?

A: add a `postcondition` in the `lifecycle` block of the instance resource

---

Q: What is the `.terraform.lock.hcl` file and when does Terraform create or modify it?

A: The `.terraform.lock.hcl` file is a dependency lock file used by Terraform. It is created or updated every time you run `terraform init`.



- [x] Test 3 - 85 %



Q: You’re using the `local` backend. In the current workspace, `terraform.tfstate` was accidentally deleted, but the configuration is unchanged. You run `terraform plan`.

A: 1 - Terraform will try to create previously managed resources.
A: 2 - Data sources may still read remote systems during planning, but they do not fix the resource state.
A: 3 - `terraform destroy` cannot identify any resources to destroy until state is restored

---

Q: Which method below ensures sensitive information is not stored in the state file?

A: none of the above


---

Q: You open the `terraform.tfstate` file in a text editor to inspect it. What format is the file, and what type of information does it contain?

A: JSON format containing resource metadata, attributes, dependencies, and potentially sensitive values in plaintext

---

Q: You have an existing VPC in your account and have added the `data` block to your configuration, as shown below. How would you reference the `id` of the VPC

```bash
 data "aws_vpc" "production" {
   tags = { Name = "prod" }
 }
```

A: `data.aws_vpc.production.id`


---

Q: Your team manages long-lived VMs with a configuration management tool, but drift and rollbacks are frequent. You’re evaluating alternatives. Which option best reflects an IaC advantage over traditional configuration management?

A: Using declarative IaC and immutable infrastructure allows you to define the desired state in code, easily replace resources, and version everything.


---

Q: Your team needs to capture Terraform logs for a production deployment. You want the logs saved to a file rather than displayed in the terminal so you can review with senior engineers. Which environment variable should you set to specify the log file location?

A: `TF_LOG_PATH`

---

Q: You need to launch an EC2 instance into the existing subnet of your production VPC and restrict SSH to the VPC CIDR. You add the following data sources as shown below. Which snippets correctly use the returned attributes from these data sources in your configuration? (select two)

```
data "aws_vpc" "prod" {
  tags = { Name = "bk-prod" }
}
 
data "aws_subnet" "app" {
  filter {
    name   = "tag:Tier"
    values = ["bk-app"]
  }
  vpc_id = data.aws_vpc.prod.id
}
```

A: 1

```
resource "aws_instance" "web" {
  ami           = "ami-0abcd1234"
  instance_type = "t3.micro"
  subnet_id     = data.aws_subnet.app.id
}
```

A: 2 

```
resource "aws_security_group" "ssh" {
  name   = "ssh"
  vpc_id = data.aws_vpc.prod.id
 
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.prod.cidr_block]
  }
}
```

---

Q: Your team is using two HCP Terraform workspaces. The `prod-webserver` workspace has successfully deployed an Azure VM. You're now working in the `prod-dns` workspace and need to use the public IP to create a DNS record. The webserver IP keeps changing, so you don't want to manually update a variable whenever it changes.

What can you add to the `prod-dns` workspace to automatically retrieve the IP from `prod-webserver`?

A: a `tfe_outputs` data source that references the `prod-webserver` workspace


```
data "tfe_outputs" "webserver" { 
  organization = "bk-organization"
  workspace    = "prod-webserver" 
} 
```


- [x] Test 4 - 89 %


Q: Your AWS provider configuration is shown in the exhibit below. When running a `terraform plan`, the region is set to `us-west-2` in the provider block, but the `AWS_REGION` environment variable is set to `eu-west-1`. Which region will the provider use?

```
provider "aws" {
  region = "us-west-2"
  default_tags {
    tags = {
      Project = "Project-502"
    }
  }
}  
```

A: `us-west-2` from the provider block configuration

---

Q: When using Terraform, where can providers be installed from? (select four)

A: !! not from source

From Terraform’s perspective, official install sources are:

- public registry,
    
- private/external registries,
    
- local mirrors/cache,
    
- HCP Terraform private registry.
  
  
--- 

Q: You have declared a variable named `db_connection_string` inside of the `app` module. However, when you run a `terraform apply`, you get the following error message:

```
    Error: Reference to undeclared input variable
     
    on main.tf line 35:
    35: db_path = var.db_connection_string
     
    An input variable with the name "db_connection_string" has not been declared. This variable can be declared with a variable "db_connection_string" {} block.


```

Why would you receive such an error?

A: since the variable was declared within the module, it cannot be referenced outside of the module

%^%a%d^w

---
Q: You execute Terraform runs from a CI pipeline and must move an existing resource from Stack A’s state to Stack B’s state without destroying it. Which two configuration blocks enable this configuration-driven workflow? (select two)

A: `removed` block in the source stack + `import` block in the destination stack

--- 

Q: You have developed a module named `web` that creates a public DNS record for a load balancer. You want to provide an output in the CLI so that you can simply click the URL and access the application after running `terraform apply`. What code snippets would satisfy these requirements? (select two)


A: 
```Add this to the root module in the `outputs.tf` file:
output "website_url" {
  value = "https://${module.web.public_dns}:8080/index.html"
}
```

```Add this to the /modules/web/outputs.tf file:

    output "public_dns" {
      description = "DNS name of the web load balancer"
      value       = aws_lb.web.dns_name
    }
```

---

Q: You want to use the new features available in Terraform 1.12.0 and change the `required_version` constraint in your configuration to `~> 1.12.0`. After committing and pushing the change, your HCP Terraform run fails with an error stating that the Terraform version does not meet the `required_version` constraint. What is the most likely cause of this error?

A: The Terraform version setting in HCP Terraform workspace is still set to an older version and needs to be updated to 1.12.0 or later.

The most likely cause of the error is that the Terraform version setting in the HCP Terraform workspace is still configured to use an older version, which does not meet the `required_version` constraint of `~> 1.12.0`. Updating the Terraform version setting in the workspace to 1.12.0 or later should resolve this issue.

---


- [x] Test 5 - 87 %


Q: You have decided to remove a VM from your design and need Terraform to delete it without using the `terraform destroy` command. What should you do next? (select two)

A: 1 - Run `terraform apply` to reconcile state with the new desired configuration.
A: 2 - Delete the VM’s resource block from the configuration.

---

Q: You are managing multiple resources using Terraform. You want to destroy all the resources except for a single web server, which should remain running but no longer be managed by Terraform. How can you accomplish this?

A: Add a `removed` block with `from = <address>` to stop managing the web server, then run `terraform apply` followed by `terraform destroy`


---

Q: You have developed several new modules to share with the team and need to validate them. You also want to validate the root module. What steps should you take? (select two)

A: 1 - run the `terraform test` command to validate the modules
A: 2 - add `.tftest.hcl` files with run and assert blocks to each module


---

Q: You're creating a GCP configuration that requires creating a storage bucket first, then creating an IAM binding that grants access to it. The problem is that the IAM binding doesn't directly reference the bucket resource, so it's being created too quickly. How do you ensure the bucket is created before the IAM binding is applied?

A: add a `depends_on = [google_storage_bucket.data]` to the IAM binding `resource` block

---

Q: Your organization uses infrastructure across AWS, Azure, and on-premises VMware environments. The team is evaluating whether to use Terraform or separate cloud-native tools for each platform. Which statements accurately describe how Terraform handles multi-cloud and hybrid cloud workflows? (select three)

A: 1 - A single Terraform configuration can define resources across multiple cloud providers and on-premises infrastructure simultaneously.

A: 2 - Terraform's provider ecosystem allows it to manage resources beyond traditional cloud services, including SaaS platforms and network devices.

A: 3 - Terraform uses a consistent workflow and syntax across different cloud providers, reducing the learning curve for managing multi-cloud infrastructure.

---
Q: Your child module creates an Azure storage account and defines this output as shown in the exhibit below.

```
    output "storage_account_name" {
      value = azurerm_storage_account.data.name
    }

In your root module, you call this module as shown below:

    module "storage" { 
      source = "./modules/storage" 
    }
```

A: `module.storage.storage_account_name`

----

Q: After many hours of development, you've created a new Terraform configuration from scratch, and now you want to test it. Before provisioning the resources, what is the first command you should run?

A: `terraform init`


- [ ] Test 6