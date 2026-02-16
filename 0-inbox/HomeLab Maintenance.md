
Snippets for regular maintenance tasks


# Rebooting Nodes

e.g. when the OS is updated and requires restart


## Before restart

  1. Check current state — make sure nothing is mid-reconciliation
  ```bash
  flux get kustomizations
  flux get helmreleases -A
  kubectl get pods -A | grep -v Running | grep -v Completed
  ```
  2. Suspend Flux — prevent reconciliation during restart which could cause unnecessary churn
  ```bash
  flux suspend kustomization --all
  ```

  3. Drain nodes gracefully — evicts pods cleanly so apps shut down properly
  ```
  kubectl drain hpmini01 --ignore-daemonsets --delete-emptydir-data
  kubectl drain hpmini02 --ignore-daemonsets --delete-emptydir-data
  ```
 
  4. Restart nodes — control plane first, then worker
```bash
sudo reboot
```

## After restart

  5. Uncordon nodes
```
kubectl uncordon hpmini01
kubectl uncordon hpmini02
```
  
  6. Resume Flux
```
flux resume kustomization --all
```  

  7. Verify

```bash
kubectl get nodes
kubectl get pods -A | grep -v Running | grep -v Completed
flux get kustomizations
```
  