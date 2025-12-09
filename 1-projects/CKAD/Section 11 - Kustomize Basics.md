# Problem statement and ideology

3 environments - dev, stage, prod - each in its own directory

- initially all the yaml files needs to be copied over to all three dirs, with customized settings

### concept of `base` and `overlays`

https://kustomize.io/
https://kubectl.docs.kubernetes.io/guides/introduction/kustomize/

```
~/someApp
├── base
│   ├── deployment.yaml
│   ├── kustomization.yaml
│   └── service.yaml
└── overlays
    ├── development
    │   ├── cpu_count.yaml
    │   ├── kustomization.yaml
    │   └── replica_count.yaml
    └── production
        ├── cpu_count.yaml
        ├── kustomization.yaml
        └── replica_count.yaml
```

Base + Overlays = Final manifests


# Kustomize vs Helm

- both addressing multi-environment cluster

Helm
- uses Go templates `{{ .Values.replicaCount }}`
- more than just a tool to customize configuration
- also a package manager
- extra features like conditionals, loops, functions and hooks
- Helm templates with go syntax are not valid yaml files!
- complex and can be hard to read


Helm project structure

```
~/k8s
├── enviroments
│   ├── values.dev.yaml
│   ├── values.stg.yaml
│   └── values.prod.yaml
└── templates
    ├── nginx-deployment.yaml
    ├── db-deployment.yaml
    └── nginx-service.yaml
    
```

# Installation/Setup

```bash
# install on Mac
brew install kustomize

# get version
kustomize version
v5.8.0
```

https://kubectl.docs.kubernetes.io/installation/kustomize/


# kustomization.yaml file

https://kubectl.docs.kubernetes.io/guides/introduction/kustomize/

```yaml
---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

# kubernetes resources to be managed by kustomize
resources:
  - deployment.yaml
  - service.yaml
  - configmap.yaml
    
# customizations to be made
commonLabels:
  company: KodeKloud
```


```bash
# generate Kustomize YAML file
kustomize build my-app/
```

Kustomize:

- looks for a kustomization file
- the file contains a list of all Kubernetes manifests to be managed by Kustomize
- all of the customization that should be applied
- `kustomize build` combines all the manifests and applies the defined transformations
- it does not apply/deploy anything
- to apply one needs to run `kubectl apply`

# Kustomize output

 ```bash
 # apply/deploy
 kustomize build my-app/ | kubectl apply -f -
 
 # delete
 kustomize build my-app/ | kubectl delete -f -
 
 # natively with kubectl
 kubectl delete -k my-app/ # -k for kustomize
 ```
# Kustomize ApiVersion & Kind

