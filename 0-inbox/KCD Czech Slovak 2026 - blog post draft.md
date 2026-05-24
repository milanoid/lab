# KCD Czech & Slovak 2026 — My Notes from Two Days in Prague

KCD Czech & Slovak is a community-run Kubernetes and cloud-native conference, this year held on May 21–22 at FIT CTU in Prague. Two packed days, a mix of talks and hands-on workshops, and a crowd that clearly enjoys getting into the weeds. Here's what I took away from the sessions I attended.

---

## Day 1

### Keynote: Rethinking Observability as a Platform Product — Kasper Borg Nissen

The opening keynote reframed a question I've heard a lot: why do observability setups so often disappoint despite good tooling? Kasper's answer was that most teams treat observability as a tooling decision rather than a platform product. You pick a vendor, deploy agents, and expect insight to follow — but without a shared foundation, a coherent user experience, and sane defaults, the data just accumulates without becoming useful.

The pitch for OpenTelemetry was straightforward: a vendor-neutral layer that decouples instrumentation from backends, enables signal correlation by default, and reduces the cognitive load of switching or mixing vendors. It also sets the stage for AI-assisted debugging — something that only works if your telemetry is structured and consistent in the first place.

I came away with a reading assignment: the [OpenTelemetry for Dummies, Dash0 Special Edition](https://www.dash0.com/lp/opentelemetry-for-dummies), and a cert to look into: the [OpenTelemetry Certified Associate (OTCA)](https://training.linuxfoundation.org/certification/opentelemetry-certified-associate-otca/).

### We Built an AI Incident Responder. Here's What We Got Wrong. — David Pech

An honest retrospective on building an AI SRE agent — one of the more grounded AI talks I've sat through. David divided the work into three roughly equal thirds. The first third, writing the Python, was the easy part. The second was prompt engineering: getting from ~80% useful answers to 95% took more iteration than expected, but it's achievable. The third — and the one nobody talks about — was security. Running even a read-only agent with MCP access required twelve layers of defense-in-depth, and that's before the agent can touch anything writable.

The agent is now useful for real incident questions: is this alert recurring, who responded last time, what did they do, is this CVE affecting us. The talk was a useful reality check on what "AI for ops" actually takes to get right.

### Hundreds of Environments, Database Resets at Scale with Argo — Martin Beránek

ShipMonk operates hundreds of full production-clone environments, each with its own database, message broker, cache, and search index, reset daily. When the business asked for 300,000 orders in a demo environment and the one-hour reset became two, they had to rethink the whole approach. The talk covered how they solved this at scale using Argo Workflows — a good reminder that boring infrastructure problems at scale become interesting engineering problems fast.

### Treating Kubernetes as a Linux Distro: APT-Style Packaging with FluxCD — Andrei Kvapil

Andrei's Cozystack project introduces `Package` and `PackageSource` CRDs — analogous to dpkg and `sources.list` — on top of FluxCD and OCI artifacts, giving Kubernetes the kind of pluggable, community-driven package ecosystem that Linux has had for decades. The chicken-and-egg problem of bootstrapping CNI via the package system was an interesting detail.

### The OS Layer Your Platform Ignores — Brian Exelbierd

The premise: you have a hundred Kubernetes nodes, but can you prove their filesystems match what you shipped? Kubernetes solves orchestration, not OS integrity. Debug sessions leave files. Daemonsets write to the host. Two nodes report identical versions while their filesystems diverge silently.

Brian made the case for immutable operating systems — [Flatcar](https://www.flatcar.org/) and [Talos](https://www.talos.dev/) — where the OS itself becomes a read-only artifact. The [Kubernetes Shift Down Security Paper](https://github.com/kubernetes/sig-security/blob/main/sig-security-docs/papers/shift-down/shift-down-security.md) was recommended reading. I left thinking seriously about trying Flatcar on my Proxmox homelab.

### Kubernetes-in-Kubernetes: Hosted Control Planes — Ashley Reese

A deep-dive (in Czech) on building a custom hosted Kubernetes platform capable of running and scaling 200+ clusters with minimal overhead and zero downtime. The core theme: when upstream solutions don't fit your requirements, you can build your own — and here's what that actually looks like in production.

### Craft Your Home AI Lab with Ollama + Open WebUI — Petr Hanák

An afternoon workshop that had attendees up and running with local LLMs by the end of the session. [Ollama](https://ollama.com/) handles running models like Llama 3.2 locally; Open WebUI wraps it in a ChatGPT-like interface. The interesting additions were [llmfit](https://www.llmfit.org/) — one command to find which models actually fit your hardware — and [RunPod](https://www.runpod.io/) for when your local GPU isn't enough and you need to rent infrastructure. Flash attention and KV cache quantization flags (`OLLAMA_FLASH_ATTENTION=1`, `OLLAMA_KV_CACHE_TYPE=q8_0`) made a visible difference on Apple Silicon.

---

## Day 2

### GitOps using ArgoCD and Kargo — Ondrej Sika

A hands-on workshop building a complete GitOps delivery pipeline from scratch: ArgoCD for cluster sync, [Kargo](https://kargo.io/) for multi-stage environment promotion (dev → stage → prod). The distinction matters — ArgoCD keeps a cluster in sync with git, but it doesn't decide *when* to promote a change to the next environment. That's Kargo's job, and it turns out to be a much cleaner solution than custom CI pipeline scripts or ArgoCD Image Updater hacks.

[ttl.sh](https://ttl.sh/) was a fun discovery: an ephemeral, no-auth container registry where images vanish after an hour. Useful for workshop demos and throwaway builds.

### State of Kubernetes on European Sovereign Clouds — Kim Sondrup

A thorough comparison of five EU cloud providers — Hetzner, UpCloud, OVHcloud, T Cloud Public, Scaleway — across the dimensions that actually matter when you're evaluating sovereign infrastructure. The headline finding: none of them support OIDC federation on the "accepts tokens" side, which means workload identity is a non-starter. You're stuck generating credentials out-of-band, storing them in Kubernetes Secrets or CI variables, and automating rotation — the operational drag that OIDC federation was supposed to eliminate.

The audit log picture was equally mixed: Hetzner has no K8s audit logs natively, UpCloud's aren't enabled by default, and only Scaleway offers a full native observability stack (Mimir, Loki, Tempo, Grafana). OpenCost works for cost allocation on OVHcloud and T Cloud Public, but actual invoice reconciliation isn't supported anywhere.

Kim's closing recommendations stuck with me: think in capabilities not products, plan your machine identity story before you commit to a provider, and treat GitOps as your portability layer across all five.

### The Complete Guide to Secret Hygiene for Java and Cloud-Native Engineers — Martin Ladecký

Probably the most forensically satisfying talk of the conference. Martin structured it around an "evidence chain" — every stage where secrets can and do escape: the developer's desk (`settings.xml`), source control (Git history), container images (Docker layers), pipelines (log output), and runtime (Vault/secret stores).

The Maven reveal was a crowd moment: `mvn help:effective-settings -DshowPasswords=true` prints your Nexus credentials in plain text, even if you think you've hidden them. The fix — `mvn --encrypt-master-password` and `mvn --encrypt-password` — takes two commands.

The Git history section covered "the illusion of git rm": delete a file, assume it's gone, but the secret remains in every prior commit. Anyone with repo access can retrieve it with `git log --all -p -G "password"`. Real cleanup means `git filter-branch` or BFG Repo Cleaner, followed by rotating the credential — in that order.

Docker layers were the most striking: deleted files in later layers don't remove the data from earlier ones, and security audits find residual secrets in roughly 30% of container images. The fix is multi-stage builds — keep secrets in the builder stage, copy only the final artifact to a clean runtime image. The `--mount=type=secret` approach is cleaner still.

### System Design in Your Hands — Emrah Sifoğlu

The most unconventional session of the two days. Each participant installed a Linux VM using QEMU and joined an actual Kubernetes cluster — I was `cp-02`, one of the control plane nodes. By the end of the workshop, we had a real multi-node cluster assembled from laptops in the room, with a shared kubeconfig and `kubectl get nodes` showing all of us listed. Theory about stateless vs. stateful workloads, scalability, and resilience lands differently when you *are* a node.

### Breaking Free of a Single Datacenter: Geo-Distributed AI Platforms with k0smos — Jussi Nummelin & Soeren Becker

Commissioned by Germany's [SPRIN-D](https://www.sprind.org/en) agency, this project tackles a real problem: AI compute is scattered across clouds, on-prem, and edge — siloed and underutilized. The k0smos stack unifies it: [k0smotron](https://k0smotron.io/) manages hosted control planes in a management cluster; [k0s](https://k0sproject.io/) provides a lightweight runtime that works on heterogeneous hardware; [k0rdent](https://k0rdent.io/) handles cluster provisioning and GPU workload deployment via ClusterTemplates and ServiceTemplates — all declarative, all Kubernetes-native.

The ambition is to turn distributed GPU resources into a cohesive, ephemeral fabric. [DiLoCo](https://deepmind.google/blog/decoupled-diloco/) — decoupled distributed training across sites — is the longer-term target this architecture is designed to support.

---

## Takeaways

- **GitOps tooling is maturing.** Kargo filling the promotion gap between ArgoCD and production is a meaningful step forward from scripted pipelines.
- **Secrets hygiene is still underestimated.** The evidence chain — desk to source to image to pipeline to runtime — has a leak at every stage, and most teams have plugged at most one or two of them.
- **Local AI is accessible.** Running capable LLMs on a laptop is no longer a niche hobby. Ollama and llmfit make it straightforward.
- **European cloud sovereignty has real gaps.** No OIDC federation, patchy audit logs, and inconsistent observability mean the "sovereign" label needs scrutiny before you commit.
- **The OS layer remains an afterthought.** Immutable OS (Flatcar, Talos) solves a real problem that Kubernetes itself can't — and most platform teams aren't thinking about it.
