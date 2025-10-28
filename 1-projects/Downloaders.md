### Radarr

- movie downloads

https://radarr.video/#downloads-dockeri
https://hotio.dev/containers/radarr/

https://wiki.servarr.com/docker-guide


username: milan
pass: lastpass

### Prowlarr

- indexer

https://prowlarr.com/

https://hotio.dev/containers/prowlarr/


### qBittorrent Client

- download client

https://hub.docker.com/r/linuxserver/qbittorrent

user: admin
pass: lastpass

TODO

- [x] not enough disk space on hpmini - NAS?
- [ ] VPN for security reasons (torrents)
- [ ] cleanup - switch back to `main`
- [ ] service (+cloudflare DNS)


### Synology NAS as storage device

- DS218play

1. enable NFS in Synology UI
2. ` apt install nfs-common` - install NFS client on the Ubuntu server running K3s
3. create PVC

```yaml
apiVersion: v1  
kind: PersistentVolume  
metadata:  
  name: synology-nfs-pv  
spec:  
  capacity:  
    storage: 100Gi  
  accessModes:  
    - ReadWriteMany  
  nfs:  
    path: /volume1/video 
    server: 192.168.1.36
```


### testing NFS connection from mac

```bash
sudo mkdir -p /Volumes/synology-nfs

sudo mount -t nfs -o resvport 192.168.1.36:/volume1/k8s /Volumes/synology-nfs
```


Modifying storage is complex - spec is immutable. I had to disable entire deployment, make a change and than enable it back.


```
flux get kustomizations apps

READY MESSAGE apps downloaders@sha1:d4eb6de0 False False PersistentVolumeClaim/downloaders/synology-nfs-pvc dry-run failed (Invalid): PersistentVolumeClaim "synology-nfs-pvc" is invalid: spec: Forbidden: spec is immutable after creation except resources.requests and volumeAttributesClassName for bound claims core.PersistentVolumeClaimSpec{ AccessModes: {"ReadWriteOnce"}, Selector: nil, Resources:
```

---

- each application in a separate namespace with its own deployment
- storage - PV in its own directory `persistant-volumes` (no namespace - available for entire cluster)


PV status

- `Bound`
- `Released`


prowlarr

- PVC `prowlarr-config-pvc` (local-path)

radarr

- PVC `radarr-config-pvc` (local-path)
- PVC `synology-nfs-pvc` (NFS)

torrent-client

- PVC `qbittorrent-config-pvc` (local-path)
- PVC `synology-nfs-pvc` (NFS)
---

## NFS access rights

the app containers are running `chown` command on its config files. Pods needs to be set to use user existing on NAS:

```
PUID: "1024"    # NAS user `admin`  
PGID: "101"     # NAS group `administrators`
```

