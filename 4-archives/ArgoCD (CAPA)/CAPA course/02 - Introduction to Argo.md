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

# Installing Kubernetes locally

I'll use Rancher Desktop

fixes for company Macbook
```bash
# symlink
ln -sf "/Applications/Rancher Desktop.app/Contents/Resources/resources/darwin/docker-cli-plugins/docker-compose" ~/.rd/bin/docker-compose


# ~/.bashrc
# commented the docker=podman alias
```

```bash
milan@SPM-LN4K9M0GG7 ~
> docker version
Client:
 Version:           29.5.3-rd
 API version:       1.54
 Go version:        go1.26.4
 Git commit:        5d9ffe3
 Built:             Thu Jun  4 07:33:36 2026
 OS/Arch:           darwin/arm64
 Context:           rancher-desktop

Server:
 Engine:
  Version:          29.5.2
  API version:      1.54 (minimum version 1.41)
  Go version:       go1.25.10
  Git commit:       568f755ebeb1ac9c6a8febbda6cd371ea0a9630b
  Built:            Sun May 31 13:53:18 2026
  OS/Arch:          linux/arm64
  Experimental:     false
 containerd:
  Version:          v2.3.2
  GitCommit:        fff62f14765df376e5fc36f5a8f8e795b5670f61
 runc:
  Version:          1.4.0
  GitCommit:        8bd78a9977e604c4d5f67a7415d7b8b8c109cdc4
 docker-init:
  Version:          0.19.0
  GitCommit:
```

```bash
# k8s context
milan@SPM-LN4K9M0GG7 ~
> kubectx rancher-desktop
✔ Switched to context "rancher-desktop".



# version
milan@SPM-LN4K9M0GG7 ~
> kubectl version
Client Version: v1.31.5
Kustomize Version: v5.4.2
Server Version: v1.31.5+k3s1
```

The course suggest to install docker, k8s and [kind](https://kind.sigs.k8s.io/). Not gonna do that. I'm running Rancher Desktop:

```bash
milan@SPM-LN4K9M0GG7 ~
> kubectl get nodes.
NAME                   STATUS   ROLES                  AGE    VERSION
lima-rancher-desktop   Ready    control-plane,master   412d   v1.31.5+k3s1
```



### switching between Rancher Desktop and Podman Desktop

to Rancher: `kubectx rancher-desktop`

to Podman:

- quit Rancher Desktop
- switch to a non-rancher-desktop kubectx contex
- run `podman` commands (`docker` alias commented out in `~/.bashrc`)



