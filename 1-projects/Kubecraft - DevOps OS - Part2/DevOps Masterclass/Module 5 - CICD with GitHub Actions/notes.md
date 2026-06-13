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

