
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

- Mischa's backend directory with all the files in Kubecraft (Backend code)
- Mischa's stress importance the intro to FastAPI (path params, request body etc.)


