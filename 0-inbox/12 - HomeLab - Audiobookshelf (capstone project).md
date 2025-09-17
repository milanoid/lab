https://www.audiobookshelf.org/

https://www.audiobookshelf.org/docs

https://www.audiobookshelf.org/docs#docker-compose-install


## Stage 1

- The application should use port 3005
    
- This should be configured through a ConfigMap
    
- It should have a ClusterIP service using port 3005

ghcr.io/advplyr/audiobookshelf:2.29.0

### change of the source branch for FluxCD

after a branch change in `gotk-sync.yaml` it needs to be re-apply:

`kubectl apply -f clusters/staging/flux-system/gotk-sync.yaml`

```bash


```