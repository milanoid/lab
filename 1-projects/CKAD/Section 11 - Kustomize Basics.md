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

- technically optional but use them

```
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
```

# Managing directories

```bash
~/k8s
├── api-depl.yaml
├── api-service.yaml
├── db-service.yaml
└── db-depl.yaml
```

.. later we split that to a separate directories

```bash
~/k8s
├── api
|	├── api-depl.yaml
|	├── api-service.yaml
└── db
	├── db-service.yaml
	└── db-depl.yaml
```

which brings the need to run `apply` for each dir:

```bash
kubectl apply -f k8s/api/

kubectl apply -f k8s/db/
```

it becomes a tedious job 

Here it comes `kustomization.yaml`:

```bash
~/k8s
└── kustomization.yaml
├── api
|	├── api-depl.yaml
|	├── api-service.yaml
└── db
	├── db-service.yaml
	└── db-depl.yaml
	
	
# kustomization.yaml:
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - api/api-depl.yaml
  - api/api-service.yaml
  - db/db-depl.yaml
  - db/db-service.yaml
    
    
# to apply
kustomize build k8s/ | kubectl apply -f -

```

but still (imagine having dozens of directories)

```bash
~/k8s
├── kustomization.yaml
├── api/
├── cache/
├── kafka/
├── rabbit/
├── ...
└── db/

# the kustomization.yaml file would be huge
```

lets split that once more

```bash
~/k8s
├── kustomization.yaml
├── api/
|    ├── kustomization.yaml
├── cache/
|    ├── kustomization.yaml
├── kafka/
|    ├── kustomization.yaml
├── rabbit/
|    ├── kustomization.yaml
├── ...
└── db/
     └── kustomization.yaml
```


outer (root) `kustomization.yaml`:

```yaml
---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - api/
  - db/
  - cache/
  .....
```

Apply: `kustomize build k8s/ | kubectl apply -f -`


# Common Transformers

- some build in, can write my own too

What issue they solve?

- e.g. we want to have same label on all the resources


- `commonLabel` - adds a label to all Kubernetes resources
- `namePrefix/Suffix` - adds a common prefix-suffix to all resource names
- `Namespace` - adds a common namespaces
- `commonAnnotations`


# Image Transformers

change image
```yaml
images:
  - name: nginx
    newName: haproxy
```

change image tag
```yaml
images:
  - name: nginx
    newTag: 2.4
```

change both

```yaml
images:
  - name: nginx
    newName: haproxy
    newTag: "2.4"
```

# Patches Intro

- another method to modify Kubernetes configs
- more surgical approach to target

3 parameters

1. Operation Type: add/remove/replace
2. Target: Kind, Name, Namespace ...
3. Value

```yaml
# api-depl.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-deployment
spec:
.....
```

```yaml
# kustomization.yaml
# Json 6902
patches:
  - target:
      kind: Deployment
      name: api-deployment
      
    patch: |-
      - op: replace
        path: /metadata/name
        value: web-development
```


## Json 6902 vs Strategic Merge Patch

	- both equal, can use either

```yaml
# kustomization.yaml
# strategic merge patch
patches:
  - patch: |-
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: api-deployment
      spec:
        replicas: 5
```

```yaml
# kustomization.yaml
# Json 6902
patches:
  - target:
      kind: Deployment
      name: api-deployment
      
    patch: |-
      - op: replace
        path: /metadata/name
        value: web-development
```

# Different Types of Patches

1. inline (above)
2. separate file (also can be both Json 6902 or strategic merge)

```yaml
# Kustomization
patches:
  - path: replica-patch.yaml
    target:
      kind: Deployment
      name: nginx-deployment
```

```yaml
# replica-path.yaml
- op: replace
  path: /spec/replicas
  values: 5
```

# Patches Dictionary


```yaml
# api-depl.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-deployment
spec:
  ...
  template:
    metadata:
      labels:
        org: KodeKloud
        component: api
   ...
```

```yaml kustomization
patches:
  - label-patch.yaml
```

- use `null` to remove
```yaml
# label-patch.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-deployment
spec:
  ...
  template:
    metadata:
      labels:
        org: null
```


# Patches List


```yaml
# api-depl.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-deployment
spec:
  ...
  template:
    metadata:
      labels:
        org: KodeKloud
        component: api
    spec:
      containers:
        - name: nginx
          image: nginx
```


replace
```yaml
# kustomization (json 6902)
patches:
  - target:
      kind: Deployment
      name: api-deployment
      
    patch: |-
      - op: replace
        path: /spec/template/spec/containers/0
        value:
          name: haproxy
          image: haproxy
```

`-` append to end of the list 
```yaml
# kustomization (json 6902)
patches:
  - target:
      kind: Deployment
      name: api-deployment
      
    patch: |-
      - op: add
        path: /spec/template/spec/containers/-
        value:
          name: haproxy
          image: haproxy
```

delete using strategic merge

```yaml
# label-patch.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-deployment
spec:
  ...
  template:
    spec:
      containers:
        - $patch: delete
	      image: nginx
```

# Overlays

```
k8s/
├── base/
│   ├── deployment.yaml
│   ├── kustomization.yaml
│   └── service.yaml
└── overlays/
    ├── dev/
    │   ├── cpu_count.yaml
    │   ├── kustomization.yaml
    │   └── replica_count.yaml
    └── prod/
        ├── cpu_count.yaml
        ├── kustomization.yaml
        └── replica_count.yaml
```

```yaml
# dev/kustomization
bases:
  - ../../base
patch: |-
	 - op: replace
	   path: /spec/replicas
	   value: 2
```


# Component

- components provide the ability to define reusable pieces of configuration logic (resources + patches) that can be included in multiple overlays
- components are useful in situations where applications support multiple optional features that need to be enabled only in a subset of overlays


E.g.  caching or DB to apply only to subset of overlays (prod, stage, not dev)


```yaml
#@components/db/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1alpha1
kind: Component

resources:
  - postgres-depl.yaml

secretGenerator:
  - name: postgres-cred
    literals:
      - password=postgres123
patches:
  - deploylment-patch.yaml

```

```yaml
# overlay/premium/kustomization
bases:
  - ../../base

components:
  - ../../components/db
```