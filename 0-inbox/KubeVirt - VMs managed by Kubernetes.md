with GitHub Action self-hosted runners


# Plan

To an existing runner group (pod based via [ARC](https://github.com/actions/actions-runner-controller)) add another group of self-hosted runners on an ephemeral VMs.

Create a new K3s node `kubevirt01` on a large Proxmox VM (4 vCPU, 12 GB). On this node install [KubeVirt](https://kubevirt.io/), custom Autoscaler (based on [ScaleSet library](https://github.com/actions/scaleset)).


The runner VM image to be built and stored in Nexus registry (if not possible fallback to ghcr).


### Side-quests

- [ ] nexus-config-terraform repo



---

## Step 1a: Create the VM on Proxmox


