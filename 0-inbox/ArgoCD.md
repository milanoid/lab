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



http://argocd.milanoid.net