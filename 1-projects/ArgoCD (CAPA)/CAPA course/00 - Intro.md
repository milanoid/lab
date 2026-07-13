course portal https://trainingportal.linuxfoundation.org/learn/course/devops-and-workflow-management-with-argo-lfs256

## my labs

1. k3s homelab (ArgoCD, Argo Workflows)
2. Rancher Desktop


#Essential Concepts for Argo

### What Is GitOps?

- drift
- single source of truth
- desired state

Declarative configuration

 - define the desired state, rather than how to get there
 - e.g. app should have run three containers
 - agent compares the desired and current state and performs actions to align
 - contrast to imperative style (specify commands to get to state step by step)

Immutable storage

- Git not only a version control but serves as immutable storage for configuration
- Git is a single source of truth for desired state

Automation

- software agents takes over after git change, no manual steps
- agents applies changes via continues reconciliation process

Close loops

- continues reconciliation process (check the git for desired state and apply changes to have that state on the system) to mitigate drift


### What Is Argo?

- set of Kubernetes-native tools to enhance the workflow management caps of Kubernetes

- ArgoCD for state management
- Argo Workflows for running complex jobs
- Argo Events for event-based dep management
- Argo Rollouts fro progressive delivery


### ArgoCD

also covered in [[02 - Argo CD]]

- declarative GitOps CD tool for Kubernetes
- automates applying Kubernetes manifests from a Git repo to cluster
- continuously monitors the repo for changes
- when a change is detected in syncs the cluster to match the desired state

### Argo Workflows

also covered in [[01 - Argo Workflows]]

- Kubernetes API extension
- introduces a new Workflow CRD (custom resource definition)
- for each step in a workflow runs a pod, makes it modular
- for data processing (ML, Data Pipelines) and automation (fan-out fan-in pattern)

### Argo Events

also covered in [[04 - Argo Events]]

- event-driven workflow automation fmw for Kubernetes
- helps to trigger k8s objects, Argo Workflows, serverless workloads
- in response to events such as webhooks, S3, schedules, messaging queues ..
- 2 components - Triggers and Event Sources
- use cases - CI/CD, combines Argo Events, Workflows & Pipelines, CD, Rollouts


### Argo Rollouts

also covered in [[03 - Argo Rollouts]]

- delivery controller
- for more advanced deployment strategies
- automates promotion, rollback
- to safely deploy new app features into Production without manual analysis, testing etc.

