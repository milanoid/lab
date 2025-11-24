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
- [x] cleanup - switch back to `main`
- [x] service (+cloudflare DNS)


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

# Mobile app

https://github.com/ruddarr/app

- [x] ~expose Radarr via Cloudflare tunnel~ local only
- [x] connect the app with Radarr
- [x] add Sonarr too!
- [x] profit

### Subtitles

- https://www.bazarr.media/

- [x] 

**You CANNOT store your config directory over an NFS share as it is unsupported by SQLITE. You'll face a locked database error.**

https://wiki.bazarr.media/Getting-Started/Installation/Docker/docker/

https://hub.docker.com/r/linuxserver/bazarr


# Homarr

https://homarr.dev/docs/getting-started/installation/helm

- create a namespace
- create a secret for SQLite DB
- (optional) install using updated `values.yaml` https://github.com/homarr-labs/charts/blob/dev/charts/homarr/values.yaml



```bash
# namespace
kubectl create namespace homarr

# generate secret key
SECRET=$(openssl rand -hex 32)

# create Kubernetes secret
kubectl -n homarr create secret generic db-encryption --from-literal=db-encryption-key=$SECRET

# install
helm install homarr oci://ghcr.io/homarr-labs/charts/homarr --namespace homarr

Pulled: ghcr.io/homarr-labs/charts/homarr:8.3.0
Digest: sha256:f548e78c04d9611c1a593b02961f76697c1fa572362de12cadfac0f516d2cb10
NAME: homarr
LAST DEPLOYED: Mon Nov 24 09:53:34 2025
NAMESPACE: homarr
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace homarr -l "app.kubernetes.io/name=homarr,app.kubernetes.io/instance=homarr" -o jsonpath="{.items[0].metadata.name}")
  export CONTAINER_PORT=$(kubectl get pod --namespace homarr $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl --namespace homarr port-forward $POD_NAME 8080:$CONTAINER_PORT
```


user: admin/3l71UwvO#7 (temp)


