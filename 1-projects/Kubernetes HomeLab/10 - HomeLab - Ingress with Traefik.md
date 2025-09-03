Setting up _ingress_ to route traffic into my cluster to Grafana dashboard.

Options to make the Grafana (or any other app) accessible:

1. port-forwarding (a temporary solution only)
2. LoadBalancer
3. cloudflare tunnel (as we did with Linkding)
4. ingress (e.g. Traefik)

# Traefik

K3s installs traefik (ingress controller) by default:

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