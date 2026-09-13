# Intro

- Prometheus Query Language
- main way to query metrics within Prometheus
- data returned can be visualized in dashboards (Grafana or others)
- used to build alerting rules to notify admin


### PromQL Data Types

1. String - a simple string value "some-string"
2. Scaler - numeric value `54.03`
3. Instant Vector (single point in time)
4. Range Vector  (range over time)


# Selector & Matchers


`node_filesystem_avail_bytes`

Label Matchers
- `=`
- `!=`
- `=~` (regex)
- `!~` (negative regex)


```
node_filesystem_avail_bytes{instance = "localhost:9100"}
node_filesystem_avail_bytes{device != "/dev/sda1"}
node_filesystem_avail_bytes{ device =~ "/dev/sda.*" }
node_filesystem_avail_bytes{ device !~ "/boot.*" }
```


Multiple Selectors


```bash
node_filesystem_avail_bytes{ instance = "localhost:9100", device !~ "tmpfs" }
```


### Range Vector Selectors

- return all the values for a metric over a period of time

```bash
node_arp_entries{instance = "localhost:9100" } [2m]
```

# Modifiers


