- install just docker engine (not Docker Desktop) - no licensing needed

```bash
# install
curl -fsSL https://get.docker.com | sh

# user must be added to docker group
...

# check
groups
milan sudo lpadmin docker vboxsf lpic1
```


- [x] install on Ubuntu VM
- [x] verify the installation `docker run hello-world`


```bash
ssh ubuntu

docker version
Client: Docker Engine - Community
 Version:           29.2.1
 API version:       1.53
 Go version:        go1.25.6
 Git commit:        a5c7197
 Built:             Mon Feb  2 17:17:05 2026
 OS/Arch:           linux/arm64
 Context:           default

Server: Docker Engine - Community
 Engine:
  Version:          29.2.1
  API version:      1.53 (minimum version 1.44)
  Go version:       go1.25.6
  Git commit:       6bc6209
  Built:            Mon Feb  2 17:17:05 2026
  OS/Arch:          linux/arm64
  Experimental:     false
 containerd:
  Version:          v2.2.1
  GitCommit:        dea7da592f5d1d2b7755e3a161be07f43fad8f75
 runc:
  Version:          1.3.4
  GitCommit:        v1.3.4-0-gd6d73eb8
 docker-init:
  Version:          0.19.0
  GitCommit:        de40ad0
```

# basic commands


```bash
docker version
docker info

docker search nginx
docker pull nginx:1.28
docker run -d nginx

docker ps
docker ps -a

# run a command in container
docker exec -it frosty_swartz curl http://localhost

# run interactive shell
docker exec -it frosty_swartz bash

# auto remove on exit
docker run -it --rm nginx bash
```