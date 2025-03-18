`kubectl create deployment -h | less`

- deploy is an alias to deployment
`k create deploy test --image=httpd --replicas=3`

`k get deployments.apps`

Editing deployment
`k edit deployments.apps test`

Describe deployment
`k describe deployments.apps test`

Delete deployment
`k delete deployments.apps test`

Generate .yaml file
`k create deploy test --image=httpd --replicas=10 --dry-run=client -o yaml > deploy.yaml`

Apply the deployment
`k apply -f deploy.yaml`

`k get replicasets.apps`

---
Piping the doc to vim
`k create deploy -h | vim -`

watch the rolling update strategy in action
````bash
brew install watch
````
`watch -n 1 "kubectl get pods"`

`k apply -f deploy.yaml`

Simulating crashing app

```deploy.yaml
command: ["/bin/bash", "-c",] # override the default command
args: ["sleep; exit 1"] # sleep for 30 seconds then exit with an error
```

STATUS => RunContainerError, CrashLoopBackOff


### Deployments - namespaces

- a logical grouping

`k get namespaces`

`k create namespace <namespace_name>`
`k create namespace mealie`

`k create namespace <namespace_name> -o yaml`
`k create namespace mealie -o yaml --dry-run=client`


`k create ns mealie --dry-run=client -o yaml > namespace.yaml`


run a pod

`k run milan --image=nginx`

- runs a pod in default namespace
```
milan ~/repos/lab/kubernetes-masterclass/mealie [main] $ k get pods -n default
NAME    READY   STATUS    RESTARTS   AGE
milan   1/1     Running   0          15s
```
```
milan ~/repos/lab/kubernetes-masterclass/mealie [main] $ k get pods -n mealie
No resources found in mealie namespace.
```

Run a pod in a specific namespace

`k run milan-mealie --image=nginx --namespace mealie`

```
milan ~/repos/lab/kubernetes-masterclass/mealie [main] $ k get pods -n mealie
NAME           READY   STATUS              RESTARTS   AGE
milan-mealie   0/1     ContainerCreating   0          9s
```

#### Set my namespace as default

`k config current-context`
`k config set-context --current --namespace=mealie`

now `mealie` is the default namespace:

```
milan ~/repos/lab/kubernetes-masterclass/mealie [main] $ k get pods
NAME           READY   STATUS    RESTARTS   AGE
milan-mealie   1/1     Running   0          2m35s
```

### Deployments - Our First Application

