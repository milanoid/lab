
1. most obvious way - open a port on (Wifi) router and port forward to the pod (RISKY)
2. Cloudflare Tunnel (thiw way)

https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/

### Cloudflare Tunnel

- create account (free tier)
- purchase Cloudflare domain
- install the `cloudflared` (where? On Ubuntu Server running my cluster?)
- authenticate, generate secret
- use the secret in the deployement


#### installing `clouadflared`

https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/do-more-with-tunnels/local-management/create-local-tunnel/

I'll install it on my workstation (Arch Linux btw.). It is needed to generate the secret file.

```bash
# install
pacman -S cloudflared

# authenticate
cloudflared tunnel login
```