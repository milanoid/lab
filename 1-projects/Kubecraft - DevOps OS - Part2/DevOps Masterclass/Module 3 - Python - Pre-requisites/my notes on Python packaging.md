
# Python package formats

https://packaging.python.org/en/latest/discussions/package-formats/

There are two formats on package indicies

1. source distributions, or `sdists` for short (e.g. `pip-23.3.1.tar.gz`)
2. binary distributions, commonly called `wheels` (e.g. `pip-23.3.1-py3-none-any.whl`)

See pypi (Python Package Index) page for pip 23.3.1 - there are both available for downloads https://pypi.org/project/pip/23.3.1/#files


## Source distribution (sdist)

- an archive of the source code in raw form
- a `.tar.gz` archive containing the source code plus an additional special file called `PKG-INFO` (project metadata)
- `pip` falls back to `sdist` if cannot find `wheel`, compiles a `wheel` from it and installs `wheel`



## Binary distribution (wheel)

- contains exactly the files that need to be copied when installing the package
- for pure-Python packages, the difference between `sdists` and `wheels` is not major
- `wheels` should never include tests and documentation, while `sdists` commonly do
- wheel format more complex than sdist
- unlike `sdist` it's a .zip
- supersedes the old format - `eggs`


These were my notes on reading https://packaging.python.org/en/latest/discussions/package-formats/

---

# Introduction to uv
## uv

A package and project manager.

- replaces other tools such as `pip`, `poetry`, `pyenv`, `virtualenv` and others
- installs and manages Python versions
- includes pip-compatible interface
- can manage versioning (do we need release-please?) https://docs.astral.sh/uv/guides/package/#building-your-package
- industry standard


# Python project and packaging
## uv Concepts

### Projects

- help manage Python code spanning multiple files
- https://docs.astral.sh/uv/concepts/projects/

```bash
# create project
uv init 
```

- init creates `pyproject.toml`, `main.py`, `README.md`, `.python-version` and makes it a git directory!
- `pyproject.toml` specified in [PEP-621](https://peps.python.org/pep-0621/)

### Dependencies

- https://docs.astral.sh/uv/concepts/projects/dependencies/

### Packages

- https://docs.astral.sh/uv/concepts/projects/config/
- a Python _Project_ must be built to be installed
- [_packaging_](https://docs.astral.sh/uv/concepts/projects/config/#project-packaging): a way how to distribute python project



# Initialize a package

- https://docs.astral.sh/uv/concepts/projects/init/

- `uv init`
- 2 basic templates - `application` and `libraries`
- by default `uv` will create a project for an application
- `--lib` flag for libraries

## Applications

- web servers, scripts, command-line interfaces ...
- `uv init --app example-app ` or just `uv init example-app`
- it's NOT a _package_ and will not be installed into the environment
- no built system specified

```bash
> uv init example-app
Initialized project `example-app` at `/private/tmp/example-app`

milan@SPM-LN4K9M0GG7 /tmp/example-app (main)
> ls -la
total 32
drwxr-xr-x@  8 milan  wheel   256 Jun 11 14:13 .
drwxrwxrwt  32 root   wheel  1024 Jun 11 14:13 ..
drwxr-xr-x@  9 milan  wheel   288 Jun 11 14:13 .git
-rw-r--r--@  1 milan  wheel   109 Jun 11 14:13 .gitignore
-rw-r--r--@  1 milan  wheel     5 Jun 11 14:13 .python-version
-rw-r--r--@  1 milan  wheel    89 Jun 11 14:13 main.py
-rw-r--r--@  1 milan  wheel   157 Jun 11 14:13 pyproject.toml
-rw-r--r--@  1 milan  wheel     0 Jun 11 14:13 README.md
```


## Packaged Applications

- use-case - a command-line interface that will be published to PyPI or an application with tests in a dedicated directory
- `uv init --package example-pkg`


```bash
# inside src subdirectory!
milan@SPM-LN4K9M0GG7 /tmp/my-uv-packaged-app/src
> uv init --package backend
Initialized project `backend` at `/private/tmp/my-uv-packaged-app/src/backend`

milan@SPM-LN4K9M0GG7 /tmp/my-uv-packaged-app/src
> tree
.
└── backend
    ├── pyproject.toml
    ├── README.md
    └── src
        └── backend
            └── __init__.py

4 directories, 3 files

```

TODO

- [ ] init uv project in https://github.com/milanoid-labs/devops-study-app

## Repository structure

Discussion [To src or not, how do you structure your Python repos?](https://www.skool.com/kubecraft/to-src-or-not-how-do-you-structure-your-python-repos?p=5cf3b24c)

we are creating a _monorepo_ (python, kube files, scripts) 

- python code in `src`



## Initializing a package

```bash
# create src/ dir and in it run uv init
mkdir src/ && cd src/ && uv init --package backend

milan@SPM-LN4K9M0GG7 ~/repos/devops-study-app (main)
> tree
.
└── src
    └── backend
        ├── pyproject.toml
        ├── README.md
        └── src
            └── backend
                └── __init__.py

5 directories, 3 files
```

- `uv init` created the scaffolding for python `3.11` (changed to `3.13` to match Mischa's repo)
- build system changed from `uv` to [hatchling](https://pypi.org/project/hatchling/)


## Backend code walkthrough

dir is `devops-study-app/src/backend/src/backend`


- added _config.py_, _main.py_, _models.py_, _storage.py_

```bash
milan@SPM-LN4K9M0GG7 ~/repos/devops-study-app/src/backend/src (main)
> tree
.
└── backend
    ├── __init__.py
    ├── config.py
    ├── main.py
    ├── models.py
    └── storage.py

2 directories, 5 files
```


- Mischa's backend directory with all the files in Kubecraft (Backend code)
- Mischa's stress importance the intro to FastAPI (path params, request body etc.)

The python code follows [12 Factor app](https://12factor.net/) recommendations.


## Adding dependencies

in `devops-study-app/src/backend`

deps to add: `fastapi`, `uvcorn`, `httpx`

- [x] `uv add fastapi`

errors

```bash
      ValueError: Unable to determine which files to ship inside the wheel using the following heuristics:
      https://hatch.pypa.io/latest/plugins/builder/wheel/#default-file-selection

      The most likely cause of this is that there is no directory that matches the name of your project (study_tracker_backend).

      At least one file selection option must be defined in the `tool.hatch.build.targets.wheel` table, see: https://hatch.pypa.io/latest/config/build/

      As an example, if you intend to ship a directory named `foo` that resides within a `src` directory located at the root of your project, you can define the following:

      [tool.hatch.build.targets.wheel]
      packages = ["src/foo"]
```

fix

- update the `pyproject.toml`:

```toml
[tool.hatch.build.targets.wheel]
packages = ["src/backend"]
```


Success

```bash
> uv add fastapi
Resolved 11 packages in 14ms
      Built study-tracker-backend @ file:///Users/milan/repos/devops-study-app/src/backend
Prepared 1 package in 176ms
Installed 11 packages in 20ms
 + annotated-doc==0.0.4
 + annotated-types==0.7.0
 + anyio==4.13.0
 + fastapi==0.136.3
 + idna==3.18
 + pydantic==2.13.4
 + pydantic-core==2.46.4
 + starlette==1.3.0
 + study-tracker-backend==0.0.0 (from file:///Users/milan/repos/devops-study-app/src/backend)
 + typing-extensions==4.15.0
 + typing-inspection==0.4.2
```


- [x] `uv add uvcorn`

- [x] `uv add httpx`

After running `uv add` the lib is added to `pyproject.toml`:

```toml
dependencies = [
    "fastapi>=0.136.3",
    "httpx>=0.28.1",
    "uvicorn>=0.49.0",
]
```


## Running our backend using uv run


### step is 1 - install it

`uv sync --locked --no-editable`

- install deps from lock file
- `--no-editable` - package
- uses the `.venv` virtual python interpreter (created when running `uv add`?)

```bash
> uv sync --locked --no-editable
Resolved 18 packages in 17ms
      Built study-tracker-backend @ file:///Users/milan/repos/devops-study-app/src/backend
Prepared 1 package in 300ms
Uninstalled 1 package in 0.76ms
Installed 1 package in 1ms
 ~ study-tracker-backend==0.0.0 (from file:///Users/milan/repos/devops-study-app/src/backend)
```


! I don' have th venv activated?

- either activate it
- or run via uv (below)

```bash
milan@SPM-LN4K9M0GG7 ~/repos/devops-study-app/src/backend (main)
> python --version
pyenv: version `3.13' is not installed (set by /Users/milan/repos/devops-study-app/src/backend/.python-version)
pyenv: python: command not found

The `python' command exists in these Python versions:
  3.9.23

Note: See 'pyenv help global' for tips on allowing multiple
      Python versions to be found at the same time.
```



### step 2 run

```bash
uv run study-tracker-api
```


```bash
milan@SPM-LN4K9M0GG7 ~/repos/devops-study-app/src/backend (main)
> uv run study-tracker-api
2026-06-12 09:29:54,323 - backend.main - INFO - Starting DevOps Study Tracker API
INFO:     Will watch for changes in these directories: ['/Users/milan/repos/devops-study-app/src/backend']
INFO:     Uvicorn running on http://0.0.0.0:22112 (Press CTRL+C to quit)
INFO:     Started reloader process [19189] using StatReload
INFO:     Started server process [19249]
INFO:     Waiting for application startup.
INFO:     Application startup complete.
```


```bash
> curl localhost:22112/health
{"status":"healthy"}
```



## Exercise - Set up the frontend

- use python code Frontend code (in Kubecraft)
- similar to what we did for backend, `pythonproject.toml` tweaks might be needed

https://github.com/milanoid-labs/devops-study-app/issues/1

- once done using `cz` close the issue


```bash
milan@SPM-LN4K9M0GG7 ~/repos/devops-study-app/src (JIRA-001-frontend)
> uv init --package frontend
Initialized project `frontend` at `/Users/milan/repos/devops-study-app/src/frontend`
```

```bash
milan@SPM-LN4K9M0GG7 ~/repos/devops-study-app (JIRA-001-frontend)
> tree
.
└── src
    ├── backend
    │   ├── pyproject.toml
    │   ├── README.md
    │   ├── src
    │   │   ├── backend
    │   │   │   ├── __init__.py
    │   │   │   ├── __pycache__
    │   │   │   │   ├── __init__.cpython-313.pyc
    │   │   │   │   ├── config.cpython-313.pyc
    │   │   │   │   ├── main.cpython-313.pyc
    │   │   │   │   ├── models.cpython-313.pyc
    │   │   │   │   └── storage.cpython-313.pyc
    │   │   │   ├── config.py
    │   │   │   ├── main.py
    │   │   │   ├── models.py
    │   │   │   └── storage.py
    │   │   └── data
    │   └── uv.lock
    └── frontend
        ├── pyproject.toml
        ├── README.md
        └── src
            └── frontend
                └── __init__.py

10 directories, 16 files
```

- [x] python files and templates added
- [x] deps `flask`, `requests`
- [ ] `uv sync --locked --no-editable`
- [x] run `uv run study-tracker-frontend`

```bash
milan@SPM-LN4K9M0GG7

~/repos/devops-study-app/src/frontend

(JIRA-001-frontend)

> uv run study-tracker-frontend 2026-06-12 10:58:30,217 - frontend.main - INFO - Starting DevOps Study Timer Frontend * Serving Flask app 'frontend.main' * Debug mode: off 2026-06-12 10:58:32,998 - werkzeug - INFO -

WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.

* Running on all addresses (0.0.0.0) * Running on http://127.0.0.1:22111 * Running on http://192.168.1.158:22111 2026-06-12 10:58:32,999 - werkzeug - INFO -

Press CTRL+C to quit
```

Create a new study session record

via fronted

or 

via backend
```bash
curl -X POST http://localhost:22112/sessions \
    -H "Content-Type: application/json" \
    -d '{"minutes": 30, "tag": "Python packaging 01"}'
```



TODO

- [ ] import repos `devops-study-app` and `devops-study-app-main` to TF/tofu
- [ ] 