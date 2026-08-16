

Repo: https://github.com/milanoid-labs/milanoid-labs-terraform

I want to run the tofu via Actions on my self-hosted runners.

- Action to use: https://github.com/marketplace/actions/opentofu-setup-tofu
- GH needs scoped access to AWS S3 bucket where the state is
- Use short-lived tokens via [OIDC](https://docs.github.com/en/actions/concepts/security/openid-connect) (OpenID Connect)


## Setting up OIDC trust in AWS for GitHub Actions

https://github.com/milanoid-labs/milanoid-labs-terraform/pull/28


```bash
# outputs
apply_role_arn = "arn:aws:iam::268091806187:role/milanoid-labs-terraform-ci-apply" 
plan_role_arn = "arn:aws:iam::268091806187:role/milanoid-labs-terraform-ci-plan"
```


## Setting up OIDC provider in GitHub



