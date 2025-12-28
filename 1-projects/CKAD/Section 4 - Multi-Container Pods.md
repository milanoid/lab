
multicontainer pod sharing:

- lifecycle
- network (can call each other via localhost)
- storage

## Design patterns

### co-located containers

- both are meant to run together, e.g. webserver and main app

### regular init containers

https://kubernetes.io/docs/concepts/workloads/pods/init-containers/

- e.g. an init container checking the DB connection to be ready and than starts the main app container
- when the init is done the container stops
- there can be more than 1 init container

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  labels:
    app.kubernetes.io/name: MyApp
spec:
  containers:
  - name: myapp-container
    image: busybox:1.28
    command: ['sh', '-c', 'echo The app is running! && sleep 3600']
  initContainers:
  - name: init-myservice
    image: busybox:1.28
    command: ['sh', '-c', "until nslookup myservice.$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace).svc.cluster.local; do echo waiting for myservice; sleep 2; done"]
  - name: init-mydb
    image: busybox:1.28
    command: ['sh', '-c', "until nslookup mydb.$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace).svc.cluster.local; do echo waiting for mydb; sleep 2; done"]
```


### sidecar container

https://kubernetes.io/docs/concepts/workloads/pods/sidecar-containers/

- similar to init, but stays running (sidecar)
- unlike co-located setup we can define which starts first



```yaml
# example of a Deployment with two containers, one of which is a sidecar:
# restartPolicy: Always -> that makes it sidecar?

apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
  labels:
    app: myapp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
        - name: myapp
          image: alpine:latest
          command: ['sh', '-c', 'while true; do echo "logging" >> /opt/logs.txt; sleep 1; done']
          volumeMounts:
            - name: data
              mountPath: /opt
      initContainers:
        - name: logshipper
          image: alpine:latest
          restartPolicy: Always
          command: ['sh', '-c', 'tail -F /opt/logs.txt']
          volumeMounts:
            - name: data
              mountPath: /opt
      volumes:
        - name: data
          emptyDir: {}
```


