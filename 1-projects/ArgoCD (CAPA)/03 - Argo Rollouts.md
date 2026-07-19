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









