
60 questions each
# Lab - Mock Exam 1


Q: What type of metric should be used for measuring internal temperature of a server?
A: Since temperature readings can go up or down, a **gauge** metric should be used in this case.

---

Q: For a histogram metric, what are the different submetrics?
A: `_count`, `_bucket`, `_sum`


---

Q: What does the following `metric_relabel_config` do?

```yaml
scrape_configs:
  - job_name: example
    metric_relabel_configs:
      - source_labels: [datacenter]
        regex: (.*)
        action: replace
        target_label: location
        replacement: dc-$1
```
A:  Changes the `datacenter` label to `location` and prepends the value with `dc-`


---

Q: Which of the following statements are true regarding Alert labels and annotations?

```yaml
route:
  receiver: staff
  group_by: ['severity']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 12h
  routes:
    - matchers:
        job: kubernetes
      receiver: infra
      group_by: ['severity']

```
A: Alert `labels` can be used as metadata so alertmanager can match on them and performing routing policies, `Annotations` should be used for cosmetic descriptions of the alerts

---

Q: An engineer forgot to address an alert, based off the alertmanager config below, how long will they need to wait to see the alert again?

```yaml
route:
  receiver: pager
  group_by: [alertname]
  group_wait: 10s
  repeat_interval: 4h
  group_interval: 5m
  routes:
    - match:
        team: api
      receiver: api-pager
    - match:
        team: frontend
      receiver: frontend-pager
```
A: `4h`


---
Q: What is the purpose of Prometheus scrape_interval?
A: Defines how frequently to scrape a target

---
Q: What is the purpose of the for attribute in a Prometheus alert rule?
A: Determines how long a rule must be true before firing an alert

---
Q: Which cli command can be used to verify/validate prometheus configurations?
A: `promtool check config`


---
Q: Analyze the example alertmanager configs and determine when an alert with the following labels arrives on alertmanager, what receiver will it send the alert to team: api and severity: critical?

```yaml
route:
  receiver: general-email
  routes:
    - receiver: frontend-email
      matchers:
        - team: frontend
      routes:
        - matchers:
            severity: critical
          receiver: frontend-pager
    - receiver: backend-email
      matchers:
        - team: backend
      routes:
        - matchers:
            severity: critical
          receiver: backend-pager
    - receiver: auth-email
      matchers:
        - team: auth
      routes:
        - matchers:
            severity: critical
          receiver: auth-pager
  receiver: auth-pager
```
A: general-email
- The label `team: api` does not match with any of the parent routes, so it goes to the default route, which uses the general-email receiver

---

Q: What are the 3 components of the prometheus server?
A: retrieval node, tsdb, http server


---

Q: Which of the following is not something that is tracked in a span within a trace?
A: complexity


For PCA context: this ties into the "three pillars of observability" (metrics, logs, traces) that Prometheus courses often cover — traces (spans) capture _causality and timing_ across a request's path through distributed services, which is a different concern from Prometheus's own metrics scraping, but PCA exams sometimes touch on the broader observability landscape.

---
Q: The metric http_errors_total{code=”404”} tracks the number of 404 errors a web server has seen. Which query returns what is the average rate of 404s a server has seen for the past 2 hours? Use a 2m sample range and a query interval of 1m

A: `avg_over_time(rate(http_errors_total{code=”404”}[2m]) [2h:1m])`


---
Q: Which query below will give the 99% quantile of the metric http_requests_total?

A: `histogram_quantile(0.99, http_requests_total_bucket)`

---

Q: What is the default web port of Prometheus?
A: 9090

---

Q: Add an annotation to the alert called description that will print out the message that looks like this:

_Instance has low disk space on filesystem , current free space is at %_

```yaml
groups:
  - name: node
    rules:
      - alert: node_filesystem_free_percent
        expr: 100 * node_filesystem_free_bytes{job="node"} / node_filesystem_size_bytes{job="node"} < 10

Examples of the two metrics used in the alert can be seen below

node_filesystem_free_bytes{device="/dev/sda3", fstype="ext4", instance="node1", job="web", mountpoint="/home"}

node_filesystem_size_bytes{device="/dev/sda3", fstype="ext4", instance="nodde1", job="web", mountpoint="/home"}

Choose the correct option:

Option A:
description: Instance << $Labels.instance >> has low disk space on filesystem << $Labels.mountpoint >>, current free space is at << .Value >>%

Option B:
description: Instance {{ .Labels.instance }} has low disk space on filesystem {{ .Labels.mountpoint }}, current free space is at {{ .Value }}%

Option C:
description: Instance {{ .Labels=instance }} has low disk space on filesystem {{ .Labels=mountpoint }}, current free space is at {{ .Value }}%

Option D:
description: Instance {{ .instance }} has low disk space on filesystem {{ .mountpoint }}, current free space is at {{ .Value }}%
```

A: Option B

---

Q: Which of the following is not a valid way to reload Prometheus configuration?
A: `promtool config reload`



---

Q: What are the different states a Prometheus alert can be in?
A: inactive, pending, firing

---

Q: What is this an example of? `Service provider guaranteed 99.999% uptime each month or else customer will be awarded $10k'
A: SLA

---

Q: What configuration will make it so Prometheus doesn’t scrape targets with a label of team: frontend?

```yaml
Option A:

relabel_configs:
  - source_labels: [team]
    regex: frontend
    action: drop

Option B:

relabel_configs:
  - source_labels: [frontend]
    regex: team
    action: drop

Option C:

metric_relabel_configs:
  - source_labels: [team]
    regex: frontend
    action: drop

Option D:

relabel_configs:
  - match: [team]
    regex: frontend
    action: drop
```
A:  Option A

---

Q: Which query will give sum of all filesystems on the machine? The metric node_filesystem_size_bytes will list out all of the filesystems and their total size.

```text
node_filesystem_size_bytes{device="/dev/sda2", fstype="vfat", instance="192.168.1.168:9100", mountpoint="/boot/efi"} 536834048 node_filesystem_size_bytes{device="/dev/sda3", fstype="ext4", instance="192.168.1.168:9100", mountpoint="/"} 13268975616 node_filesystem_size_bytes{device="tmpfs", fstype="tmpfs", instance="192.168.1.168:9100", mountpoint="/run"} 727924736 node_filesystem_size_bytes{device="tmpfs", fstype="tmpfs", instance="192.168.1.168:9100", mountpoint="/run/lock"} 5242880 node_filesystem_size_bytes{device="tmpfs", fstype="tmpfs", instance="192.168.1.168:9100", mountpoint="/run/snapd/ns"} 727924736 node_filesystem_size_bytes{device="tmpfs", fstype="tmpfs", instance="192.168.1.168:9100", mountpoint="/run/user/1000"} 727920640
```
A: `sum(node_filesystem_size_bytes{instance="192.168.1.168:9100"})`


---

Q: What two labels are assigned to every metric by default?

A: instance, job

---

Q: What selector will match on time series whose mountpoint label doesn’t start with /run
A: `node_filesystem_avail_bytes{mountpoint!~"/run.*"}`

---

Q: How can alertmanager prevent certain alerts from generating notification for a temporary period of time?
A: Configuring a Silence

---


Q: The metric node_cpu_temp_celcius reports the current temperature of a nodes CPU in celsius. What query will return the average temperature across all CPUs on a per node basis? The query should return 

{instance="node1"} 23.5 //average temp across all CPUs on node1 
{instance="node2"} 33.5 //average temp across all CPUs on node2

A: `avg by(instance) (node_cpu_temp_celsius)`

---

Q: Analyze the alertmanager configs below. For all the alerts that got generated, how many total notifications will be sent out.? Analyze the alertmanager configs below. For all the alerts that got generated, how many total notifications will be sent out.?

```yaml
route:
  receiver: general-email
  group_by: [alertname]
  routes:
    - receiver: frontend-email
      group_by: [env]
      matchers:
        - team: frontend
 



The following alerts get generated by Prometheus with the defined labels.

alert1
	team: frontend
	env: dev


alert2
	team: frontend
	env: dev


alert3
	team: frontend
	env: prod

alert4
	team: frontend
	env: prod

alert5
	team: frontend
	env: staging

```

A: 3

---

Q: What does the double underscore __ before a label name signify?  
A: The label is a reserved label

---

Q: Which of the following would make for a poor SLI?
A: high disk utilization

---

Q: Analayze the example alertmanager configs and determine when an alert with the following labels arrives on alertmanager, what receiver will it send the alert to team: backend and severity: critical

```yaml
route:
  receiver: general-email
  routes:
    - receiver: frontend-email
      matchers:
        - team: frontend
      routes:
        - matchers:
            severity: critical
          receiver: frontend-pager
    - receiver: backend-email
      matchers:
        - team: backend
      routes:
        - matchers:
            severity: critical
          receiver: backend-pager
    - receiver: auth-email
      matchers:
        - team: auth
      routes:
        - matchers:
            severity: critical
          receiver: auth-pager
  receiver: auth-pager
```

A: backend-pager

---

Q: Management has decided to offer a file upload service where the SLO states that 97% of all upload should complete within 30s. A histogram metric is configured to track the upload time, which of the following bucket configurations is recommended for the desired slo?

A: 10, 25, 27, 30, 32, 35, 40, 50

---

Q: Which component of the Prometheus architecture should be used to automatically discover all nodes in a Kubernetes cluster?

A: service discovery

---

Q: In the scrape configs for a pushgateway, what is the purpose of the honor_labels: true

```yaml
scrape_configs:
  - job_name: pushgateway
    honor_labels: true
    static_configs:
      - targets: ["192.168.1.168:9091"]

```

A: Allows metrics to specify the instance and job labels instead of pulling it from scrape_configs







# Lab - Mock Exam 2


---

Vocabulary

- Metric types 
	  Histogram (what submetrics has?), 
	  Gauge, 
	  Counter, 
	  Summary
- Quantile
- rate vs irate
- SLO, SLA, SLI
- Alertmanager config 
	  `group_by`
	  `group_wait`
	  `group_interval`
	  `repeat_interval`




