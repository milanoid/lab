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

# autostart
sudo systemctl enable prometheus.service

# view logs
sudo journalctl -u prometheus.service -f
```



## Node Exporter


- also installed on each k8s node
- https://github.com/prometheus/node_exporter


- [ ] install on prom-lab VM https://prometheus.io/download/#node_exporter

```bash
# setup Node Exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.12.1/node_exporter-1.12.1.linux-amd64.tar.gz

tar -xvf node_exporter-1.12.1.linux-amd64.tar.gz

## systemd
sudo cp node_exporter /usr/local/bin
sudo useradd --no-create-home --shell /bin/false node_exporter
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
sudo vi /etc/systemd/system/node_exporter.service


### /etc/systemd/system/node_exporter.service
[Unit]  
Description=Node Exporter
Wants=network-online.target
After=network-online.target
  
[Service]  
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target

###

sudo systemctl daemon-reload
sudo systemctl enable node_exporter.service
sudo systemctl start node_exporter.service
sudo systemctl status node_exporter.service
sudo journalctl -u node_exporter.service -f

curl http://localhost:9100/metrics
```


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

---

Configuration on prom-lab

```bash
# edit as user prometheus
sudo -u prometheus vi /etc/prometheus/prometheus.yml


###
global:
  scrape_interval: 1m
  scrape_timeout: 10s

scrape_configs:
  - job_name: 'node'
    scrape_interval: 15s
    scrape_timeout: 5s
    sample_limit: 1000
    schema: http
    metrics_path: /stats/metrics
    static_configs:
      - targets: ['localhost:9090']
###


# check syntax
promtool check config /etc/prometheus/prometheus.yml Checking /etc/prometheus/prometheus.yml SUCCESS: /etc/prometheus/prometheus.yml is valid prometheus config file syntax
```

- after a change in `/etc/prometheus/prometheus.yml` we need to restart prometheus

```bash
kill -HUP <pid_of_prometheus>

# or simply
sudo systemctl restart prometheus
```

- [x] configure auto-reload https://github.com/prometheus/prometheus/issues/9783 https://github.com/prometheus/prometheus/pull/14769

```bash
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
    --storage.tsdb.path /var/lib/prometheus/ \
    --enable-feature=auto-reload-config \
    --config.auto-reload-interval=30s

[Install]
WantedBy=multi-user.target

```


```bash
Sep 11 13:07:31 prom-lab prometheus[1923]: time=2026-09-11T13:07:31.795Z level=INFO source=main.go:1411 msg="Configuration file change detected, reloading the configuration."
Sep 11 13:07:31 prom-lab prometheus[1923]: time=2026-09-11T13:07:31.795Z level=INFO source=main.go:1690 msg="Loading configuration file" filename=/etc/prometheus/prometheus.yml
Sep 11 13:07:31 prom-lab prometheus[1923]: time=2026-09-11T13:07:31.796Z level=INFO source=main.go:1729 msg="Completed loading of configuration file" db_storage=34.347µs remote_storage=5.702µs web_handler=2.626µs query_engine=754ns scrape=838.964µs scrape_sd=10.247µs notify=12.72µs notify_sd=2.548µs rules=25.643µs tracing=6.264µs filename=/etc/prometheus/prometheus.yml totalDuration=1.339558ms
```

# Authentication & Encryption


between Prometheus and Targets, via TLS

- by default no auth, anybody with access can also scrape

```bash
# generate tls for the node exporter - on hpmini01
sudo openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout node_exporter.key -out node_exporter.crt -subj "/C=US/ST=California/L=Oakland/O=MyOrg/CN=localhost" -addext "subjectAltName = DNS:localhost"
```

the Values are in subchart https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus-node-exporter/values.yaml#L42


```bash
# creete node_exporter directory
sudo mkdir /etc/node_exporter

# move generated certs to that directory
sudo mv node_exporter.* /etc/node_exporter

# create the config
touch /etc/node_exporter/config.yml

# fix permissions
sudo chown -R node_exporter:node_exporter /etc/node_exporter

# update service
sudo vi /etc/systemd/system/node_exporter.service

###
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter --web.config.file=/etc/node_exporter/config.yml

[Install]
WantedBy=multi-user.target

###


sudo systemctl daemon-reload
sudo systemctl restart node_exporter.service

curl https://localhost:9100/metrics
```


tls error `SSL routines::wrong version number`

```bash
milan@prom-lab:~$ curl -v https://localhost:9100/metrics
* Host localhost:9100 was resolved.
* IPv6: ::1
* IPv4: 127.0.0.1
*   Trying [::1]:9100...
* ALPN: curl offers h2,http/1.1
* TLSv1.3 (OUT), TLS handshake, Client hello (1):
* SSL Trust Anchors:
*   CAfile: /etc/ssl/certs/ca-certificates.crt
*   CApath: /etc/ssl/certs
* TLS connect error: error:0A00010B:SSL routines::wrong version number
* closing connection #0
curl: (35) TLS connect error: error:0A00010B:SSL routines::wrong version number
```


```bash
# tls is disabled?
Sep 12 15:17:44 prom-lab node_exporter[6430]: time=2026-09-12T15:17:44.692Z level=INFO source=tls_config.go:418 msg="TLS is disabled." http2=false address=[::

>
```


```bash
# fix the config.yml

###

# TLS and basic authentication configuration example.
#
# Additionally, a certificate and a key file are needed.
tls_server_config:
  cert_file: node_exporter.crt
  key_file: node_exporter.key

###



Sep 12 15:32:00 prom-lab node_exporter[6931]: time=2026-09-12T15:32:00.612Z level=INFO source=tls_config.go:415 msg="TLS is enabled." http2=true address=[::]:

>
```

- doc https://github.com/prometheus/exporter-toolkit/blob/master/docs/web-configuration.md


Now we have set the node_exporter to listen on tls connection. But we also need to configure Prometheus to use tls instead plain http.


```bash
# copy node_exporter.crt (public key) to Prometheus server
sudo cp /etc/node_exporter/node_exporter.crt /etc/prometheus
sudo chown prometheus:prometheus node_exporter.crt

# update prometheus config
sudo -u prometheus vi /etc/prometheus/prometheus.yml


###

global:
  scrape_interval: 1m
  scrape_timeout: 10s

scrape_configs:
  - job_name: 'node'
    scrape_interval: 15s
    scrape_timeout: 5s
    sample_limit: 2000
    scheme: https
    tls_config:
      insecure_skip_verify: true
      ca_file: /etc/prometheus/node_exporter.crt
    metrics_path: /metrics
    static_configs:
      - targets: ['localhost:9100']

  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

###
```


- doc https://prometheus.io/docs/prometheus/latest/configuration/configuration/#tls_config


Done with Encrypted connection - now let's configure Authentication

On the node_exporter config

- we need to generate bcrypt hash

```bash
sudo apt install apache2-utils
htpasswd -nBC 12 "" | tr -d ':\n' # 'secret-password'
$2y$12$ReC83YF6fpghLBQjPzirWehg5xTk.UXtTQY3nrwy3Need.xenZjrm


### /etc/node_exporter/config

# TLS and basic authentication configuration example.
#
# Additionally, a certificate and a key file are needed.
tls_server_config:
  cert_file: node_exporter.crt
  key_file: node_exporter.key

# Usernames and passwords required to connect.
# Passwords are hashed with bcrypt: https://github.com/prometheus/exporter-toolkit/blob/master/docs/web-configuration.md#about-bcrypt.
basic_auth_users:
  prometheus: $2y$12$ReC83YF6fpghLBQjPzirWehg5xTk.UXtTQY3nrwy3Need.xenZjrm

###

```


- in http://192.168.1.103:9090/targets

```bash
**Error scraping target:** server returned HTTP status 401 Unauthorized
```

- the Prometheus must be updated with the user too

On prometheus config add the password in plaintext?:


```bash

###

global:
  scrape_interval: 1m
  scrape_timeout: 10s

scrape_configs:
  - job_name: 'node'
    scrape_interval: 15s
    scrape_timeout: 5s
    sample_limit: 2000
    scheme: https
    tls_config:
      insecure_skip_verify: true
      ca_file: /etc/prometheus/node_exporter.crt
    basic_auth:
      username: 'prometheus'
      password: 'secret-password'
    metrics_path: /metrics
    static_configs:
      - targets: ['localhost:9100']

  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

###
sudo systemctl restart prometheus.service

now all green in http://192.168.1.103:9090/targets
```

- doc https://prometheus.io/docs/prometheus/latest/configuration/configuration/#http_config





# Metrics


## Metric types

_Counter_ 
   - how many times X did happen?
   - e.g. total # requests
   - can only go up

_Gauge_
- what is the current value of X? 
- e.g. current CPU utilization
- can go up or down


_Histogram_

- how long or how big something is
- e.g. response time
- groups observation into buckets (cumulative)
- e.g. response time < 1s, response time < 0.5s

_Summary_

- similar to histogram
- how many observations fell below X
- e.g. response time
  - 20 % = 0.3s
  - 50 % = 0.8s
  - 80 % = 1.0s




## Metric Rules


## Metrics Labels

- key values pair
- why? e.g. request_total metric for each endpoint (/auth, /user ...) differentiate them by label - can easily count requests_total across all endpoints (application)
- can have multiple labels
- metric name is just another label
- `__name__` - internal labels enclosed by `__`
- every metric is assigned 2 labels by default (_instance_ and _job_)

```bash
node_memory_KernelStack_bytes{instance="localhost:9100", job="node"}
```



