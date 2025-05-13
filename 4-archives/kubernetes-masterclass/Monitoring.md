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


Setting Grafana service

- to have IP address or name usable in `homarr` dashboard
- to have open port on localhost so the Grafana is accessible without port-forwaring in K9s

`/monitoring/loadbalancer.yaml` -  based on `mealie/service.yaml`


`k apply -f loadbalancer.yaml

should be accessible at external IP http://192.168.5.15:3000/

:( same as with mealie - it does not work for me

! works over IP assigned to a NIC via router, e.g. http://192.168.1.49:3000/login

#### Setting up a Grafana dashboard

use sample https://github.com/mischavandenburg/lab/blob/main/kubernetes/grafana/dashboards/simple-namespace-overview.json

