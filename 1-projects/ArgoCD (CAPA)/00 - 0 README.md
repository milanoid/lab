- test cluster - my Homelab
- (Argo CD & Argo Rollouts) Udemy Course [Argo CD and Argo Rollouts for GitOps: The Definitive Guide](https://www.udemy.com/course/argo-cd-rollouts-gitops 
- https://github.com/lm-academy/argocd-course
- (Argo Workflows) - [doc](https://argo-workflows.readthedocs.io/en/latest/workflow-concepts/) & [[04 - Argo Workflows]]
- (Argo Events) - doc & & [[06 - Argo Events]]





# Exam

https://trainingportal.linuxfoundation.org/courses/certified-argo-project-associate


- Multiple Choice Exam  
- Duration of Exam 90 minutes


### Hardware Compatibility Check

https://docs.linuxfoundation.org/tc-docs/certification/lf-handbook2/candidate-requirements#hardware-compatibility-check


PSI Secure Browser trial

- [x] check (no external display, headset, extra apps)
- [x] uninstall


Exam day 30/7@8:00am

- at the office at 7am
- login 30 minutes before https://test-takers.psiexams.com/linux/manage/my-tests
- ID CARD and iPhone!
- No Apple Watch

---

# Mock exam questions review


## Argo Events

 
- Which filter type is available for Argo Events Sensors?
	- > _Expr_ filter type (others - _Data_, _Script_, _Context_, _Time) 
	- https://argoproj.github.io/argo-events/sensors/filters/intro/#types

---

- What is the primary role of a Sensor in Argo Events?
	- > Listen on the EventBus, evaluate dependencies, and fire triggers such as Workflows.
	- https://argoproj.github.io/argo-events/concepts/sensor/

---

- Which EventSource manifest correctly defines a webhook listener on port 12000?

answer:

```yaml
apiVersion: argoproj.io/v1alpha1 
kind: EventSource 
metadata: 
  name: webhook 
  spec: 
    service: 
      ports: 
        - port: 12000 
          targetPort: 12000 
    webhook: 
      example: 
        port: "12000" 
        endpoint: /example
```

https://github.com/argoproj/argo-events/blob/master/examples/event-sources/webhook.yaml

---


- How can you express boolean logic over multiple dependencies in an Argo Events Sensor?
	- > Define dependencyGroups and a dependencyExpression
	- `dependencyGroups` plus `dependencyExpression` let you express AND/OR logic.


## Argo Rollouts

- In Argo Rollouts, which setting controls the maximum number of Pods that may be unavailable during an update?
	- _maxUnavailable_
	- https://argo-rollouts.readthedocs.io/en/stable/features/specification/

## Argo Workflows

- What is the purpose of the `nginx` sidecar in the following template? 

```yaml
name: sidecar-nginx-example 
container: 
  image: appropriate/curl 
  command: 
    [sh, -c] 
  args: ["until curl -G 'http://127.0.0.1/' >& /tmp/out; do echo sleep && sleep 1; done && cat /tmp/out"] 
sidecars: 
  - name: nginx 
    image: nginx:1.13 
    command: [nginx, -g, daemon off;]
```

- > Run a basic NGINX web server alongside the curl container.



## Argo CD

- Which of the following destination rules is **invalid** for an Argo CD AppProject? 

Example formats: 

```yaml
namespace: "*" server: "https://kubernetes.default.svc"
```

- > `namespace: "*"; server: "https://team1-*"`
- The server field cannot use wildcards; it must be '*' or an exact cluster API URL.

---

- When you add a Kubernetes cluster to Argo CD, it is stored as what resource type?
	- > A Kubernetes Secret
	- Cluster connection details and credentials are stored in a Secret in the Argo CD namespace.

---

- You want to override a few Helm values inline while keeping the main values file. Which field should you use in the Application?
	- > `spec.source.helm.valuesObject`
	- valuesObject merges a map of key/values with the chart's values.

---

- Where can you customize health checks for a specific Kubernetes resource kind in Argo CD?
	- > **argocd-cm** `resource.customizations` (or 'resource.customizations.health')

---

- In an Argo CD AppProject, which destination rule is invalid?
	- > `namespace: '!kube-system', server: '*'`
	- Negation is not supported for the namespace field in destinations.
	- https://argo-cd.readthedocs.io/en/stable/user-guide/projects/

- WRONG? According to docs `!` is supported
```yaml
spec:
  destinations:
  # Do not allow any app to be installed in `kube-system`  
  - namespace: '!kube-system'
    server: '*'
  # Or any cluster that has a URL of `team1-*`   
  - namespace: '*'
    server: '!https://team1-*'
    # Any other namespace or server is fine though.
  - namespace: '*'
    server: '*'
```



---

- How do you combine two ApplicationSet generators to create the cartesian product of their parameters?
	- Use the matrix generator
	- Matrix builds the product across generators' outputs.

---


- Where can you override Kustomize image tags from an Argo CD Application?
	- > `spec.source.kustomize.images`
	- https://argo-cd.readthedocs.io/en/stable/user-guide/kustomize/

---

- How can CI obtain a scoped token for an AppProject role?
	- > Run `argocd proj role create-token <project> <role>`
	- Project roles can mint JWTs via the CLI/API.

---

- Which CLI command forces a hard refresh of an Application's tree?
	- > `argocd app get my-app --hard-refresh`
	- https://argo-cd.readthedocs.io/en/stable/user-guide/commands/argocd_app_get/

---

- Which AppProject setting whitelists the Git repositories an Application may use?
	- > `spec.sourceRepos`
	- sourceRepos is a list of allowed repo URLs/patterns (e.g., '*').
	- https://argo-cd.readthedocs.io/en/stable/user-guide/projects/