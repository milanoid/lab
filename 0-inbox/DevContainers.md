Mischa demonstrated the usage with MS VisualCode. With DevContainers plugin one can setup and manage the docker based development  environment.

https://containers.dev/

https://devpod.sh/

Benefits
- reproducible and shareable among machines and team members
- the `.devcontainer.json` [spec](https://containers.dev/implementors/spec/) file in the code repository, always in sync

System of Features: https://containers.dev/features (like plugins?)

## 03 - Using the Setup Script

issue with missing `docker-credentials-pass`:

```bash
failed to store tokens: error storing credentials - err: exec: "docker-credential-pass": executable file not found in $PATH, out: ``
error storing credentials - err: exec: "docker-credential-pass": executable file not found in $PATH, out: `
```
Install it by: `yay -S docker-credential-pass`


Starting the container:

```bash
# from a project with .devcontainers directory having .devcontainers.json file
devpod --ide=none up .

12:53:57 info Workspace devcontainers already exists
12:53:57 info Creating devcontainer...
12:53:59 info Inspecting image mcr.microsoft.com/devcontainers/base:ubuntu
12:53:59 info Image mcr.microsoft.com/devcontainers/base:ubuntu not found
12:53:59 info Pulling image mcr.microsoft.com/devcontainers/base:ubuntu
12:54:24 info 6425665f141e4a36ed94633c1df819d4815491ab092226e3e6541f21a6be9420
12:54:25 info Setup container...
12:54:25 info Chown workspace...
12:54:25 info Chown projects...
```

Stopping:

```bash
devpod down .
12:57:06 info Stopping container...
12:57:06 info Successfully stopped container...
```

List:

```bash
milan@jantar:~/repos/lab/0-inbox/devcontainers (main)$ devpod ls

        NAME      |                      SOURCE                       | MACHINE | PROVIDER | IDE  |  LAST USED  |     AGE
  ----------------+---------------------------------------------------+---------+----------+------+-------------+--------------
    devcontainers | local:/home/milan/repos/lab/0-inbox/devcontainers |         | docker   | none | 2m0s        | 12m18s
    pi            | local:/home/milan/repos/pi                        |         | docker   | none | 2259h41m13s | 2259h48m45s
```

Recreate a devcontainer:

`devpod --ide=none up . --recreate`

Start devpod with dotfiles:

```
devpod up https://github.com/example/repo --dotfiles https://github.com/my-user/my-dotfiles-repo
```

Start devpod with dotfiles from a specific branch

```bash
evpod --ide=none up . --dotfiles https://github.com/milanoid/dotfiles.git@devcontainers --recreate
```