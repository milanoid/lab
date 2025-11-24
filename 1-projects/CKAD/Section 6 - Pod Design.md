# Labels, Selectors and Annotations


- L. and S. used to group and select object
- once label assigned we can filter, e.g. `kubectl get pods --selector app=App1`

```bash
# get all object matching a selector

kubectl get all  --selector env=dev
NAME              READY   STATUS    RESTARTS   AGE
pod/app-1-d69fw   1/1     Running   0          99s
pod/app-1-pvhd8   1/1     Running   0          99s
pod/app-1-tshrq   1/1     Running   0          99s
pod/db-1-mxh5j    1/1     Running   0          99s
pod/db-1-n4dm5    1/1     Running   0          99s
pod/db-1-v8nc2    1/1     Running   0          99s
pod/db-1-xrxhd    1/1     Running   0          99s

NAME                    DESIRED   CURRENT   READY   AGE
replicaset.apps/app-1   3         3         3       99s
replicaset.apps/db-1    4         4         4       99s
```


```bash
kubectl get pods --selector env=prod --selector bu=fi
nance --selector tier=frontend
NAME          READY   STATUS    RESTARTS   AGE
app-1-d69fw   1/1     Running   0          3m10s
app-1-pvhd8   1/1     Running   0          3m10s
app-1-tshrq   1/1     Running   0          3m10s
app-1-zzxdf   1/1     Running   0          3m10s
app-2-s4hjq   1/1     Running   0          3m10s
```

Annotations - to record other details (e.g. contact, build number etc.)


# Rolling Updates & Rollbacks in Deployments

`kubectl rollout status deployment/my-app-deployment`


```bash
# get rollout history

kubectl rollout history deployment --namespace downloaders
deployment.apps/bazarr
REVISION  CHANGE-CAUSE
1         <none>
2         <none>

deployment.apps/prowlarr
REVISION  CHANGE-CAUSE
1         <none>
2         <none>

deployment.apps/radarr
REVISION  CHANGE-CAUSE
1         <none>
2         <none>

deployment.apps/sonarr
REVISION  CHANGE-CAUSE
1         <none>
2         <none>

deployment.apps/torrent-client
REVISION  CHANGE-CAUSE
1         <none>
2         <none>
3         <none>


# get by revision
kubectl rollout history deployment nginx --revision=1
```

Deployment Strategies

1. destroy existing ones before starting the new -> _Recreate_
2. destroy and start a new one one by one -> _RollingUpdate_ (default)

How to upgrade:

1. `kubect apply -f`
2. `kubectl set image deployment/my-app nginx=nginx:1.9.1`

```bash
kubectl get replicasets.apps --namespace downloaders
NAME                        DESIRED   CURRENT   READY   AGE
bazarr-6c4dcc6db8           1         1         1       12d
bazarr-8d9bcd744            0         0         0       12d
prowlarr-6675f87cdf         0         0         0       12d
prowlarr-b667bf985          1         1         1       12d
radarr-5c785788c            0         0         0       12d
radarr-d44fb4744            1         1         1       12d
sonarr-64df6f54d7           0         0         0       12d
sonarr-6c8bb8c585           1         1         1       12d
torrent-client-6d96657cbd   1         1         1       38h
torrent-client-8577d648d6   0         0         0       12d
torrent-client-f9885444d    0         0         0       12d
```

How to rollback

`kubectl rollout undo deployment my-app-deployment`

