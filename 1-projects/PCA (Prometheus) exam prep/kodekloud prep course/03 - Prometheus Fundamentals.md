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



- [x] already setup on my homelab, verify the access (UI, etc)
- [x] update: not updated by Renovate, installed 77.x, current latest [90.x](https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack)
- [x] fix: renovate to update _kube-prometheus-stack_ https://github.com/milanoid-labs/homelab-cluster/pull/478
kube-prometheus-stack - https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack

- [x] install Prometheus on a throw away VM@Proxmox - there is a lot K8s overhead, slow me down with the subject itself - use VM ID 103 (prom-lab)
- [ ] Prometheus as systemd service


```bash
# already running as simple binary in - I want to run via systemd
~/prometheus-training/prometheus-3.14.0.linux-amd64

# create user/service account (user cannot login)
sudo useradd --no-create-home --shell /bin/false prometheus

# dir for configuration file prometheus.yaml
sudo mkdir /etc/prometheus

# dir for data
sudo mkdir /var/lib/prometheus

# update permissions
sudo chown prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus


# copy binaries
milan@prom-lab:~/prometheus-training/prometheus-3.14.0.linux-amd64 $ sudo cp prometheus promtool /usr/local/bin/

# update permissions
sudo chown prometheus:prometheus /usr/local/bin/prometheus /usr/local/bin/promtool


# copy configuration file
sudo cp prometheus.yml /etc/prometheus/prometheus.yml
sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml


# actual run command
sudo -u prometheus /usr/local/bin/prometheus \
  --config.file /etc/prometheus/prometheus.yml \
  --storage.tsdb.path /var/lib/prometheus/ \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries
  
# service file
sudo vi /etc/systemd/system/prometheus.service

### /etc/systemd/system/prometheus.service
[Unit]  
Description=Prometheus
Wants=network-online.target
After=network-online.target
  
[Service]  
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/

[Install]
WantedBy=multi-user.target

###
  
  
  
# reload
sudo systemctl daemon-reload

# start
sudo systemctl start prometheus

# get
sudo systemctl status prometheus

× prometheus.service - Prometheus
     Loaded: loaded (/etc/systemd/system/prometheus.service; disabled; preset: enabled)
     Active: failed (Result: exit-code) since Fri 2026-09-11 10:50:38 UTC; 4s ago
   Duration: 45ms
 Invocation: 1ac62a328728488282217f9e8664af3f
    Process: 27030 ExecStart=/usr/local/bin/prometheus --config.file /etc/prometheus/prometheus.yml --storage.tsdb.path /var/lib/prometheus/ --web.console.tem>
   Main PID: 27030 (code=exited, status=2)
   Mem peak: 12.3M
        CPU: 45ms

Sep 11 10:50:38 prom-lab systemd[1]: Started prometheus.service - Prometheus.
Sep 11 10:50:38 prom-lab prometheus[27030]: time=2026-09-11T10:50:38.736Z level=ERROR source=main.go:751 msg="Error loading config (--config.file=/etc/prometh>
Sep 11 10:50:38 prom-lab systemd[1]: prometheus.service: Main process exited, code=exited, status=2/INVALIDARGUMENT
Sep 11 10:50:38 prom-lab systemd[1]: prometheus.service: Failed with result 'exit-code'.

```



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

UI  /query http://localhost:9090/

- [ ] expose as a Service/Ingress
```bash
# query UI
kubectl -n monitoring port-forward svc/kube-prometheus-stack-prometheus 9090:9090
http://localhost:9090/query
```


UI Grafana

https://grafana.milanoid.net/




# Authentication & Encryption


between Prometheus and Targets, via TLS

- by default no auth, anybody with access can also scrape

```bash
# generate tls for the node exporter - on hpmini01
sudo openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout node_exporter.key -out node_exporter.crt -subj "/C=US/ST=California/L=Oakland/O=MyOrg/CN=localhost" -addext "subjectAltName = DNS:localhost"
```

the Values are in subchart https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus-node-exporter/values.yaml#L42

