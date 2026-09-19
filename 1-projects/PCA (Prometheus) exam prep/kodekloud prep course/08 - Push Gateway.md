- a middleman for a short-lived jobs
- a job before it exits sends all its metrics to PG
- Prometheus reach the PG as any other target and scrape the data as usual
- https://github.com/prometheus/pushgateway
- [ ] collect the metrics from ephemeral self-hosted GitHub Action Runners or Renovate Job!


# Installation

- can run *anywhere* but I'll install it on the same host `prom-lab` where Prometheus is running
- k3s: no push gateway running

```bash
wget https://github.com/prometheus/pushgateway/releases/download/v1.11.3/pushgateway-1.11.3.linux-amd64.tar.gz

tar xvf pushgateway-1.11.3.linux-amd64.tar.gz
cd pushgateway-1.11.3.linux-amd64
./pushgateway
```

- [ ] configure push gateway as systemd service

```bash
# create user, copy the binary and set the ownership
sudo useradd --no-create-home --shell /bin/false pushgateway
sudo cp pushgateway /usr/local/bin
chown pushgateway:pushgateway /usr/local/bin/pushgateway
vim /etc/system/systemd/pushgateway.service
```

```bash
# /etc/system/systemd/pushgateway.service
[Unit]
Decription=Prometheus Pushgateway
Wants=network-online.target
Afer=network-online.target

[Service]
User=pushgateway
Group=pushgateway
Type=simple
ExecStart=/usr/local/bin/pushgateway

[Install]
WantedBy=multi-user.target

```


```bash
# reload, restart and enable the pushgateway to start automatically
sudo systemctl daemon reload
sudo systemctl restart pushgateway
sudo systemctl enable pushgateway
sudo systemctl status pushgateway
```

```bash
# listens on :9091 by default
curl http://localhost:9091/metrics
```


- [ ] configure Prometheus to scrape Pushgateway


```yaml
# /etc/prometheus/prometheus.yml
scrape_configs:
  - job_name: pushgateway
    honor_labels: true
    static_configs:
      - targets: ["locahost:9091"]
```


- `honor_labels: true` - to keep labels from multiple jobs reporting metrics to PG
- without it Prometheus would label it all as PG instance



# Push metrics


1. via a plain HTTP POST request to PG
2. using a client library

```bash
POST http://<pushgatewayhost:port>/metrics/job/<job_name>/<label1>/<value1>/<label2>/<value2>
```

- `job_name` - job label of the metrics pushed
- `<label1>/<value1>` - grouping key


- [ ] push some metrics in

example - push metric `example_metric 4421` with a job label `{job="db_backup}`

```bash
echo "example_metric 4421" | curl --data-binary @- http://localhost:9091/metrics/job/db_backup 
```

- must be sent as binary data
- `@-` read the binary data from stdin

```bash
# now to metric `example_metric` is available for scraping
curl http://locahost:9091/metrics
```

POST vs PUT vs DELETE

- PUT - replace all metrics within a group
- DELETE - delete all metrics within a group



# Client library


there are 3 functions to call

1. `push` - as HTTP PUT - any exiting metrics for a job are removed and pushed metrics are added
2. `pushadd` - as HTTP POST - pushed metrics override existing metrics with same names, all others remain unchanged
3. `delete` - as HTTP DELETE - all metrics for a group are deleted


```python
from prometheus_client import CollectorRegistry, Gauge, pushadd_to_gateway

registry = CollectorRegistry()
test_metric = Gauge('Test metric', 'This is an example metric', registry=registry)

test_metric.set(10)

pushadd_to_gateway('user2:9091', job='batch', registry=registry)

```


# Lab

- [ ] kodekloud lab
- [ ] install PG as systemd servide @ 'prom-lab'
- [ ] (install PG @ k3s lab)
- [ ] push metrics in by curl (POST, PUT, DELETE)
- [ ] scrape the metrics from either GHA self-hosted runner or Renovate job



kodekloud
```bash
# send metrics in
echo "processing_time_seconds 120" | curl --data-binary @- http://localhost:9091/metrics/job/video_processing
```