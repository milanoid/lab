
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


Kubernetes has its own Service Discovery.

https://prometheus.io/docs/prometheus/latest/configuration/configuration/#kubernetes_sd_config

http://prometheus.milanoid.net/config




# Deploy Demo Application

- [x] re-use my `home-dashboard`
- [x] app-side config https://github.com/milanoid-labs/home-dashboard/pull/10
- monitored via `prom-lab` instance only at the moment



# Additional Scrape Configs

- [x] K8s Prometheus scraping setup


2 ways to do that

1. (less preferred) via Helm Values
2. (ideal) - using ServiceMonitor


### 1 . Scrape Config via Helm Values

```bash
# list all the possible values
helm show values prometheus-community/kube-prometheus-stack
```

- then update _values_ in [release.yaml](https://github.com/milanoid-labs/homelab-cluster/blob/main/monitoring/controllers/base/kube-prometheus-stack/release.yaml#L29) in [additionalScrapeConfigs](https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/values.yaml#L4914)
- no validation, can break prometheus update

```bash
# for bare helm installations, doesn't apply for my GitOps
helm upgrade prometheus-community/kube-prometheus-stack -f values.yaml
```




# Service Monitors

### 2. Scrape Config using ServiceMonitor



```bash
kubectl get crd

kubectl get crd servicemonitors.monitoring.coreos.com
NAME                                    SCOPE        VERSIONS      CREATED AT
servicemonitors.monitoring.coreos.com   Namespaced   v1(storage)   2025-08-24T16:48:13Z
```


- defines a set of targets for Prometheus to monitor
- allow to avoid touching Prometheus config directly, offers a declarative K8s syntax



```bash
kubectl get servicemonitors.monitoring.coreos.com
NAME                                             AGE
kube-prometheus-stack-alertmanager               394d
kube-prometheus-stack-apiserver                  394d
kube-prometheus-stack-coredns                    394d
kube-prometheus-stack-grafana                    394d
kube-prometheus-stack-kube-controller-manager    394d
kube-prometheus-stack-kube-etcd                  394d
kube-prometheus-stack-kube-proxy                 394d
kube-prometheus-stack-kube-scheduler             394d
kube-prometheus-stack-kube-state-metrics         394d
kube-prometheus-stack-kubelet                    394d
kube-prometheus-stack-operator                   394d
kube-prometheus-stack-prometheus                 394d
kube-prometheus-stack-prometheus-node-exporter   394d
```

e.g. home-dashboards SM

https://github.com/milanoid-labs/homelab-cluster/blob/main/apps/argocd/home-dashboard/backend-servicemonitor.yaml


```yaml
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: home-dashboard-backend
  labels:
    release: kube-prometheus-stack
spec:
  selector:
    matchLabels:
      app: home-dashboard-backend
  endpoints:
    - port: metrics
      path: /metrics
      interval: 30s
```

- the SM refers to a Service - in this case to `home-dashboard-backend`
- note matching port and app label
- note label release - must match label

```bash
kubectl get prometheuses.monitoring.coreos.com -o yaml
```

```yaml
apiVersion: v1
items:
- apiVersion: monitoring.coreos.com/v1
  kind: Prometheus
  metadata:
    annotations:
      meta.helm.sh/release-name: kube-prometheus-stack
      meta.helm.sh/release-namespace: monitoring
    labels:
      release: kube-prometheus-stack # <<<<<< this
```

https://github.com/milanoid-labs/homelab-cluster/blob/main/apps/argocd/home-dashboard/backend-service.yaml

```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: home-dashboard-backend
  labels:
    app: home-dashboard-backend
spec:
  ports:
    - port: 80
      name: http
      targetPort: 8001
    - port: 8000
      name: metrics
      targetPort: 8000
  selector:
    app: home-dashboard-backend
```

- so the Prometheus knows which Service Monitors to scrape from


http://prometheus.milanoid.net/targets?pool=serviceMonitor%2Fhome-dashboard%2Fhome-dashboard-backend%2F0

http://prometheus.milanoid.net/query?g0.expr=%7Bjob%3D%27home-dashboard-backend%27%7D&g0.show_tree=0&g0.tab=table&g0.range_input=1h&g0.res_type=auto&g0.res_density=medium&g0.display_mode=lines&g0.show_exemplars=0


# Adding Rules



CRD - PrometheusRule

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: api-rules
  labels:
    release: kube-prometheus-stack
spec:
  groups:
    - name: api
      rules:
        - alert: ApiTargetDown
          expr: up{job="home-dashboard-backend"} == 0
          for: 5m
          labels:
            severity: critical
          annotations:
            summary: "API target {{ $labels.instance }} is down"
            description: "Prometheus has failed to scrape {{ $labels.job }} on {{ $labels.instance }} for 5 minutes."
```

https://github.com/milanoid-labs/homelab-cluster/pull/550

- it's a dummy rule - alert will appear only if a pod crash
- only if the scraping endpoint is not reachable (e.g. a pod crash)
- if fired, goes to Alert Manager (not yet configured to send any notification yet)

# Alertmanager Rules


- CRD `AlertmanagerConfig` - handles new rules to Alartmanager
- `alertmanagerConfigSelector` - label allows Alertmanager to find AlertmanagerConfig objects in the cluster and register them
- Helm Chart by default does not specify a label, must be added !
- plain `alertmanager.yml` uses _snake_case_ 
- AlertmanagerConfig CRD uses _CamelCase_



```bash
### alertmanagerConfigSelector must be set. by default empty:
### alertmanagerConfigSelector: {}
# get all values
helm show values prometheus-community/kube-prometheus-stack 
```


- [ ] Telegram Notification - a bit more complex as the Telegram bot-token must be sops encrypted https://github.com/milanoid-labs/homelab-cluster/pull/551



