Hashicorp Cloud Platform


- Remote Execution (default, recommended)
- Local Execution (limited HCP features)

HCP Workspace != CLI Terraform Workspace


![[Pasted image 20260815205518.png]]


CLI triggered Run vs VCS Automated Run

For the VCS triggered Run the GH repository must be connected to the HCP Terrafom Workspace.



## Private Registry

HCP Terraform offers private registry for Terraform Modules.


```bash
source = "app.terraform.io/example_corp/vpc/aws"
```

## Policy Enforcement - Sentinel (cz: stráž)


e.g. do not allow to create public S3 bucket

Policy as Code

two frameworks available

1. Hashicorp Sentinel
2. Open Policy Agent (OPA) - CNCF

https://www.openpolicyagent.org/ - OPA uses Rego language (SP!)



### Sentinel Enforcement Level

Advisory
Soft Mandatory
Hard Mandatory

### OPA Levels

Advisory
Mandatory


## Additional HCP Terraform Workspace Features


### Health Assessments

- Drift Detection
- Continues Validation


### Run Triggers

- a Workspace can depend on another one (e.g. Networking)


## Tracking Work with _Change Request_

- like a GitHub Issue or a Jira ticket



## Explorer

- gaining visibility across organization






