
# Intro

If we want to monitor the workload running on a K8s cluster it's better to have the Prometheus running on the cluster itself.

What can be monitored:

- workload (applications) running on the cluster
- K8s cluster itself
	- Control Plane components (api-server, coredns, kube-scheduler)
	- Kubelet (cAdvisor) - exposing container metrics
	- Kube-state-metrics - cluster level metrics (deployments, pod metrics) - not exposed by default
	- Node-exporter - run on all nodes for host related metrics (cpu, mem, network) - via [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/) (a pod running on each Node)


It will use Service Discovery.

On homelab cluster already deployed via HelmChart https://prometheus-community.github.io/helm-charts/:


- Alertmanager
- Grafana
- Node Exporter(s)
- Prometheus
- Kube-state-metrics

Kube-Prometheus-stack chart makes use of the Prometheus Operator.

K8s [Operator](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/) - an application specific controller that extends the K8s API to create/configure/manage instances of complex applications (like Prometheus)

https://github.com/prometheus-operator/prometheus-operator




# Installing Helm Chart

- [x] already installed

# Prometheus Chart Overview

```bash
# set ns as default
kubectl config set-context --current --namespace monitoring
# or
kubens monitoring

# get all resources in that ns
kubectl get all
```


- look around
- e.g. `prometheus.yaml` configuration is in Secret `prometheus-kube-prometheus-stack-prometheus`

```bash
kubectl describe secrets prometheus-kube-prometheus-stack-prometheus
Name:         prometheus-kube-prometheus-stack-prometheus
Namespace:    monitoring
Labels:       app.kubernetes.io/managed-by=prometheus-operator
              managed-by=prometheus-operator
Annotations:  <none>

Type:  Opaque

Data
====
prometheus.yaml.gz:  3166 bytes
```

- not to be edited directly

# Connecting to Prometheus

- [ ] how is it setup on my cluster that I can access the addresses below?
- [ ] expose the Alertmanager the same way

Prometheus

- http://prometheus.milanoid.net
- https://prometheus.milanoid.net


Grafana

- http://grafana.milanoid.net
- https://grafana.milanoid.net


# Prometheus Configuration


