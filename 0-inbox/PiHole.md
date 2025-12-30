with DoH (DNS over HTTPS)?

- [ ] prerequisite [[iSCSI as Persistant Volume]]

## Docker

https://docs.pi-hole.net/docker/configuration/

## Helm

https://github.com/MoJo2600/pihole-kubernetes

Install
```bash
# add repo
helm repo add mojo2600 https://mojo2600.github.io/pihole-kubernetes/
helm repo update

# show values
helm show values mojo2600/pihole > pihole.values.yaml

# edit the values yaml file then run
helm install pihole mojo2600/pihole --namespace pihole --create-namespace --values=pihole.values.yaml
```


values.yaml - `~/Documents/pihole.values.yaml`

Install output
```bash
helm install pihole mojo2600/pihole --namespace pihole --create-namespace --values=pihole.values.yaml

NAME: pihole
LAST DEPLOYED: Mon Dec 29 15:26:15 2025
NAMESPACE: pihole
STATUS: deployed
REVISION: 1
NOTES:
Pi-hole Helm Chart Deployment

1. Pi-hole Deployment Information:
   - Release Name: pihole
   - Namespace: pihole
   - Chart Name: pihole
   - Chart Version: 2.35.0

2. Pi-hole Service Information:
   - Service Name: pihole-web
   - Service Type: ClusterIP
   - Service Port: 80/443 TCP

   - Service Name: pihole-dns-tcp
   - Service Type: NodePort
   - Service Port: 53 TCP

   - Service Name: pihole-dns-udp
   - Service Type: NodePort
   - Service Port: 53 UDP

   - Service Name: pihole-dhcp
   - Service Type: NodePort
   - Service Port: 67 UDP

3. Accessing Pi-hole:
   !!! This chart does not create a Loadbalancer for pihole by default. Please
   create a configuration that is tailored to your setup. Especially the DNS
   and DHCP services are system services that require a dedicated setup based
   on your system !!!

   Find more information in the wiki:
   https://github.com/MoJo2600/pihole-kubernetes/wiki/Pi%E2%80%90hole

4. Useful Commands:
   - Check the Pi-hole Deployment Status:
     helm status pihole

   - Get Detailed Information about the Pi-hole Deployment:
     helm get all pihole

5. Clean Up:
   - To uninstall/delete the Pi-hole deployment, run:
     helm uninstall pihole
```

make pihole-web accessible (shift+f in K9s)

http://localhost:8081/admin/

allow to get IP address in my LAN range 192.168.x.x:

```yaml
serviceDns:
  type: LoadBalancer
```
K3s has its own LoadBalancer - https://github.com/k3s-io/klipper-lb



- another way is to use ingress (traefik)

```bash
# after values update run
helm upgrade pihole mojo2600/pihole --namespace pihole --values=pihole.values.yaml
```

then I get the External IP 192.168.1.232:

```bash
kubectl get service -o wide
NAME             TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)          AGE   SELECTOR
pihole-dhcp      NodePort       10.43.131.90   <none>          67:30650/UDP     18m   app=pihole,release=pihole
pihole-dns-tcp   LoadBalancer   10.43.95.131   192.168.1.232   53:31593/TCP     18m   app=pihole,release=pihole
pihole-dns-udp   LoadBalancer   10.43.123.50   192.168.1.232   53:30297/UDP     18m   app=pihole,release=pihole
pihole-web       ClusterIP      10.43.80.68    <none>          80/TCP,443/TCP   18m   app=pihole,release=pihole
```

Router settings

LAN - DHCP Server - DNS Server 1 = 192.168.1.232

Profit!


Added extra blocklist https://github.com/hagezi/dns-blocklists?tab=readme-ov-file#normal

Issue with Rolling Update
https://github.com/MoJo2600/pihole-kubernetes/issues/397


# Persistant storage

- now using localPath
- [ ] switch to NAS (NFS or iSCSI)