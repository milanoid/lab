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

