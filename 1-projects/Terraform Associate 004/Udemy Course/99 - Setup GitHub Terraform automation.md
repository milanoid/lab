

Repo: https://github.com/milanoid-labs/milanoid-labs-terraform

I want to run the tofu via Actions on my self-hosted runners.

- Action to use: https://github.com/marketplace/actions/opentofu-setup-tofu
- GH needs scoped access to AWS S3 bucket where the state is
- Use short-lived tokens via [OIDC](https://docs.github.com/en/actions/concepts/security/openid-connect) (OpenID Connect)


