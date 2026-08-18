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


- [x] Test 2


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



- [ ] Test 3








- [ ] Test 4
- [ ] Test 5
- [ ] Test 6