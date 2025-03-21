## Ephemeral Storage


`k describe pod mealie-6d9455c57-tdwkc`

```
Volumes:
  kube-api-access-kmblg:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
```

### EmptyDir
- `nginx-pod.yaml`
- https://kubernetes.io/docs/concepts/storage/volumes/#emptydir

switching into a container
`k exec -it nginx-storage -- bash`

switching to a specific container (for multi container pods)

- use `-c`

`k exec -it nginx-storage -c nginx -- bash`

Understanding the syntax errors

`k apply -f nginx-pod.yaml
```
Error from server (BadRequest): error when creating "nginx-pod.yaml": Pod in version "v1" cannot be handled as a Pod: strict decoding error: unknown field "spec.containers[0].arg"
```
https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#Container

## Persistant Storage