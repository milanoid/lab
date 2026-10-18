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



## Step 3a: nexus-config


- [x] [nexus-config-terraform](https://github.com/milanoid-labs/nexus-config-terraform) repo https://github.com/milanoid-labs/milanoid-labs-terraform/pull/47
- [ ] side quest: make OIDC global for all tf repos: https://github.com/milanoid-labs/milanoid-labs-terraform/pull/48
- [ ] requires to apply OIDC (global) manually (can't be run in CI)

```bash
# in milanoid-labs-terraform/bootstrap/aws-oidc
tofuenv use 1.12.2
tofu plan
tofu apply
```



## 3b: Bootstrap the Nexus tofu user

setup nexus user `tofu` for the CI

```bash
read -rs -p "Nexus admin password: " NEXUS_ADMIN_PW; echo
TOFU_PW=$(openssl rand -base64 32 | tr -d '/+=' | cut -c1-32)

curl -sf -u "admin:${NEXUS_ADMIN_PW}" -X POST \
  http://192.168.1.204:8081/service/rest/v1/security/users \
  -H 'Content-Type: application/json' \
  -d "{\"userId\":\"tofu\",\"firstName\":\"OpenTofu\",\"lastName\":\"nexus-config-terraform\",
       \"emailAddress\":\"tofu@nexus.local\",\"password\":\"${TOFU_PW}\",
       \"status\":\"active\",\"roles\":[\"nx-admin\"]}" && echo "created"

# Local credentials file (same convention as ~/.config/milanoid-tailscale-terraform.env)
( chmod 600; cat > ~/.config/nexus-config-terraform.env <<EOF
export TF_VAR_nexus_username=tofu
export TF_VAR_nexus_password=${TOFU_PW}
export AWS_PROFILE=milanoid
EOF
)
unset NEXUS_ADMIN_PW TOFU_PW
```

- `read -rs` keeps the admin password out of your shell history and off the screen.
- The tofu password is random and never typed. It exists only in the env file, which umask 077 makes readable by you alone (mode 600).
- `TF_VAR_*` is the same convention as the tailscale repo. Tofu maps `TF_VAR_nexus_password` to `var.nexus_password` automatically.



```bash
source ~/.config/nexus-config-terraform.env
curl -s -o /dev/null -w '%{http_code}\n' -u "tofu:${TF_VAR_nexus_password}" \
  http://192.168.1.204:8081/service/rest/v1/security/users?userId=tofu    # expect 200
```




## 3c: nexus-config-terraform scaffolding


- [ ] PR https://github.com/milanoid-labs/nexus-config-terraform/pull/1

nexus provider [datadrivers/nexus](https://registry.terraform.io/providers/datadrivers/nexus/latest/docs)

```bash
# create repo secrets
source ~/.config/nexus-config-terraform.env
gh secret set TF_VAR_NEXUS_USERNAME -R milanoid-labs/nexus-config-terraform --body "$TF_VAR_nexus_username"
gh secret set TF_VAR_NEXUS_PASSWORD -R milanoid-labs/nexus-config-terraform --body "$TF_VAR_nexus_password"

# check
gh secret list -R milanoid-labs/nexus-config-terraform

```



## 3d: a push/pull test from my Mac


The test proves five things: login works through the Bearer/Basic path, ci-push can push, k8s-pull can pull, k8s-pull can't push, and a tag can't be overwritten.


- get password from tf state: `tofu output -raw ci_push_password`

```bash
source ~/.config/nexus-config-terraform.env
cd ~/repos/nexus-config-terraform && git switch main && git pull
tofuenv use 1.12.2 && tofu init -input=false >/dev/null

REG=192.168.1.204:8081
IMG=$REG/docker-hosted/smoke/busybox:test-1

# 1. ci-push: log in and push (password goes straight from state to stdin, never printed)
tofu output -raw ci_push_password | podman login --tls-verify=false -u ci-push --password-stdin $REG
podman pull docker.io/library/busybox:1.37.0
podman tag docker.io/library/busybox:1.37.0 $IMG
podman push --tls-verify=false $IMG                 # expect: success

# 2. ALLOW_ONCE: pushing the same tag again must be refused
podman tag docker.io/library/alpine:3.22 $IMG 2>/dev/null || { podman pull docker.io/library/alpine:3.22 && podman tag docker.io/library/alpine:3.22 $IMG; }
podman push --tls-verify=false $IMG                 # expect: error (repository does not allow updating assets)

# 3. k8s-pull: may pull, must NOT push
podman logout $REG
tofu output -raw k8s_pull_password | podman login --tls-verify=false -u k8s-pull --password-stdin $REG
podman rmi $IMG
podman pull --tls-verify=false $IMG                 # expect: success (the busybox one)
podman tag docker.io/library/busybox:1.37.0 $REG/docker-hosted/smoke/busybox:test-2
podman push --tls-verify=false $REG/docker-hosted/smoke/busybox:test-2   # expect: error (denied/403)

podman logout $REG
```


-  issue with podman login - Nexus Realms didn't have active _Docker Bearer Token Realm_
- [x] fix: https://github.com/milanoid-labs/nexus-config-terraform/pull/3



## 3e: Let containerd on kubevirt01 pull from Nexus

What: `/etc/rancher/k3s/registries.yaml` on `kubevirt01`. On every start, k3s turns this file into containerd's registry config.

Why it's needed:
- containerd defaults to HTTPS, and Nexus speaks HTTP. A mirror entry with an http:// endpoint tells it to use plain HTTP for this registry.
- When the scaler starts a runner VMI, it's containerd that pulls the containerDisk, not podman, not you. It needs the k8s-pull credentials.
- Only on kubevirt01: runner VMs only run there, so the other nodes don't need the credentials. Least privilege again.

Run from my Mac

```bash
cd ~/repos/nexus-config-terraform && source ~/.config/nexus-config-terraform.env
PW=$(tofu output -raw k8s_pull_password)

ssh kubevirt01 'sudo install -m 600 -o root -g root /dev/stdin /etc/rancher/k3s/registries.yaml' <<EOF
# containerd registry config for kubevirt01 (rendered by k3s at start). Not in git: holds the
# k8s-pull password (nexus-config-terraform: tofu output -raw k8s_pull_password).
mirrors:
  "192.168.1.204:8081":
    endpoint:
      - "http://192.168.1.204:8081"
configs:
  "192.168.1.204:8081":
    auth:
      username: k8s-pull
      password: "${PW}"
EOF
unset PW

ssh kubevirt01 'sudo systemctl restart k3s-agent && sleep 5 && systemctl is-active k3s-agent'
```

K3s agent after restart generates `hosts.toml` from the `/etc/rancher/k3s/registries.yaml` I have created in the previous step.


```bash
sudo cat /var/lib/rancher/k3s/agent/etc/containerd/certs.d/192.168.1.204:8081/hosts.toml
# File generated by k3s. DO NOT EDIT.
server = "https://192.168.1.204:8081/v2"
capabilities = ["pull", "resolve", "push"]

[host]

[host."http://192.168.1.204:8081/v2"]
  capabilities = ["pull", "resolve"]
```


- [ ] the same settings needed for other nodes, if I want to pull/push to docker registry on Nexus




The real test: you pull the image as containerd:

```bash
ssh kubevirt01 'sudo k3s crictl pull 192.168.1.204:8081/docker-hosted/smoke/busybox:test-1'
```




## step 4, the runner VM image


Unlike homelab-runner pod image, we need to build a VM image. 

Using [virt-customize](https://libguestfs.org/virt-customize.1.html) we start a helper VM, boot, install extra tools (gh tool ... etc) and save it as VM image with baked in tooling.


A new repo [kubevirt-scaleset](https://github.com/milanoid-labs/kubevirt-scaleset) + VM image build.

- [x] PR https://github.com/milanoid-labs/milanoid-labs-terraform/pull/49


give the new repo the Nexus push credentials. The workflow logs in as ci-push:


```bash
cd ~/repos/nexus-config-terraform && source ~/.config/nexus-config-terraform.env
tofu output -raw ci_push_password | gh secret set NEXUS_PUSH_PASSWORD -R milanoid-labs/kubevirt-scaleset
gh variable set NEXUS_PUSH_USERNAME -R milanoid-labs/kubevirt-scaleset --body ci-push
gh variable set NEXUS_REGISTRY      -R milanoid-labs/kubevirt-scaleset --body 192.168.1.204:8081
gh secret list -R milanoid-labs/kubevirt-scaleset   # check it really landed this time
```


- [ ] PR with the image build https://github.com/milanoid-labs/kubevirt-scaleset/pull/1
- using [crane](https://michaelsauter.github.io/crane/index.html)
- pre-baked image - a disk the throwaway VM boot from

- 1st build assigned to `hpmini01` - could take 40 - 120 minutes ...

