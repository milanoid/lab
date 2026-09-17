
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


`prometheus.yml`
```yaml
scrape_configs:
 - job_name: EC2
   ec2_sd_configs:
    - region: <region>
      access_key: <acccess_key>
      secret_key: <secret_key>
```

- requires credentials with IAM user with _AmazonEC2ReadOnlyAccess_ policy


- [ ] create IAM user
# Re-Labeling

