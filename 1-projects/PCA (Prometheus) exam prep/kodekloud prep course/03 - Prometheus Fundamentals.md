# Use cases




# Basics


- collects metrics data, visualize and alerts


# Architecture

High-level

1. Retrieval - Scrapes metrics data
2. TSDB (Time Series DB) - metrics storage
3. HTTP Server - accepts PromQL Queries


- _exporters_ - exposes internal data of a component to Prometheus readable format
- Retrieval _pulls_ metrics from the _exporters_
- For a short lived jobs it can be also _push_ method (Pushgateway)
- Pushed based systems: Logstash, Graphite, OpenTSDB

- Service Discovery - detects the targets to scrape

- Alert Manager - email, sms ...

- Prometheus web UI (or Grafana)

- Exporters - Node exporter (linux systems), Windows, MySQL, Apache, HAProxy

- Client libraries - for custom application (e.g. devops-sample-app!), Go/Python/Java... https://github.com/prometheus/client_python


# Installation



- [ ] already setup on my homelab, verify the access (UI, etc)
- [ ] update: not updated by Renovate, installed 77.x, current latest [90.x](https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack)
- [ ] fix: renovate to update _kube-prometheus-stack_ https://github.com/milanoid-labs/homelab-cluster/pull/478
kube-prometheus-stack - https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack



## Node Exporter


- also installed on each k8s node
- https://github.com/prometheus/node_exporter


## Prometheus Configuration

`prometheus.yml`

- spec https://prometheus.io/docs/prometheus/latest/configuration/configuration/
- example: https://github.com/prometheus/prometheus/blob/release-3.14/config/testdata/conf.good.yml

in my k8s:

- Secret `monitoring/prometheus-kube-prometheus-stack-prometheus`
- `prometheus.yaml.gz`


```bash
#dump
kubectl get secret -n monitoring prometheus-kube-prometheus-stack-prometheus \
  -o jsonpath='{.data.prometheus\.yaml\.gz}' | base64 -d | gunzip
```

UI  /query

```bash
# query UI
kubectl -n monitoring port-forward svc/kube-prometheus-stack-prometheus 9090:9090
http://localhost:9090/query
```


UI Grafana

https://grafana.milanoid.net/




# Authentication & Encryption


between Prometheus and Targets

