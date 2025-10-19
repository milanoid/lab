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

- [ ] not enough disk space on hpmini - NAS?
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