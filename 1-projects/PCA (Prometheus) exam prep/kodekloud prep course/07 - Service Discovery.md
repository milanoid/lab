
# Intro


Instead of manually updating endpoints to scrape in `/etc/prometheus/prometheuse.yaml` we can auto-discovery them.

SD allows Prometheus to populate a list of endpoints to scrape that can get dynamically updated as new endpoints get created & destroyed.

Built-in support for EC2, Azure, GCE, Consul, Nomad, Kubernetes.

# File


File Service Discovery - a list of jobs/targets can be imported from a file.


`file-sd.json`
```json
[
  {
	  "targets": ["node1:9100"],
	  "labels": {
		  "team": "dev",
		  "job": "node"
	  }
  },
  
.......

]
```


`prometheus.yml`

```yaml
scrape_configs:
 - job_name: file-example
   file_sd_configs:
    - files:
       - 'file-sd.json'
       - '*.json'
```

# AWS EC2


`/etc/prometheus/prometheus.yml`
```yaml
scrape_configs:
 - job_name: "ec2"
   ec2_sd_configs:
    - region: <region>
      access_key: <acccess_key>
      secret_key: <secret_key>
```

- requires credentials with IAM user with _AmazonEC2ReadOnlyAccess_ policy


- [x] create IAM user https://github.com/milanoid-labs/milanoid-aws-terraform/pull/13

- user: `prometheus-ec2-scraper`


start an EC2 instance to get some metrics
```bash
aws ec2 run-instances \
  --region eu-west-1 \
  --image-id resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64 \
  --instance-type t4g.nano \
  --count 1
```

- with EC2s going up and down the auto-discovery will manage them

- [ ] terminate the running test ec2 instance

```bash
aws ec2 terminate-instances --region eu-west-1 --instance-ids i-0c3ba7063b6a6d338
```

# Re-Labeling (!)

- allows to filter out targets we're not interested for scraping
- rename/relabel metrics, e.g. `node1:9100` -> `node1`

https://grafana.com/blog/how-relabeling-in-prometheus-works/

https://training.promlabs.com/training/relabeling/introduction-to-relabeling/relabeling-overview/


- ! all labels beginning with `__` will be discarded at the end of re-labeling (that's why they don't show up as target labels)


Two options


1. `relabel_configs` - occurs before scrape occurs and only has access to labels added by Service Discovery
2. `metric_relabel_configs` - relabeling occurs after the scrape

```yaml
scrape_configs:
  - job_name: "ec2"
    relabel_configs:
    metric_relabel_configs:
    ec2_sd_configs:
      - region: <region>
        access_key: <acccess_key>
        secret_key: <secret_key>
```


e.g. a meta metrics `__meta_ec2_architecture`


```yaml
scrape_configs:
  - job_name: "ec2"
    relabel_configs:
      - source_labels: [__meta_ec2_architecture]
        regex: arm64
        action: drop # keep|drop|replace
    ec2_sd_configs:
      - region: <region>
        access_key: <acccess_key>
        secret_key: <secret_key>
```

- do not scrape ec2 targets with architecture `arm64`


another examples


```yaml
scrape_configs:
  - job_name: "ec2"
    relabel_configs:
      - source_labels: [env, team]
        regex: dev;marketing
        action: keep # keep|drop|replace
```




```yaml
scrape_configs:
  - job_name: "ec2"
    relabel_configs:
      - source_labels: [env, team]
        regex: dev-marketing
        action: keep # keep|drop|replace
        separator: "-"
```

- change delimiter between labels





# Re-Labeling Demo


- `relabel_configs` → runs at target-discovery time, controls target labels _and_ which targets are scraped
- `metric_relabel_configs` → runs after scrape, controls which series/labels get ingested


# Lab

- For the `demo` job, configure `re-label` configs to scrape only `targets` with `env="prod"` label and `drop` all other targets.
   
   ```yaml
   - job_name: "demo"
    relabel_configs:
      - source_labels: [env]
        regex: prod
        action: keep
    file_sd_configs:
      - files:
          - /etc/prometheus/file-sd.json
   ```
   
   
- We have decided to scrape the metrics from targets that have the following labels only: `team=api` `env=prod` Make the required changes for demo job.
  
  
  ```yaml
    - job_name: "demo"
    relabel_configs:
      - source_labels: [team, env]
        regex: api;prod
        action: keep
  ```


- Currently, there is a label that follows the format `team=<team-name>`: 
  
  `team=api` 
  `team=database` 
  
  Re-label this label so the label name changes to the organization and the value gets prepended with org- text. Example: `organization=org-api` `organization=org-database` Make the required changes for demo job.
  
  
  ```yaml
   - job_name: "demo"
    relabel_configs:
      - source_labels: [team]
        regex: (.*)
        replacement: "org-$1"
        action: replace
        target_label: organization
  ```



- The `type` label is no longer needed, set up a `relabel policy` for the `demo` job to drop this label.
  
  
  ```yaml
    - job_name: "demo"
    relabel_configs:
      - regex: type
        action: labeldrop
  ```


- By default, the labels that start with `__` will get dropped after the re-labeling process. Now, we want to keep all of those labels as well and change the name so it removes the `__meta_` text from the name.
  
  For example change: 
  `__meta_os__=centos` ⇒ `os=centos` 
  `__meta_mem__=8000mb` ⇒ `mem=8000mb` 
  
  Use the `labelmap` action to assign these discovered labels as target labels. Make the required changes under demo job.
  
  https://grafana.com/blog/how-relabeling-in-prometheus-works/#labelmap
  
  ```yaml
    - job_name: "demo"
    relabel_configs:
      - action: labelmap
        regex: __meta_(.*)
        replacement: $1
  ```