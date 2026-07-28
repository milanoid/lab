- [x] install on homelab cluster https://github.com/milanoid-labs/homelab-cluster/pull/407
- [x] UI access

```bash
# port forward
kubectl port-forward -n argo-rollouts pods/argo-rollouts-dashboard-7f8648bcd8-mst2p 3100:3100 --address 0.0.0.0

# or run
kubectl argo rollouts dashboard
```
http://localhost:3100/


# Limitations of Kubernetes Deployments


Only _RollingUpdate_ (default) or _Recreate_ strategies.

- Too fast and "All or nothing"
- Success is defined poorly (health check is not enough)
- No real traffic control
- Rollbacks are basically just another RollingUpdate


Enter Argo Rollouts with BlueGreen and Canary deployment strategies.


## Rollout CRD

https://argo-rollouts.readthedocs.io/en/stable/features/specification/

- very similar to Deployment with some extras (_strategy_)
- easy to migrate to/from Rollout/Deployment
- Rollout with missing _strategy_ can be applied (kubectl apply), but fails in rollout phase (Degraded, InvalidSpec)


# First Rollout@homelab


https://github.com/argoproj/rollouts-demo


## Canary Deployment demo

- 2 services - canary and stable
  
```yaml
canaryService: canary-demo-canary
stableService: canary-demo-stable
```

- Rollout with _pause_ steps
- needs to be _promoted_ (either via UI or cli)


```yaml
 strategy:
    canary:
      canaryService: canary-demo-canary
      stableService: canary-demo-stable
      steps:
        - setWeight: 20
        - pause: {} # pause indefinitelly (must be manually promoted)
        - setWeight: 40
        - pause: {duration: 10}
        - setWeight: 60
        - pause: {duration: 10}
        - setWeight: 80
        - pause: {duration: 10}
```


https://github.com/milanoid-labs/homelab-cluster/tree/main/apps/argocd/argo-rollouts-canary-demo


![[Pasted image 20260720095232.png]]


```bash
# promote
> kubectl argo rollouts promote 

Usage: kubectl-argo-rollouts promote ROLLOUT_NAME [flags] 

Examples: 
# Promote a paused rollout 
kubectl argo rollouts promote guestbook 

# Fully promote a rollout to desired version, skipping analysis, pauses, and steps 
kubectl argo rollouts promote guestbook --full
```

After promotion:

```bash
> kubectl argo rollouts get rollout canary-demo -n argo-rollouts-canary-demo
Name:            canary-demo
Namespace:       argo-rollouts-canary-demo
Status:          ✔ Healthy
Strategy:        Canary
  Step:          8/8
  SetWeight:     100
  ActualWeight:  100
Images:          argoproj/rollouts-demo:green@sha256:e32df3d15f759d36c323b3dccb7003d38df1a4274d37217715151f085c24c58f (stable)
Replicas:
  Desired:       5
  Current:       5
  Updated:       5
  Ready:         5
  Available:     5

NAME                                     KIND        STATUS        AGE    INFO
⟳ canary-demo                            Rollout     ✔ Healthy     12h
├──# revision:3
│  └──⧉ canary-demo-7d94b95fd5           ReplicaSet  ✔ Healthy     108m   stable
│     ├──□ canary-demo-7d94b95fd5-2dwpl  Pod         ✔ Running     108m   ready:1/1
│     ├──□ canary-demo-7d94b95fd5-8szxf  Pod         ✔ Running     4m5s   ready:1/1
│     ├──□ canary-demo-7d94b95fd5-fh8df  Pod         ✔ Running     3m52s  ready:1/1
│     ├──□ canary-demo-7d94b95fd5-6xkd9  Pod         ✔ Running     3m41s  ready:1/1
│     └──□ canary-demo-7d94b95fd5-ks9g7  Pod         ✔ Running     3m30s  ready:1/1
└──# revision:2
   └──⧉ canary-demo-67fc7c4899           ReplicaSet  • ScaledDown  11h
```


can watch interactively using `--watch`:

```bash
kubectl argo rollouts get rollout canary-demo -n argo-rollouts-canary-demo --watch
```


see the Canary deployment in action

- it's Paused
- 1 out of 5 Pods is the Canary
- Ready to be tested/inspected
- Needs to be promoted to continue

```bash
Name:            canary-demo
Namespace:       argo-rollouts-canary-demo
Status:          ॥ Paused
Message:         CanaryPauseStep
Strategy:        Canary
  Step:          1/8
  SetWeight:     20
  ActualWeight:  20
Images:          argoproj/rollouts-demo:green@sha256:e32df3d15f759d36c323b3dccb7003d38df1a4274d37217715151f085c24c58f (stable)
                 argoproj/rollouts-demo:red (canary)
Replicas:
  Desired:       5
  Current:       5
  Updated:       1
  Ready:         5
  Available:     5

NAME                                     KIND        STATUS        AGE   INFO
⟳ canary-demo                            Rollout     ॥ Paused      13h
├──# revision:4
│  └──⧉ canary-demo-7f8d7cc775           ReplicaSet  ✔ Healthy     2m3s  canary
│     └──□ canary-demo-7f8d7cc775-9w7vx  Pod         ✔ Running     2m2s  ready:1/1
├──# revision:3
│  └──⧉ canary-demo-7d94b95fd5           ReplicaSet  ✔ Healthy     145m  stable
│     ├──□ canary-demo-7d94b95fd5-2dwpl  Pod         ✔ Running     145m  ready:1/1
│     ├──□ canary-demo-7d94b95fd5-8szxf  Pod         ✔ Running     41m   ready:1/1
│     ├──□ canary-demo-7d94b95fd5-6xkd9  Pod         ✔ Running     41m   ready:1/1
│     └──□ canary-demo-7d94b95fd5-ks9g7  Pod         ✔ Running     40m   ready:1/1
└──# revision:2
   └──⧉ canary-demo-67fc7c4899           ReplicaSet  • ScaledDown  12h
```


```bash
# cli to pronote a paused deployment
kubectl argo rollouts promote canary-demo -n argo-rollouts-canary-demo
```


# Core Rollout Strategies

## Blue-Green Deployment

- 2 environments running side by side
- after promotion the blue is scaled down

1. all blue
	- blue Service
	- blue RS running blue Pods
2. green
    - green Service
    - green RS running green Pods
3. scaling down blue, scaling up green
4. promotion

- resource heavy (2 environments)
- _activeService_ vs _previewService_
- _Service_ selector contains a hash -> to know to which RS route the traffic
	- `selector: app=rollout-bluegreen,rollouts-pod-template-hash=6858478779`

Example Blue-Green Rollout https://github.com/argoproj/argo-rollouts/blob/master/examples/rollout-bluegreen.yaml

![[Pasted image 20260728093544.png]]

- after a promotion there is small delay on scaling down the old revision 
- [_scaleDownDelaySeconds_](https://argo-rollouts.readthedocs.io/en/stable/features/bluegreen/#scaledowndelayseconds) (default 30 seconds)

## Canary Deployment

- gradual shift
- e.g. 80 % stable env, 20 % canary env
- 1 service in a load balancer role

- _setWeight_ - dictates the percentage of traffic that should be sent to the canary


_stableService_ vs _canaryService_

![[Pasted image 20260728105650.png]]



# Advanced Traffic Management

## Replica-Weighted Limitations 

- precision problem (5 replicas -> how to have 5 %?)
- resource waste (over-provision)
- no header-based routing (a canary request header to get the canary response)
- Solution - a Gateway/Traefik


## Traffic-Weighted Canary

Instead of relying on "public" service we create a Gateway (Ingress successor) which weights the traffic exactly as defined (5/95 %) not based on number of Pods.

![[Pasted image 20260728113625.png]]


![[Pasted image 20260728113807.png]]


```yaml
# rollout.yaml
strategy:
  canary:
    canaryService: rollout-gateway-canary
    stableService: rollout-gateway-stable
    trafficRouting:
      plugins:
        argoproj-labs/gatewayAPI:
          httpRoute: rollout-gateway-route # our created httproute
          namespace: gateway-lab # namespace where this rollout resides
```


- `dynamicStableScale: true` - reduce the scale of the stable ReplicaSet during an update such that it scales down as the traffic weight increases to canary
- (When using traffic routing, by default the stable ReplicaSet is left scaled to 100% during the update.)
- see https://argo-rollouts.readthedocs.io/en/stable/features/canary/#dynamic-stable-scale-with-traffic-routing

## Header-Based Routing

I want to query canary application predictably.

E.g. `x-canary: true` in http request







# Automated Analysis and Promotion


## Prometheus & Metrics Architecture


### Prometheus


- https://prometheus.io/
- [The Prometheus Certified Associate (PCA) exam ($250)](https://www.cncf.io/training/certification/pca/)
- [x] Helm Chart `kube-prometheus-stack` on my Homelab (with extras, like Grafana)
- [ ] vs much simple `prometheus-community/prometheus`

-  scrapes metrics, stored them for further analysis
- living in it's own namespace
- prometheus monitors resources with a proper `prometheus` annotation


Components

- _prometheus-server_ - scraping the resources metrics (Rollout, Service etc.)
- _prometheus-kube-state-metrics_ - K8s API for cluster/nodes metrics
- _prometheus-node-exporter_ - run on every mode (CPU, memory ..l)
- _prometheus-pushgateway_
- _prometheus-alertmanager_ - Slack, email, PageDuty alerts


https://argo-rollouts.readthedocs.io/en/stable/analysis/prometheus/

Enrich the K8s manifests with a special annotation:

```yaml
annotations:
  prometheus.io/scrape: 'true'
  prometheus.io/port: '3000'
  prometheus.io/path: '/metrics'
```

- prometheus-server will reach the targets every 1 minute (default)
- _pull model_
- can be setup to use _push model_  - via _prometheus-pushgateway_
- the `/metrics` endpoint must be implemented in the application itself

```
# example /metrics response

# HELP http_requests_total Total number of HTTP requests 
# TYPE http_requests_total counter http_requests_total{method="GET",status="200"} 1027 

# HELP process_resident_memory_bytes Resident memory size in bytes 
# TYPE process_resident_memory_bytes gauge 
process_resident_memory_bytes 5.5452928e+07 

# HELP http_request_duration_seconds Histogram of request duration 
# TYPE http_request_duration_seconds histogram http_request_duration_seconds_bucket{le="0.1"} 240 http_request_duration_seconds_bucket{le="0.5"} 450 http_request_duration_seconds_bucket{le="+Inf"} 500 http_request_duration_seconds_sum 128.4 http_request_duration_seconds_count 500
```

## Automated Analysis & Promotion

- can be used with both Canary and Blue-Green strategy


![[Screenshot 2026-07-28 at 13.27.05.png]]

https://argo-rollouts.readthedocs.io/en/stable/features/analysis/

- we need to scrape metrics on both deployment (canary/stable, green/blue) before promoting it
- _AnalysisTemplete_ - a template for our analysis (namespace scoped)
- _AnalysisRun_ - an instance of the template, either fail (Rollback) or succeed (Auto-Promotion)
- _ClusterAnalysisTemplate_ - like _AnalysisTemplate_ but cluster wide



https://argo-rollouts.readthedocs.io/en/stable/analysis/prometheus/
```yaml
# Example
apiVersion: argoproj.io/v1alpha1
kind: AnalysisTemplate
metadata:
  name: success-rate
spec:
  args:
  - name: service-name
  metrics:
  - name: success-rate
    interval: 5m
    # NOTE: prometheus queries return results in the form of a vector.
    # So it is common to access the index 0 of the returned array to obtain the value
    successCondition: result[0] >= 0.95
    failureLimit: 3
    # take 5 measurements 60 seconds between each other
    interval: 60
    count: 5 
    provider:
      prometheus:
        address: http://prometheus.example.com:9090
        # timeout is expressed in seconds
        timeout: 40
        headers:
        - key: X-Scope-OrgID
          value: tenant_a
        query: |
          sum(irate(
            istio_requests_total{reporter="source",destination_service=~"{{args.service-name}}",response_code!~"5.*"}[5m]
          )) /
          sum(irate(
            istio_requests_total{reporter="source",destination_service=~"{{args.service-name}}"}[5m]
          ))

```

- _AnalysisTemplate_ accepts _arguments_ - e.g. `args.service-name`


```yaml
# example of passing arguments to AnalysisTemplete
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: guestbook
spec:
...
  strategy:
    canary:
      analysis:
        templates:
        - templateName: args-example
        args:
        # required value
        - name: service-name
          value: guestbook-svc.default.svc.cluster.local
```

- query language called [PromQL](https://prometheus.io/docs/prometheus/latest/querying/basics/) (Prometheus Query Language)

Analysis can run either as a `step` or continuously in background.



