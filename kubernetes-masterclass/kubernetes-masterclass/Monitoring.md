https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack

- Grafana dashboard
- Prometheus


Installing Helm chart

1. adding repository
2. installing the Helm chart

```
helm install prometheus-stack prometheus-community/kube-prometheus-stack --namespace=monitoring --create-namespace
```

### Port Forward via K9s

1. `: + svc` -  to show all services
2. select `prometheus-stack-grafana` service
3. `shift + f` - opens a port forward window, offers defaults (port 3000)
4. Grafana available at http://localhost:3000/

### Getting Grafana login credentials


export default values to a file for inspection

`helm show values prometheus-community/kube-prometheus-stack > prometheus-default-values.yaml`

- password: `prom-operator
- username: `admin
### Changing default password

in `values.yaml` file

```
grafana:
  adminPassword: hello-world
```

upgrade the helm chart

```
helm upgrade -n monitoring prometheus-stack prometheus-community/kube-prometheus-stack --values values.yaml
```