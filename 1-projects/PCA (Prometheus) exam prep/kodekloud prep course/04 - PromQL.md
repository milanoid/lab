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

Offset Modifier

- to go back in time `ms`, `s`, `m`, `h`, `d`, `w`, `y`

```bash
# offset
node_memory_Active_bytes{instance="localhost:9100"} offset 1h30m


# go to a specific time
node_memory_Active_bytes{instance="localhost:9100"} @<unix_timestamp>


# combination
node_memory_Active_bytes{instance="localhost:9100"} @<unix_timestamp offset 1h
```


# Lab - PromQL


- can query via UI or CLI

query using `promtool`


```bash
promtool query instant http://localhost:9090 up
up{instance="localhost:9090", job="prometheus"} => 1 @[1789287154.861]
up{instance="node01:9100", job="web"} => 1 @[1789287154.861]
up{instance="node02:9100", job="web"} => 1 @[1789287154.861]
up{instance="loadbalancer:9100", job="loadbalancer"} => 1 @[1789287154.861]


promtool query instant http://localhost:9090 "up
{job='web'}"
up{instance="node01:9100", job="web"} => 1 @[1789287225.415]
up{instance="node02:9100", job="web"} => 1 @[1789287225.415]


promtool query instant http://localhost:9090 "node_arp_entries{node='node01:9100'}"
```


# Operators


