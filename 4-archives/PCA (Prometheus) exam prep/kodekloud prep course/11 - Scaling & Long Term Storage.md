
- time series metrics must be stored somewhere
- by default it uses local storage
- customize via `--storage.tsdb.path`
- 15d default retention period
- 10G default retention size



# Long Term Storage

For long term storage - other than local storage solutions - e.g. [influxdb](https://www.influxdata.com/) or S3 bucket, [Mimir](https://github.com/grafana/mimir), [Thanos](https://thanos.io/).

With remote storage Prometheus must be configured for [Remote Read](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#remote_read) and [Remote Write](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#remote_write).


On my homelab the storage lives on localPath at hpmini02.

- [ ] move the storage elsewhere (not NFS NAS), iSCSI LUN

# Thanos

- allows to see metrics from multiple Prometheus instances, e.g. 1x Thanos, 3x Prometheus
- can deduplicate (for scenario with HA Prometheus)
- can store metrics in Long-Term Storage

Thenos Sidecar along the Prometheus streams metrics data to Long-Term storage such as S3.

Via Grafana/Client run Thanos Query.



# Scaling Prometheus


# Horizontal Sharding


# Federation


