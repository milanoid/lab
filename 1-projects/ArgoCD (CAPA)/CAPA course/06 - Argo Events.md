# The Main Components


## Event-Driven Architecture (EDA)

- Event, e.g. Pod lifecycle change
- EDA responds to such Events


[Event Source](https://argoproj.github.io/argo-events/concepts/event_source/)

- where Events are generated
- e.g. AWS SNS/SQS, Slack, GitHub, Webhook


```yaml
# example EventSource
apiVersion: argoproj.io/v1alpha1
kind: EventSource
metadata:
  name: webhook-example
spec:
  service:
    ports:
      - port: 12000
        targetPort: 12000
  webhook:
    example-endpoint:
      endpoint: /example
      method: POST
```

[Sensor](https://argoproj.github.io/argo-events/concepts/sensor/)

- Event listener
- defines a set of event dependencies (inputs) and triggers (outputs)
- listens to events on the eventbus and acts as an event dependency manager to resolve and execute the triggers


```yaml
piVersion: argoproj.io/v1alpha1
kind: Sensor
metadata:
  name: webhook-sensor
spec:
  dependencies:
    - name: example-dep
      eventSourceName: webhook-example
      eventName: example-endpoint
  triggers:
    - template:
        name: k8s-trigger
        k8s:
          group: batch
          version: v1
          resource: jobs
          operation: create
          source:
            resource:
              apiVersion: batch/v1
              kind: Job
              metadata:
                generateName: webhook-job-
              spec:
                template:
                  spec:
                    containers:
                      - name: hello
                        image: busybox
                        command: ["echo", "Hello from Argo Sensor!"]
                    restartPolicy: Never
```



[EventBus](https://argoproj.github.io/argo-events/concepts/eventbus/)

- It's responsible for managing the delivery of events from sources to sensors

```yaml
apiVersion: argoproj.io/v1alpha1  
kind: EventBus  
metadata:  
  name: default  
spec:  
  nats:  
    native:  
      replicas: 1
```


[Trigger](https://argoproj.github.io/argo-events/concepts/trigger/)

- the resource/workload executed by the sensor

```yaml
trigger:  
  template:  
    name: argo-workflow-trigger  
    argoWorkflow:  
      source:  
        resource:  
          apiVersion: argoproj.io/v1alpha1  
          kind: Workflow  
          metadata:  
            generateName: hello-world-  
          spec:  
            entrypoint: whalesay  
            templates:  
            - name: whalesay  
              container:  
                image: docker/whalesay:latest  
                command: [cowsay]  
                args: ["Hello from Argo Events!"]
```



![[Pasted image 20260717112133.png]]

---

# Lab 6.1 Setting Up Event Triggers with Argo


1. Prereq

- [x] Argo Workflows installed


2. Install Argo Events and the Needed components


```bash
kubectl create namespace argo-events
kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-events/stable/manifests/install.yaml
```

The next command applies a validating webhook for Argo Events. Validating webhooks are used to ensure that incoming requests to the Kubernetes API server are valid:
```bash
kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-events/stable/manifests/install-validating-webhook.yaml
```



For setting up a native EventBus in the argo-events namespace, which handles event transportation in Argo Events, apply the configuration with this command:

```bash
kubectl -n argo-events apply -f https://raw.githubusercontent.com/argoproj/argo-events/stable/examples/eventbus/native.yaml
```


Next we need to define an EventSource configuration that listens for webhook events in Argo Events, apply the following configuration using this command:

```bash
kubectl -n argo-events apply -f https://raw.githubusercontent.com/argoproj/argo-events/stable/examples/event-sources/webhook.yaml
```


For the Sensor to properly interact with Kubernetes resources, apply the necessary RBAC policies with the command below:

```bash
kubectl apply -n argo-events -f https://raw.githubusercontent.com/argoproj/argo-events/master/examples/rbac/sensor-rbac.yaml
```



Similarly, apply RBAC policies for Workflows to ensure they have the necessary permissions in Kubernetes. Run the following command:

```bash
kubectl apply -n argo-events -f https://raw.githubusercontent.com/argoproj/argo-events/master/examples/rbac/workflow-rbac.yaml
```



Set up a Sensor to trigger workflows based on webhook events by creating this Sensor configuration in a file called webhook.yaml. Run the following command:

```yaml
---
apiVersion: argoproj.io/v1alpha1 
kind: Sensor
metadata:
name: webhook
spec:
template:
serviceAccountName: operate-workflow-sa
dependencies:
- name: test-dep
eventSourceName: webhook
eventName: example
triggers:
- template:
name: webhook-workflow-trigger
k8s:
operation: create
source:
resource:
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
generateName: webhookspec:
entrypoint: cowsay
arguments:
parameters:
- name: message
# the value will get overridden by event payload
from test-dep
value: hello world
templates:
- name: cowsay
inputs:
parameters:
- name: message
container:
image: rancher/cowsay:latest
command: [cowsay]
args: ["{{inputs.parameters.message}}"]
parameters:
- src:
dependencyName: test-dep
dataKey: body
dest: spec.arguments.parameters.0.value
```