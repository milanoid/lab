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

- very similar to Deployment with some extras
- easy to migrate to/from Rollout/Deployment


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
        - pause: {}
        - setWeight: 40
        - pause: {duration: 10}
        - setWeight: 60
        - pause: {duration: 10}
        - setWeight: 80
        - pause: {duration: 10}
```


https://github.com/milanoid-labs/homelab-cluster/tree/main/apps/argocd/argo-rollouts-canary-demo


![[Pasted image 20260720095232.png]]


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







