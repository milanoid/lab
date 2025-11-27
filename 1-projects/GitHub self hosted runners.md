https://docs.github.com/en/actions/tutorials/use-actions-runner-controller/quickstart

To have a few runners connected to a GitHub repo. Simulate the SP usage.

ARC - Action Runner Controller


Installing the ARC

```bash
NAMESPACE="arc-systems"
helm install arc \
    --namespace "${NAMESPACE}" \
    --create-namespace \
    oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller
Pulled: ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller:0.13.0
Digest: sha256:631c20c333bfcf4af68773928c0e0c5d8d2fbed0683fe77689b45b2c73751c90
NAME: arc
LAST DEPLOYED: Thu Nov 27 16:20:51 2025
NAMESPACE: arc-systems
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
Thank you for installing gha-runner-scale-set-controller.

Your release is named arc.
```

GH repo to use https://github.com/milanoid/fizz-buzz (sample maven/java project)

`GITHUB_PAT` - fine grained just for the repo with `repo` and `admin:org` scopes

### [arc-pat-fine-grained](https://github.com/settings/personal-access-tokens/9964713)

```bash
# I've set GITHUB_PAT with my PAT

INSTALLATION_NAME="arc-runner-set"
NAMESPACE="arc-runners"
GITHUB_CONFIG_URL="https://github.com/milanoid/fizz-buzz"
helm install "${INSTALLATION_NAME}" \
    --namespace "${NAMESPACE}" \
    --create-namespace \
    --set githubConfigUrl="${GITHUB_CONFIG_URL}" \
    --set githubConfigSecret.github_token="${GITHUB_PAT}" \
    oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set
Pulled: ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set:0.13.0
Digest: sha256:8c7de2bc84e9596b1137a48c462a566c828f507707e64dac58675de1e483ac03
NAME: arc-runner-set
LAST DEPLOYED: Thu Nov 27 16:46:19 2025
NAMESPACE: arc-runners
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
Thank you for installing gha-runner-scale-set.

Your release is named arc-runner-set.
```


Check installation

```bash
helm list -A
```

TODO setup runner & test

https://docs.github.com/en/actions/tutorials/use-actions-runner-controller/quickstart#using-runner-scale-sets

