
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
kubectl drain hpmini03 --ignore-daemonsets --delete-emptydir-data
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
kubectl uncordon hpmini03
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

# Action Runner Controller restart after changing repo url


## Background 

The way I vibe coded the ACR with Claude is there is a hardcoded url to a github repo which only can submit jobs to runners.

After a repo change e.g. [here](https://github.com/milanoid/homelab-cluster/commit/3cbe7e9ae3b83164a1d5350b8360c5b1aa1a93e8) the ACR needs to be "restarted" (otherwise the listener keeps in restart loop with 404 error).

```bash
Application returned an error: createSession failed: failed to create session: actions error: StatusCode 404, AcivityId "":
  GitHub.Actions.Runtime.WebApi.RunnerScaleSetNotFoundException, GitHub.Actions.Runtime.WebApi: No runner scale set found with identifier 1.
```

## Solution

After changing `githubConfigUrl` in the release YAML and pushing:

  1. Delete the HelmRelease to force a fresh install (upgrade preserves the stale scale set ID):
  
  `kubectl delete helmrelease homelab-runners -n arc-runners`
  
  2. Trigger Flux reconciliation (or wait ~1 minute for the next cycle):
  
  `flux reconcile kustomization infrastructure-controllers --with-source`

  Flux recreates the HelmRelease, Helm does a fresh install (not upgrade), and the ARC controller registers a new scale set with the new repo.