
1. most obvious way - open a port on (Wifi) router and port forward to the pod (RISKY)
2. Cloudflare Tunnel (thiw way)

https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/

### Cloudflare Tunnel

- create account (free tier)
- purchase Cloudflare domain
- install the `cloudflared` (where? On Ubuntu Server running my cluster?)
- authenticate, generate secret
- use the secret in the deployement


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