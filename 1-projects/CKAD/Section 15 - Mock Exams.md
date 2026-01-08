real like exams

https://uklabs.kodekloud.com/topic/mock-exam-1-5/

# Mock exam 1

## create a service

imperative command to create a service:

Create a service `messaging-service` to expose the `redis` deployment in the `marketing` namespace within the cluster on port `6379`.

- Use imperative commands
- Service: messaging-service
- Port: 6379
- Use the right type of Service
- Use the right labels

```bash
kubectl expose deployment redis --port=6379 --name=messaging-service --namespace=marketing
```


```bash
# with same name instead of delete then apply we can run `replace`
kubectl replace -f webapp-color.yaml --force
```

## create a deployment

Create a `redis` deployment using the image `redis:alpine` with `1 replica` and label `app=redis`. Expose it via a ClusterIP service called `redis` on port 6379. Create a new `Ingress Type` NetworkPolicy called `redis-access` which allows only the pods with label `access=redis` to access the deployment.

- Image: redis:alpine
- Deployment created correctly?
- Service created correctly?
- Network Policy allows the correct pods?
- Network Policy applied on the correct pods?



- [x] how to `explain` with details on e.g. pod's `.spec`?

```bash
kubectl explain pods.spec.hostname
KIND:       Pod
VERSION:    v1

FIELD: hostname <string>


DESCRIPTION:
    Specifies the hostname of the Pod If not specified, the pod's hostname will
    be set to a system-defined value.
```


# Mock exam 2

