de facto standard - Prometheus, Graphana

https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack

```bash
# add repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
# update repo
helm repo update
# install
helm install my-kube-prometheus-stack prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace
```

got error:

```bash
helm install my-kube-prometheus-stack prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace
Error: INSTALLATION FAILED: unable to build kubernetes objects from release manifest: [resource mapping not found for name: "my-kube-prometheus-stack-alertmanager" namespace: "monitoring" from "": no matches for kind "Alertmanager" in version "monitoring.coreos.com/v1"

...
```

Claude AI suggest to install CRDs:

```bash
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml
```