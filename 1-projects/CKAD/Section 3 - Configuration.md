
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