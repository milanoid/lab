
### List pods with more details

- `kubectl get pods --output wide`

```bash
milan@jantar:~$ kubectl get pods --output wide
NAME         READY   STATUS    RESTARTS        AGE     IP           NODE                   NOMINATED NODE   READINESS GATES
nginx        1/1     Running   1 (3m50s ago)   2d21h   10.42.0.16   lima-rancher-desktop   <none>           <none>
nginx-doc    1/1     Running   1 (3m50s ago)   2d19h   10.42.0.15   lima-rancher-desktop   <none>           <none>
nginx-yaml   1/1     Running   1 (3m50s ago)   2d19h   10.42.0.17   lima-rancher-desktop   <none>           <none>
m
```

### Delete a pod

- `kubectl delete pods <pod>`
```bash
milan@jantar:~$ kubectl delete pods nginx
pod "nginx" deleted
```

### Run a command in the container

- `kubectl exec -it <pod> -- <command>`
- `kubectl exec -it <pod> -- /bin/bash` - open session

```bash
milan@jantar:~$ kubectl exec -it nginx-doc -- /bin/bash
root@nginx-doc:/# echo $SHELL
/bin/bash
```

To exit the session type `CTRL+D` or type `exit`.