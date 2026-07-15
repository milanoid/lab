- an extension of Argo
- GitOps tool designed for declarative CD of Kubernetes applications



# Argo Workflows Core Concepts

### Workflow

- a series of tasks, processes or steps to achieve a goal
- deployment, testing, and promotion of software applications
- a CRD

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: hello-world-
spec:
  entrypoint: whalesay
  templates:
- name: whalesay
  container:
    image: docker/whalesay
    command: [cowsay]
    args: ["hello world"]
```


### Template Types

#### Template Definitions

Container

- most common
- a step in workflow that runs a container

```yaml
# example
- name: whalesay
  container:
    image: docker/whalesay
    command: [cowsay]
    args: ["hello world"]
```

Resource

- template for creating, modifying, or deleting Kubernetes resources

```yaml
# example
- name: k8s-owner-reference
  resource:
    action: create
    manifest: |
      apiVersion: v1
      kind: ConfigMap
      metadata:
        generateName: owned-eg-
      data:
        some: value
```


Script

- similar to container type but allows to specify a script inline
- for simple one-liners

```yaml
# example
- name: gen-random-int
  script:
    image: python:alpine3.6
    command: [python]
    source: |
      import random
      i = random.randint(1, 100)
      print(i)
```


Suspend

- template to suspend an execution
- can be resumed using the CLI, the API or UI

```yaml
# example
- name: delay  
  suspend:  
    duration: "20s"
```


#### Template Invocators

DAG (Direct-Acyclic Graph)

- allows define tesks as a graph of dependencies
- for workflows with complex dependencies and conditional execution

```yaml
# example
- name: diamond
  dag:
    tasks:
    - name: A
      template: echo
    - name: B
      dependencies: [A]
      template: echo
    - name: C
      dependencies: [A]
      template: echo
    - name: D
      dependencies: [B, C]
      template: echo
```

Steps

- defines multiple steps within a template
- for sequential or parallel execution


```yaml
# example
- name: hello-hello-hello
  steps:
  - - name: step1
      template: prepare-data
  - - name: step2a
      template: run-data-first-half
    - name: step2b
      template: run-data-second-half
```



### Outputs

- define an output (an artifact) of a step
- can be used in subsequent step

```yaml
# example
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: artifact-passing-
spec:
  entrypoint: artifact-example
  templates:
  - name: artifact-example
    steps:
    - - name: generate-artifact
        template: whalesay
    - - name: consume-artifact
        template: print-message
        arguments:
          artifacts:
          - name: message
            from: "{{steps.generate-artifact.outputs.artifacts.hello-art}}"

  - name: whalesay
    container:
      image: docker/whalesay:latest
      command: [sh, -c]
      args: ["cowsay hello world | tee /tmp/hello_world.txt"]
    outputs:
      artifacts:
    - name: hello-art
      path: /tmp/hello_world.txt

  - name: print-message
    inputs:
      artifacts:
      - name: message
        path: /tmp/message
    container:
      image: alpine:latest
      command: [sh, -c]
      args: ["cat /tmp/message"]
```


### WorkflowTemplate

- reusable and shareable Workflow
- to encapsulate logic, parameters and metadata
- abstraction which promotes modularity and reusability

```yaml
# example
apiVersion: argoproj.io/v1alpha1
kind: WorkflowTemplate
metadata:
  name: sample-template
spec:
  templates:
   - name: hello-world
     inputs:
       parameters:
         - name: msg
           value: "Hello World!"
     container:
       image: docker/whalesay
       command: [cowsay]
       args: ["{{inputs.parameters.msg}}"]
```


```yaml
# Once defined, this WorkflowTemplate can be referenced and instantiated within multiple workflows. For example:
---
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: hello-world-
spec:
entrypoint: whalesay
templates:
  - name: whalesay
    steps:
      - - name: hello-world
          templateRef:
            name: sample-template
            template: hello-world
```


### Defining Argo Workflows and Its Components

#### Building Blocks

Argo Server
- central component
- exposes REST API for workflow submissions, monitoring, and management

Workflow Controller
- manages lifecycle of workflows
- interacts with Kubernetes API server

Argo UI

Argo Server and Workflow Controller runs in `argo` namespace.


### Argo Workflow Overview

each step and DAG generates a Pod with 3 containers

1. `init` 
2. `main`
3. `wait`



### Examples

- orchestrate end-to-end data processing pipeline
- machine learning projects
- foundation for CI/CD pipelines
- batch processing

---

# Lab 4.1. Installing Argo Workflows


Install (on my Rancher Desktop)

```bash
# ns
kubectl create namespace argo

# quick start manifest
kubectl apply -n argo -f https://github.com/argoproj/argo-workflows/releases/download/v3.7.3/install.yaml
```


Accessing UI

Patch argo-server authentication 

(by default is uses a client authentication, which requires clients to provide their Kubernetes bearer token, we switch the authentication mode to the server so that we can bypass UI login for now)

```bash
kubectl patch deployment -n argo argo-server --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/args", "value": [ "server", "--auth-mode=server" ]}]'
```

Ingress (so no port-forward is necessary)

```yaml
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argo
spec:
  ingressClassName: traefik
  rules:
    # to be accessed from LAN/VPN only
    - host: capa-argo.milanoid.net  # subdomain of my cloudflare domain
      http:
        paths:
          - backend:
              service:
                name: argo-server
                port:
                  number: 2746
            path: /
            pathType: Prefix
```



```bash
curl -k -H "Host: capa-argo.milanoid.net" https://127.0.0.1
Client sent an HTTP request to an HTTPS server.
```

-> patch argo-server deployment to fix that

```bash
kubectl -n argo patch deployment argo-server --type='json' \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--secure=false"}]'
```

```bash
# fix probe schema too
kubectl -n argo patch deployment argo-server --type='json' \
  -p='[{"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/scheme","value":"HTTP"}]'
```

and then rolling restart

```bash
kubectl -n argo rollout status deployment argo-server
```


https://capa-argo.milanoid.net/


#### cli

```bash
> argo version
argo: v4.0.7+9aeb47c.dirty
  BuildDate: 2026-07-07T11:53:02Z
  GitCommit: 9aeb47ce10339f4a14819335c6a00027353ba0df
  GitTreeState: dirty
  GitTag: v4.0.7
  GoVersion: go1.26.4
  Compiler: gc
  Platform: darwin/arm64
```

enable autocompletion

`source <(argo completion bash)`

https://argoproj.github.io/argo-rollouts/generated/kubectl-argo-rollouts/kubectl-argo-rollouts_completion/


# Lab 4.2. A Simple DAG Workflows

install resources

```bash
# tamplete
cat <<EOF > dag-workflow-template.yaml
---
apiVersion: argoproj.io/v1alpha1
kind: WorkflowTemplate
metadata:
  name: echo-template
  namespace: argo
spec:
  serviceAccountName: argo
  templates:
  - name: echo
    inputs:
      parameters:
      - name: message
    container:
      image: alpine:3.7
      command: [echo, "{{inputs.parameters.message}}"]
EOF
```

```bash
cat <<EOF > dag-workflow.yaml
---
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: dag-diamond
  namespace: argo
spec:
  entrypoint: diamond
  templates:
    - name: diamond
      dag:
        tasks:
        - name: A
          arguments:
            parameters: [{name: message, value: A}]
          templateRef:
            name: echo-template
            template: echo
        - name: B
          dependencies: [A]
          templateRef:
            name: echo-template
            template: echo
          arguments:
            parameters: [{name: message, value: B}]
        - name: C
          dependencies: [A]
          templateRef:
            name: echo-template
            template: echo
          arguments:
            parameters: [{name: message, value: C}]
        - name: D
          dependencies: [B, C]
          templateRef:
            name: echo-template
            template: echo
          arguments:
            parameters: [{name: message, value: D}]
EOF
```

To successfully deploy this Workflow we need to temporarily grant admin permissions to argo ServiceAccount with the following command:

`kubectl create rolebinding default-admin --clusterrole=admin --serviceaccount=argo:default -n argo`

For a production environment, please follow the [official documentation](https://argo-workflows.readthedocs.io/en/latest/service-accounts/).

Create the WorkflowTemplate

```bash
kubectl apply -f dag-workflow-template.yaml
```

Submit Workflow

```bash
kubectl create -f dag-workflow.yaml
```


Inspect the created workflow

```bash
kubectl -n argo get workflowtemplates.argoproj.io
```


```bash
> kubectl -n argo get workflow
NAME               STATUS      AGE   MESSAGE
dag-diamondxhzxw   Succeeded   58s

> argo -n argo list
NAME               STATUS      AGE   DURATION   PRIORITY   MESSAGE
dag-diamondxhzxw   Succeeded   1m    40s        0
```

```bash
# get details
> argo -n argo get dag-diamondxhzxw
Name:                dag-diamondxhzxw
Namespace:           argo
ServiceAccount:      unset (will run with the default ServiceAccount)
Status:              Succeeded
Conditions:
 PodRunning          False
 Completed           True
Created:             Wed Jul 15 10:36:23 +0200 (1 minute ago)
Started:             Wed Jul 15 10:36:23 +0200 (1 minute ago)
Finished:            Wed Jul 15 10:37:03 +0200 (1 minute ago)
Duration:            40 seconds
Progress:            4/4
ResourcesDuration:   0s*(1 cpu),14s*(100Mi memory)

STEP                 TEMPLATE            PODNAME                           DURATION  MESSAGE
 ✔ dag-diamondxhzxw  diamond
 ├─✔ A               echo-template/echo  dag-diamondxhzxw-echo-2250723928  10s
 ├─✔ B               echo-template/echo  dag-diamondxhzxw-echo-2301056785  5s
 ├─✔ C               echo-template/echo  dag-diamondxhzxw-echo-2284279166  3s
 └─✔ D               echo-template/echo  dag-diamondxhzxw-echo-2334612023  3s
```

```bash
# read logs
> argo -n argo logs dag-diamondxhzxw
dag-diamondxhzxw-echo-2250723928: A
dag-diamondxhzxw-echo-2250723928: time="2026-07-15T08:36:33.384Z" level=info msg="sub-process exited" argo=true error="<nil>"
dag-diamondxhzxw-echo-2284279166: C
dag-diamondxhzxw-echo-2301056785: B
dag-diamondxhzxw-echo-2284279166: time="2026-07-15T08:36:46.157Z" level=info msg="sub-process exited" argo=true error="<nil>"
dag-diamondxhzxw-echo-2301056785: time="2026-07-15T08:36:47.087Z" level=info msg="sub-process exited" argo=true error="<nil>"
dag-diamondxhzxw-echo-2334612023: D
dag-diamondxhzxw-echo-2334612023: time="2026-07-15T08:36:55.154Z" level=info msg="sub-process exited" argo=true error="<nil>"
```

A run first, then B, C in parallel, then D

![[Pasted image 20260715104029.png]]