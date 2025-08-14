- a service offers a consistent address to access a set of pods
- a grouping of pods, e.g. FE service, BE service

Why?

- Pods are ephemeral, you should not expect a pod to have a long lifespan
- Pods are constantly changing and being moved accrros nodes
- How will the system keeps track of the constantly changing IP addresses

#### creating a new service (Frontend)

Service example - see _frontend.yaml_.

Tip - vim tip `:%s/test/frontend/g` - globally change string test to string frontend

```bash
kubectl get services
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.43.0.1    <none>        443/TCP   6d3h
```

- using an `expose` command
- `expose` - Expose a resource as a new Kubernetes service.

```bash
kubectl expose deployment frontend --port 8080
service/frontend exposed
```

```bash
kubectl get services --output wide
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE    SELECTOR
frontend     ClusterIP   10.43.138.172   <none>        8080/TCP   35s    app=frontend
kubernetes   ClusterIP   10.43.0.1       <none>        443/TCP    6d3h   <none>
```

- now all the 10 instances of FE service are loadbalanced by Kubernetes, available on `frontend` address

### Types of services

- _ClusterIP_ - default, service reachable using a cluster-wide IP address
- _NodePort_ - exposes a port on each node allowing direct access to the service through any node's IP address
- _LoadBalencer_ - such a service is accessible via external IP address

```bash
kubectl get services
NAME         TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)          AGE
frontend     LoadBalancer   10.43.138.172   192.168.5.15   8080:31317/TCP   15m
```

### Setting up service for Mealie

Create a service using `expose` command

```bash
kubectl expose deployment mealie --port 9000
service/mealie exposed
```

Port-forward to a service

```bash
kubectl port-forward services/mealie 9000
Forwarding from 127.0.0.1:9000 -> 9000
Forwarding from [::1]:9000 -> 9000
Handling connection for 9000
Handling connection for 9000
Handling connection for 9000
Handling connection for 9000
Handling connection for 9000
Handling connection for 9000
```

- now accessible from laptop at localhost:9000

Creating a load-balancer for the (Mealie) service:

- see _service.yaml_

```bash
kubectl get service mealie --output yaml > service.yaml
```

```bash
kubectl apply --filename service.yaml
service/mealie created
```

```bash
kubectl get svc
NAME     TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)          AGE
mealie   LoadBalancer   10.43.144.205   192.168.5.15   9000:31826/TCP   26s
```

- the Mealie app should be accessible on my laptop on http://192.168.5.15:9000 but it is not working => tried to enable _Administrative Access_ in Rancher Desktop - Preferences - Application - General (restart required), did not help
