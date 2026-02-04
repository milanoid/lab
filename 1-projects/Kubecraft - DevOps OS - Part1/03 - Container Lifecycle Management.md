Containers can be in states: Created, Running, Paused, Exited

### docker run

- creates a new container from an image
- starts it with specified command
- every `run` creates a new container

```bash
docker run -it ubuntu bash
```

### docker exec

- exec into a running container

```bash
docker run --name=myubuntu -d ubuntu sleep 10000

docker exec -it myubuntu bash
```
### docker attach

- connects to the main process (PID 1) of a running container
- shares the same STDIN/STDOUT
- Dangerous: Ctrl+C may stop the container!

```bash
docker attach my-container
```

- for debugging, not used much


### Stopping and Killing

`docker stop` - stops gracefully 
`docker kill` - agressive stop/kill

### Start/Restart

- `docker start` - starts existing (vs. `docker run` which always creates a new one)
- `docker restart`

### Restart policy

`--restart=no|on-failure|on-failure:3|always|unless-stopped`

## Inspecting Containers


```bash
docker inspect -f '{{.State.Status}}' myubuntu
running


docker inspect -f '{{.Config.Env}}' myubuntu
[PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin]


docker stats myubuntu
CONTAINER ID   NAME       CPU %     MEM USAGE / LIMIT   MEM %     NET I/O         BLOCK I/O    PIDS
3e5d8d5dcdd9   myubuntu   0.00%     396KiB / 3.303GiB   0.01%     4.14kB / 126B   0B / 4.1kB   1

```

### Volumes

```bash
# create volume
docker volume create mydata

# create container and mount the volume in
docker run -d --name mybox -v mydata:/data alpine sleep 3600

# exec to container and create a file in the mounted volume /data
docker exec mybox touch /data/file-created-in-container.txt


# the data are stored in the host system
root@ubuntu:/var/lib/docker/volumes/mydata/_data# ls -la
total 8
drwxr-xr-x 2 root root 4096 Feb  4 13:38 .
drwx-----x 3 root root 4096 Feb  4 13:34 ..
-rw-r--r-- 1 root root    0 Feb  4 13:36 file-created-in-container.txt



# mount current dir
docker run -it -v $(pwd):/app --name dev ubuntu bash
```

Use case for mounting current dir
- testing out (a script) in a specific system (e.g. fedora vs ubuntu)


```bash
docker volume inspect mydata
[
    {
        "CreatedAt": "2026-02-04T13:34:41+01:00",
        "Driver": "local",
        "Labels": null,
        "Mountpoint": "/var/lib/docker/volumes/mydata/_data",
        "Name": "mydata",
        "Options": null,
        "Scope": "local"
    }
]

# to get into that dir `sudo su -` needed


docker volume ls
DRIVER    VOLUME NAME
local     3f0faceadad83e0cde2e19408d9601f71ba8d5fbd99e84bf9264dcf00a4e14cd
local     data_volume
local     data_volume2
local     mydata


docker volume prune
```


### Volume vs Bind Mount

use Docker Volumes, forgot Bind Mounts

## Cleanup


```bash
docker rm -f mybox
docker rmi image
docker volume prune --all


docker system df
TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
Images          0         0         0B        0B
Containers      0         0         0B        0B
Local Volumes   0         0         0B        0B
Build Cache     0         0         0B        0B
```