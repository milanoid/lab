
1. most obvious way - open a port on (Wifi) router and port forward to the pod (RISKY)
2. Cloudflare Tunnel (this way)

https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/

### Cloudflare Tunnel

- create account (free tier)
- purchase Cloudflare domain
- install the `cloudflared` (where? on cluster as deployment)
- authenticate, generate secret
- use the secret in the deployment


#### install `clouadflared`, create tunnel and generate secret

https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/do-more-with-tunnels/local-management/create-local-tunnel/

I'll install it on my workstation (Arch Linux btw.). It is needed to generate the secret file.

```bash
# install
pacman -S cloudflared

# authenticate
cloudflared tunnel login

A browser window should have opened at the following URL:

...

2025-08-15T09:32:43Z INF You have successfully logged in.
If you wish to copy your credentials to a server, they have been saved to:
/home/milan/.cloudflared/cert.pem

# create tunnel
cloudflared tunnel create cftunnel

Tunnel credentials written to /home/milan/.cloudflared/cf838265-1863-4c1b-a710-f8bb9fbf038b.json. cloudflared chose this file based on where your origin certificate was found. Keep this file secret. To revoke these credentials, delete the tunnel.

Created tunnel cftunnel with id cf838265-1863-4c1b-a710-f8bb9fbf038b

# list
cloudflared tunnel list
You can obtain more detailed information for each tunnel with `cloudflared tunnel info <name/uuid>`
ID                                   NAME     CREATED              CONNECTIONS
cf838265-1863-4c1b-a710-f8bb9fbf038b cftunnel 2025-08-15T09:36:18Z
```

#### create service for the linkding app

application exposed on the port 9090

```bash
#apps/base/linkding/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: linkding
spec:
  ports:
    - port: 9090
  selector:
    app: linkding
  type: ClusterIP
```

```bash
kubectl get service
NAME       TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
linkding   ClusterIP   10.43.248.39   <none>        9090/TCP   18m
```

- ? cannot reach it from the localhost on the Ubuntu server, is that ok?
- but reachable using the CLUSTER-IP:
```bash
milan@hpmini01:~$ wget 10.43.248.39:9090
--2025-08-16 09:31:59--  http://10.43.248.39:9090/
Connecting to 10.43.248.39:9090... connected.
HTTP request sent, awaiting response... 302 Found
Location: /bookmarks [following]
```

#### create Kubernetes secret

- the Cloudflared generated secret needs to be added to cluster
- this is one-time "manual" setup, in the follow up section it will be done full GitOps way

```bash
# on Arch (where cloudflared was installed)
milan@jantar:~ ()$ ls -la .cloudflared/
Permissions Size User  Date Modified Name
.rw-------   266 milan 15 Aug 11:32   cert.pem
.r--------   175 milan 15 Aug 11:36   cf838265-1863-4c1b-a710-f8bb9fbf038b.json
milan@jantar:~ ()$ cat .cloudflared/cf838265-1863-4c1b-a710-f8bb9fbf038b.json
```

```
kubectl create secret generic tunnel-credentials --from-file=credentials.json=.cloudflared/cf838265-1863-4c1b-a710-f8bb9fbf038b.json

secret/tunnel-credentials created
```

```bash
milan@jantar:~ ()$ kubectl get secrets
NAME                 TYPE     DATA   AGE
tunnel-credentials   Opaque   1      33s
```

Content of the secret can be revealed in K9s - by `x` .

#### Adding to Cloudflare DNS

Go to cloudflare DNS, add a new record

select CNAME

Enter:

[cf838265-1863-4c1b-a710-f8bb9fbf038b.cfargotunnel.com](http://cf838265-1863-4c1b-a710-f8bb9fbf038b.cfargotunnel.com "http://cf838265-1863-4c1b-a710-f8bb9fbf038b.cfargotunnel.com")

[server.milanoid.net](https://server.milanoid.net)

#### cloudflared deployement

- in file `cloudflare.yaml`

```bash
milan ~/repos/homelab-cluster [main] $ tree
.
├── README.md
├── apps
│   ├── base
│   │   └── linkding
│   │       ├── deployment.yaml
│   │       ├── kustomization.yaml
│   │       ├── namespace.yaml
│   │       ├── service.yaml
│   │       └── storage.yaml
│   └── staging
│       └── linkding
│           ├── cloudflare.yaml
│           └── kustomization.yaml
└── clusters
    └── staging
        ├── apps.yaml
        └── flux-system
            ├── gotk-components.yaml
            ├── gotk-sync.yaml
            └── kustomization.yaml

9 directories, 12 files
```

an error on missing .pem file but connection works!

```bash
2025-08-16T10:15:19Z ERR Cannot determine default origin certificate path. No file cert.pem in [~/.cloudflared ~/.cloudflare-warp ~/cloudflare-warp /etc/cloudflared /usr/local
```