https://github.com/mealie-recipes/mealie
https://docs.mealie.io/

generate the deployment manifest based on nginx and then update for Mealie

```bash
kubectl create deployment mealie --image=nginx --dry-run=client --output yaml > deployment.yaml
```
updates the image and exposes a port 9000 to the Pod (not to the host running Kubernetes cluster - my laptop)

```yaml
    spec:
      containers:
      - image: hkotel/mealie:v1.2.0
        name: mealie
        ports:
            # exposes port to a pod
            - containerPort: 9000
```

- see file `mealie/deployment.yaml`

#### port forwarding

The Mealie app is running in container on port 9000, we have exposed the same port to Pod but we want to access the app on the host running the Kubernetes via port-forward.

`kubectl port-forward`

_Forward one or more local ports to a pod._

```bash
kubectl port-forward pods/mealie-5d76fdb59c-q65lx 9000
Forwarding from 127.0.0.1:9000 -> 9000
Forwarding from [::1]:9000 -> 9000
Handling connection for 9000
Handling connection for 9000
Handling connection for 9000
Handling connection for 9000
Handling connection for 9000
```
