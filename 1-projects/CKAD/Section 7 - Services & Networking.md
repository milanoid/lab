# Network Policies

https://kubernetes.io/docs/concepts/services-networking/network-policies/

Ingress - incoming traffic
Egress - outgoing traffic

- where the traffic originates

E.g.
- User ---> (Ingress) ---> WebServer
- WebServer ---> (Egress) ---> BackendServer

## Network Security

In Kubernetes cluster a Pod is able to communicate with any other Pod within the cluster (even on a different Node) without a need to specify any policy.

- _All Allow_ - default


_Network Policy_ - Kubernetes object as any other

- defines Ingress and Egress policy

To link a Network Policy to a Pod _Selectors_ are used.


```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: db-policy
spec:
  podSelector:
    matchLabels:
      role: db
    policyTypes:
    - Ingress
    ingress:
    - from:
      - podSelector:
          matchLabels:
            name: api-pod
       ports:
       - protocol: TCP
         port: 3306
```

`kubectl create -f policy.yaml`

Note:

Solution that support Network Policies

- Kube-router
- Calico
- Romana

No support:

- Flannel

# Developing network policies

task - secure DB Pod;

- DB Pod listens on port 3306
- it should accept Ingress only from API Pod
- it should reject any other Ingress
- it should allow only Egress on port 3306 (no need to set, allowed by Ingress already)

```yaml
# policy to block all traffic to DB Pod except Ingress 3306 from API Pod
# to limit that to a specific namespace use `namespaceSelector`
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: db-policy
spec:
  podSelector:
    matchLabels:
      role: db
    policyTypes:
    - Ingress
    ingress:
    - from:
      - podSelector:
          matchLabels:
            name: api-pod
        namespaceSelector:
          matchLabels:
            kubernetes.io/metadata.name: prod
       ports:
       - protocol: TCP
         port: 3306
```


extra task - allow traffic to DB Pod for a backup server

- the backup server is not part of the Kubernetes cluster (not a Pod)
- but knowing its IP address we can set the policy too

```yaml
ipBlock:
  cidr: 192.168.5.10/32
```


```
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: db-policy
spec:
  podSelector:
    matchLabels:
      role: db
    policyTypes:
    - Ingress
    ingress:
    - from:
      - podSelector:
          matchLabels:
            name: api-pod
        namespaceSelector:
          matchLabels:
            kubernetes.io/metadata.name: prod
       - ipBlock:
		  cidr: 192.168.5.10/32
       ports:
       - protocol: TCP
         port: 3306
```

It works like this:

- `podSelector` OR `ipBlock` - logical OR between rules
- `podSelector` AND `namespaceSelector` - logical AND


```yaml
# by adding '=' before `namespaceSelector` we have 3 separate ruls, with logical OR between each
- from:
      - podSelector:
          matchLabels:
            name: api-pod
       - namespaceSelector:
           matchLabels:
             kubernetes.io/metadata.name: prod
       - ipBlock:
		  cidr: 192.168.5.10/32
       ports:
       - protocol: TCP
         port: 3306
```


Task - Egress rule for the DB Pod to backup server

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: db-policy
spec:
  podSelector:
    matchLabels:
      role: db
    policyTypes:
    - Ingress
    - Egress
    ingress:
    - from:
      - podSelector:
          matchLabels:
            name: api-pod
       ports:
       - protocol: TCP
         port: 3306
    egress:
    - to:
       - ipBlock:
           cidr: 192.168.5.10/32
        ports:
        - protocol: TCP
          port: 80
```