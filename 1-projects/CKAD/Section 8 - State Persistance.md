# Storage in Docker

- Storage Drivers
- Volume Drivers

After docker installation in File System:

`/var/lib/docker`

```bash
milan@ubuntu:/var/lib$ sudo ls -la ./docker/
total 48
drwx--x--- 11 root root 4096 Dec  3 09:48 .
drwxr-xr-x 81 root root 4096 Dec  3 09:47 ..
drwx--x--x  4 root root 4096 Dec  3 09:47 buildkit
drwx--x---  3 root root 4096 Dec  3 09:48 containers
-rw-------  1 root root   36 Dec  3 09:47 engine-id
drwxr-x---  3 root root 4096 Dec  3 09:47 network
drwx------  3 root root 4096 Dec  3 09:47 plugins
drwx--x---  3 root root 4096 Dec  3 09:48 rootfs
drwx------  2 root root 4096 Dec  3 09:47 runtimes
drwx------  2 root root 4096 Dec  3 09:47 swarm
drwx------  2 root root 4096 Dec  3 09:47 tmp
drwx-----x  2 root root 4096 Dec  3 09:47 volumes
```


## Layered Architecture

- each line in Dockerfile represents a layer
- when building it reuses existing layers which (the lines of Dockerfiles which are the same as before)
- the layers are read-only (can be changed only by running `docker build` again)
- running `docker run` creates extra writable layer on top of the image layers
- the writable layers is used to store app log files etc.
- when container is destroyed all the changes in writable layer are destroyed too


In running container:

- extra writeable layer
- if I change a file in container it gets copied on save to the writable container layer (copy-on-write mechanism)
- to persist the data we need to use Volume

## Volume

`docker volume create data_volume`

```bash
# create a volume
milan@ubuntu:/var/lib$ docker volume create data_volume
data_volume

milan@ubuntu:/var/lib$ sudo ls -ls ./docker/volumes
total 28
 0 brw------- 1 root root  8, 2 Dec  3 09:47 backingFsBlockDev
 4 drwx-----x 3 root root  4096 Dec  3 10:06 data_volume
24 -rw------- 1 root root 32768 Dec  3 10:06 metadata.db


# mount the volume to a container
# it's called `volume mounting` (mounting the default /var/lib/docker/volumes)
docker run -v data_volume:/var/lib/mysql mysql

# if volume is not created it gets created on first run
docker run -v data_volume2:/var/lib/mysql mysql

# use absolute path to store volume in a non-default /var/lib/docker/volumes path
# it's called `bind mounting`
docker run -v /data/mysql:/var/lib/mysql mysq
```

### `--mount` is preferred

Using `-v` is a legacy way. Preferred is to use `--mount`:

- it is more verbose and easier to read

```bash
docker run \
  --mount type=bind,source=/data/mysql,target=/var/lib/mysql mysql
```



### Storage Drivers

- All these actions (mounting etc) is done by _Storage Drivers_
- OS dependent

- AUFS (default on Ubuntu), ZFS, BTRFR, Device Mapper, Overlay, Overlay2



# Volume Driver Plugins in Docker


default - `Local`

others - `Azure File Storage`, `Convoy`, `Flocker`, `gce-docker` ...

Specify Volume Driver on container start:

```bash
docker run -it \
  --name mysql
  --volume-driver= rexray/ebs
  --mount src=ebs-vol,target=/var/1
```


# Volumes in Kubernetes

Let's start again with Docker first:

- docker containers are meant to be transient (temporary)
- started to perform an action and destroyed when finished

In Kubernetes it's similar

- a Pod is transient in nature
- to persist data generate by the Pod we need to attach a Volume

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: random-number-generator
spec:
  containers:
  - image: alpine
    name: alpine
    command: ["/bin/sh","-c"]
    args: ["shuf -i 0-100 -n 1 >> /opt/number.out;"]
    volumeMounts:
    - mountPath: /opt
      name data-volume
    
  volumes:
  - name: data-volume
	hostPath:
      path: /data
      type: Directory
```

- the example would work well on a Single Node cluster!
- for multi Node (my case) one can use `NFS`, `Flocker`, `GlusterFS`, public cloud solutions by AWS, Azure, Google




```yaml
volumes:
- name: data-volume
  awsElasticBlockStore:
    volumeID: <volume-id>
    fsType: ext4
```


# Persistent Volumes

The examples above shows the Volumes spec as part of the Pod specification. So it is tied to the Pod. Not good for Persistent Volumes.

For env with a lot of Pods each would need to specify the Volume again.

Better to centralize the Storage:

- a cluster wide Storage solution
- each Pod than can claim a part of the storage using PVC


```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-log
spec:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 100Mi
  hostPath:
    path: /pv/log
```


## Persistent Volume Claims

- PVC is bind to PV
- it's 1:1 relationship
- can use `selector` to make sure PVC is bound to a specific PV


By default if PVC is deleted, PV is retained. Can be controlled by `persistentVolumeReclaimPolicy`:

- _Reclaim_ - keeps PV and its data
- _Delete_ - deletes PV
- _Recycle (deprecated)_ - data deleted, PV made available for claims again

https://kubernetes.io/docs/concepts/storage/persistent-volumes/#claims-as-volumes

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
    - name: myfrontend
      image: nginx
      volumeMounts:
      - mountPath: "/var/www/html"
        name: mypd
  volumes:
    - name: mypd
      persistentVolumeClaim:
        claimName: myclaim
```


https://kubernetes.io/docs/concepts/storage

LAB

```bash
# run command within a pod
kubectl exec webapp -- cat /log/app.log
```

