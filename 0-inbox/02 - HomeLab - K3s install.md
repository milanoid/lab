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
