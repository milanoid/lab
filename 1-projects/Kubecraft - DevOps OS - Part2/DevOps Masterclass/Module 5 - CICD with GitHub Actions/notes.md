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


with pre-commit hook

```yaml
repos:
  - repo: https://github.com/commitizen-tools/commitizen
    rev: v1.17.0
    hooks:
      - id: commitizen
        stages: [commit-msg]
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.11.7
    hooks:
      # Run the linter.
      - id: ruff
      # Run the formatter.
      - id: ruff-format
```

- introduce python code syntax error, e.g. `import` -> `immport`
- try to commit

An issue with running ruff as pre-commit hook on my Macbook:

- maybe this is the reason why to use devcontainers :)

```bash
pre-commit version: 4.6.0
git --version: git version 2.54.0
sys.version:
    3.14.5 (main, May 10 2026, 10:21:34) [Clang 21.0.0 (clang-2100.0.123.102)]
sys.executable: /opt/homebrew/Cellar/pre-commit/4.6.0/libexec/bin/python3.14
os.name: posix
sys.platform: darwin

------
ERROR: Could not find a version that satisfies the requirement setuptools>=40.8.0 (from versions: none)

ERROR: No matching distribution found for setuptools>=40.8.0

[end of output]

note: This error originates from a subprocess, and is likely not a problem with pip.

ERROR: Failed to build 'file:///Users/milan/.cache/pre-commit/repovfdvuwn_' when installing build dependencies

Check the log at /Users/milan/.cache/pre-commit/pre-commit.log
```