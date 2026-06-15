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

turned out not a python version issue but VPN not being connected

- `~/.pip/pip.conf` sets SP Nexus as only source
- enabling VPN helped but other issue

Issue 2 with pre-commit hook - it doesn't run:

```bash
ci(ruff): ruff pre-commit hook should catch this

commitizen check.........................................................Passed ruff.................................................(no files to check)Skipped ruff-format..........................................(no files to check)Skipped [ci/add-ruff-linting c5eafff] ci(ruff): ruff pre-commit hook should catch this 
1 file changed, 1 insertion(+), 1 deletion(-)
```

Claude updated the `.pre-commit-config.yaml` with

```yaml
default_install_hook_types: [pre-commit, commit-msg]
```

and then run `pre-commit install --overwrite`

```bash
> pre-commit install --overwrite 
pre-commit installed at .git/hooks/pre-commit 
pre-commit installed at .git/hooks/commit-msg
```



# Code linting with ruff - GHA

`.github\workflows\backend-tests.yaml`

The workflow was failing on Lint with Ruff:

```bash
```

Needs install the dependency:

```bash
> uv add ruff
Resolved 19 packages in 327ms
      Built study-tracker-backend @ file:///Users/milan/repos/devops-study-app/src/backend
Prepared 2 packages in 645ms
Uninstalled 1 package in 2ms
Installed 2 packages in 2ms
 + ruff==0.15.17
 ~ study-tracker-backend==0.0.0 (from file:///Users/milan/repos/devops-study-app/src/backend)
```

Issue - local ruff linter pass but the ruff in CI fails:

```bash
uv run ruff check --output-format=github --target-version=py313 src tests
uv run ruff format --diff --check --target-version=py313 src tests
shell: /usr/bin/bash -e {0}
env:
	UV_CACHE_DIR: /home/runner/_work/_temp/setup-uv-cache
  
3 files would be reformatted, 2 files already formatted
--- src/backend/config.py
+++ src/backend/config.py
@@ -29,4 +29,3 @@
 CORS_ALLOW_METHODS = parse_list_env("CORS_ALLOW_METHODS")
 CORS_ALLOW_HEADERS = parse_list_env("CORS_ALLOW_HEADERS")
 CORS_ALLOW_CREDENTIALS = os.getenv("CORS_ALLOW_CREDENTIALS", "True").lower() == "true"
-
--- src/backend/models.py
+++ src/backend/models.py
@@ -32,4 +32,3 @@
     sessions_by_tag: Dict[str, int] = Field(
         ..., description="Number of sessions grouped by tag"
     )
-
--- src/backend/storage.py
+++ src/backend/storage.py
@@ -120,4 +120,3 @@
         f"Calculated statistics: {total_minutes} minutes across {len(sessions)} sessions"
     )
     return stats
-
Error: Process completed with exit code 1.

```


# Adding tests to backend code

Tests files in Kubecraft

```toml
# Add to pyproject.toml
[tool.pytest.ini_options]
asyncio_default_fixture_loop_scope = "function"
```
- Seems the above is not needed
```bash
milan@SPM-LN4K9M0GG7 ~/repos/devops-study-app/src/backend (ci/add-ruff-linting)
> tree tests/
tests/
├── __init__.py
├── test_config.py
├── test_main.py
└── test_storage.py

1 directory, 4 files
```

We need to add dependencies

```bash
uv add pytest
```

```bash
# run tests
> uv run pytest

===================================================================== test session starts =====================================================================

platform darwin -- Python 3.13.13, pytest-9.0.3, pluggy-1.6.0 rootdir: /Users/milan/repos/devops-study-app/src/backend configfile: pyproject.toml plugins: anyio-4.13.0

collected 11 items / 1 error

=========================================================================== ERRORS ============================================================================

_____________________________________________________________ ERROR collecting tests/test_main.py _____________________________________________________________

ImportError while importing test module '/Users/milan/repos/devops-study-app/src/backend/tests/test_main.py'.

Hint: make sure your test modules/packages have valid Python names.

Traceback:

/opt/homebrew/Cellar/python@3.13/3.13.13_1/Frameworks/Python.framework/Versions/3.13/lib/python3.13/importlib/__init__.py:88: in import_module

return _bootstrap._gcd_import(name[level:], package, level)

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

tests/test_main.py:2: in <module>

import pytest_asyncio

E ModuleNotFoundError: No module named 'pytest_asyncio'

=================================================================== short test summary info ===================================================================

ERROR

tests/test_main.py !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Interrupted: 1 error during collection !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

======================================================================

1 error

in 0.13s =======================================================================
```

still missing more depedencies


```bash
uv add pytest_asyncio
```


# Running tests in the pipeline

```yaml
      - name: Run Backend Tests
        run: |
          uv run pytest
```

- [x] https://github.com/milanoid-labs/devops-study-app/pull/3

# Test coverage

```bash
# old people do this
git checkout -b ci/add-coverage-testing

# new kids do (switch can change to remote branch too)
git switch -c ci/add-coverage-testing
```

```bash
milan@SPM-LN4K9M0GG7 ~/repos/devops-study-app/src/backend (ci/add-coverage-testing)
> uv run pytest tests/ -v --cov=src/backend --cov-report=xml --cov-fail-under=80
      Built study-tracker-backend @ file:///Users/milan/repos/devops-study-app/src/backend
Uninstalled 1 package in 1ms
Installed 1 package in 1ms
ERROR: usage: pytest [options] [file_or_dir] [file_or_dir] [...]
pytest: error: unrecognized arguments: --cov=src/backend --cov-report=xml --cov-fail-under=80
  inifile: /Users/milan/repos/devops-study-app/src/backend/pyproject.toml
  rootdir: /Users/milan/repos/devops-study-app/src/backend
```

- we are missing another dependency
- `uv add pytest-cov`



Issue with step _Add Coverage PR Comment_

```bash
Error: Resource not accessible by integration - [https://docs.github.com/rest/issues/comments#create-an-issue-comment](https://docs.github.com/rest/issues/comments#create-an-issue-comment)
```

- workflow is trying to write a comment which is not allowed
- we need to enable it in Actions -> General - Workflow permissions - Read and write permissions -> https://github.com/milanoid-labs/milanoid-labs-terraform/pull/8


- [x] https://github.com/milanoid-labs/devops-study-app/pull/4



# Development dependencies

```bash
TAG=05 && docker build -t backend:$TAG .
```

- after we added tests the image size grown from 69.1 MB (tag 04) to 101 MB (tag 05)

```bash
milan@SPM-LN4K9M0GG7 ~/repos/devops-study-app/src/backend (main)
> docker images | grep backend
localhost/backend                                                                         05                                       8a1f23af7e92  8 seconds ago   101 MB
localhost/backend                                                                         04                           a80925cc67ba  26 hours ago    69.1 MB
```

- we were adding dependencies (pytest etc) but into `dependencies` not `dev dependencies`
- these are not needed in runtime

```toml
dependencies = [
    "fastapi>=0.136.3",
    "httpx>=0.28.1",
    "pytest>=9.0.3",
    "pytest-asyncio>=1.4.0",
    "pytest-cov>=7.1.0",
    "ruff>=0.15.17",
    "uvicorn>=0.49.0",
]
```

Fix: remove pytest, pytest-asyncio, pytest-cov, ruff and add them again by:

```bash
uv add pytest pytest-asyncio pytest-cov ruff --dev
```

```toml
[dependency-groups]
dev = [
    "pytest>=9.0.3",
    "pytest-asyncio>=1.4.0",
    "pytest-cov>=7.1.0",
    "ruff>=0.15.17",
]
```

- these won't be in runtime

We also need to update Dockerfile - add `--no-dev`:

```Dockerfile
# Sync the project and install it, now that we have access to the source code
RUN --mount=type=cache,target=/root/.cache/uv \
  uv sync --locked --no-editable --no-dev
```


```bash
TAG=06 && docker build -t backend:$TAG -f Dockerfile.podman.secured

-> back to 69.1 MB
```

- [x] https://github.com/milanoid-labs/devops-study-app/pull/5

# Exercise - Scanning with Trivy

- build the (backend) Docker image in CI and run Trivy on it

https://github.com/aquasecurity/trivy-action

issue on my homelab-runner:

```bash
Run docker build -t docker.io/milanoid-labs/backend:4eaa96b2c14d118a2f301f541ae17bfa763cd805 -f Dockerfile.secured
ERROR: docker: 'docker buildx build' requires 1 argument

Usage:  docker buildx build [OPTIONS] PATH | URL | -

Run 'docker buildx build --help' for more information

```

the same with GH hosted runner? It is.

```bash
ERROR: docker: 'docker buildx build' requires 1 argument
Usage:  docker buildx build [OPTIONS] PATH | URL | -
Run 'docker buildx build --help' for more information
Error: Process completed with exit code 1.
Run docker build -t docker.io/milanoid-labs/backend:4e75dc53e914d0938b427d2ed4c95c8911f85a6a -f Dockerfile.secured
  docker build -t docker.io/milanoid-labs/backend:4e75dc53e914d0938b427d2ed4c95c8911f85a6a -f Dockerfile.secured
  shell: /usr/bin/bash -e {0}

```


- [x] https://github.com/milanoid-labs/devops-study-app/pull/6


# Exercise solution - implementing the frontend

- I skipped that exercise and head over to solution


Install dev deps
```bash
uv add --dev pytest pytest-cov responses
```

Run tests
`uv run pytest tests/ -v --cov=src/frontend --cov-report=xml --cov-fail-under=80`

Update Dockerfile

- add `--no-dev` switch to not add dev deps to runtime

Build image
```bash
TAG=05 && docker build -t fronted:$TAG .
```

Add workflow

- [x] https://github.com/milanoid-labs/devops-study-app/pull/10


# DRY in pipelines


- do not over engineer
- sometimes it's OK to repeat yourself
- more value in having it readable
- applies to one repo, small team etc.
- in large org templates and resuable workflows makes sens



# Automatic versioning


- we want to release frontend and backed app, using tag
- as we have 2 components we could
	  - version them both the same
	  - version them independently (advanced)


We go the advanced way:

- a change in frontend -> release frontend only
- artifact is Docker image in GH Packages



# Automated release creation


- using release-please action https://github.com/googleapis/release-please-action


Why `secrets.GITHUB_TOKEN` (default identity) is not enough for release-please?

- the release please triggers other actions - for that we need custom PAT with correct rights
- see https://github.com/googleapis/release-please-action#github-credentials

```yaml
# release-please.yaml
# Will not trigger other workflows when using GITHUB_TOKEN
# token: ${{ secrets.GITHUB_TOKEN }}
token: "${{ secrets.DEVOPS_STUDY_APP }}"
```

There are multiple ways how Authenticate in GH:

- PAT - `Personal Access Token` - tight to my account
- Deploy Keys - ssh keys added to my GH repo (then e.g. Flux can use to authenticate)
- GitHub Apps - oauth app (advanced)

- we will use both PAT and Deploy Keys in this course

In a corporate environment we should avoid using PAT, prefer other methods.


### PAT DEVOPS_STUDY_APP

1. create PAT (classic) `DEVOPS_STUDY_APP` (saved to Lastpass)
2. make it available in the _devops-study-app_ repo
   - [x] https://github.com/milanoid-labs/milanoid-labs-terraform/pull/9

Rights

- scope: repo
- expire: 90 days



### release please

1. _.github/workflows/release-please.yaml_ - Action
2. _.release-please-config.json_
3. _.release-please-manifest.json_

```json
// release-please-config.json_
{
  "packages": {
    "src/backend": {
      "release-type": "python",
      "package-name": "study-tracker-backend",
      "component": "backend",
      "include-component-in-tag": true,
      "changelog-path": "CHANGELOG.md",
      "extra-files": [
        {
          "type": "toml",
          "path": "uv.lock",
          "jsonpath": "$.package[?(@.name.value=='study-tracker-backend')].version"
        }
      ]
    }
  }
}
```

- the extra-files are important here
- w/o the `uv sync` would be out-of-sync (?)
- updates the version in `pyproject.yaml` and also in `uv.lock`


```json
// ./.release-please-manifest.json
{
  "src/backend": "0.0.0"
}
```

- starting point
- first run won't read it from `pyproject` - we need to specify it here


Pre-commit hook issue workaround - `--no-verify`

- `git commit -m "ci(gha): Add release-please Action" --no-verify`
- the pre-commit hook has hanged

- [x] https://github.com/milanoid-labs/devops-study-app/pull/12
- [x] first release https://github.com/milanoid-labs/devops-study-app/pull/13

Issue:


- https://github.com/milanoid-labs/devops-study-app/actions/runs/27492187635/job/81259371476?pr=13
```bash
Run uv sync --locked --dev

Using CPython 3.13.14

Creating virtual environment at: .venv

Resolved 27 packages in 766ms

The lockfile at `uv.lock` needs to be updated, but `--locked` was provided. To update the lockfile, run `uv lock`.

Error: Process completed with exit code 1.
```

fixed by running `uv sync` and push the `uv.lock` file to the release-please PR.



# Building and pushing images

## Building and pushing the images to the ghcr

https://github.com/docker/build-push-action

- [x] https://github.com/milanoid-labs/devops-study-app/pull/16
- [x] release-please https://github.com/milanoid-labs/devops-study-app/pull/17


Issue

- any new release-please PR is failing on Backend Tests
- maybe it fails right after merging in the app code change PR to main, e.g. https://github.com/milanoid-labs/devops-study-app/pull/16
- I need to locally run `uv sync` and push the updated `uv.lock` manually
- e.g. https://github.com/milanoid-labs/devops-study-app/pull/20

- [ ] fix