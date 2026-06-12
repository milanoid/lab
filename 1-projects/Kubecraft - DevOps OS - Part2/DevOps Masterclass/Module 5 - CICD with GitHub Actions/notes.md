# Introduction


CI (Continuous Integration) - is our code ready to deploy?

- linting
- testing
- scanning (trivy)

CD (Continuous Deployment) - deploy as safely, quickly & easily as possible

- GitOps

Tools for CI/CD we are going to use - GitHub Actions 

- others GitLab, Azure DevOps ... all using `yaml`
- all are glorified script runners
- event -> action (e.g. a push triggers a script)


# Repository Settings

- [x] delete branch after merging PR
- [x] ruleset _main_ 
      Restrict deletions
      Require PR before merging
      Require status check to pass
- https://github.com/milanoid-labs/milanoid-labs-terraform/pull/6

- [x] add `CODEOWNERS` (to all managed repos)
- https://github.com/milanoid-labs/milanoid-labs-terraform/pull/7



# Code linting with ruff - pre-commit

https://docs.astral.sh/ruff/

install locally `brew install ruff`

```bash
ruff check
All checks passed!
```

2 ways how we going to call it:

1. via pre-commit hook
2. via github workflow

