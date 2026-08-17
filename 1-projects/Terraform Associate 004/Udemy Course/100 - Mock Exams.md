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


- [ ] Test 2
- [ ] Test 3
- [ ] Test 4
- [ ] Test 5
- [ ] Test 6