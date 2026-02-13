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

# port forwarding
docker run -d -p 8080:80 nginx

curl localhost:8080
<!DOCTYPE html>

# port fwd with a random port
docker run -d -p 80 nginx

# env vars
docker run -d \
 --name mydb \
 -e POSTGRES_PASSWORD=secret \
 -e POSTGRES_USER=milan \
 -e POSTGRES_DB=mydb \
postgres

# envs from a file
docker run -d --env-file db.env postgres

# read logs
docker logs -f mydb

# cleanup
docker ps -a
docker rm # for exited
docker rm -f mydb # for running
docker rmi nginx:1.28 # remove image
docker container prune
docker image prune

# nuclear option
docker system prune -a


# oneliner to delete all images and containers
docker rm -f $(docker ps -aq) && docker rmi -f $(docker images -aq)
```