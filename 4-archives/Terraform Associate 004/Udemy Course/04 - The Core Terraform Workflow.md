write -> plan -> apply



## Resource Graph

- what actually happens when you run a Terraform plan
- order in which resources are created/destroyed
- happens behind the scene
- order can be set explicitly - [`depends_on`](https://developer.hashicorp.com/terraform/language/meta-arguments/depends_on)

VPC must exists before a subnet or an EC2.


### Dependencies

- Implicit dependencies (automatic)
- Explicit dependencies (manual) - `depends_on`


Terraform run up to 10 parallel processes (default).

