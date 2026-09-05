

Repo: https://github.com/milanoid-labs/milanoid-labs-terraform
Doc: https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-aws

I want to run the tofu via Actions on my self-hosted runners.

- Action to use: https://github.com/marketplace/actions/opentofu-setup-tofu
- GH needs scoped access to AWS S3 bucket where the state is
- Use short-lived tokens via [OIDC](https://docs.github.com/en/actions/concepts/security/openid-connect) (OpenID Connect)


## Setting up OIDC trust in AWS for GitHub Actions

- [x] https://github.com/milanoid-labs/milanoid-labs-terraform/pull/28


```bash
# outputs
apply_role_arn = "arn:aws:iam::268091806187:role/milanoid-labs-terraform-ci-apply" 
plan_role_arn = "arn:aws:iam::268091806187:role/milanoid-labs-terraform-ci-plan"
```


## Setting up OIDC provider in GitHub


https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-aws#updating-your-github-actions-workflow


- [x] https://github.com/milanoid-labs/milanoid-labs-terraform/pull/29



## GitHub Actions

Action [https://github.com/aws-actions/configure-aws-credentials](https://github.com/aws-actions/configure-aws-credentials/releases/tag/v6.2.3)

The terraform variables needed to be available in GH

1. nexus pass/user -> milanoid-labs-terraform repo added to the scoped
2. github token (which interacts via the github provider with GH API) - new one `milanoid-labs-terraform-ci`
3. DEVOPS_STUDY_APP add to repo scope


```bash
# add repo secrets, it prompts for password 
gh secret set TF_ADMIN_GITHUB_TOKEN --repo milanoid-labs/milanoid-labs-terraform
gh secret set TF_VAR_devops_study_app_pat --repo milanoid-labs/milanoid-labs-terraform
```



### Workflow for plan and apply

https://github.com/milanoid-labs/milanoid-labs-terraform/pull/30

#### version mismatch issue

locally I had tofu `1.12.5`, in CI is set `1.12.2`. The CI already planned something. 

```bash
# install tofuenv, might need to uninstall tofu first
brew install tofuenv

# swithc to correct version
tofuev use 1.12.2

tofu init -reconfigure
```


Test PR (plan) https://github.com/milanoid-labs/milanoid-labs-terraform/pull/31
Tofu applied https://github.com/milanoid-labs/milanoid-labs-terraform/actions/runs/31945886063