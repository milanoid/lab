### Networking on Pod level

- each pod gets its own IP address
- by default, pods can connect to all pods on all nodes
- container in pods can communication with each other through localhost

### CNI Plugin

Container Networking Interface

- provides network connectivity to containers
- configures network interfaces in container
- assigns IP address and sets up routes (IPTables)

plugins: [Cilium](https://cilium.io/use-cases/cni/), [Calico](https://docs.tigera.io/calico/latest/getting-started/kubernetes/hardway/install-cni-plugin), [Flannell](https://github.com/flannel-io/flannel)

#### What CNI is used in Rancher Desktop?

One needs to connect VM running the Kubernetes cluster:

`rdctl shell bash`

```bash
/ $ cd /etc/cni/
/etc/cni $ tree
.
└── net.d
    └── 10-flannel.conflist

1 directories, 1 files
```