Pre-requisites

Watch this video until Chapter 5 - 1:13:00 https://youtu.be/RqTEHSBrYFw


# Introduction

- One container, one process - [https://docs.docker.com/build/building/best-practices/#decouple-applications](https://docs.docker.com/build/building/best-practices/#decouple-applications "https://docs.docker.com/build/building/best-practices/#decouple-applications")
- https://12factor.net/concurrency

# Building a Python image with a simple main py

we will create a temporary project to demonstrate the containarization

```bash
# in /src
uv init demo # init a simple python project in flat structure

milan@SPM-LN4K9M0GG7 ~/repos/devops-study-app (module4-python-image-with-a-simple-main-py)
> python3.11 src/demo/main.py
Hello from demo!


milan@SPM-LN4K9M0GG7 ~/repos/devops-study-app (module4-python-image-with-a-simple-main-py)
> uv run src/demo/main.py
Hello from demo!
```


Let's containerize it

Dockerfile

```Dockerfile
FROM python:latest 
WORKDIR /app 
COPY . /app 
CMD ["python", "main.py"]
```

Build image & inspect

```bash
# Build the image
docker build -t demo:01 .

# See what we have
docker image ls

# Inspect it
docker image inspect demo:01
docker history demo:01
```

```bash
milan@SPM-LN4K9M0GG7 ~/repos/devops-study-app/src/demo (module4-python-image-with-a-simple-main-py)
> docker history demo:01
ID            CREATED        CREATED BY                                     SIZE                 COMMENT
d8667a6b90af  3 minutes ago  /bin/sh -c #(nop) CMD ["python", "main.py"]    0B
<missing>     3 minutes ago  /bin/sh -c #(nop) COPY dir:8dedc456111c18b...  6.14kB
b4d76f273457  3 minutes ago  /bin/sh -c #(nop) WORKDIR /app                 0B                   FROM docker.io/library/python:latest
<missing>     32 hours ago   CMD ["python3"]                                0B                   buildkit.dockerfile.v0
<missing>     32 hours ago   RUN /bin/sh -c set -eux;                       for src in idle3...  5.12kB              buildkit.dockerfile.v0
<missing>     32 hours ago   RUN /bin/sh -c set -eux;                                            savedAptMark="$...  79.5MB      buildkit.dockerfile.v0
<missing>     32 hours ago   ENV PYTHON_SHA256=143b1dddefaec3bd2e21e3b8...  0B                   buildkit.dockerfile.v0
<missing>     32 hours ago   ENV PYTHON_VERSION=3.14.6                      0B                   buildkit.dockerfile.v0
<missing>     32 hours ago   RUN /bin/sh -c set -eux;                       apt-get update; ...  19.1MB      buildkit.dockerfile.v0
<missing>     32 hours ago   ENV PATH=/usr/local/bin:/usr/local/sbin:/u...  0B                   buildkit.dockerfile.v0
<missing>     34 hours ago   RUN /bin/sh -c set -ex;                        apt-get update;      ...         653MB       buildkit.dockerfile.v0
<missing>     35 hours ago   RUN /bin/sh -c set -eux;                       apt-get update; ...  196MB       buildkit.dockerfile.v0
<missing>     36 hours ago   RUN /bin/sh -c set -eux;                       apt-get update; ...  60.3MB      buildkit.dockerfile.v0
<missing>     2 days ago     # debian.sh --arch 'arm64' out/ 'trixie' '...  146MB                debuerreotype 0.17
```



Run the container


```bash
> docker run demo:01
Hello from demo!
```

- container started, printed the message and shut down


## Adding layers

```Dockerfile
FROM python:latest

WORKDIR /app

# Add some silly layers
RUN touch file1.txt
RUN echo "hello" > file2.txt
RUN mkdir -p /app/test

COPY . /app

CMD ["python", "main.py"]
```

```bash
# build and inspect
docker build -t demo:02 .

milan@SPM-LN4K9M0GG7 ~/repos/devops-study-app/src/demo (module4-python-image-with-a-simple-main-py)
> docker history demo:02
ID            CREATED         CREATED BY                                     SIZE                 COMMENT
522cf4898971  11 seconds ago  /bin/sh -c #(nop) CMD ["python", "main.py"]    0B
<missing>     11 seconds ago  /bin/sh -c #(nop) COPY dir:1f69bf6e27ac74c...  6.14kB
126382745279  12 seconds ago  /bin/sh -c mkdir -p /app/test                  2.56kB
350312422647  13 seconds ago  /bin/sh -c echo "hello" > file2.txt            3.07kB
8fee1b931379  14 seconds ago  /bin/sh -c touch file1.txt                     3.58kB
b4d76f273457  6 minutes ago   /bin/sh -c #(nop) WORKDIR /app                 0B                   FROM docker.io/library/python:latest
<missing>     32 hours ago    CMD ["python3"]                                0B                   buildkit.dockerfile.v0
<missing>     32 hours ago    RUN /bin/sh -c set -eux;                       for src in idle3...  5.12kB              buildkit.dockerfile.v0
<missing>     32 hours ago    RUN /bin/sh -c set -eux;                                            savedAptMark="$...  79.5MB      buildkit.dockerfile.v0
<missing>     32 hours ago    ENV PYTHON_SHA256=143b1dddefaec3bd2e21e3b8...  0B                   buildkit.dockerfile.v0
<missing>     32 hours ago    ENV PYTHON_VERSION=3.14.6                      0B                   buildkit.dockerfile.v0
<missing>     32 hours ago    RUN /bin/sh -c set -eux;                       apt-get update; ...  19.1MB      buildkit.dockerfile.v0
<missing>     32 hours ago    ENV PATH=/usr/local/bin:/usr/local/sbin:/u...  0B                   buildkit.dockerfile.v0
<missing>     34 hours ago    RUN /bin/sh -c set -ex;                        apt-get update;      ...         653MB       buildkit.dockerfile.v0
<missing>     35 hours ago    RUN /bin/sh -c set -eux;                       apt-get update; ...  196MB       buildkit.dockerfile.v0
<missing>     36 hours ago    RUN /bin/sh -c set -eux;                       apt-get update; ...  60.3MB      buildkit.dockerfile.v0
<missing>     2 days ago      # debian.sh --arch 'arm64' out/ 'trixie' '...  146MB                debuerreotype 0.17
```



# Containerizing our backend package with uv

- [x] add .gitignore + housekeeping https://github.com/github/gitignore
- [x] add .dockerignore

Details on using `uv` in docker https://docs.astral.sh/uv/guides/integration/docker/

```bash
# run it once more using uv
milan@SPM-LN4K9M0GG7 ~/repos/devops-study-app/src/backend (main)
> uv sync --locked --no-editable
Resolved 18 packages in 21ms
Uninstalled 1 package in 2ms
Installed 1 package in 5ms
 ~ study-tracker-backend==0.0.0 (from file:///Users/milan/repos/devops-study-app/src/backend)
 
 
# run
milan@SPM-LN4K9M0GG7 ~/repos/devops-study-app/src/backend (main)
> uv run study-tracker-api
Uninstalled 1 package in 1ms
Installed 1 package in 6ms
2026-06-12 15:39:17,280 - backend.main - INFO - Starting DevOps Study Tracker API
INFO:     Will watch for changes in these directories: ['/Users/milan/repos/devops-study-app/src/backend']
INFO:     Uvicorn running on http://0.0.0.0:22112 (Press CTRL+C to quit)
INFO:     Started reloader process [36470] using StatReload
INFO:     Started server process [36693]
INFO:     Waiting for application startup.
INFO:     Application startup complete.
```

- [x] still works after cleanup


```Dockerfile
FROM python:latest
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

COPY . /app

RUN uv sync --locked --no-editable

CMD ["uv", "run", "study-tracker-api"]
```

```bash
# build & run
TAG=00 && docker build -t backend:$TAG .

docker run backend:$TAG
```


```bash
milan@SPM-LN4K9M0GG7 ~/repos/devops-study-app/src/backend (main)
> docker run backend:$TAG
   Building study-tracker-backend @ file:///app
      Built study-tracker-backend @ file:///app
Uninstalled 1 package in 0.77ms
Installed 1 package in 1ms
2026-06-12 13:48:40,852 - backend.main - INFO - Starting DevOps Study Tracker API
INFO:     Will watch for changes in these directories: ['/app']
INFO:     Uvicorn running on http://0.0.0.0:22112 (Press CTRL+C to quit)
INFO:     Started reloader process [18] using StatReload
INFO:     Started server process [20]
INFO:     Waiting for application startup.
INFO:     Application startup complete.
```

```bash
> docker images
REPOSITORY                                                                                TAG                                      IMAGE ID      CREATED             SIZE
localhost/backend                                                                         00                                       5b06d9501fa5  About a minute ago  1.24 GB
```

- image too large
- needs to be slimmed down



# Scanning image with Trivy

https://trivy.dev/

- vulnerability scanner
- also can detect misconfigurations (IaC), Kubernetes clusters !


TODO

- [ ] use it for my homelab (Kubernetes, IaC scan)


```bash
# install trivy
# (could work by running a container too)
brew install trivy

# scan my image
TAG=00 && trivy image --format table --severity CRITICAL,HIGH backend:$TAG


# truncated
backend:00 (debian 13.5)

Total: 152 (HIGH: 132, CRITICAL: 20)

```



# Reducing image size with base image

let's reduce the size and attack surface


```Dockerfile
#FROM python:latest
FROM python:3.13-slim

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

COPY . /app

RUN uv sync --locked --no-editable

CMD ["uv", "run", "study-tracker-api"]
```


```bash
TAG=01 && docker build -t backend:$TAG .
```


- down from 1.24 GB to 237 MB
```bash
milan@SPM-LN4K9M0GG7 ~/repos/devops-study-app/src/backend (main)
> docker images
REPOSITORY                                                                                TAG                                      IMAGE ID      CREATED            SIZE
localhost/backend                                                                         01                                       8dd29e59f4fb  6 seconds ago      237 MB
localhost/backend                                                                         00                                       5b06d9501fa5  20 minutes ago     1.24 GB
```

- trivy: down from _Total: 152_ to _Total: 10_

```bash
milan@SPM-LN4K9M0GG7 ~/repos/devops-study-app/src/backend (main)                                                                                               > TAG=01 && trivy image --format table --severity CRITICAL,HIGH backend:$TAG

backend:01 (debian 13.5)

Total: 10 (HIGH: 8, CRITICAL: 2)
```

- `--ignore-unfixed` -> Total 0

```bash
TAG=01 && trivy image --format table --severity CRITICAL,HIGH backend:$TAG --ignore-unfixed
```


Another tweak

- [Alpine linux](https://www.alpinelinux.org/)
- [Chainguard images](https://edu.chainguard.dev/) (Free from CVEs, obviously not for free but have free-tier)



```Dockerfile
#FROM python:latest
#FROM python:3.13-slim
FROM python:3.13-alpine

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

COPY . /app

RUN uv sync --locked --no-editable

CMD ["uv", "run", "study-tracker-api"]
```


```bash
TAG=02 && docker build -t backend:$TAG .
```

with Alpine it went down even further - from 237MB to 150 MB

```bash
> docker images
REPOSITORY                                                                                TAG                                      IMAGE ID      CREATED            SIZE
localhost/backend                                                                         02                                       0d126496d191  29 seconds ago     150 MB
localhost/backend                                                                         01                                       8dd29e59f4fb  9 minutes ago      237 MB
localhost/backend                                                                         00                                       5b06d9501fa5  29 minutes ago     1.24 GB
```


0 CVEs in current `python:3.13-alpine` !

```bash
TAG=02 && trivy image --format table --severity CRITICAL,HIGH backend:$TAG
```



# Optimizing the backend Docker image

Implement caching & multi stage builds

- https://docs.docker.com/build/cache/optimize/#use-cache-mounts

```Dockerfile
FROM python:3.13-alpine AS builder


# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Change the working directory to the `app` directory
WORKDIR /app

# Install dependencies in a cache layer. This speeds up build time
RUN --mount=type=cache,target=/root/.cache/uv \
  --mount=type=bind,source=uv.lock,target=uv.lock \
  --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
  uv sync --locked --no-install-project --no-editable

# Copy the project into the intermediate image
COPY . /app

# Sync the project and install it, now that we have access to the source code
RUN --mount=type=cache,target=/root/.cache/uv \
  uv sync --locked --no-editable

FROM python:3.13-alpine

# Copy the environment, but not the source code
COPY --from=builder --chown=app:app /app/.venv /app/.venv

# Run the application
CMD ["/app/.venv/bin/study-tracker-api"]
```


```bash
TAG=03 && docker build -t backend:$TAG
```