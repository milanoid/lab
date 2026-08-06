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