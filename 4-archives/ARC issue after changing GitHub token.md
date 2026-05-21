
After changing GH token (or adding GH App) the listeners kept failing:

```bash
Application returned an error: failed to create actions message session client: failed to create message session: failed to do the session request: request POST https://broker.actions.githubusercontent.com/rest/_apis/runtime/runnerscalesets/6/sessions?api-version=6.0-preview failed(status="404 Not Found", github_request_id="..."): unexpected status code 404 Not Found: GitHub.Actions.Runtime.WebApi.RunnerScaleSetNotFoundException, GitHub.Actions.Runtime.WebApi: No runner scale set found with identifier 6.
```


# Fix

1. Delete the AutoscalingRunnerSet (cascades and clears all derived state including the stale ID)

```bash
kubectl delete autoscalingrunnerset homelab-runners -n arc-runners
```

2. Let Flux recreate it fresh

```
flux reconcile helmrelease homelab-runners -n arc-runners
```

 That's it. The key insight is that deleting just the _AutoscalingListener_ or the HelmRelease wasn't enough — the controller kept regenerating the listener with the same cached ID. Deleting the AutoscalingRunnerSet is the root resource; everything else (listener, ephemeral runner sets) is derived from it, so they all get recreated clean.
