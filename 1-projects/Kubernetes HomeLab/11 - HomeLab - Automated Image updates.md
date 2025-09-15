[Mend Renovate](https://www.mend.io/renovate/) - tool to auto update image versions

1. create dir structure
   
```bash
├── infrastructure
│   └── controllers
│       ├── base
│       │   ├── kustomization.yaml
│       │   └── renovate
│       └── staging
│           ├── kustomization.yaml
│           └── renovate
│               └── kustomization.yaml
```
2. create a secret (token for github account to create PRs)
   token name n GH: `renovate-homelab`
```bash
kubectl create secret generic renovate-container-env \
--from-literal=RENOVATE_TOKEN=$RENOVATE_TOKEN \
--dry-run=client \
-o yaml > renovate-container-env.yaml```
   
```bash
sops --age=$AGE_PUBLIC \
--encrypt --encrypted-regex '^(data|stringData)$' --in-place renovate-container-env.yaml
```

3. configure Renovate

- its own namespace - `renovate`
- with a cron job

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: renovate
  namespace: renovate
spec:
  schedule: "@hourly"
  concurrencyPolicy: Forbid
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: renovate
              image: renovate/renovate:latest
              args:
                - milanoid/homelab-cluster

              envFrom:
                - secretRef:
                    # the GH (classic) token
                    name: renovate-container-env
                - configMapRef:
                    name: renovate-configmap

          restartPolicy: Never
```

config map

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: renovate-configmap
  namespace: renovate
data:
  RENOVATE_AUTODISCOVER: "false"
  RENOVATE_GIT_AUTHOR: "Renovate Bot <bot@renovateapp.com>"
  RENOVATE_PLATFORM: "github"
```

renovate.json

```json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "kubernetes": {
    "fileMatch": [
      "\\.yaml$"
    ]
  }
}
```


+ add it to flux file in `clusters/staging/infrastructure.yaml`

`flux reconcile source git flux-system`

`flux reconcile kustomization infrastructure-controllers --with-source`

FluxCD can do images update too.



