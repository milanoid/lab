# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

This is a **personal Obsidian vault** and knowledge base organized with the PARA method, focused on DevOps, Kubernetes, and containerization learning. It is not a traditional software project — there is no build system, test suite, or deployable application at the top level.

Git commits are automated by the Obsidian Git plugin with the format: `vault backup: YYYY-MM-DD HH:MM:SS`.

## Directory Structure (PARA)

- `0-inbox/` — Unsorted new notes and exploratory work
- `1-projects/` — Active learning projects (currently: Kubecraft DevOps course)
- `2-areas/` — Ongoing topics of interest (Linux, etc.)
- `3-resources/` — Reference materials and certification prep
- `4-archives/` — Completed modules (Arch Linux setup, CKAD, HomeLab K8s, etc.)

## Runnable Code

### Joke Dashboard (Docker Compose capstone)
Located at `1-projects/Kubecraft - DevOps OS - Part1/Containers/06_project/joke-dashboard/`:
```bash
docker compose up
```
Multi-container app: `init` (volume setup) → `updater` (fetches dad jokes every 30s) → `web` (nginx on port 8080). The `updater` service uses a multi-stage Dockerfile (Ubuntu builder → Alpine runtime) and runs as non-root (UID 101).

### DevContainer
Located at `0-inbox/devcontainers/`:
```bash
devpod --ide=none up .
devpod down .
```
Based on Microsoft Python 3.12 (Bullseye) with Azure CLI, GitHub CLI, 1Password, GNU Stow, and cowsay features.

## Obsidian Vault Notes

- Vim mode is enabled in the vault
- New notes default to `0-inbox/`
- Backlinks and graph view are active core plugins
- `.obsidian/` directory contains all vault configuration — avoid modifying it manually
