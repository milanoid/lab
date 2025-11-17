https://docs.k3s.io/quick-start


Current setup
- K3s one-node installation - node `hpmini01`

On another HP machine install:

- [ ] Ubuntu Server
- [ ] add K3s additional agent node `hpmini02-agent` to cluster 
- [ ] experiment with [Taints and Tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/), e.g. have some apps only on one Node