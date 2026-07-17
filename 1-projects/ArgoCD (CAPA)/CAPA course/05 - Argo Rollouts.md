https://trainingportal.linuxfoundation.org/learn/course/devops-and-workflow-management-with-argo-lfs256/argo-rollouts/introduction


## Progressive Delivery

Progressive delivery is often described as an evolution of continuous delivery. It focuses on releasing updates of a product in a controlled and gradual manner, thereby reducing the risk of the release, typically coupling automation and metric analysis to drive the automated promotion or rollback of the update.

##### Canary releases

Gradually roll out the change to a small subset of users before rolling it out to the entire user base.

##### Feature flags

Control who gets to see what feature in the application, allowing for selective and targeted deployment.

##### Experiments & A/B testing

Test different versions of a feature with different segments of the user base.

##### Phased rollouts

Slowly roll out features to incrementally larger segments of the user base, monitoring and adjusting based on feedback.


## Deployment Strategies

### Recreate/Fixed Deployment

A Recreate deployment deletes the old version of the application before bringing up the new version. As a result, this ensures that two versions of the application never run at the same time, but there is downtime during the deployment. This strategy is an option for the Kubernetes Deployment object.

### Rolling Update

A Rolling Update slowly replaces the old version with the new version. As the new version comes up, the old version is scaled down in order to maintain the overall count of the application. This reduces downtime and risk as the new version is gradually deployed. This is the **default strategy** of the Kubernetes Deployment object.


### Blue-Green Deployment

A blue-green deployment (sometimes referred to as a red/black) has both the new and old versions of the application deployed at the same time. During this time, only the old version of the application will receive production traffic. This allows the developers to run tests against the new version before switching the live traffic to the new version. Once the new version is ready and tested, the traffic is switched (often at the load balancer level) from the old environment to the new one. The advantage here is a quick rollback in case of issues and minimal downtime during deployment.

An important drawback of a blue-green deployment is, that twice the amount of instances is created during the time of the deployment. This is a common show-stopper for this pattern.

https://martinfowler.com/bliki/BlueGreenDeployment.html


### Canary Deployment

A small subset of users are directed to the new version of the application while the majority still use the old version. Based on the feedback and performance of the new version, the deployment is gradually rolled out to more users. This reduces risk by affecting a small user base initially, allows for A/B testing and real-world feedback. While this is technically possible in native Kubernetes by manually adjusting Service Selectors between the “old” and “new” versions of a deployment, having an automated solution is more ideal.

https://martinfowler.com/bliki/CanaryRelease.html

## Strategies for Smooth and Reliable Releases

![[Pasted image 20260716153517.png]]

| Strategy              | Supported By      | Common Use Cases                                                                                                                                                                                                                                                                                                              |
| --------------------- | ----------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Fixed deployment      | Kubernetes Native | - The most basic way to deploy a workload is whenever downtime is acceptable.<br>- Often stateful workloads (e.g., Databases) require a “recreation” to avoid data corruption.                                                                                                                                                |
| Rolling update        | Kubernetes Native | - Commonly used for stateless, low-maintenance workloads like proxies, RESTful APIs, etc.                                                                                                                                                                                                                                     |
| Blue-green deployment | Argo Rollouts     | - Use when a) you can afford the extra cost of running twice the resources and b) need a quick and easy rollback option.<br>- B/G can also be helpful for experimentation scenarios.<br>- Can be advantageous to update services that depend on stateful connections, e.g., via WebSockets.                                   |
| Canary deployment     | Argo Rollouts     | - Use it whenever a partial rollout is desirable (experimentation with a subset of users, desire a gradual rollout over hours or days, want to make rollout dependent on certain conditions).<br>- It can be a good alternative if the deployments are too large and the infra cost of running a full blue-green is too high. |


## Argo Rollouts Architecture and Core Components


### Building Blocks of Argo Rollouts

![[Pasted image 20260716154002.png]]

- Argo Rollouts Controller
- Argo Rollout Resource
- Ingress and the Gateway API
- Service
- ReplicaSet
- AnalysisTemplate and AnalysisRun
- Metric Providers

### A Refresher: The Kubernetes Replica Set

- initially there was no Deployment, just Replica Sets
- later Deployment added, it's an abstraction over Replica Sets
- Replica Sets still run under the hood of Deployments

A Kubernetes **ReplicaSet** is a resource used to ensure that a specified number of pod replicas are running at any given time. Essentially, it's a way to manage the lifecycle of pods. The main function of a ReplicaSet is to maintain a stable set of pod replicas running at any given time. It does so by scheduling pods as needed to reach the desired number.


If a pod fails, the ReplicaSet will replace it; if there are more pods than needed, it will terminate the extra pods. ReplicaSets are used to achieve redundancy and high availability within Kubernetes applications. (kind of what AWS ASG does)

Lets create a Deployment of nginx proxies to demonstrate the ownership between Deployment and ReplicaSet.

```bash
# create deployement with 3 replicas
> kubectl create deploy nginx-deployment --image=nginx --replicas=3

# see the underlying replicasets
> kubectl get replicaset
NAME                          DESIRED   CURRENT   READY   AGE
nginx-deployment-5959b5b5c9   3         3         3       51s


# note the Controller By: Deployment/nginx-deployment
> kubectl describe replicasets.apps
Name:           nginx-deployment-5959b5b5c9
Namespace:      default
Selector:       app=nginx-deployment,pod-template-hash=5959b5b5c9
Labels:         app=nginx-deployment
                pod-template-hash=5959b5b5c9
Annotations:    deployment.kubernetes.io/desired-replicas: 3
                deployment.kubernetes.io/max-replicas: 4
                deployment.kubernetes.io/revision: 1
Controlled By:  Deployment/nginx-deployment
Replicas:       3 current / 3 desired
Pods Status:    3 Running / 0 Waiting / 0 Succeeded / 0 Failed
...

```

Kubernetes has a HPA - Horizontal Autoscaler

https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/#replicaset-as-a-horizontal-pod-autoscaler-target

```bash
kubectl autoscale rs nginx-deployment-5959b5b5c9 --max=10 --min=3 --cpu-percent=10
```


### Key Features of Argo Rollouts

- ##### Blue-green deployments
- ##### Canary deployments
- ##### Advanced traffic routing
- ##### Integration with metric providers
- ##### Automated decision making
	  Automatically promote or roll back deployments based on the success or failure of defined metrics.


#### Rollout resource

- managed by Argo Rollouts Controller, basically a Kubernetes Deployment with extra fields
- The Controller monitor only Rollout (Argo) objects, not a standard K8s Deployments.

spec https://argoproj.github.io/argo-rollouts/features/specification/



### Migrating Existing Deployments to Rollouts

The similarity of Deployments and Rollouts spec makes it easier to convert from one to the other resource type. Argo Rollouts supports a great way to migrate existing Deployment resources to Rollouts.

By providing a **spec.workloadRef** instead of **spec.template** a Rollout can refer to a Deployments template:

```yaml
apiVersion: argoproj.io/v1alpha1  
kind: Rollout  
metadata:  
  name: nginx-rollout  
spec:  
  replicas: 3  
  selector:  
    matchLabels:  
      app: nginx  
  workloadRef:  
    apiVersion: apps/v1  
    kind: Deployment  
    name: nginx-deployment
```

- [ ] migrate (some) existing deployment to rollout in homelab?

## Ingress and Service Resources

### Relevant Resources for Traffic Routing

- Kubernetes Ingress - K8s native, manages external access to services in cluster
- Kubernetes Service - way how to expose application running on a set of Pods
- Pod Template Hash - uniq identifier of a Pod/ReplicaSet - to distinguish "old" from "new"
- Stable/Canary ReplicaSets - stable (old), canary (new)



## Rollout Analysis & Experiments


### Analysis

- answers question whether the _canary_ workload is performing well

_AnalysisTemplate_ - defines the metrics
_AnalysisRun_ - instance of the template

Supports various providers like _Prometheus_, K8s Job, [Web provider](https://argo-rollouts.readthedocs.io/en/stable/analysis/web/).

- https://argo-rollouts.readthedocs.io/en/stable/features/analysis/

### Experiments

- designed to test and evaluate changes in two or more versions of an application in a controlled, **temporary** environment
- https://argoproj.github.io/argo-rollouts/features/experiment/


---

# Lab 5.1 - installing Argo Rollouts


```bash
# ns
kubectl create namespace argo-rollouts

# quick start manifest
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/download/v1.8.3/install.yaml

# verify
kubectl get pods -n argo-rollouts
```


Install Rollouts kubectl Plugin

Unlike Argo CD and Argo Workflows, Argo Rollouts uses a kubectl plugin as its CLI client.

```bash
# install
brew install argoproj/tap/kubectl-argo-rollouts

# verify
> kubectl argo rollouts version
kubectl-argo-rollouts: v1.9.0+838d4e7
  BuildDate: 2026-03-20T21:11:48Z
  GitCommit: 838d4e792be666ec11bd0c80331e0c5511b5010e
  GitTreeState: clean
  GoVersion: go1.24.13
  Compiler: gc
  Platform: darwin/amd64
```



UI Dashboard

For the sake of completeness it needs to be mentioned that Argo Rollouts ships with a fully fledged UI Dashboard. It can be accessed via the kubectl argo rollouts dashboard command and provides a nice overview and basic commands for administration

```bash
> kubectl argo rollouts dashboard
INFO[0000] Argo Rollouts Dashboard is now available at http://localhost:3100/rollouts
```

http://localhost:3100/rollouts


# Lab 5.2 Argo Rollouts Blue-Green


1. Install Resources

```bash
# check existing rollouts
> kubectl get rollout
> No resources found in default namespace.
```


```bash
# create the Rollout resource
> kubectl apply -f rollout.yaml
rollout.argoproj.io/rollout-bluegreen created

# get the rollout
> kubectl get rollout
NAME                DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
rollout-bluegreen   2
```

- not ready yet


```bash
> kubectl describe rollouts.argoproj.io rollout-bluegreen
...
Status:
  Conditions:
    Last Transition Time:  2026-07-17T05:27:32Z
    Last Update Time:      2026-07-17T05:27:32Z
    Message:               The Rollout "rollout-bluegreen" is invalid: spec.strategy.blueGreen.activeService: Invalid value: "rollout-bluegreen-active": service "rollout-bluegreen-active" not found
    Reason:                InvalidSpec
    Status:                True
    Type:                  InvalidSpec
  Message:                 InvalidSpec: The Rollout "rollout-bluegreen" is invalid: spec.strategy.blueGreen.activeService: Invalid value: "rollout-bluegreen-active": service "rollout-bluegreen-active" not found
  Observed Generation:     1
  Phase:                   Degraded
Events:
  Type    Reason                  Age   From                 Message
  ----    ------                  ----  ----                 -------
  Normal  RolloutAddedToInformer  116s  rollouts-controller  Rollout resource added to informer: default/rollout-bluegreen
...
```

- we need to create the services the rollout refers to

```bash
kubectl apply -f service-blue-green-active.yaml -f service-blue-green-preview.yaml
```


Now the rollout is ready:

```bash
> kubectl argo rollouts get ro rollout-bluegreen
Name:            rollout-bluegreen
Namespace:       default
Status:          ✔ Healthy
Strategy:        BlueGreen
Images:          argoproj/rollouts-demo:blue (stable, active)
Replicas:
  Desired:       2
  Current:       2
  Updated:       2
  Ready:         2
  Available:     2

NAME                                           KIND        STATUS     AGE  INFO
⟳ rollout-bluegreen                            Rollout     ✔ Healthy  11m
└──# revision:1
   └──⧉ rollout-bluegreen-5ffd47b8d4           ReplicaSet  ✔ Healthy  25s  stable,active
      ├──□ rollout-bluegreen-5ffd47b8d4-cww4z  Pod         ✔ Running  15s  ready:1/1
      └──□ rollout-bluegreen-5ffd47b8d4-dtrm9  Pod         ✔ Running  15s  ready:1/1
```


2. Perform an Upgrade

