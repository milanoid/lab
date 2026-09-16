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
> SHC_PASSWORD=<admin-password> uv run home-dashboard-api
```  



- [ ] monitor my Python app https://github.com/milanoid-labs/home-dashboard

### home-dashboard prometheus monitoring

doc https://prometheus.github.io/client_python/

- [ ] https://github.com/prometheus/client_python
- [ ] 

