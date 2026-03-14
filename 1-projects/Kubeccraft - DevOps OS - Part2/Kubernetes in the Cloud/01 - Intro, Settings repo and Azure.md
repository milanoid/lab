Course starts with Kubernetes deployment on MS Azure first. Only later we do the same with AWS. However Mischa teach it the vendor agnostic way.

Not just watch! Hands on!

At the end we will act as company providing managed N8N (low code tool) service.


## Resources - Course repo

- `~/repos/mercury-workflows` (mercury - the company name)
- uses _devcontainers - [[00 - Intro]]



### course repo in Devpod

- fallback - also one can open IDEA too

```bash
# creates devpod and clones my dotfiles into it
~/repos/mercury-workflows (master)
> devpod up .
> 
```

- dotfiles in https://github.com/milanoid/dotfiles-demo


_Approach_

- use plain `vi` in the Devpod
- config `vi` along the way, only if needed



#### issues in devpod

- [ ] port forward `3008` not working

```bash
09:28:39 info Error port forwarding 3008: accept tcp 127.0.0.1:3008: use of closed network connection
09:28:39 info Error tunneling to container: wait: remote command exited without exit status or exit signal
09:28:40 info Done setting up dotfiles into the devcontainer
```


- [ ] git files ownership issue

- maybe something I've resolved in [[02 - Module 2 - Dev Containers]] ?

```bash
vscode ➜ /workspaces/mercury-workflows $ git status
fatal: detected dubious ownership in repository at '/workspaces/mercury-workflows'
To add an exception for this directory, call:

        git config --global --add safe.directory /workspaces/mercury-workflows
```


## MS Azure Free Account


- [x] create a `@outlook.com` email account first (e.g. `milan.cloudcourse@outlook`)
- [ ] create a Free Tier Azure account (Personal), credit card required
- [ ] 