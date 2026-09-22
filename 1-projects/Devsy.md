
sucessor of [devpod](https://devpod.sh/)
# installation

https://devsy.sh/docs/getting-started/install

```bash
brew trust devsy-org/tap
brew install devsy-org/homebrew-tap/devsy
```



```bash
devsy --version 
v1.19.0

devsy provider add podman
```


```bash
# switched to beta channel to get fixes
devsy update --channel beta 2>&1; echo "---"; devsy --version 2>&1
```



example how to run https://github.com/statsperform/devops-infrastructure-utils/tree/main/jcasc-updater

```bash
# starting container
devsy workspace up . \
  --devcontainer jcasc-updater/.devcontainer/devcontainer.json \
  --ide none
  
devsy workspace ls
devsy workspace ssh
```