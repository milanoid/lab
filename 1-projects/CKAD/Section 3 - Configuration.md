
### Docker images

Exercise - containerize a Flask web application

```
FROM ubuntu

RUN apt-get update
RUN apt-get install python

RUN pip install flask
RUN pip install flask-mysql

COPY . /opt/source-code

ENTRYPOINT FLASK_APP=/opt/souce-code/app.py flask run
```

- INSTRUCTIONS - in CAPITAL, e.g. FROM, RUN
- arguments - in lowercase, e.g. ubuntu


#### Layered architecture

-  each line of instructions creates a new layer!
- `docker history <image>` show the layers and size in MBs
- all the layers are cached

```bash
docker history docker.io/library/rabbitmq:3.6.15-management
ID            CREATED      CREATED BY                                     SIZE                     COMMENT
bf13a3aceead  7 years ago  /bin/sh -c #(nop)  EXPOSE 15671/tcp 15672/tcp  0B
<missing>     7 years ago  /bin/sh -c set -eux;                           erl -noinput -eval '...  24.7MB
<missing>     7 years ago  /bin/sh -c rabbitmq-plugins enable --offli...  3.07kB
<missing>     7 years ago  /bin/sh -c #(nop)  CMD ["rabbitmq-server"]     0B
<missing>     7 years ago  /bin/sh -c #(nop)  EXPOSE 25672/tcp 4369/t...  0B
<missing>     7 years ago  /bin/sh -c #(nop)  ENTRYPOINT ["docker-ent...  0B
<missing>     7 years ago  /bin/sh -c ln -s usr/local/bin/docker-entr...  1.54kB
<missing>     7 years ago  /bin/sh -c #(nop) COPY file:7f3c1def1757a3...  13.8kB
<missing>     7 years ago  /bin/sh -c ln -sf "/usr/lib/rabbitmq/lib/r...  1.54kB
<missing>     7 years ago  /bin/sh -c ln -sf /var/lib/rabbitmq/.erlan...  2.05kB
<missing>     7 years ago  /bin/sh -c #(nop)  VOLUME [/var/lib/rabbitmq]  0B
<missing>     7 years ago  /bin/sh -c mkdir -p /var/lib/rabbitmq /etc...  10.8kB
<missing>     7 years ago  /bin/sh -c #(nop)  ENV HOME=/var/lib/rabbitmq  0B
<missing>     7 years ago  /bin/sh -c set -eux;                                                    apt-get update;   ap...       11.4MB
<missing>     7 years ago  /bin/sh -c #(nop)  ENV RABBITMQ_DEBIAN_VER...  0B
<missing>     7 years ago  /bin/sh -c #(nop)  ENV RABBITMQ_GITHUB_TAG...  0B
<missing>     7 years ago  /bin/sh -c #(nop)  ENV RABBITMQ_VERSION=3....  0B
<missing>     7 years ago  /bin/sh -c #(nop)  ENV RABBITMQ_GPG_KEY=0A...  0B
<missing>     7 years ago  /bin/sh -c #(nop)  ENV PATH=/usr/lib/rabbi...  0B
<missing>     7 years ago  /bin/sh -c #(nop)  ENV RABBITMQ_LOGS=- RAB...  0B
<missing>     7 years ago  /bin/sh -c set -eux;                           apt-get update;          if ...        41.1MB
<missing>     7 years ago  /bin/sh -c set -eux;                                                    fetchDeps='               ca-ce...    3.16MB
<missing>     7 years ago  /bin/sh -c #(nop)  ENV GOSU_VERSION=1.10       0B
<missing>     7 years ago  /bin/sh -c groupadd -r rabbitmq && useradd...  350kB
<missing>     7 years ago  /bin/sh -c set -eux;                           apt-get update;          apt...      9.58MB
<missing>     7 years ago  /bin/sh -c #(nop)  CMD ["bash"]                0B
<missing>     7 years ago  /bin/sh -c #(nop) ADD file:d423aa6d423df23...  53.8MB

```


passing argument to process running in container:

```
# Dockerfile, runs `sleep` command with default value of 5 (can be overriden)
FROM ubuntu
ENTRYPOINT ["sleep"] # command to run
CMD ["5"]            # argument for the command

# passing 10 seconds to `sleep` command (overrides the CMD value)
docker run ubuntu-sleeper 10

# overriding the ENTRYPOINT
docker run --entrypoint sleep2.0 ubuntu-sleeper 10
```

### Commands and Arguments in Kubernetes

```yaml
apiVersion: v1
kind Pod
metadata:
  - name: ubuntu-slepper
    image: ubuntu-sleepr
    command: ["sleep2.0"] # corresponds to entrypoint
    args: ["10"]          # argument to be passed to the container
```


| Docker/Dockerfile | Kubernetes/Pod manifest |
| ----------------- | ----------------------- |
| `Entrypoint`      | `command`               |
| `CMD`             | `args`                  |


### Environment variables in Kubernetes

- direct plain key value specification
  
```yaml
env:
  - name: APP_COLOR
    value: pink
```

- _ConfigMap_ 
```yaml
env:
  - name: APP_COLOR
    valueFrom:
      configMapKeyRef: 
```

- _Secrets_
  
```yaml
env:
  - name: APP_COLOR
    valueFrom:
      secretKeyRef:
```


#### ConfigMaps

Imperative approach

- `kubectl create configmap <config-name> --from-literal=<key>=<value>`
- `kubectl create configmap <config-name> --from-file=<path-to-file>`

Declarative approach

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  APP_COLOR: blue
  APP_MODE: prod
```


Using it in a pod (injecting)

```yaml
    envFrom:
      - configMapRef:
          name: app-config
```


#### Secrets

imperative way (no file)

- key=value pair
```bash
kubectl create secret generic my-secret --from-literal=DB_HOST=mysql --from-literal=DB_PASS=secret
secret/my-secret created
```

- using a file

```bash
cat app_secret.properties

host=mysql
user=mysql
password=secret
database=app


kubectl create secret generic my-app-secret --from-file=app_secret.properties
secret/my-app-secret created
```


declarative way (yaml file)

- the values must be encoded - here we use `sops` and `age`

```yaml
apiVersion: v1
data:
    credentials.json: ENC[AES256_GCM,data:2lZ7KpNyH7NiOkan4Oa5PgCpsi/R/TxemLJAKbMvrcGjJ9pC2S0eyJy8J+31Wt4uUNWETAjk5o9aEePqLbwuS1AG0Z+J/0rsjofR3da3x98WAvA4/13zXZtR6igMVy3XaFkrN1ui+kLVs5u8On/vu1ZUjnmydn3zkh0RI4bMwpcmgUjFJfoqzEh3jQV1t1/b0xxzafFCS1ce/RNgsdP8zTj/yXLPq1uo7/cLs/ujtGuRUSXw8U5BVwTS0ZrLvvQj7ORscQe0HX2RArc+P4jDuRSXDl1wvbaGEA3HrHqfeQNibDHIaoZ0NRM1yd0=,iv:cY4gRUO50s/DH2DnvvmkxnkgQwlEnUaZDWtqX8PjYNo=,tag:T6hyFmaoZiapHLJUDn+ZCA==,type:str]
kind: Secret
metadata:
    name: webhosting-tunnel-credentials
sops:
    age:
        - recipient: age1jnfhet7cj900tg9f0dwgqktjwux4km4hen8gnevpujm5260sayesujm92y
          enc: |
            -----BEGIN AGE ENCRYPTED FILE-----
            YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0+IFgyNTUxOSBtNmhJdG9vWEY0SWdYUnhZ
            b2Z2VytlVGEwQUlDbHViU0NKSDNzbUxXQUdvCnhnajR1OUg5VVdRZmtnajZnNkZL
            b05RZGR3TjlmT3ZreHBDMmV4Y1VkcDQKLS0tIElSYU5Rakg3SjZ3QUVyaEdQSnBx
            b1VzRTFRUzRNK2x5cGNvSG11OWVmSGcKOJUdPoY6hbk9s7z2IrNm7s2eROj9Vfyq
            uDVOIjHm9ZMwT4AvAr6x6pL76sDzsx5sPfjerQU0xSLty2H9rigcLQ==
            -----END AGE ENCRYPTED FILE-----
    lastmodified: "2025-10-05T18:04:58Z"
    mac: ENC[AES256_GCM,data:5vhYQuyWoDyUPM/ApjcDgXIu2bzvjjXe5LySlgBiuSoaJ/vjV5IvJPXeSuvFChElcKNNIkBNMUrJosZT3JBKdOpVspXNB7VMK6vmt/bdpZ9jr0LfE+irCZafQPoXHyEO1cQcdg5hWOjSvCn9KXU4OxH1YrF5VnnPMOM8rGRdrQ0=,iv:Fiu+S0IV6GTluY6ldE9pig16qrC23+KPVFCqXRUT9w4=,tag:p/3dCLtS5S4SeTd13Qfhwg==,type:str]
    encrypted_regex: ^(data|stringData)$
    version: 3.11.0
```


https://kubernetes.io/docs/concepts/configuration/secret/#risks

```bash
# get secret
kubectl get secrets my-app-secret -o yaml

apiVersion: v1
data:
  app_secret.properties: Cmhvc3Q9bXlzcWwKdXNlcj1teXNxbApwYXNzd29yZD1zZWNyZXQKZGF0YWJhc2U9YXBwCgo=
kind: Secret
metadata:
  creationTimestamp: "2025-11-06T12:29:36Z"
  name: my-app-secret
  namespace: default
  resourceVersion: "10608424"
  uid: 6e1633b6-b459-4813-ab77-935f99bd9a4b
type: Opaque

# then base64 decode
echo Cmhvc3Q9bXlzcWwKdXNlcj1teXNxbApwYXNzd29yZD1zZWNyZXQKZGF0YWJhc2U9YXBwCgo= | base64 --decode

host=mysql
user=mysql
password=secret
database=app
```

Secrets in Pods as Volumes

```yaml
volumes:
 - name: app-secret-volume
   secret:
	  secretName: app-secret
```

- each value in the secret file (e.g. DB_HOST, DB_PASSWORD) are mounted as files:
  
```
ls /opt/app-secret-volumes
DB_HOST DB_PASSWORD

cat /opt/app-secret-volumes/DB_PASSWORD
secret-password-here
```

Additional Resource - YT video on Secrets Manager https://www.youtube.com/watch?v=MTnQW9MxnRI


## Demo - Encrypting Secret Data at Rest

https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/

### etcd install

Update: this below would install the server, not needed for this excercise

installing `etcd` (on ubuntu hpmini) https://github.com/etcd-io/etcd/releases/tag/v3.4.37
- installed `etcd` and `etcdctl` binaries into `/usr/local/bin/`

```bash
milan@hpmini01:~$ etcdctl version
etcdctl version: 3.4.37
API version: 3.4
```

=> Do this instead: `apt-get install etcd-client`
- installs the client only
- server running on control plane

In my K3s installation I don't have running `etcd` server:

```
kubectl get pods -n kube-system | grep "etcd"
```

But Mumshad's installation does have it:

```
kubectl get pods -n kube-system | grep "etcd"
NAME READY   STATUS      RESTARTS         AGE
etcd-controlplane  1/1     Running     6 (4d14h ago)    99d
```

INFO - K3s by default does not come with `etcd` but uses SQLite `/var/lib/rancher/k3s/server/db/state.db` instead.

`sudo apt install sqlite3`

view the content:

`root@hpmini01:/var/lib/rancher/k3s/server/db# sqlite3 state.db`

```
SQLite version 3.45.1 2024-01-30 16:01:20
Enter ".help" for usage hints.
sqlite> .tables
kine
sqlite> .schema kine
CREATE TABLE kine
                        (
                                id INTEGER PRIMARY KEY AUTOINCREMENT,
                                name INTEGER,
                                created INTEGER,
                                deleted INTEGER,
                                create_revision INTEGER,
                                prev_revision INTEGER,
                                lease INTEGER,
                                value BLOB,
                                old_value BLOB
                        );
CREATE INDEX kine_name_index ON kine (name);
CREATE INDEX kine_name_id_index ON kine (name,id);
CREATE INDEX kine_id_deleted_index ON kine (id,deleted);
CREATE INDEX kine_prev_revision_index ON kine (prev_revision);
CREATE UNIQUE INDEX kine_name_prev_revision_uindex ON kine (name, prev_revision);
```

```
# show data
sqlite> SELECT * FROM kine LIMIT 2;
1|compact_rev_key|1|0|0|11093527|0||
2|/registry/health|1|0|0|0|0|{"health":"true"}|
```


## Security context (in Docker)

- unlike VMs the container shares the kernel with the host
- isolation by _Namespaces_
- all the process within container are run by the host but in its own namespace
- by default docker runs processes as `root` user

```bash
# run container with `sleep` command
docker run ubuntu sleep 3600

# ps aux in container
$ docker exec -it 56da524f871f bash
root@56da524f871f:/# ps aux
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.0  0.0   2272  1204 ?        Ss   09:31   0:00 sleep 3600
root           2  0.0  0.0   4300  3548 pts/0    Ss   09:32   0:00 bash
root           5  0.0  0.0   7632  3468 pts/0    R+   09:32   0:00 ps aux

# ps aux on host - the sleep process should be here
# I see just 'podman run' coommand? Maybe a podman feature?
ps aux | grep sleep
milan            55857   0.0  0.1 411943264  15488 s006  S+   10:31AM   0:00.05 podman run ubuntu sleep 3600
milan            56541   0.0  0.0 410733616   1568 s009  S+   10:33AM   0:00.00 grep sleep
```


#### Users

Process in a container runs as `root` by default. Can be changed though:

```Dockerfile
FROM ubuntu
USER 1000
```

- `root` has all the capabilities on the system, the full list is in `/usr/include/linux/capability.h`
- by default the `root` in docker has limited capabilities (e.g. cannot reboot the host)
- can explicitly enable/disable capabilities
  
```bash
# add extra cap
docker run --cap-add MAC_ADMIN ubuntu

# remove a cap
docker run --cap-drop KILL ubuntu

# with all caps!
docker run --privileged ubuntu
```

- similarly we can configure it in Kubernetes
- in K8s it is either on container level or on a Pod level
- settings on container level take precedens over the Pod level settings

```yaml
---  
apiVersion: apps/v1  
kind: Deployment  
metadata:  
  name: linkding  
spec:
  containers:  
    - name: ubuntu  
      image: ubuntu 
      securityContext:  
        allowPrivilegesEscalation: false  
        runAsUser: 33
        capabilities:
	      add: ["MAC_ADMIN"]
```

Practice test:

To get to shell of a pod 

```bash
kubectl exec -it pods/ubuntu-sleeper -- bash
```

To change the user used for run

```bash
kubectl edit pods ubuntu-sleeper

# do edits, some changes cannot be applied (such as securityContext)
# the file needs to be written to a .yaml, then applied
```


# Resource requirements

CPU and MEM - monitored by _Kubernetes Scheduler_

- assignes Pod to a Node based on the Node utilization 

Pod has Resource Requests, e.g. 1 CPU and 4Gi MEM.

### CPU

- `0.1` or `100m` (mili)
- minimum `1m`

1 CPU is
- 1 AWS vCPU
- 1 GCP Core
- 1 Azure Core
- 1 Hyperthread


### MEM

- 256Mi or in bytes 268435456 or 268M
- 1G vs 1Gi

1G (Gigabyte) = 1 000 000 000 bytes
1Gi (Gigibyte) = 1 073 741 824 bytes

### Resource Limits

- a Pod can be limited to use less than maximum resources available
- e.g. total CPU is 10, can be limited to 5 or total MEM is 16G can be limited to 8GB

```yaml
# on container level
resources:
  requests:
	memory: "1Gi"
	cpu: 2
  limits:
    memory: "2Gi"
    cpu: 2
```


#### Exceeding limits

- CPU is throttled 
- MEM is not, can exceed the limit temporarily, if constantly it will be terminated with OOM error 

Best practices

CPU - Requests, No Limits

##### LimitRange

- on namespace level object

```
apiVersion: v1
kind: LimitRange
...
```

##### Resource Quotas

- on namespace level object


# Service Account

User (Admin, Developer) vs Service Account (Prometheus, Jenkins)

```
# create a service account
kubectl create serviceaccount dashboard-sa

# then create service account token (previously was auto-created)
kubectl create token dashboard-sa

# view
kubectl get serviceaccount

# token - to be used by external application (in Secret object)
kubectl describe serviceaccount dashboard-sa

# to get the token
kubectl describe secret dashboard-sa-token-kbbdm
```

The secret can be mounted as a volume to a Pod (with an application), so the app can use the token.

All namespaces has `default` service account and its already mounted as a Mount. It's very restricted.


```yaml
Containers:
  sonarr:
    Container ID:   containerd://3371bc4865816331b34900f59601af8da8b8bb9997121744ceb045d5797412fa
    Image:          ghcr.io/hotio/sonarr:release-4.0.16.2944
    Image ID:       ghcr.io/hotio/sonarr@sha256:20cf6013b2b35c035f9ce7d5e8149eccf03c933c58ea40a9bd397e57a6dee714
    Port:           8989/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Tue, 11 Nov 2025 18:41:53 +0100
    Ready:          True
    Restart Count:  0
    Environment Variables from:
      sonarr-configmap  ConfigMap  Optional: false
    Environment:        <none>
    Mounts:
      /config from sonarr-config (rw,path="sonarr/config")
      /data from sonarr-data (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-2n9nd (ro)
```

Can read to token on shell:

```
cat /var/run/secrets/kubernetes.io/serviceaccount/token

eyJhbGciOiJSUzI1NiIsImtpZCI6InlsQ25VV2I2TDBkLW5jbmdLN2Q4SHI3a1JmQ2F3ekpkR1Bka0VDRVJLMGcifQ.eyJhdWQiOlsiaHR0cHM6Ly9rdWJlcm5ldGVzLmRlZmF1bHQuc3ZjLmNsdXN0ZXIubG9jYWwiLCJrM3MiXSwiZXhwIjoxNzk0NjQ0MzU1LCJpYXQiOjE3NjMxMDgzNTUsImlzcyI6Imh0dHBzOi8va3ViZXJuZXRl ...
```

Creating a new Service Account

In a Pod definition:

```yaml
spec:
. serviceAccountName: dashboard-sa
  automountServiceAccountToken: false # true by default
  containers:
    - name: ubuntu
      image: ubuntu:latest
```

Decoding the token:

`jq -R 'split(".") | select(length > 0) | .[0],.[1] | @base64d | fromjson' <<< [token]`

```bash
jq -R 'split(".") | select(length > 0) | .[0],.[1] | @base64d | fromjson' <<< eyJhbGciOiJSUzI1NiIsImtpZCI6InlsQ25VV2I2TDBkLW5jbmdLN2Q4SHI3a1JmQ2F3ekpkR1Bka0VDRVJLMGcifQ.eyJhdWQiOlsiaHR0cHM6Ly9rdWJlcm5ldGVzLmRlZmF1bHQuc3ZjLmNsdXN0ZXIubG9jYWwiLCJrM3MiXSwiZXhwIjoxNzk0NjQ0MzU1LCJpYXQiOjE3NjMxMDgzNTUsImlzcyI6Imh0dHBzOi8va3ViZXJuZXRlcy5kZWZhdWx0LnN2Yy5jbHVzdGVyLmxvY2FsIiwianRpIjoiNDlkMWUyYjctNGE2NC00Yjk2LWI4ZGMtNGI5NDhkZTU4MjYwIiwia3ViZXJuZXRlcy5pbyI6eyJuYW1lc3BhY2UiOiJsaW5rZGluZyIsIm5vZGUiOnsibmFtZSI6ImhwbWluaTAxIiwidWlkIjoiOTA2YzAzNmItZWU1ZS00YWZmLWFhMzktMjFkZmRlMDUwMGFkIn0sInBvZCI6eyJuYW1lIjoibGlua2RpbmctNTZmNTljOTU5NC00c3RrayIsInVpZCI6IjA0MjRiMjJhLTdkZGItNDcwMC05MWIxLWE3MjcxZTRkNGM3NyJ9LCJzZXJ2aWNlYWNjb3VudCI6eyJuYW1lIjoiZGVmYXVsdCIsInVpZCI6IjIzZDIyZjM1LWQzNjctNDQwOC05MzQ2LTc1MjM1OWNlY2Q2YiJ9LCJ3YXJuYWZ0ZXIiOjE3NjMxMTE5NjJ9LCJuYmYiOjE3NjMxMDgzNTUsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDpsaW5rZGluZzpkZWZhdWx0In0.liipjUmFYrW_0VNDNPTzu-KFhRo21nFif3iAP6Wy9Wj301NR5OWsuMF4gJQTa_ohdyxBzhWtN6r_SANWaRvex7_XM5u6FP_ve6JD6GwXhLpMs8xkZhq5w2M-foHGOxLK2rIt9B5O9lr-duuMFwa9T4Dvwsd6Rukxajqr2UtHeLqAj5zwdrmb4oyt5LuXZu1qvDwaHo6m0PcgONT0d9L3wi65uq3BHOMWkAUAZQt2kT4-a_JTfgGpSiRNRqNJDqkET5pPG2e2sbcggaDJ7UD6Phb9ukR847ZlOYwt8QnnPvgqoyetGCtJfokI4cEG01lbr2uxT8nuIaPrb5WUlSECGA
{
  "alg": "RS256",
  "kid": "ylCnUWb6L0d-ncngK7d8Hr7kRfCawzJdGPdkECERK0g"
}
{
  "aud": [
    "https://kubernetes.default.svc.cluster.local",
    "k3s"
  ],
  "exp": 1794644355,
  "iat": 1763108355,
  "iss": "https://kubernetes.default.svc.cluster.local",
  "jti": "49d1e2b7-4a64-4b96-b8dc-4b948de58260",
  "kubernetes.io": {
    "namespace": "linkding",
    "node": {
      "name": "hpmini01",
      "uid": "906c036b-ee5e-4aff-aa39-21dfde0500ad"
    },
    "pod": {
      "name": "linkding-56f59c9594-4stkk",
      "uid": "0424b22a-7ddb-4700-91b1-a7271e4d4c77"
    },
    "serviceaccount": {
      "name": "default",
      "uid": "23d22f35-d367-4408-9346-752359cecd6b"
    },
    "warnafter": 1763111962
  },
  "nbf": 1763108355,
  "sub": "system:serviceaccount:linkding:default"
}
```

# Taints and Tolerations

taint (n.) - skvrna
taint (v.) - zamořit (ale i postřik či sprej proti komárům)

vs.
_Node affinity_ - a property of Pods that _attracts_ them to a set of _nodes_.

https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/
### Pod and Node 

analogy - Pod (a bug) vs Node (person) - Taint (sprej) on a person vs. a bug (tolerant or intoleran to taint)

- what Pods can be scheduled on which Node
- a Node can be taint
- Pods by default are intolerant to taint
- only Pods **set to** tolerate a taint can land on the taint Pod

### adding a taint

`kubectl taint nodes node-name key=value:taint-effect`

### remove a taint

`kubectl taint nodes node-name key=value:taint-effect-`

`taint-effect` 
- specify what happens to a Pod if it does not tolerate the taint 
- _NoSchedule_ - won't be scheduled, guaranteed
- _PreferNoSchedule_ - not guaranteed 
- _NoExecute_

```yaml
# pod definition
...
  containers: ubuntu
  - name: ubuntu
    image: ubuntu
  tolerations:
   - key: "app"
     operatorator: "Equal"
     value: "blue"
     effect: "NoSchedule"
```


```shell
kubectl describe node hpmini01

Name:               hpmini01
Roles:              control-plane,master
...
Taints:             <none>

```


If a Pod is intolerant - in `kubectl describe pod`:

```
  Type     Reason            Age   From               Message
  ----     ------            ----  ----               -------
  Warning  FailedScheduling  30s   default-scheduler  0/2 nodes are available: 1 node(s) had untolerated taint {node-role.kubernetes.io/control-plane: }, 1 node(s) had untolerated taint {spray: mortein}. no new claims to deallocate, preemption: 0/2 nodes are available: 2 Preemption is not helpful for scheduling.
```

