
Instead of using VS Code we can interact with devcontainers using


1. DevPod https://devpod.sh
2. Dev Container CLI https://github.com/devcontainers/cli 



# DevPod

```bash
# install
curl -L -o devpod "https://github.com/loft-sh/devpod/releases/latest/download/devpod-darwin-arm64" && sudo install -c -m 0755 devpod /usr/local/bin && rm -f devpod
```

## Providers

https://devpod.sh/docs/managing-providers/what-are-providers

- docker (default)
- kubernetes 
- ssh
- aws - e.g. can create a VM to test something
- gcloud
- azure
- digitalocean

## Personalizing a Workspace

https://devpod.sh/docs/developing-in-workspaces/dotfiles-in-a-workspace

Using a dotfiles repo (remote or local)

I have a dotfile repo https://github.com/milanoid/dotfiles but it uses Stow. Probably can't be used.

- [x] todo create another dotfiles repo `dotfiles-demo` a temporary, than after course create a proper one

- https://github.com/milanoid/dotfiles-demo



# Running our first Devpod Workspace

- run the following commands in the directory `./module3_code`

```bash
# run - the `none` is important
devpod up . --ide none --dotfiles git@github.com:milanoid/dotfiles-demo
```

## issues


```bash
# no provider specified
> devpod up . --ide none --dotfiles git@github.com:milanoid/dotfiles-demo
08:28:35 error Try using the --debug flag to see a more verbose output
08:28:35 fatal prepare workspace client: no default provider found. Please make sure to run 'devpod provider use'
```

- I have GUI app - I used it to setup `docker` provider