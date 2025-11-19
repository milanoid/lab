Extra step on top of [[02 - HomeLab - K3s install]]

https://docs.k3s.io/quick-start


Current setup
- K3s one-node installation - node `hpmini01`

On another HP machine install:

- [x] Ubuntu Server
- [x] add K3s additional agent node `hpmini02-agent` to cluster 
- [ ] experiment with [Taints and Tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/), e.g. have some apps only on one Node


- `K3S_TOKEN` in `/var/lib/rancher/k3s/server/node-token` on your server node

```bash
curl -sfL https://get.k3s.io | K3S_URL=https://192.168.1.231:6443 K3S_TOKEN="$K3S_TOKEN" sh -
```


label it as a worker

```bash
kubectl label node hpmini02 node-role.kubernetes.io/worker=worker
node/hpmini02 labeled
```

```bash
# check status of the K3s Agent
sudo systemctl status k3s-agent

[sudo] password for milan:
● k3s-agent.service - Lightweight Kubernetes
     Loaded: loaded (/etc/systemd/system/k3s-agent.service; enabled; preset: enabled)
     Active: active (running) since Mon 2025-11-17 15:28:56 UTC; 13min ago
       Docs: https://k3s.io
    Process: 3419 ExecStartPre=/sbin/modprobe br_netfilter (code=exited, status=0/SUCCESS)
    Process: 3422 ExecStartPre=/sbin/modprobe overlay (code=exited, status=0/SUCCESS)
   Main PID: 3423 (k3s-agent)
      Tasks: 51
     Memory: 167.8M (peak: 169.5M)
        CPU: 47.484s
     CGroup: /system.slice/k3s-agent.service
             ├─3423 "/usr/local/bin/k3s agent"
             ├─3450 "containerd "
             ├─3860 /var/lib/rancher/k3s/data/86a616cdaf0fb57fa13670ac5a16f1699f4b2be4772e842d97904c69698ffdc2/bin/containerd-shim-runc-v2 -namespace k8s.io >
             └─4069 /var/lib/rancher/k3s/data/86a616cdaf0fb57fa13670ac5a16f1699f4b2be4772e842d97904c69698ffdc2/bin/containerd-shim-runc-v2 -namespace k8s.io >

Nov 17 15:28:57 hpmini02 k3s[3423]: I1117 15:28:57.392017    3423 iptables.go:211] Changing default FORWARD chain policy to ACCEPT
Nov 17 15:28:57 hpmini02 k3s[3423]: time="2025-11-17T15:28:57Z" level=info msg="Wrote flannel subnet file to /run/flannel/subnet.env"
Nov 17 15:28:57 hpmini02 k3s[3423]: time="2025-11-17T15:28:57Z" level=info msg="Running flannel backend."
Nov 17 15:28:57 hpmini02 k3s[3423]: I1117 15:28:57.396605    3423 vxlan_network.go:65] watching for new subnet leases
Nov 17 15:28:57 hpmini02 k3s[3423]: I1117 15:28:57.396645    3423 subnet.go:152] Batch elem [0] is { lease.Event{Type:0, Lease:lease.Lease{EnableIPv4:true, E>
Nov 17 15:28:57 hpmini02 k3s[3423]: I1117 15:28:57.396763    3423 vxlan_network.go:100] Received Subnet Event with VxLan: BackendType: vxlan, PublicIP: 192.1>
Nov 17 15:28:57 hpmini02 k3s[3423]: I1117 15:28:57.418492    3423 iptables.go:357] bootstrap done
Nov 17 15:28:57 hpmini02 k3s[3423]: I1117 15:28:57.433167    3423 iptables.go:357] bootstrap done
Nov 17 15:29:04 hpmini02 k3s[3423]: I1117 15:29:04.088786    3423 pod_startup_latency_tracker.go:104] "Observed pod startup duration" pod="monitoring/kube-pr>
Nov 17 15:29:15 hpmini02 k3s[3423]: I1117 15:29:15.151336    3423 pod_startup_latency_tracker.go:104] "Observed pod startup duration" pod="kube-system/svclb->
```

View logs

```bash
sudo journalctl -u k3s-agent -f
```


Test a pod can run on the worker node:


```bash
kubectl run test-pod --image=nginx
pod/test-pod created

# explicitly tell scheduller to use the worker node `hpmini02`
kubectl run nginx-test --image=nginx --overrides='{"spec":{"nodeName":"hpmini02"}}'

```