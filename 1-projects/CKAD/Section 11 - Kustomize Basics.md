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