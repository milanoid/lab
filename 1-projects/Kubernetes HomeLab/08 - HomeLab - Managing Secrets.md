I want to have my GitOps repo public. At the same time I want to do manual steps as little as possible.

Manual step from the chapter 07 - creating a Kubernetes secret (with Cloudflare secret)

```bash
kubectl create secret generic tunnel-credentials --from-file=credentials.json=.cloudflared/cf838265-1863-4c1b-a710-f8bb9fbf038b.json
```


## Managing Kubernetes secrets with SOPS

```bash
# install tooling (age is like gpg but newer?)
pacman -S sops age
```
- `sops` - encrypted file editor with AWS KMS, GCP KMS, Azure Key Vault, age, and GPG support
- `age` - simple, modern, and secure file encryption

1. creating `age` key (save it to password manager!)
   
```bash
# generate private/public keys
age-keygen -o age.agekey
Public key: age1jnfhet7cj900tg9f0dwgqktjwux4km4hen8gnevpujm5260sayesujm92y
```
   
2. encrypting secret using `age`
   
```bash
kubectl create secret generic test-secret \
--from-literal=user=admin \
--from-literal=password=mischa \
--dry-run=client \
-o yaml > test-secret.yaml
```

```bash
# sensitive data in base64 (readable)
milan@jantar:~/repos/homelab-cluster (main)$ kubectl create secret generic test-secret \
--from-literal=user=admin \
--from-literal=password=mischa \
--dry-run=client \
-o yaml
apiVersion: v1
data:
  password: bWlzY2hh
  user: YWRtaW4=
kind: Secret
metadata:
  creationTimestamp: null
  name: test-secret
```
3. export the `age` public key to an environment variable

```bash
export AGE_PUBLIC=age1jnfhet7cj900tg9f0dwgqktjwux4km4hen8gnevpujm5260sayesujm92y
```

4. using `sops` encrypt the sensitive data
   
- using `age` public key encrypt the data
- only owner of the private key can decrypt, hence putting the encrypted version to GH is OK 

```bash
sops --age=$AGE_PUBLIC --encrypt --encrypted-regex '^(data|stringData)$' --in-place test-secret.yaml
```

```bash
# ecrypted versuionn save to be put in GH
milan@jantar:~/repos/homelab-cluster (main)$ cat test-secret.yaml
apiVersion: v1
data:
    password: ENC[AES256_GCM,data:tkXWLLqp3ow=,iv:rTUDI8pgKzNOklByUAOb6t3Q6nR4txUWHGFcS0cbu0s=,tag:LHW5/Psei7/RHNm/Hncnzg==,type:str]
    user: ENC[AES256_GCM,data:PFchCF+f46c=,iv:MScyQnVTRg3bLxpX37dd1PtYK0cbyjzIZQz5hHX4Lgc=,tag:jug71d65NGM+EP5xmarspw==,type:str]
kind: Secret
metadata:
    creationTimestamp: null
    name: test-secret
sops:
    age:
        - recipient: age1jnfhet7cj900tg9f0dwgqktjwux4km4hen8gnevpujm5260sayesujm92y
          enc: |
            -----BEGIN AGE ENCRYPTED FILE-----
            YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0+IFgyNTUxOSBDM3NydmdyWnBuUVlUZllp
            SW5NYWZtWW9Ic2VKaDUzYWh0UGtrc043L0VVCnk3eFpKZXRsQUpuT0R4Z1hxZjBU
            V2tXT05iOU1kVUlUWVhFb3FGcXBuZjgKLS0tIDllbnBCbld6cGliQUxLaHVBZzE5
            MWdNYUZDWU0xb3BDWTRHRFZtY24wU0EKqWTxEf3wurpiLckoLyHBBhxs6enaqFa9
            FPYc8GJomCpNw2Xq+NeWbTBa5+ug0D5nPqI+HQwWOVAzq4FE4Q5BeQ==
            -----END AGE ENCRYPTED FILE-----
    lastmodified: "2025-08-16T15:20:05Z"
    mac: ENC[AES256_GCM,data:7s4Pplr/OLp+qd8f/tbh7gof8QjQXxEH0mCucWNXlqP/BWVA6okXhtEuUCwv7IpR/pizSTknG/LkrLRw5fABxy5QYe6nqPwRCQltOZuaDZUY8eviAGzXAqxtNtuCf28TSqrC40yElWjvnCNcoJAOA2n0wJepcae2m7scaBBp0U4=,iv:jmOHnv0E6piGx8mhpKOFDxCyY980rWCfOjCZWalnetw=,tag:JfvMxxpbgOO8QGe+4C6Jhg==,type:str]
    encrypted_regex: ^(data|stringData)$
    version: 3.10.2
```

5. Add the private key to the cluster

```bash
cat age.agekey |
kubectl create secret generic sops-age \
--namespace=flux-system \
--from-file=age.agekey=/dev/stdin
```

```bash
milan@jantar:~ ()$ kubectl --namespace=flux-system get secrets
NAME          TYPE     DATA   AGE
flux-system   Opaque   3      12d
sops-age      Opaque   1      26s
```

! vim trick: `:r! cat age.agekey` - run shell script and insert the string

```bash
# crate sops.yaml in clusters/staging and age public key
creation_rules:
  - path_regex: .*.yaml
    encrypted_regex: ^(data|stringData)$
    age: age1jnfhet7cj900tg9f0dwgqktjwux4km4hen8gnevpujm5260sayesujm92y
```

pushing it all to git:

```bash
milan@jantar:~/repos/homelab-cluster (main)$ tree
.
├── apps
│   ├── base
│   │   └── linkding
│   │       ├── deployment.yaml
│   │       ├── kustomization.yaml
│   │       ├── namespace.yaml
│   │       ├── service.yaml
│   │       └── storage.yaml
│   └── staging
│       └── linkding
│           ├── cloudflare.yaml
│           ├── kustomization.yaml
│           └── test-secret.yaml
├── clusters
│   └── staging
│       ├── apps.yaml
│       ├── flux-system
│       │   ├── gotk-components.yaml
│       │   ├── gotk-sync.yaml
│       │   └── kustomization.yaml
│       └── sops.yaml
└── README.md
```


```bash
flux logs
2025-08-16T15:53:10.219Z error Kustomization/apps.flux-system - Reconciliation failed after 158.297856ms, next try in 1m0s Secret/linkding/test-secret is SOPS encrypted, configuring decryption is required for this secret to be reconciled
2025-08-16T15:53:23.822Z error Kustomization/apps.flux-system - Reconciliation failed after 176.22762ms, next try in 1m0s Secret/linkding/test-secret is SOPS encrypted, configuring decryption is required for this secret to be reconciled
```