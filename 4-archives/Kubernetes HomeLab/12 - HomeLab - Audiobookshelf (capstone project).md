https://www.audiobookshelf.org/

https://www.audiobookshelf.org/docs

https://www.audiobookshelf.org/docs#docker-compose-install


## Stage 1

- The application should use port 3005
    
- This should be configured through a [ConfigMap](https://kubernetes.io/docs/concepts/configuration/configmap/#using-configmaps-as-environment-variables)
    
- It should have a ClusterIP service using port 3005

- [x] Access the application through a port-forward and upload an audio file.

user: root
pass: passrott

ghcr.io/advplyr/audiobookshelf:2.29.0

### change of the source branch for FluxCD

after a branch change in `gotk-sync.yaml` it needs to be re-apply:

`kubectl apply -f clusters/staging/flux-system/gotk-sync.yaml`

## Stage 2

Add persistent volumes for all of the suggested volumes in the Audiobookshelf documentation.

Audiobooks and configuration should persist when you restart the pod.

suggested volumes:

1. `/config`
2. `/metadata`
3. `/audiobooks`

- `flux get kustomizations apps` - get status, handy if the reconsilation stucks - shows the errors

## Stage 3

Run Audiobookshelf as the “node” user (meaning: not running it as root) and make it accessible from the public internet. The tunnel secret should be encrypted with SOPS and deployed through Flux.

---
- As the PVC run first with app under root user the directories and files were under root ownership. I had to do: 
  
  `chown -R node:node config metadata audibooks`

- using `.sops` config file (contains my AGE public key)

```
# create .yaml file with unencrypted tunnel data
kubectl create secret generic audiobooks-tunnel-credentials --from-file=credentials.json=./89bd5528-bdf9-486a-99ca-6680e5f6d9ec.json --dry-run=client -o yaml > audibookshelf-tunnel-credentials.json


# encrypt
sops --config ~/repos/homelab-cluster/.sops.yaml --encrypt --in-place audibookshelf-tunnel-credentials.yaml
```

#### Adding to Cloudflare DNS

Go to cloudflare DNS, add a new record

select CNAME

Enter:


[89bd5528-bdf9-486a-99ca-6680e5f6d9ec.cfargotunnel.com](http://89bd5528-bdf9-486a-99ca-6680e5f6d9ec.cfargotunnel.com "http://89bd5528-bdf9-486a-99ca-6680e5f6d9ec.cfargotunnel.com")

[audiobooks.milanoid.net](https://audibooks.milanoid.net)


Tips on applications to host: https://github.com/awesome-selfhosted/awesome-selfhosted