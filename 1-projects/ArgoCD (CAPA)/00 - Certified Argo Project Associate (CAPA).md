
Argo is an umbrella project

- 1. Argo Workflows - workflow engine
- 2. ArgoCD - a gitops tool

- cert: https://training.linuxfoundation.org/certification/certified-argo-project-associate-capa/
- documentation: https://argo-cd.readthedocs.io/en/stable/
- udemy courses: https://www.udemy.com/course/argo-cd-rollouts-gitops/

### My ArgoCD installation

- [x] installed and ready to use

https://github.com/milanoid-labs/homelab-cluster/tree/main/infrastructure/controllers/base/argocd

web UI http://argocd.milanoid.net/applications

cli login

```bash
# credentials in Lastpass
argocd login argocd.milanoid.net
```

argocd cli config

```bash
# config file with contexts
~/.config/argocd/config
```

```bash
# list apps
milan@SPM-LN4K9M0GG7 ~
> argocd app list
NAME                CLUSTER                         NAMESPACE  PROJECT  STATUS  HEALTH   SYNCPOLICY  CONDITIONS  REPO                                                  PATH                   TARGET
argocd/app-of-apps  https://kubernetes.default.svc  argocd     default  Synced  Healthy  Auto-Prune  <none>      https://github.com/milanoid-labs/homelab-cluster.git  apps/argocd            HEAD
argocd/guestbook    https://kubernetes.default.svc  guestbook  default  Synced  Healthy  Auto-Prune  <none>      https://github.com/milanoid-labs/homelab-cluster.git  apps/argocd/guestbook  HEAD
```


### My Argo Workflows installation

- [x] installed and ready to use
      - https://github.com/milanoid-labs/homelab-cluster/pull/339
      - https://github.com/milanoid-labs/homelab-cluster/pull/341
      - https://github.com/milanoid-labs/homelab-cluster/pull/342


Running at http://argo.milanoid.net/

Token

```bash
echo "Bearer $(kubectl -n argo get secret argo-ui-token -o jsonpath='{.data.token}' | base64 -d)"
```


- GitHub: https://github.com/argoproj/argo-workflows
- Docs: https://argo-workflows.readthedocs.io/en/latest/quick-start/


cli
```bash
# install on Mac
brew install argo
```


- [x] with help of Claude declaratively setup Argo Workflows on my homeLab


