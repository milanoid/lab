# Intro

Examples on Python App, mostly with Flask framework

# Basics


### Python Prometheus Client

- https://github.com/prometheus/client_python
```python
from prometheus_client import Counter, start_http_server

if __name__ == '__main__':
	start_http_server(8000)
	app.run(port='5001`)
```

- `localhost:8000` - Prometheus metrics
- `localhost:5001` - The Python App




### Flask framework

- no need for extra http server for metrics

```python
from flask import Flask
from prometheus_client import make_wsgi_app
from prometheus_client import Counter
from werkzeug.middleware.dispatcher import DispatcherMiddleware

REQUEST = Counter('http_requests_total', 'Total number of requests')

app = Flask(__name__)


# Add prometheus middleware to export metrics at /metrics
app.wsgi_app = DispatcherMiddleware(app.wsgi_app, {'/metrics': make_wsgi_app()})

### Flask App: localhost:5001
### Prometheus localhost:5001/metrics

@app.get("/cars")
def get_cars():
	REQUESTS.inc()
	returns ["toyta", "honda", "mazda", "lexus"]
	
	
@app.get(/cars/<int:id>)
def get_car():
	REQUESTS.inc()
	return "Single car"
	
### and more....
```



# Labels


```python
REQUEST = Counter(
	'http_requests_total', 
	'Total number of requests',
	Labelnames=['path']
	)
	
	
	
@app.get("/cars")
def get_cars():
	REQUESTS.labels('/cars').inc()
	returns ["toyta", "honda", "mazda", "lexus"]
	
	
@app.get("/boats")
def get_boats():
	REQUESTS.labels('/boats').inc()
	returns ["boat1", "boat2", "boat3"]
```


```bash

#Prometheus query
http_requests_total{path='/cars'}
http_requests_total{path='/boats'}

# with not path returns both
http_requests_total
```

- there could be multiple labels , not just one


# Histogram/Summary


```python
LATENCY = Histogram('request_latency_seconds', 'Request Latency', Labelnames=['path', 'method'])


def before_request():
	request.start_time = time.time()
	
def after_request():
	request_latency = time.time() - request.start_time
	LATENCY.labels(request.method, request.path).observe(request_latency)
	return response
	
if __name__ == '__main__':
	start_http_server(8000)
	app.before_request(before_request)
	app.after_request(after_request)

```

- by default the client lib picks buckets, those might need to be modified

```python
LATENCY = Histogram(
	'request_latency_seconds', 
	'Request Latency', 
	Labelnames=['path', 'method'],
	buckets=[0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.07, 0.08, 0.09, 0.1]
	)
```

for Summary the same


```python
LATENCY = Summary(
	'request_latency_seconds', 
	'Request Latency', 
	Labelnames=['path', 'method']
	)
```

# Gauge


```python
IN_PROGRESS = Gauge('inprogress_requests', 'Total nuber of requests in progress', Labelnames=['path', 'method'])


def before_request():
	IN_PROGRESS.labels(request.method, request.path).inc()
	request.start_time = time.time()
	
def after_request():
	IN_PROGRESS.labels(request.method, request.path).dec()
	return response
```


# Best Practice


### Naming

- `snake_case`
- 1st word for the application we are monitoring (library)
- 2nd word for the metric of the app we are monitoring
- unit should always be included (bytes, seconds, meters) - unprefixed

GOOD examples

```bash
http_request_total
process_cpu_seconds
postgres_queue_size_bytes
redis_connection_errors
node_disk_read_bytes_total
```

BAD examples

```bash
container_docker_restarts (X)
http_requests_sum (X)
nginx_disk_free_kilobytes (X)
dotnet_queue_waiting_time (X)
```


### What to instrument?

- Online-serving systems
- Offline processing
- Batch jobs

#### Online-serving systems

- immediate response expected
- number of Queries/Requests
- number of Errors
- latency
- number of in progress requests


#### Offline processing

- no-one is actively waiting for the response
- usually multiple stages
- amount of queued work
- amount of work in progress
- rate of processing
- errors


#### Batch jobs

- run on schedule
- requires Push Gateway
- time processing
- jobs completed





# Lab


- [x] kodekloud lab
- [x] make the app runnable locally first
      
```bash
milan@SPM-LN4K9M0GG7 ~/repos/home-dashboard/src/backend/src/backend (main)
> SHC_PASSWORD=<admin-password> API_RELOAD=true uv run home-dashboard-api
```  


```bash

curl http://localhost:8001/  
curl http://localhost:8001/health
curl http://localhost:8001/zones

# switch of light in living room
curl -X POST http://localhost:8001/zones/hz_1/devices/xCo:6602052_u0/control -H "Content-Type: application/json" -d '{"state": "on"}'

```



- [x] basic monitor my Python app https://github.com/milanoid-labs/home-dashboard

### home-dashboard prometheus monitoring


#### app changes

- doc https://prometheus.github.io/client_python/
- [x] PR in app https://github.com/milanoid-labs/home-dashboard/pull/10
- [x] PR in app https://github.com/milanoid-labs/home-dashboard/pull/16


#### k8s prometheus changes

- [x] K8s homelab Prometheus scraping https://github.com/milanoid-labs/homelab-cluster/pull/497

```bash
# to access Prometheus@homelab http://localhost:9090
kubectl -n monitoring port-forward svc/kube-prometheus-stack-prometheus 9090:9090
```

now available at http://prometheus.milanoid.net/
https://grafana.milanoid.net/

```bash
# to curl the backend
kubectl -n home-dashboard port-forward svc/home-dashboard-backend 8001:80

> curl http://localhost:8001/ 
> {"message":"Home Dashboard API"}
```


```bash
# query
request_processing_seconds_count{job="home-dashboard-backend"}
```

#### prom-lab prometheus changes

- [x] Prometheus scraping in `prom-lab` installation

- Ingress so Prometheus on `prom-lab` can reach the `/metrics` https://github.com/milanoid-labs/homelab-cluster/pull/502

```bash
# metrics now available for scraping at:
curl http://home-dashboard.milanoid.net/metrics
```



```yaml
# /etc/prometheus/prometheus.yaml

- job_name: 'home-dashboard'
  static_configs:
     - targets: ['home-dashboard.milanoid.net/metrics'] # << invalid, can't use path here
```

```bash
journalctl -u prometheus.service -f

Sep 17 07:02:56 prom-lab prometheus[8017]: time=2026-09-17T07:02:56.181Z level=ERROR source=main.go:1414 msg="Error reloading config" err="couldn't load configuration (--config.file=\"/etc/prometheus/prometheus.yml\"): parsing YAML file /etc/prometheus/prometheus.yml: \"home-dashboard.milanoid.net/metrics\" is not a valid hostname"
```

```yaml
# path to be defined in `metrics_path`
- job_name: 'home-dashboard'
  metrics_path: /metrics 
  static_configs: 
     - targets: ['home-dashboard.milanoid.net']
```

working query - note the missing `-backend` (as in k8s prometheus)

`request_processing_seconds_count{job="home-dashboard"}`