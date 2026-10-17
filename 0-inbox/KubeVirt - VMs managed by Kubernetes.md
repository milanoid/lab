with GitHub Action self-hosted runners


# Plan

To an existing runner group (pod based via [ARC](https://github.com/actions/actions-runner-controller)) add another group of self-hosted runners on an ephemeral VMs.

Create a new K3s node `kubevirt01` on a large Proxmox VM (4 vCPU, 12 GB). On this node install [KubeVirt](https://kubevirt.io/), custom Autoscaler (based on [ScaleSet library](https://github.com/actions/scaleset)).


The runner VM image to be built and stored in Nexus registry (if not possible fallback to ghcr).


### Side-quests

- [ ] nexus-config-terraform repo



---

## Step 1a: Create the VM on Proxmox


**What**: one Ubuntu 24.04 VM that will become a k3s worker. KubeVirt will later start the runner VMs inside it.

**Why** a VM inside Proxmox: KubeVirt runs VMs as pods on a Kubernetes node, and that node needs /dev/kvm. Proxmox has nested virtualisation turned on (I checked: kvm_intel nested=Y). If we pass the CPU's virtualisation feature through to this VM, it can run its own VMs. The Proxmox host itself stays a plain hypervisor.


```bash
# ssh proxmox
# 1. Download the Ubuntu cloud image. It is already in qcow2 format; naming it .qcow2 makes that explicit.
wget -O /var/lib/vz/import/noble-server-cloudimg-amd64.qcow2 \
  https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
  
  
# 2. Create the empty VM shell
qm create 300 --name kubevirt01 --ostype l26 --machine q35 \
  --cpu host --cores 4 --memory 12288 --balloon 0 \
  --net0 virtio,bridge=vmbr0 --scsihw virtio-scsi-single \
  --agent enabled=1 --onboot 1 --serial0 socket --vga serial0

# - --cpu host is the key flag. It passes Intel VT-x (vmx) through so the guest gets /dev/kvm. The default x86-64-v2-AES CPU type hides it.

# - --balloon 0 gives the VM a fixed 12 GB. If Proxmox reclaimed memory from it, the nested runner VMs would be the ones to suffer, and badly.

# - --serial0 socket --vga serial0 lets qm terminal 300 work if networking breaks.


# 3. Attach the disk (imported from the cloud image) and grow it to 100 GB
qm set 300 --scsi0 local-lvm:0,import-from=/var/lib/vz/import/noble-server-cloudimg-amd64.qcow2,discard=on,ssd=1,iothread=1
# scsi0: successfully created disk 'local-lvm:vm-300-disk-0,discard=on,iothread=1,size=3584M,ssd=1'

qm resize 300 scsi0 100G

# Size of logical volume pve/vm-300-disk-0 changed from 3.50 GiB (896 extents) to 100.00 GiB (25600 extents). Logical volume pve/vm-300-disk-0 successfully resized.

qm set 300 --boot order=scsi0

# update VM 300: -boot order=scsi0


# 4. Cloud-init: user, SSH key, static IP

# copy my Mac's pub key to proxmox first
scp ~/.ssh/id_rsa.pub root@192.168.1.200:/root/kubevirt01.pub

qm set 300 --ide2 local-lvm:cloudinit
qm set 300 --ciuser milan --sshkeys /root/kubevirt01.pub \
  --ipconfig0 ip=192.168.1.234/24,gw=192.168.1.1 \
  --nameserver "192.168.1.232 8.8.4.4"
qm start 300
```


Access the VM `kubevirt01` 

```bash
# IP: 192.168.234, assigned via mac address in router
ssh kubevirt01
```


cloud-init

```bash
# cloud-config
sudo cat /var/lib/cloud/instance/user-data.txt

# logs
sudo cat /var/log/cloud-init*.log

# cloud-init managed via systemd serviec
sudo systemctl status cloud-init.service
```



## Step 1b: Prepare the OS (before it joins k3s)

```bash
# Fix 1: qemu-guest-agent
sudo apt-get update && sudo apt-get install -y qemu-guest-agent
sudo systemctl start qemu-guest-agent

# Fix 2: a unique iSCSI initiator name
sudo systemctl start iscsid
sudo grep -v '^#' /etc/iscsi/initiatorname.iscsi   # should now show InitiatorName=iqn.2004-10.com.ubuntu:01:<random>

# InitiatorName=iqn.2004-10.com.ubuntu:01:5bec92359e9a

# Why: CLAUDE.md requires every node to have a unique /etc/iscsi/initiatorname.iscsi. The synology-csi node plugin (a DaemonSet) will start on this node, and if two nodes shared an IQN, the NAS would treat them as one initiator. The cloud image ships the placeholder GenerateName=yes, and the first iscsid start replaces it with a random IQN. Runner VMs don't use iSCSI, but this keeps the node consistent with the rest of the cluster.

# Fix 3: static /etc/resolv.conf (the pi-hole trap)
sudo rm /etc/resolv.conf
printf '# Static on purpose: bypasses the systemd-resolved stub (127.0.0.53), which\n# pi-hole klipper-lb iptables rules hijack; see homelab-cluster memory/pihole trap.\nnameserver 1.1.1.1\nnameserver 1.0.0.1\nsearch milanoid.net\n' | sudo tee /etc/resolv.conf

getent hosts github.com


# reboot
ls /var/run/reboot-required && sudo reboot
```


## Step 1c: install k3s agent v1.37.1+k3s1, join the cluster



```bash
# 1. On hpmini01:
ssh -t hpmini01 'sudo k3s token create --ttl 1h --description kubevirt01-join'

# 2. Write the k3s config (on kubevirt01)
sudo mkdir -p /etc/rancher/k3s
sudo nano /etc/rancher/k3s/config.yaml     # paste the content below, insert the token

---
server: https://192.168.1.231:6443
token: <agent-token>
node-label:
  - homelab.milanoid.net/kubevirt-runners=true
node-taint:
  - homelab.milanoid.net/kubevirt-runners=true:NoSchedule
---

sudo chmod 600 /etc/rancher/k3s/config.yaml



# 3. Install the agent, same version as the cluster
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.37.1+k3s1 INSTALL_K3S_EXEC=agent sh -
systemctl status k3s-agent --no-pager | head -5


# 4. Add the worker role label (from your Mac, admin context)
kubectl label node kubevirt01 node-role.kubernetes.io/worker=worker
```


fix for system-upgrade-controller - so the new node gets updated



---


## Step 2: install kubevirt operator

vendored CRD: copy the code from upstream to my repo

- [x] https://github.com/milanoid-labs/homelab-cluster/pull/689
- [x] https://github.com/milanoid-labs/homelab-cluster/pull/690


smoke test: `smoke-cirros.yaml`
```yaml
# Throwaway KubeVirt smoke test. Not for git.
#   kubectl apply -f smoke-cirros.yaml   ...   kubectl delete -f smoke-cirros.yaml
apiVersion: kubevirt.io/v1
# VirtualMachineInstance = one running VM, like a bare Pod: gone when it stops.
# (A VirtualMachine is the Deployment-like wrapper that restarts it; runners won't need that.)
kind: VirtualMachineInstance
metadata:
  name: smoke-cirros
  namespace: default
spec:
  # The CR's workloads.nodePlacement only placed virt-handler. Each VMI needs its own
  # selector + toleration to reach the tainted node. The scaler will set these too.
  nodeSelector:
    homelab.milanoid.net/kubevirt-runners: "true"
  tolerations:
    - key: homelab.milanoid.net/kubevirt-runners
      operator: Exists
      effect: NoSchedule
  terminationGracePeriodSeconds: 0
  domain:                       # "domain" = libvirt's word for the virtual machine's hardware
    cpu:
      cores: 1
    memory:
      guest: 128Mi              # RAM the guest sees; the pod requests a bit more for QEMU itself
    devices:
      disks:
        - name: rootdisk
          disk:
            bus: virtio         # paravirtual disk: fast, guest knows it's virtual
        - name: cloudinit
          disk:
            bus: virtio
      interfaces:
        - name: default
          masquerade: {}        # VM gets NAT'd behind the pod IP (simplest, works with flannel)
  networks:
    - name: default
      pod: {}
  volumes:
    - name: rootdisk
      containerDisk:            # the disk image shipped inside a container image
        image: quay.io/kubevirt/cirros-container-disk-demo:v1.9.1@sha256:ebdb8d8b9b480f6ee7664ed3fdde8428767664f507d98f94090edeff04d7ebf2
    - name: cloudinit
      cloudInitNoCloud:         # same NoCloud mechanism Proxmox used for kubevirt01 in step 1a
        # Inline only because it's harmless. Runner VMs will use secretRef (JIT token).
        userData: |
          #!/bin/sh
          echo "kubevirt smoke test: cloud-init ran" > /dev/console
```


```bash
kubectl apply -f smoke-cirros.yaml
```

- starts a VM in VM :)
- managed by K3s Kubevirt Operator

#### virtctl

https://kubevirt.io/user-guide/user_workloads/virtctl_client_tool/

```bash
brew install virtctl

# or
kubectl krew install virt
```


to see console logs of the throwaway vm:

```bash
# didn't work
virtctl console smoke-cirros
```


---



## Step 3: Nexus (ghcr as fallback)

- [x] [nexus-config-terraform](https://github.com/milanoid-labs/nexus-config-terraform) repo https://github.com/milanoid-labs/milanoid-labs-terraform/pull/47