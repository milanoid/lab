if a _condition_ is met trigger an action.

Condition - a PromQL expression, e.g. `node_filesystem_avail_bytes < 1000`'

Alertmanager 
- the component sending the notifications
- one AM can be used by multiple Prometheus instances 


Alert states

- Inactive - expression has not returned any results
- Pending - expression returned results, not yet firing (e.g. 5m CPU spike needed)
- Firing - active for more than the defined `for` clause (e.g. 5m)



## Labels & Annotations


_Labels_ - can be added to alerts to provide a mechanism to classify and match specific alerts in Alartmanager


```yaml
# rules.yml
groups:
  - name: node
    rules:
      - alert: Node down
        expr: up{job="node"} == 0
        labels:
          severity: warning
          
      - alert: Multiple Nodes down
        expr: avg without(instance)(up{job="node"}) <= 0.5
        labels:
          severity: critical
```


_Annotations_ - an extra description

- to access alert labels use `{{.Labels}}`
- to get instance label use `{{.Labels.instance}}`
- to get the firing sample value use `{{.Value}}`

```yaml
# rules.yml
groups:
  - name: node
    rules:
      - alert: node_filesystem_free_percent
        expr: 100 * node_filesystem_free_bytes{job="node"} / node_filesystem_size_bytes{job="node"} < 70
        annoatations:
          description: "filesystem {{.Labels.device}} on {{.Labels.instance}} is low on space, current available space is {{.Value}}"
```

## Alertmanager Architecture


- has its own API
- can serve multiple Prometheus instances
- dispatcher
- inhibition
- silencing
- routing
- notification
- integration (with receivers)
- receivers (chat, pager, email)



## Alertmanager Installation

- [x] install on `prom-lab`
- [x] install on `k3s` (already installed via the helm chart)


`prom-lab` - as a systemd service

```bash
wget https://github.com/prometheus/alertmanager/releases/download/v0.34.1/alertmanager-0.34.1.linux-amd64.tar.gz

tar xvf alertmanager-0.34.1.linux-amd64.tar.gz
```

`amtool` - cli utility
`alertmanager.yml` - configuration file
`alertmanager` - executable
`data/` - where notification states are stored

- default port 9093
- http://192.168.1.103:9093/#/alerts


Prometheus config side:

```yaml
global: 
  scrape_interval: 1m 
  scrape_timeout: 10s 
alerting:
  alertmanagers:
    - static_configs:
        - targets:
            - alertmanager1:9093 # localhost:9093
              alertmanager2:9093
```

## Alertmanager Installation - systemd



```bash
sudo useradd --no-create-home --shell /bin/false alertmanager
sudo mkdir /etc/alertmanager
sudo mv alertmanager.yml /etc/alertmanager/
sudo chown -R alertmanager:alertmanager /etc/alertmanager

sudo mkdir -p /var/lib/alertmanager
sudo chown -R alertmanager:alertmanager /var/lib/alertmanager

sudo cp alertmanager amtool /usr/local/bin
sudo chown alertmanager:alertmanager /usr/local/bin/alertmanager
sudo chown alertmanager:alertmanager /usr/local/bin/amtool

```


```bash
sudo vim /etc/systemd/system/alertmanager.service
```


```bash
[Unit]
Description=Alert Manager
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=alertmanager
Group=alertmanager
ExecStart=/usr/local/bin/alertmanager \
  --config.file=/etc/alertmanager/alertmanager.yml \
  --storage.path=/var/lib/alertmanager

Restart=always

[Install]
WantedBy=multi-user.target
```


```bash
sudo systemctl daemon-reload
sudo systemctl start alertmanager
sudo systemctl enable alertmanager
```
## Configuration


`sudo -u alertmanager vim /etc/alertmanager/alertmanager.yml`



- all alerts with the `job=Kubernetes` & `severity=ticket` labels will match this rule
- alerts that match get sent to receiver `k8s-slack` (defined in `reciever` section)
```yml
route:
  routes:
  - match_re:
      job: (node|windows)
    receiver: infra-email
  - matchers:
      job: kubernetes
      severity: ticket
    reciever: k8s-slack
```


Sub-routes

- parent route - all alerts with label `job=kubernetes` will be sent to receiver `k8s-email`
- sub-route - alerts with a label `severity=pager` then it will be sent to `k8s-pager`

```yml
route:
  routes:
  - matcher:
      job: kubernetes
    receiver: k8s-email
    routes:
    - matchers:
        severity: pager
      reciever: k8s-pager
```


### Restarting Alertmanager

- systemd service restart
- send SIGHUP `sudo killall -HUP alertmanger`
- `POST /-/reload`



## Receivers and Notifiers


Notifier - an integration with a service (e.g. Telegram, Slack, email...)
https://prometheus.io/docs/alerting/latest/integrations/

### Notification Templates

- using Go templating system
  
- `GroupLabels`
- `CommonLabels`
- `CommonAnnotations`
- `ExternalURL`
- `Status`
- `Receiver`
- `Alerts`


```yml
# alertmanager.yml
route:
  reciever: 'slack'
receivers:
  - name: slack
    slack_configs:
      - api_url: https://hooks.slack.com/xxx
        channel: '#alerts'
        title: '{{.GroupLabels.severity}} alerts in region {{.GroupLabels.region}}'
        text: {{.Alerts | len}} alerts:
```



## Alertmanager Demo





## Silences



# Labs


### kodekloud

- Create an alert in Prometheus to check the low disk space on nodes (`node01` and `node02`).
- https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/

```yml
# /etc/prometheus/rules.yml
groups:
  - name: node
    rules:
      - alert: LowDiskSpace
        expr: 100 * node_filesystem_free_bytes{job="nodes"} / node_filesystem_size_bytes{job="nodes"} < 10
        labels:
          severity: warning
          environment: prod
          
```

syntax check

```bash
promtool check rules /etc/prometheus/rules.yml
Checking /etc/prometheus/rules.yml
  SUCCESS: 1 rules found
```

update `/etc/prometheus/prometheus.yml` - to use the rules

```yml
rule_files:
  - "rules.yml"
```


### prom-lab

- [ ] setup Telegram Alerting on low free memory

1. `/etc/prometheus/rules.yml`
2. update `/etc/prometheus/prometheus.yml` with the rule files to use
3. Telegram Bot setup
4. update `/etc/alertmanager/alertmanager.yml` with thee receiver (Telegram) & restart



- create rules file
```bash
# 
sudo -u prometheus vim /etc/prometheus/rules.yml
```

```yml
# /etc/prometheus/rules.yml
groups:
- name: prom-lab-alert
  rules:
  - alert: LowDiskSpace
    expr: node_memory_MemAvailable_bytes{instance='localhost:9100'} / 1000000 < 3500
    for: 2m
    annotations:
      summary: Low on free memory
```

```bash
# validate the rules.yml
promtool check rules /etc/prometheus/rules.yml 
Checking /etc/prometheus/rules.yml 
  SUCCESS: 1 rules found
```



- enable the rules file in Prometheus

```bash
sudo -u prometheus vim prometheus.yml
```


```yml
rule_files:
  - 'rules.yml'
```






### homelab 

- [ ] alerting to Telegram on low disk space and high temperature