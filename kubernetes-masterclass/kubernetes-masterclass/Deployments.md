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
