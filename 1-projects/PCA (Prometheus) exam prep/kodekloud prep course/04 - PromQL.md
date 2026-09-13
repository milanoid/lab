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


## Aritmetic Operators

- `+`
- `-`
- `/`
- `*`

```bash
node_memory_Active_bytes{instance='node1'}       2204815360
node_memory_Active_bytes{instance='node1'} + 10  2204815370
```


## Comparison Operators

- `==`
- `!==`
- `>`
- `<`
- `>=`
- `<=`

```bash
node_network_flags > 100
```


## Bool Operator

- good for alerts
- 1/true, 0/false

```bash
node_filesystem_avail_bytes < 1000
```


## Binary Operator Precedence


1. `^`
2. `*`, `/`, `%`, `atan2`
3. `==`, `!=`, `<=`, `<`, `>=`, `>`
4. `and`, `unless`
5. `or`


## Logical Operators


`OR`, `AND`, `UNLESS`


```bash
node_filesystem_avail_bytes > 1000 and node_filesystem_avail_bytes < 3000

node_filesystem_avail_bytes > 1000 unless node_filesystem_avail_bytes > 3000
```




# Vector Matching


- operations between 2 instant vectors
- `1:1`, `many:1`, `many:many`
- samples with exactly the same labels get matched together

```bash
node_filesystem_avail_bytes / node_filesystem_size_bytes * 100
```


### `ignoring` keyword

- an extra label can be set to be ignored to make the match: `ignoring` keyword

Example:

- a metric with 2 labels

```bash
http_errors{method='get', code='500'}     40 # vector
http_errors{method='get', code='404'}     10
http_errors{method='put', code='201'}     10
http_errors{method='post', code='202'}    11
```

- a metric with all requests, one label

```bash
http_requests{method='get'}     4000
http_requests{method='get'}     1000
http_requests{method='put'}     1000
http_requests{method='post}     1100
```



```bash
# NO MATCH
http_errors{code='500'} / http_requests

# WORKS
http_errors{code='500'} / ignoring(code) http_requests
```


### `on` keyword - the opposite of `ignoring`



```bash
http_errors{code='500'} / on(method) http_requests
```


### Many-To-One


- `group_left` keyword
- `group_rigt` keyword

![[Pasted image 20260913153641.png]]


# Aggregation


https://prometheus.io/docs/prometheus/latest/querying/operators/#aggregation-operators

- `Sum`
- `Min`
- `Max`
- `Avg`
.....

### `by` clause


```bash
sum by(instance) (http_requests)
```



### `without` keyword


- opposite of `by`