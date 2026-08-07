

# Terraform plugins

https://developer.hashicorp.com/terraform/plugin/how-terraform-works

Two main components - Terraform Core and Terraform Plugins


## Terraform Core

- Go binary (`terraform` CLI command - entrypoint for anyone using Terrraform)
- responsibilities: IaC, Resource state management, Construct of the Resource Graph, Plan execution, Communication with plugins via RPC

## Terraform Plugins

- also in Go
- exposes an implementation for a specific service (e.g. AWS, Github)
- all _Providers_ and _Provisioners_ are _Plugins_

### Responsibilities

#### Provider Plugins

- init libraries used to make API calls
- authentication with Infrastructure Provider

#### Provisioner Plugins

- executing commands or scripts on the designated Resource after creating, or on destruction

---


# Purpose of Terraform State

https://developer.hashicorp.com/terraform/language/v1.12.x/state/purpose

Why is it required? Why not to query the real state on every run?


