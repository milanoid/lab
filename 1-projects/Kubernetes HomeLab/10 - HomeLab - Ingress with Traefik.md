Setting up _ingress_ to route traffic into my cluster to Grafana dashboard.

Options to make the Grafana (or any other app) accessible:

1. port-forwarding (a temporary solution only)
2. LoadBalancer
3. cloudflare tunnel (as we did with Linkding)
4. ingress (e.g. Traefik)

# Traefik

K3s installs Traefik (ingress controller) by default:

```bash
kubectl get pods -A
kube-system   traefik-c98fdf6fb-pcrtp                                     1/1     Running     2 (11m ago)    31d
```


```bash
k get svc -n kube-system
NAME                                            TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)                        AGE
kube-dns                                        ClusterIP      10.43.0.10      <none>          53/UDP,53/TCP,9153/TCP         31d
kube-prometheus-stack-coredns                   ClusterIP      None            <none>          9153/TCP                       9d
kube-prometheus-stack-kube-controller-manager   ClusterIP      None            <none>          10257/TCP                      9d
kube-prometheus-stack-kube-etcd                 ClusterIP      None            <none>          2381/TCP                       9d
kube-prometheus-stack-kube-proxy                ClusterIP      None            <none>          10249/TCP                      9d
kube-prometheus-stack-kube-scheduler            ClusterIP      None            <none>          10259/TCP                      9d
kube-prometheus-stack-kubelet                   ClusterIP      None            <none>          10250/TCP,10255/TCP,4194/TCP   9d
metrics-server                                  ClusterIP      10.43.194.116   <none>          443/TCP                        31d
traefik                                         LoadBalancer   10.43.46.131    192.168.1.231   80:32328/TCP,443:31901/TCP     31d
```


```bash
kubectl describe svc -n kube-system traefik
Name:                     traefik
Namespace:                kube-system
Labels:                   app.kubernetes.io/instance=traefik-kube-system
                          app.kubernetes.io/managed-by=Helm
                          app.kubernetes.io/name=traefik
                          helm.sh/chart=traefik-34.2.1_up34.2.0
Annotations:              meta.helm.sh/release-name: traefik
                          meta.helm.sh/release-namespace: kube-system
Selector:                 app.kubernetes.io/instance=traefik-kube-system,app.kubernetes.io/name=traefik
Type:                     LoadBalancer
IP Family Policy:         PreferDualStack
IP Families:              IPv4
IP:                       10.43.46.131
IPs:                      10.43.46.131
LoadBalancer Ingress:     192.168.1.231 (VIP)
Port:                     web  80/TCP
TargetPort:               web/TCP
NodePort:                 web  32328/TCP
Endpoints:                10.42.0.70:8000
Port:                     websecure  443/TCP
TargetPort:               websecure/TCP
NodePort:                 websecure  31901/TCP
Endpoints:                10.42.0.70:8443
Session Affinity:         None
External Traffic Policy:  Cluster
Internal Traffic Policy:  Cluster
Events:
  Type     Reason                   Age   From                   Message
  ----     ------                   ----  ----                   -------
  Normal   EnsuringLoadBalancer     20m   service-controller     Ensuring load balancer                                        Normal   AppliedDaemonSet         20m   service-lb-controller  Applied LoadBalancer DaemonSet kube-system/svclb-traefik-818aeded
  Warning  UnAvailableLoadBalancer  20m   service-lb-controller  There are no available nodes for LoadBalancer
  Normal   UpdatedLoadBalancer      20m   service-lb-controller  Updated LoadBalancer with new IPs: [] -> [192.168.1.231]
```


```bash
# external IP address the cluster gets from my local DHCP
# it's IP address where the LoadBalancer is running on
LoadBalancer Ingress:     192.168.1.231 (VIP)
```

```bash
# these 2 ports are handled by Traefik
# Traefik listens and router incomming traffic elsewhere
Port:                     web  80/TCP
Port:                     websecure  443/TCP
```

```bash
~ ❯ kubectl get svc -n kube-system
# incomming traffic to 192.168.1.231 port 80|443 is picked by LoadBalancer


NAME                                            TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)                        AGE
traefik                                         LoadBalancer   10.43.46.131    192.168.1.231   80:32328/TCP,443:31901/TCP
```

based on _ingress resources_ it routes the traffic:

- currently there is none defined, LB does not know where to route the traffic to

```bash
~ ❯ kubectl get ingress -A
No resources found
```

## Routing via Ingress (Treafik)

1. We want to setup routing locally. For that the comment _cloudflared_:
2. We need to create an _Ingress Resource_

```
# https://server.milanoid.net/
# Error 1033
```

### Ingress Resource

- create file `apps/staging/linkding/ingress.yaml`
- add it to _Kustomization_ file in `apps/staging/linkding`

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: linkding
spec:
  ingressClassName: traefik
  rules:
    - host: linkding.milanoid.net
      http:
        paths:
          - backend:
              service:
                name: linkding
                port:
                  number: 9090
            path: /
            pathType: Prefix
```

- the _rules_ says to route incoming traffic to `server.milanoid.net` to _service_ `linkding` running on port 9090  as defined in `apps/base/linkding/service/yaml`
  
```yaml
apiVersion: v1
kind: Service
metadata:
  name: linkding
spec:
  ports:
    - port: 9090
  selector:
    app: linkding
  type: ClusterIP
```


to see what `ingressClassName` are available:

```bash
homelab-cluster main ❯ kubectl get ingressclasses.networking.k8s.io
NAME      CONTROLLER                      PARAMETERS   AGE
traefik   traefik.io/ingress-controller   <none>       42d
```

- on K3s is just one - the treafik.


After reconciliation we have the Ingress set up:

```bash
homelab-cluster main ❯ kubectl get ingress
NAME       CLASS     HOSTS                 ADDRESS         PORTS   AGE
linkding   traefik   server.milanoid.net   192.168.1.231   80      7s
```

```bash
homelab-cluster main ❯ kubectl describe ingress
Name:             linkding
Labels:           kustomize.toolkit.fluxcd.io/name=apps
                  kustomize.toolkit.fluxcd.io/namespace=flux-system
Namespace:        linkding
Address:          192.168.1.231
Ingress Class:    traefik
Default backend:  <default>
Rules:
  Host                 Path  Backends
  ----                 ----  --------
  server.milanoid.net
                       /   linkding:9090 (10.42.0.84:9090)
Annotations:           <none>
Events:                <none>
```

In order to access the URL https://server.milanoid.net from my local machine, I need to update my hosts file:

```bash
# sudo vim /etc/hosts

192.168.1.231 linkding.milanoid.net

# try then `nslookup linkding.milanoid.net`
```

So now I can access the `linkding` app from my local machine only.

### ### Add my internal IP to Cloudflare

- Cloudflare allows to add internal IP addresses in the DNS records (other providers might not)

Add A record for linkding.milanoud.net using the private IP 192.168.1.231

(extras: do that via Terraform cloudflare provider https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs)

So now I can remove the record from my hosts file.

Since now I can access the linkding via address without need to modify hosts file.


```bash
homelab-cluster main ❯ nslookup linkding.milanoid.net
Server:         127.0.0.53
Address:        127.0.0.53#53

Non-authoritative answer:
Name:   linkding.milanoid.net
Address: 192.168.1.231
```
Benefits:

- no need to modify hosts file
- works on any machine (as it uses public DNS record for the address)
- we are using Cloudflare as my local DNS!

Excercise

- Create an _Ingress Resource_ through the Graphana Helm chart

```bash
# checking Values
homelab-cluster main ❯ helm show values prometheus-community/kube-prometheus-stack
```

- it's about adding "ingress" to `/monitoring/controllers/kube-prometheus-stack/release.yaml`

```yaml
values:
    # to see all possible values run `helm show values prometheus-community/kube-prometheus-stack`
    grafana:
      adminPassword:
      ingress:
        enabled: true
        ingressClassName: traefik
      hosts:
        - grafana.milanoid.net
```

Git commit/push and all changes will be applied via Flux.

https://grafana.milanoid.net/






















