https://training.promlabs.com/training/introduction-to-prometheus/training-overview/introduction/


- [x] VM with Ubuntu installed on Proxmox

```bash
# vm 103, IP 192.168.1.103, password less sudo user milan
ssh prom-lab


milan@prom-lab:~$ cat /etc/os-release
PRETTY_NAME="Ubuntu 26.04 LTS"
NAME="Ubuntu"
VERSION_ID="26.04"
VERSION="26.04 LTS (Resolute Raccoon)"
VERSION_CODENAME=resolute
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
UBUNTU_CODENAME=resolute
LOGO=ubuntu-logo
```


- [x] Install, configure and run Prometheus on the VM

```bash
# download
mkdir prometheus-training
cd prometheus-training
wget https://github.com/prometheus/prometheus/releases/download/v3.14.0/prometheus-3.14.0.linux-amd64.tar.gz
tar xvfz prometheus-3.14.0.linux-amd64.tar.gz
cd prometheus-3.14.0.linux-amd64
```


```yaml
# configure Prometheus to monitor itself
# prometheus.yml
global:
  scrape_interval: 5s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
```


```bash
# start
./prometheus

milan@prom-lab:~/prometheus-training/prometheus-3.14.0.linux-amd64$ ./prometheus
time=2026-09-05T17:30:40.715Z level=INFO source=main.go:1736 msg="updated GOGC" old=100 new=75
time=2026-09-05T17:30:40.715Z level=INFO source=main.go:795 msg="Leaving GOMAXPROCS=2: CPU quota undefined" component=automaxprocs
time=2026-09-05T17:30:40.715Z level=INFO source=memlimit.go:198 msg="GOMEMLIMIT is updated" component=automemlimit package=github.com/KimMachineGun/automemlimit/memlimit GOMEMLIMIT=3627303321 previous=9223372036854775807
time=2026-09-05T17:30:40.716Z level=INFO source=main.go:902 msg="Starting Prometheus Server" mode=server version="(version=3.14.0, branch=HEAD, revision=d7598b7141418fa35be2b5ec5d0fefb634199610)"
time=2026-09-05T17:30:40.716Z level=INFO source=main.go:907 msg="operational information" build_context="(go=go1.26.6, platform=linux/amd64, user=root@f423027f4410, date=20260817-16:49:19, tags=netgo,builtinassets)" host_details="(Linux 7.0.0-30-generic #30-Ubuntu SMP PREEMPT_DYNAMIC Fri Jul 31 18:22:54 UTC 2026 x86_64 prom-lab (none))" fd_limits="(soft=524287, hard=524288)" vm_limits="(soft=unlimited, hard=unlimited)"
time=2026-09-05T17:30:40.917Z level=INFO source=web.go:727 msg="Start listening for connections" component=web address=0.0.0.0:9090
time=2026-09-05T17:30:40.918Z level=INFO source=main.go:1468 msg="Starting TSDB ..."
time=2026-09-05T17:30:40.920Z level=INFO source=tls_config.go:372 msg="Listening on" component=web address=[::]:9090
time=2026-09-05T17:30:40.920Z level=INFO source=tls_config.go:375 msg="TLS is disabled." component=web http2=false address=[::]:9090
time=2026-09-05T17:30:40.923Z level=INFO source=head.go:738 msg="Replaying on-disk memory mappable chunks if any" component=tsdb
time=2026-09-05T17:30:40.923Z level=INFO source=head.go:824 msg="On-disk memory mappable chunks replay completed" component=tsdb duration=1.103µs
time=2026-09-05T17:30:40.923Z level=INFO source=head.go:832 msg="Replaying WAL, this may take a while" component=tsdb
time=2026-09-05T17:30:40.924Z level=INFO source=head.go:927 msg="WAL segment loaded" component=tsdb segment=0 maxSegment=0 duration=260.043µs
time=2026-09-05T17:30:40.924Z level=INFO source=head.go:964 msg="WAL replay completed" component=tsdb checkpoint_replay_duration=31.399µs wal_replay_duration=286.622µs wbl_replay_duration=129ns chunk_snapshot_load_duration=0s mmap_chunk_replay_duration=1.103µs total_replay_duration=350.986µs
time=2026-09-05T17:30:40.926Z level=INFO source=main.go:1489 msg="filesystem information" fs_type=EXT4_SUPER_MAGIC
time=2026-09-05T17:30:40.926Z level=INFO source=main.go:1492 msg="TSDB started"
time=2026-09-05T17:30:40.926Z level=INFO source=main.go:1690 msg="Loading configuration file" filename=prometheus.yml
time=2026-09-05T17:30:40.926Z level=INFO source=main.go:1106 msg="TSDB retention updated" duration=15d size=0B percentage=0
time=2026-09-05T17:30:40.926Z level=INFO source=main.go:1729 msg="Completed loading of configuration file" db_storage=31.852µs remote_storage=1.748µs web_handler=555ns query_engine=778ns scrape=330.479µs scrape_sd=79.46µs notify=1.113µs notify_sd=921ns rules=1.181µs tracing=4.43µs filename=prometheus.yml totalDuration=701.665µs
time=2026-09-05T17:30:40.927Z level=INFO source=manager.go:211 msg="Starting rule manager..." component="rule manager"
time=2026-09-05T17:30:40.926Z level=INFO source=main.go:1453 msg="Server is ready to receive web requests."
```

data stored in `./data` or configure by `--storage.tsdb.path`

Web UI now running: http://192.168.1.103:9090/

Metrics: http://192.168.1.103:9090/metrics

Targets: http://192.168.1.103:9090/targets



Query http://192.168.1.103:9090/query

```promql
rate(process_cpu_seconds_total{job="prometheus"}[1m])
```


```promql
process_resident_memory_bytes{job="prometheus"} / 1024 / 1024
```


```promql
rate(prometheus_tsdb_head_samples_appended_total{job="prometheus"}[1m])
```


### cli - promtool


```bash
./promtool check config prometheus.yml
Checking prometheus.yml
 SUCCESS: prometheus.yml is valid prometheus config file syntax
```


# An Overview

