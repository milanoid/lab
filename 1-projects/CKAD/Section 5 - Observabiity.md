# Readiness and Liveness Probes


Pod Status - where the Pod is in its lifecycle

- Pending - scheduler tries to place the Pod
- Creating - image is pulled, container starts
- Running

Pod Conditions - true or false

- PodScheduled
- Initialized
- ContainersReady
- Ready

https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/

Readiness probe - to detect when we can route traffic to the application running in the Pod
Liveness probe - detects when to restart the container


```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    test: liveness
  name: liveness-http
spec:
  containers:
  - name: liveness
    image: registry.k8s.io/e2e-test-images/agnhost:2.40
    args:
    - liveness
    livenessProbe:
      httpGet:
        path: /healthz
        port: 8080
        httpHeaders:
        - name: Custom-Header
          value: Awesome
      initialDelaySeconds: 3
      periodSeconds: 3
```