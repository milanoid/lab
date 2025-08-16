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
2. aa