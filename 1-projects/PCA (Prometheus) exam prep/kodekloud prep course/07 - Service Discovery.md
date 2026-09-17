
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

# Re-Labeling

