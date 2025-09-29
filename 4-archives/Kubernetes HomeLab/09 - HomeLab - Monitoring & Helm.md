https://fluxcd.io/flux/guides/repository-structure/

they suggest to use `infrastructure`, Mischa uses `monitoring` 


https://github.com/milanoid/homelab-cluster/commit/891a0f3f1a56fb12865b906416c53c68831a430e

to see Grafana do port-forward for now:

`kubectl -n monitoring port-forward svc/kube-prometheus-stack-grafana 8080:80`

Grafana running at http://localhost:8080/

user: admin