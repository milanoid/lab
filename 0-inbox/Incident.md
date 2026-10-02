after updating scaleset-controller https://github.com/milanoid-labs/homelab-cluster/pull/589

The arc-listener in ns `arc-system` is not running.  Without the listener, no runners are starting.


```bash
flux get helmreleases -n arc-runners

NAME            REVISION        SUSPENDED       READY   MESSAGE
homelab-runners 0.15.0          False           False   Helm upgrade failed for release arc-runners/homelab-runners with chart gha-runner-scale-set@0.15.0: client rate limiter Wait returned an error: rate: Wait(n=1) would exceed context deadline
```



```bash
flux logs -n arc-runners
2026-10-02T06:29:58.705Z info HelmRelease/homelab-runners.arc-runners - HelmChart/arc-systems/arc-runners-homelab-runners with SourceRef 'HelmRepository/arc-systems/actions-runner-controller' is in-sync
2026-10-02T06:30:00.617Z info HelmRelease/homelab-runners.arc-runners - release in-sync with desired state
2026-10-02T06:32:08.266Z info HelmRelease/homelab-runners.arc-runners - Configured HelmChart/arc-systems/arc-runners-homelab-runners with SourceRef 'HelmRepository/arc-systems/actions-runner-controller'
2026-10-02T06:32:08.349Z info HelmRelease/homelab-runners.arc-runners - HelmChart 'arc-systems/arc-runners-homelab-runners' is not ready: latest generation of object has not been reconciled
2026-10-02T06:32:10.120Z info HelmRelease/homelab-runners.arc-runners - HelmChart/arc-systems/arc-runners-homelab-runners with SourceRef 'HelmRepository/arc-systems/actions-runner-controller' is in-sync
2026-10-02T06:32:10.322Z info HelmRelease/homelab-runners.arc-runners - release out-of-sync with desired state: release chart changed
2026-10-02T06:32:10.790Z info HelmRelease/homelab-runners.arc-runners - running 'upgrade' action with timeout of 5m0s
2026-10-02T06:37:13.335Z info HelmRelease/homelab-runners.arc-runners - release is in a failed state
2026-10-02T06:37:13.394Z error HelmRelease/homelab-runners.arc-runners - Reconciler error terminal error: exceeded maximum retries: cannot remediate failed release
```