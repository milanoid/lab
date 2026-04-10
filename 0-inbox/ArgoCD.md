# ArgoCD on Homelab

## Deployment

ArgoCD deployed to the homelab K3s cluster via Flux HelmRelease pattern (same as kube-prometheus-stack).

- **Helm chart**: argo-cd v9.5.0 (app v3.3.6)
- **Namespace**: `argocd`
- **UI**: `argocd.milanoid.net` (LAN/VPN via Traefik ingress)
- **Dex**: disabled (not needed for testing)

### Coexistence with Flux

ArgoCD and Flux run side by side. To avoid reconciliation conflicts:
- **Flux manages**: `apps/base/`, `apps/staging/`, `infrastructure/`, `monitoring/`
- **ArgoCD manages**: `apps/argocd/` only

### Key commands

```bash
# Check status
flux get helmreleases -n argocd
kubectl get pods -n argocd

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### Files

- Base: `infrastructure/controllers/base/argocd/`
- Overlay: `infrastructure/controllers/staging/argocd/`
- ArgoCD apps directory: `apps/argocd/`

## PRs

- [#170 feat: deploy ArgoCD via Flux HelmRelease](https://github.com/milanoid-labs/homelab-cluster/pull/170) — initial deployment (2026-04-10)
- [#171 fix: disable ArgoCD server TLS for Traefik compatibility](https://github.com/milanoid-labs/homelab-cluster/pull/171) — ArgoCD serves HTTPS by default; Traefik can't verify the self-signed cert → set `server.insecure: true` (2026-04-10)
- [#173 feat: add guestbook demo app with app-of-apps pattern](https://github.com/milanoid-labs/homelab-cluster/pull/173) — app-of-apps root + guestbook demo (2026-04-10)
- [#174 refactor: move guestbook manifests into this repo](https://github.com/milanoid-labs/homelab-cluster/pull/174) — local source so we can edit and watch ArgoCD sync (2026-04-10)
- [#175 test: scale guestbook to 3 replicas](https://github.com/milanoid-labs/homelab-cluster/pull/175) — test ArgoCD sync by changing replica count (2026-04-10)
- [#176 test: use non-existent image tag to trigger sync failure](https://github.com/milanoid-labs/homelab-cluster/pull/176) — test ArgoCD error reporting on bad image (2026-04-10)



# argocd-cli

```bash
# login
argocd login argocd.milanoid.net

# invoke sync of app guestbook
argocd app sync guestbook

# get health status
argocd app wait guestbook --health --timeout 60
```

http://argocd.milanoid.net