kubernetes control plane not reachable

```bash
milan@SPM-LN4K9M0GG7 ~
> kgp
E0806 17:53:28.238669   13834 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: the server has asked for the client to provide credentials"
E0806 17:53:28.255348   13834 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: the server has asked for the client to provide credentials"
E0806 17:53:28.273289   13834 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: the server has asked for the client to provide credentials"
E0806 17:53:28.289839   13834 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: the server has asked for the client to provide credentials"
E0806 17:53:28.306841   13834 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: the server has asked for the client to provide credentials"
error: You must be logged in to the server (the server has asked for the client to provide credentials)
```

- deployed applications running
- `kubectl` from the control plane (hpmini01) works - how? where is the kubeconfig?


```bash
# sudo journalctl -u k3s -f
Aug 06 16:04:30 hpmini01 k3s[1002]: E0806 16:04:30.297247    1002 authentication.go:75] "Unable to authenticate the request" err="[x509: certificate has expired or is not yet valid: current time 2026-08-06T16:04:30Z is after 2026-08-02T15:31:58Z, verifying certificate SN=9090122138800116046, SKID=, AKID=41:39:B1:8C:1F:EA:64:08:21:13:11:1A:65:C1:C3:01:17:5C:04:C0 failed: x509: certificate has expired or is not yet valid: current time 2026-08-06T16:04:30Z is after 2026-08-02T15:31:58Z]"
```

-> k3s control plane kube config at `/etc/rancher/k3s/k3s.yaml`



### Claude

 Fix expired kubectl client cert for homelab cluster

 Context

 kubectl from the laptop fails with the server has asked for the client to provide credentials. The k3s API server log on hpmini01 confirms an x509 client cert expired on 2026-08-02. This is not a cluster problem — it's a stale local kubeconfig.

 Root cause (confirmed via investigation):
 - The CA cert fingerprint in the laptop's ~/.kube/config (default cluster entry) matches hpmini01's CA exactly (AC:0F:EA:8D:...:3C:84), so trust/connectivity to the cluster is fine.
 - The laptop's default user entry has client cert serial 7E2699EC7818514E, valid 2025-08-02 → 2026-08-02 — expired 4 days ago, matching the server-side error exactly.
 - hpmini01's /etc/rancher/k3s/k3s.yaml currently contains a different, newer client cert (serial 1E37D84F5B938EE1), valid 2025-08-02 → 2027-04-17. Its file mtime (2026-07-15 17:40) lines up with the last k3s service restart (ActiveEnterTimestamp=2026-07-15 17:40:31).
 - k3s automatically rotates the admin client cert when it's near expiry, but only on service restart — it regenerated a fresh long-lived cert on hpmini01 on 2026-07-15, but the laptop's copy (taken earlier and never refreshed) kept the old cert, which has now genuinely expired.

 Fix: re-copy the current, valid kubeconfig from hpmini01 into the laptop's homelab context, preserving the laptop's external cluster address (192.168.1.231:6443) and all unrelated contexts (AWS EKS, rancher-desktop, etc.) already in ~/.kube/config.


- [x] fixed


---


# K3s Homelab incident


## Where are my pods?? 

You run `kubectl get pods` and instead of a list of your pods you see an error

```bash
E0806 17:53:28.238669   13834 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: the server has asked for the client to provide credentials"
```

Why is that? What happened to my cluster? Are the workloads still running?


## Troubleshooting

### Is the workload running?

I quickly checked that my applications are still running (I can access my web applications in a browser). So the workload is fine, cluster is running. I just can't access the control plane via `kubectl` from my laptop.

### Can I access the cluster directly from the control plane?

Yes! When ssh-ed to my control plane and running `kubectl` it all works fine.

So the problem must be on the client side setup. But wait, I haven't touch the `~/.kube/config` for months. 

### Logs, show me the logs

The original error message is not entirely clear. Let's see more details on that error. 

Directly on the control plane host I run `sudo journalctl -u k3s -f` while trying to `kubectl` again from my laptop. And yes, I see a more detailed log:

```bash
# sudo journalctl -u k3s -f
Aug 06 16:04:30 hpmini01 k3s[1002]: E0806 16:04:30.297247    1002 authentication.go:75] "Unable to authenticate the request" err="[x509: certificate has expired or is not yet valid: current time 2026-08-06T16:04:30Z is after 2026-08-02T15:31:58Z, verifying certificate SN=9090122138800116046, SKID=, AKID=41:39:B1:8C:1F:EA:64:08:21:13:11:1A:65:C1:C3:01:17:5C:04:C0 failed: x509: certificate has expired or is not yet valid: current time 2026-08-06T16:04:30Z is after 2026-08-02T15:31:58Z]"
```

Now I'm getting somewhere. The problem is the expired client certificate!


### Fix

I copied over the the K3s config file

```bash
scp hpmini01:/etc/rancher/k3s/k3s.yaml ~.kube
```

and used the values of `client-certificate-data` and `client-key-data` for my _default_ user in my `~/.kube/config`. `:wq!` and boom, the `kubectl` from my laptop can again access the control plane.

### What has happened

According to [official documentation](https://docs.k3s.io/cli/certificate) on K3s, the client and server certificates are valid for 365 days. Time flies by and indeed, it's been a full year since I installed my control plane.

Worth noting - the Kubernetes issues a Kubernetes Event Warning 120 days before that happens. But I wasn't monitoring it and it slipped down my radar.


### Actions steps

This going to happen again. I want to setup a proper monitoring using Prometheus with some notification system. I happed to buy [Prometheus Certified Associate (PCA) exam](https://training.linuxfoundation.org/certification/prometheus-certified-associate/) As a part of studying for the exam I'll set it up.
