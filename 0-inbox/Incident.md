After updating ARC https://github.com/milanoid-labs/homelab-cluster/pull/589, the arc-listener in ns `arc-system` is not running.  Without the listener, no runners are starting.



Get status of the helmrelease - 5 min timeout
```bash
flux get helmreleases -n arc-runners

NAME            REVISION        SUSPENDED       READY   MESSAGE
homelab-runners 0.15.0          False           False   Helm upgrade failed for release arc-runners/homelab-runners with chart gha-runner-scale-set@0.15.0: client rate limiter Wait returned an error: rate: Wait(n=1) would exceed context deadline
```


Get flux logs - timeout message again
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



Lesson 1: The timeout is a symptom, not the cause

▎ What was Helm waiting for, and why didn't it become ready?

Hint: Find the resource Helm was waiting on:


```bash
kubectl get all
NAME                                                 AGE    READY   STATUS
helmrelease.helm.toolkit.fluxcd.io/homelab-runners   186d   False   Helm upgrade failed for release arc-runners/homelab-runners with chart gha-runner-scale-set@0.15.0: client rate limiter Wait returned an error: rate: Wait(n=1) would exceed context deadline
```


```bash
kubectl get helmreleases.helm.toolkit.fluxcd.io -o yaml
# or kubectl describe helmreleases.helm.toolkit.fluxcd.io

  status:
    conditions:
    - lastTransitionTime: "2026-10-02T06:37:13Z"
      message: Failed to upgrade after 1 attempt(s)
      observedGeneration: 31
      reason: RetriesExceeded
      status: "True"
      type: Stalled
    - lastTransitionTime: "2026-10-02T06:37:13Z"
      message: 'Helm upgrade failed for release arc-runners/homelab-runners with chart
        gha-runner-scale-set@0.15.0: client rate limiter Wait returned an error: rate:
        Wait(n=1) would exceed context deadline'
      observedGeneration: 31
      reason: UpgradeFailed
      status: "False"
      type: Ready
    - lastTransitionTime: "2026-10-02T06:37:13Z"
      message: 'Helm upgrade failed for release arc-runners/homelab-runners with chart
        gha-runner-scale-set@0.15.0: client rate limiter Wait returned an error: rate:
        Wait(n=1) would exceed context deadline'
      observedGeneration: 31
      reason: UpgradeFailed
      status: "False"
      type: Released
    - lastTransitionTime: "2026-06-18T06:33:40Z"
      message: No drift detected against the cluster state
      observedGeneration: 30
      reason: NoDriftDetected
      status: "False"
      type: Drifted
    failures: 1
    helmChart: arc-systems/arc-runners-homelab-runners
    history:
    - action: upgrade
      apiVersion: v2
      appVersion: 0.15.0
      chartName: gha-runner-scale-set
      chartVersion: 0.15.0
      configDigest: sha256:6d1ca161904290568d72af11d5c798eba14196fa8d6cf1c670e9d1852e572dfe
      digest: sha256:3d5d8362ad10d013da11c40d582f058492e178ba6f047d473939036e9a38df59
      firstDeployed: "2026-02-16T10:29:51Z"
      lastDeployed: "2026-10-02T06:32:11Z"
      name: homelab-runners
      namespace: arc-runners
      status: failed
      version: 42
    - apiVersion: v2
      appVersion: 0.14.2
      chartName: gha-runner-scale-set
      chartVersion: 0.14.2
      configDigest: sha256:6d1ca161904290568d72af11d5c798eba14196fa8d6cf1c670e9d1852e572dfe
      digest: sha256:ca1b838819101a60ac19d6d55644dd97a3a4ef9844582df9e07b8beab34a913e
      firstDeployed: "2026-02-16T10:29:51Z"
      lastDeployed: "2026-10-01T07:50:44Z"
      name: homelab-runners
      namespace: arc-runners
      status: deployed
      version: 41
    - apiVersion: v2
      appVersion: 0.14.2
      chartName: gha-runner-scale-set
      chartVersion: 0.14.2
      configDigest: sha256:0970e9b5db4584a0b8604ac8012d5a5e7d8638bdec3e60bf04db1bb767a55e79
      digest: sha256:ab9bcc820f713b7453cc7df4cd4cf9d9657bc6a8f42413d322ab7e5003e8d605
      firstDeployed: "2026-02-16T10:29:51Z"
      lastDeployed: "2026-09-21T14:14:18Z"
      name: homelab-runners
      namespace: arc-runners
      status: superseded
      version: 40

```


Ask Helm directly


```bash
helm status homelab-runners
NAME: homelab-runners
LAST DEPLOYED: Fri Oct  2 06:32:11 2026
NAMESPACE: arc-runners
STATUS: failed
REVISION: 42
DESCRIPTION: Upgrade "homelab-runners" failed: client rate limiter Wait returned an error: rate: Wait(n=1) would exceed context deadline
RESOURCES:
==> v1/ServiceAccount
NAME                                   AGE
homelab-runners-gha-rs-no-permission   227d

==> v1/Role
NAME                             CREATED AT
homelab-runners-gha-rs-manager   2026-02-16T10:29:52Z

==> v1/RoleBinding
NAME                             ROLE                                  AGE
homelab-runners-gha-rs-manager   Role/homelab-runners-gha-rs-manager   227d


TEST SUITE: None
NOTES:
Thank you for installing gha-runner-scale-set.

Your release is named homelab-runners.
```



Lesson 2: "cannot remediate failed release" means Flux has given up

_exceeded maximum retries_ means Flux used up its retry budget (the default is very small) and now considers this a terminal state. It won't try again on its own, even after you fix the underlying cause. Make a note of this, because you'll need it at the end.



How to fix it

1. Get it running again now: make Flux retry the upgrade, for example:
`flux reconcile helmrelease homelab-runners -n arc-runners --force`
   Helm will recreate the missing AutoscalingRunnerSet. This time the controller is already 0.15.0, so the versions match and a listener pod should appear in arc-systems.
   
2. Stop it happening again: in the runners HelmRelease, add

spec:
  dependsOn:
    - name: arc-controller
      namespace: arc-systems

   Flux will then wait until the controller release is Ready before upgrading the runners.

3. Optional: set `upgrade.remediation.retries: 3`. A second attempt would have fixed this on its own, because by then the controller would already have been on `0.15.0`.