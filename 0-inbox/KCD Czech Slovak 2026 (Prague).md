- program https://kcd-czech-slovak-2026.sessionize.com/schedule/day/20260521
- photos https://drive.google.com/drive/folders/1LlerjuZM2seNunaG6vmRd_-i-PSyYppX



# Day 1

Sessions I have attended

1. [Keynote: Rethinking Observability as a Platform Product](https://kcd-czech-slovak-2026.sessionize.com/session/1204850)
2. [We Built an AI Incident Responder. Here's What We Got Wrong.](https://kcd-czech-slovak-2026.sessionize.com/session/1196794)
3. [Hundreds of Environments, Imaginary Downtime, Rational Bill: Database Resets at Scale with Argo](https://kcd-czech-slovak-2026.sessionize.com/session/1192018)
4. [Treating Kubernetes as a Linux Distro: APT-Style Packaging with FluxCD](https://kcd-czech-slovak-2026.sessionize.com/session/1169068)
5. [The OS Layer Your Platform Ignores](https://kcd-czech-slovak-2026.sessionize.com/session/1197215)
6. [Kubernetes-in-Kubernetes: Pod kapotou budování a provozu Hosted Control Planes](https://kcd-czech-slovak-2026.sessionize.com/session/1195818)
7. [Craft you home AI lab with Ollama + Open WebUI](https://kcd-czech-slovak-2026.sessionize.com/session/1193106)



## 1. Keynote: Rethinking Observability as a Platform Product

- https://opentelemetry.io/
- https://www.dash0.com/lp/opentelemetry-for-dummies 
- [ ] read _openTelemetry-for-Dummies-Dash0-Special-Edition_
- [ ] open telemetry demo application https://github.com/open-telemetry/opentelemetry-demo
- [OpenTelemetry Certified Associate (OTCA)](https://training.linuxfoundation.org/certification/opentelemetry-certified-associate-otca/)

smb://NAS2._smb._tcp.local/home/eBooks/OpenTelemetry For Dummies®, Dash0 Special Edition - openTelemetry-for-Dummies-Dash0-Special-Edition.pdf


## 2. We Built an AI Incident Responder. Here's What We Got Wrong.

- https://github.com/depeche-io/kcd-2026/tree/main/sre-agent/slides

### Argo Workflows

- https://argoproj.github.io/workflows/


## 4. The OS Layer Your Platform Ignores

- immutable OS
- Flatcar https://www.flatcar.org/ (Talos https://www.talos.dev/)
- [ ] read [Kubernetes “Shift Down” Security Paper](https://github.com/kubernetes/sig-security/blob/main/sig-security-docs/papers/shift-down/shift-down-security.md)
- [ ] install Flatcar on Proxmox


## 7. Craft you home AI lab with Ollama + Open WebUI

- https://github.com/petrhanakcz/ollama-lab
- https://github.com/petrhanakcz/ollama-lab/blob/main/materials/Craft_home_LAB_with_Ollama.md
- https://www.youtube.com/@kcdczechslovak5840/videos

```bash
# install
brew install ollama

To start ollama now and restart at login:
  brew services start ollama
Or, if you dont want/need a background service you can just run:
  OLLAMA_FLASH_ATTENTION="1" OLLAMA_KV_CACHE_TYPE="q8_0" /opt/homebrew/opt/ollama/bin/ollama serve
  
# run
> OLLAMA_FLASH_ATTENTION="1" OLLAMA_KV_CACHE_TYPE="q8_0" /opt/homebrew/opt/ollama/bin/ollama serve
Couldnt find '/Users/milan/.ollama/id_ed25519'. Generating new private key.
Your new public key is:

ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIqqDiQh34qSjT6SECDzcoIzXA/qYs6rQMNsNP1i4NfP

# version
> ollama --version
ollama version is 0.24.0

# list models
ollama list

# install model, available models https://ollama.com/library
ollama run llama3.2
pulling manifest
pulling dde5aa3fc5ff: 100% ▕█████████████████████████████████████████████████████████████████████████████████████████████████▏ 2.0 GB
pulling 966de95ca8a6: 100% ▕█████████████████████████████████████████████████████████████████████████████████████████████████▏ 1.4 KB
pulling fcc5a6bec9da: 100% ▕█████████████████████████████████████████████████████████████████████████████████████████████████▏ 7.7 KB
pulling a70ff7e570d9: 100% ▕█████████████████████████████████████████████████████████████████████████████████████████████████▏ 6.0 KB
pulling 56bb8bd477a5: 100% ▕█████████████████████████████████████████████████████████████████████████████████████████████████▏   96 B
pulling 34bb5ab01051: 100% ▕█████████████████████████████████████████████████████████████████████████████████████████████████▏  561 B
verifying sha256 digest
writing manifest
success
>>> Send a message (/? for help)
>>> 
>>> 


# run with claude code
ollama launch claude --model llama3.2


# ps
> ollama ps
NAME               ID              SIZE      PROCESSOR    CONTEXT    UNTIL
llama3.2:latest    a80c4f17acd5    2.5 GB    100% GPU     4096       4 minutes from now
```



### llmfit - One command to find what runs on your hardware

- https://www.llmfit.org/

```bash
brew install llmfit
```



### runpod AI infrastructure for rent

https://www.runpod.io/




---

# Day 2

## 1. GitOps using ArgoCD and Kargo (workshop)

- https://kcd-czech-slovak-2026.sessionize.com/session/1228884
- https://github.com/ondrejsika/kcd2026-kargo-workshop https://github.com/milanoid/kcd2026-kargo-workshop
- intro to Kargo and ArgoCD
- create promotional pipeline (dev, stage, prod)
- after updating image easily promote through the envs
- https://github.com/ondrejsika/kcd2026-kargo-example https://github.com/milanoid/kcd2026-kargo-example
- [ ] deploy the homeLab


### Kargo

- https://kargo.io/
- Seamlessly orchestrate stage-to-stage deployments, without custom scripts or CI pipelines
- [ArgoCD Image Updater ](https://argocd-image-updater.readthedocs.io/en/stable/)vs Kargo?
- Kargo can be used with FluxCD too


```bash
# kargo cli
brew install kargo

> kargo version
Client Version: 1.10.4
```


https://argocd.kcd.sikademo.com/ (admin, admin)
https://kargo.kcd.sikademo.com/ (admin)

add to GH webhook `https://argocd.kcd.sikademo.com/api/webhook`


- https://ttl.sh/ 
	- The ephemeral container registry that just works. (No auth)
	- Available worldwide for 1 hour. Then it vanishes. ✨

- [ ] build docker image via remote

Promotional pipeline (promotionTemplate) - it could have been a GHA too (but this works everywhere)

? what are the conditions on when to promote




## 2. State of Kubernetes on European Sovereign Clouds: Integrations, Control, and Portability


https://www.linkedin.com/in/kimsondrup/

- data residency, procurement, strategic autonomy
- [Hetzner](https://www.hetzner.com/), [UpCloud](https://upcloud.com/), [OVHcloud](https://www.ovhcloud.com/), [T Cloud Public](https://www.t-cloud-public.com/), [Scaleway](https://www.scaleway.com/en/)

- CAPI - Cluster API
- [OIDC](https://openid.net/developers/how-connect-works/) - OpenID Connect
- OIDC Federation

- https://openbao.org/ - OpenBao is an open source, community-driven secrets manager and fork of Vault managed by the Linux Foundation's OpenSSF.


FinOps - OpenCost coverage - https://opencost.io/



## 3. The Complete Guide to Secret Hygiene for Java and Cloud-Native Engineers

https://www.linkedin.com/in/martin-ladeck%C3%BD-9366ba5/

### Maven `settings.xml`

- org artifactory (Nexus) - need password
- can leak to a collegue or in logs in in pipeline

WIth Nexus access I can upload anything I want, let you deploy it to production.

```bash
# how to get the creds

# in oplder maven version only
mvn clean deploy -X

# everywhere - reveal creds
mvn help:effective-settings -DshowPasswords=true
```

Maven fix

-

```bash
mvn --encrypt-master-password KCD_Secr3t_2026
mvn --encrypt-password KCD_Secr3t_2026
```



### Git

- if pushed to remote, only way to mitigate is to change the password


### Docker Images

Docker layers never forget!

- dive tool - https://github.com/wagoodman/dive
- in an old layer I can find the removed file/secret
- any file can be downloaded as a .tar file from a layer


Fixes

1. 2-step build
2. `--mount=type=secret`

### CD/CD

- logs leak secrets

Demo - GHA

https://github.com/martin-ladecky/kcd-cz-sk-2026

https://github.com/martin-ladecky/kcd-cz-sk-2026/actions/runs/26116550782/job/77258683271

mitigations

- no-echo policy
- OIDC, do not use long lived secrets
- ENV vars protection rules
- log scanning - integrate Gitleaks

### Best practices


## 4. System Design in Your Hands: The Art of Putting Things Together

https://www.linkedin.com/in/emrahsifoglu/

### qemu

- https://www.qemu.org/
- A generic and open source machine emulator and virtualizer

### workshop

- building a cluster, each participant become a node (worker, control plane)


```bash
brew install lynx

# curl -s https://10.0.0.42:8080
curl -s http://10.0.0.42:8080/ | lynx --stdin # show HOWTO


# ### Network info
ipconfig getifaddr en0        # IP address (Wi-Fi)
ifconfig | grep "inet " # all interfaces
networksetup -listallhardwareports # adapter names


networksetup -listallhardwareports  # adapter names

Hardware Port: Wi-Fi
Device: en0
Ethernet Address: ac:07:75:04:50:f7


# from VirtualBox, native linux and qemu I choosed
brew install qemu


# downloads iso (custom builds)
#curl -O http://10.0.0.32:8080/files/isos/<arm64-iso-name>.iso
curl -O http://10.0.0.42:8080/files/isos/custom-debian-arm64-20260522091752.iso


# qemu
#curl -O http://10.0.0.32:8080/files/scripts/qemu-run.sh 
curl -O http://10.0.0.42:8080/files/scripts/qemu-run.sh 
chmod +x qemu-run.sh
cp /opt/homebrew/share/qemu/edk2-arm-vars.fd ./ovmf_vars.fd 

# create disk
qemu-img create -f qcow2 node.qcow2 20G # done

# **Install from ISO**
./qemu-run.sh install custom-debian-arm64-20260522091752.iso --adapter <ADAPTER>              # output in terminal
./qemu-run.sh install custom-debian-arm64-20260522091752.iso --adapter <ADAPTER> --window     # separate display window
./qemu-run.sh install custom-debian-arm64-20260522091752.iso --adapter <ADAPTER> --detach     # background, safe to close terminal


###
./qemu-run.sh install custom-debian-arm64-20260522091752.iso --adapter en0 --detach
Starting VM...
  Command: install
  Disk:    node.qcow2
  OS:      Darwin arm64
  CPUs:    2
  Mode:    --detach

Running detached. To reattach: screen -r qemu
To shut down gracefully: SSH into VM and run: sudo poweroff


# in screen follow the install wizard
...
root/root

 █╗  █╗ ██████╗██████╗
 █║ █╔╝█╔════╝█╔══██╗
 ████╔╝ █║     █║  █║
 █╔═██╗ █║     █║  █║
 █║  ██╗╚██████╗██████╔╝
 ╚═╝  ╚═╝ ╚═════╝╚═════╝

 Czech & Slovak · Prague 2026
 GROWING CLOUD NATIVE TOGETHER
 -----------------------------------------
 May 21-22, 2026 · FIT CTU Prague
 -----------------------------------------

=== THIS IS MY IP ===
10.0.0.40
===================
root@k8s-cluster:~# lscpu
Architecture:                aarch64
  CPU op-mode(s):            64-bit
  Byte Order:                Little Endian
CPU(s):                      2
  On-line CPU(s) list:       0,1
Vendor ID:                   Apple



## inside the vm
curl -H "X-OS: $(uname -a)" http://10.0.0.42:9999

### conect to the cluster
curl -o ~/.kube/cp-primary http://10.0.0.42:8080/files/cp-primary
export KUBECONFIG=~/.kube/cp-primary 
kubectl get nodes 
```
