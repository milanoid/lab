## DevContainers Setup

This dotfiles repo is part of a **stateless developer environment** setup explored in the [KubeCraft DevOps OS - Part 1](https://www.skool.com/kubecraft/) course.

The idea: instead of configuring a machine, you describe your environment as code. Spin up a disposable container for each project, bring your dotfiles in automatically, and be productive in seconds — on any machine with a container runtime.

### Why this approach?

- **Isolation**: each project gets its own container with only the tools it needs. When a project ends, delete the container — no leftover cruft on the host.
- **Reproducibility**: the same environment works on your laptop, a cloud VM, or GitHub Codespaces.
- **Portability**: all you need on the host is a container runtime (Docker, Podman, Rancher Desktop).

### The toolchain

| Tool | Role |
|------|------|
| [DevPod](https://devpod.sh) | Manages Dev Container workspaces from the CLI, provider-agnostic |
| [chezmoi](https://chezmoi.io) | Dotfile manager — applies this repo's files into any environment |
| [mise](https://mise.jdx.dev) | Per-project (and global) tool version manager; replaces nvm/pyenv/etc. |

DevPod starts a container from a `.devcontainer/devcontainer.json` spec, clones this dotfiles repo into it, and runs the `setup` script. chezmoi then applies the tracked dotfiles; mise installs the declared tool versions.

> Full notes from the course: [github.com/milanoid/lab](https://github.com/milanoid/lab)
