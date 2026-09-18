
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