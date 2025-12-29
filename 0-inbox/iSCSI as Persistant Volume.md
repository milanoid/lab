Enable iSCSI on Synology NAS. Use that as (default?) PV.


NFS

Currently the PV is of a type NFS (on Synology NAS). There are limitations e.g. SQLite DB (Sonarr and friends use it) is not compatible (the DB file gets corrupted).

Kubernetes can't use the NFS by default. I had to install support package [[Downloaders#Synology NAS as storage device]] on each Node `apt install nfs-common`. Instead I should have use a driver https://github.com/kubernetes-csi/csi-driver-nfs?tab=readme-ov-file#readme

https://kubernetes.io/docs/concepts/storage/persistent-volumes/



iSCSC

driver: https://github.com/kubernetes-csi/csi-driver-iscsi