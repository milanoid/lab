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