K3s by Rancher Labs (Rancher Desktop) https://k3s.io/

Install Guide for Ubuntu: https://www.digitalocean.com/community/tutorials/how-to-setup-k3s-kubernetes-cluster-on-ubuntu


```bash
# install
curl -sfL https://get.k3s.io | sh -
```

```bash
# check default Kubernetes objects
sudo kubectl get all --namespace kube-system
```

### Setting up remote management via kubectl

As we don't want to be ssh-ed to the cluster machine. The management will be done from a client machine (laptop). Configuration is necessary:

Installation created configuration file:

- see it is owned by root user
```bash
milan@hpmini01:~$ ls -l /etc/rancher/k3s/k3s.yaml
-rw------- 1 root root 2957 Aug  2 15:32 /etc/rancher/k3s/k3s.yaml
```

- we need to make it accessible by a regular user (milan), by copying to home dir

```bash
milan@hpmini01:~$ pwd
/home/milan

milan@hpmini01:~$ sudo cp /etc/rancher/k3s/k3s.yaml .

# change file ownership
milan@hpmini01:~$ sudo chown milan:milan k3s.yaml
```

- now scp the file to the client machine

```bash
scp hpmini01:/home/milan/k3s.yaml .
```

### Combining 2 Kubernetes cluster config files

I already had a configuration for Rancher Desktop cluster in `~/.kube/config`. To merge it with k3s config do the following:

```bash
# backup original file
cp ~/.kube/config ~/.kube/config.bak

# set the env var to use both config files
export KUBECONFIG=/home/milan/k3s.yaml:/home/milan/.kube/config

# view it and save it to a new file
kubectl config view --flatten > /path/to/COMBINED_FILE

# replace the original config with the new combined one
cp /path/to/COMBINED_FILE /home/milan/.kube/config

# see it reads both contexts:
milan@jantar:~/.kube$ kubectl config get-contexts
CURRENT   NAME              CLUSTER           AUTHINFO          NAMESPACE
*         k3s               k3s               k3s
          rancher-desktop   rancher-desktop   rancher-desktop   monitoring

# swtich context
kubect config use-context k3s|rancher-desktop
```


### inspecting containers (containerd)

`crictl` - client for CRI

```bash
milan@hpmini01:~$ sudo crictl ps
CONTAINER           IMAGE               CREATED             STATE               NAME                     ATTEMPT             POD ID              POD
8d038820e95fa       3a1e150bf4c56       About an hour ago   Running             traefik                  0                   3edcbb8641747       traefik-c98fdf6fb-pcrtp
7bd47bbca969f       f7415d0003cb6       About an hour ago   Running             lb-tcp-443               0                   6ad3140f6e0e8       svclb-traefik-818aeded-9j2nr
bc9cc3dc99a79       f7415d0003cb6       About an hour ago   Running             lb-tcp-80                0                   6ad3140f6e0e8       svclb-traefik-818aeded-9j2nr
0fa205ec448dc       48d9cfaaf3904       About an hour ago   Running             metrics-server           0                   5c80df643771f       metrics-server-6f4c6675d5-ftbqh
dc9855c8b86aa       52546a367cc9e       About an hour ago   Running             coredns                  0                   674da0feafb2e       coredns-5688667fd4-kwbsm
2bc182eaea0a7       8309ed19e06b9       About an hour ago   Running             local-path-provisioner   0                   edcee02ffd050       local-path-provisioner-774c6665dc-ct8pw
```