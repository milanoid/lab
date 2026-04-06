
Starting from fresh. The AKS cluster used in previous steps destroyed.
# 05.01 GitOps

`mercury-workflows/phase-5-gitops`


### Issue with devpod (skipping for now)

```bash
vscode ➜ /workspaces/mercury-workflows/phase-5-gitops $ git status 
warning: unable to access '.git/config': Permission denied fatal: unable to access '.git/config': Permission denied
```

after `devpod up . --recreate`

```bash
vscode ➜ /workspaces/mercury-workflows $ git status
fatal: detected dubious ownership in repository at '/workspaces/mercury-workflows'
To add an exception for this directory, call:

        git config --global --add safe.directory /workspaces/mercury-workflows
```