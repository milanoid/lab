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


### Kargo

- https://kargo.io/
- Seamlessly orchestrate stage-to-stage deployments, without custom scripts or CI pipelines


