- [x] install on homelab cluster https://github.com/milanoid-labs/homelab-cluster/pull/407
- [x] UI access

```bash
# port forward
kubectl port-forward -n argo-rollouts pods/argo-rollouts-dashboard-7f8648bcd8-mst2p 3100:3100 --address 0.0.0.0
```
http://localhost:3100/