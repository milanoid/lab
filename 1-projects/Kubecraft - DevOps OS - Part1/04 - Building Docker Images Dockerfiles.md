first Dockerfile

```bash
mkdir myapp && cd myapp

# greet file
#!/bin/bash
echo "Hello from my container!"
```


```Dockerfile
FROM ubuntu:24.04

WORKDIR /app

COPY greet .

CMD ["./greet"]
```


```bash
# build
docker build -t myapp:1.0.0 .

# run
docker run myapp:1.0.0
Hello from my container!
```

## Core Dockerfile instructions

### FROM
- never use `latest` tag

### RUN
- run command during the build process
- e.g. for installing tools (`apt-get install -y curl`)
- every line represents an image layer

_DO_

```bash
RUN apt-get update && \
	apt-get install -y curl && \
	apt-get clean
```

_DON'T_

```bash
RUN apt-get update
RUN	apt-get install -y curl
RUN	apt-get clean
```


#### Bundling dependencies


```bash
# example of missing deps
docker run --rm ubuntu:24.04 bash -c "
 apt-get update &&
 apt-get install -y --no-install-recommends curl &&
 curl https://example.com
"

# curl errors (missing certs)
curl: (77) error setting certificate file: /etc/ssl/certs/ca-certificates.crt
```


```bash
# adding deps
docker run --rm ubuntu:24.04 bash -c "
 apt-get update &&
 apt-get install -y --no-install-recommends curl ca-certificates &&
 curl https://example.com
"

# curl success
<!doctype html><html lang="en"><head><title>Example Domain</title><meta name="viewport" content="width=device-width, initial-scale=1"><style>body{background:#eee;width:60vw;margin:15vh auto;font-family:system-ui,sans-serif}h1{font-size:1.5em}div{opacity:0.8}a:link,a:visited{color:#348}</style><body><div><h1>Example Domain</h1><p>This domain is for use in documentation examples without needing permission. Avoid use in operations.<p><a href="https://iana.org/domains/example">Learn more</a></div></body></html>
```

### COPY

- copy files from build context into the image

### WORKDIR

### EXPOSE

- it does not publish ports
- servers as documentation which ports app uses
- still need `docker run -p 8080:8080 myapp`

### CMD

- default command
- the command to run when a container starts

### ENTRYPOINT

- like CMD but harder to override
- good for containers that should always run a specific executable

```bash
# backup
#!/bin/bash
case "$1" in
  create) echo "Creating backup..." ;;
  restore) echo "Restoring from backup..." ;;
  list) echo "Listing backups..." ;;
  *) echo "Usage: backup {create|restore|list}" ;;
esac
```

```Dockerfile
# Dockerfile.dbBackup
FROM ubuntu:24.04
WORKDIR /app
COPY backup .
RUN chmod +x backup
ENTRYPOINT ["./backup"]
CMD ["list"]
```

```bash
# build
docker build -f ./Dockerfile.dbBackup -t backup:1.0.0 .

# if no 'run' argument is added use 'list' as defined in CMD
docker run backup:1.0.0
Usage: backup {create|restore|list}

# override the CMD command with `create`
docker run backup:1.0.0 create
Creating backup...

# override entrypoint (from 'backup' to 'bash')
docker run -it --entrypoint bash backup:1.0.0 
```

Rule of thumb

- use `CMD` for the most applications
- user `ENTRYPOINT` when the container IS the command

## Understanding Layers and Caching

- when a layer changes, all subsequent layers rebuild

```Dockerfile
# Bad: Any code change reinstalls packages
COPY . .
RUN apt-get update && apt-get install -y curl jq

# Good: Packages install early, only reinstall when Dockerfile changes
RUN apt-get update && apt-get install -y curl jq
COPY . .
```

- order Dockerfile from least frequently changed to most frequently changed

### history

```bash
docker history backup:1.0.0
IMAGE          CREATED          CREATED BY                                      SIZE      COMMENT
8ddfa4b19f44   31 minutes ago   CMD ["list"]                                    0B        buildkit.dockerfile.v0
<missing>      31 minutes ago   ENTRYPOINT ["./backup"]                         0B        buildkit.dockerfile.v0
<missing>      31 minutes ago   RUN /bin/sh -c chmod +x backup # buildkit       4.1kB     buildkit.dockerfile.v0
<missing>      31 minutes ago   COPY backup . # buildkit                        12.3kB    buildkit.dockerfile.v0
<missing>      2 hours ago      WORKDIR /app                                    8.19kB    buildkit.dockerfile.v0
<missing>      3 weeks ago      /bin/sh -c #(nop)  CMD ["/bin/bash"]            0B
<missing>      3 weeks ago      /bin/sh -c #(nop) ADD file:6089c6bede9eca8ec…   110MB
<missing>      3 weeks ago      /bin/sh -c #(nop)  LABEL org.opencontainers.…   0B
<missing>      3 weeks ago      /bin/sh -c #(nop)  LABEL org.opencontainers.…   0B
<missing>      3 weeks ago      /bin/sh -c #(nop)  ARG LAUNCHPAD_BUILD_ARCH     0B
<missing>      3 weeks ago      /bin/sh -c #(nop)  ARG RELEASE                  0B
```


## 4.5 The Build Context

When you run `docker build`, Docker sends the _build context_ (the directory you specify) to the daemon.

```bash
docker build -t myapp .
#                     * build context is current directory
```


### .dockerignore

Exludes files from the build context.

```.dockerignore
.git/
*.log
.env
Dockerfile
```

- faster builds (less data to send)
- smaller image
- security (don't accidentally include secrets)

## 4.7 Building and Tagging

```bash
# basic build
docker build -t myapp .

# with tag
docker build -t myapp:1.0.0 .
docker build -t myapp:latest .

# multiple tags
docker build -t myapp:1.0.0 -t myapp:latest .
```

### Build arguments

Pass variables at build time:

```Dockerfile
ARG UBUNTU_VERSION=24.04
FROM ubuntu:${UBUNTU_VERSION}

ARG APP_VERSION=1.0.0
ENV APP_VERSION=${APP_VERSION}

docker build --build-arg UBUNTU_VERSION=22.04 --build-arg APP_VERSION=2.0.0 -t myapp .
```

### No cache

Force rebuild all layers:

```bash
docker build --no-cache -t myapp .
```


## 4.8 Tagging best practices


### Use semantic versioning

```bash
docker build -t myapp:1.0.0 .  # points tot the latest 1.0.x 
docker build -t myapp:1 .      # points to the latest 1.x.x
```

### Include git commit

```bash
docker build -t myapp:${git ref-parse --short HEAD}
```


### Never rely on latest

```bash
# Bad - what version is this?
docker pull myapp:latest

# Good - explicit version
docker pull myapp:1.2.3
```

### Tag for container registries

```bash
# Docker Hub
docker build -t username/myapp:1.0.0 .

# Other registries
docker build -t ghcr.io/username/myapp:1.0.0 .
docker build -t registry.example.com/myapp:1.0.0 .
```


## 4.9 Pushing to GitHub Container Registry


- create a new Token (classic) with scope `write:packages` `delete:packages`
- name `containercourse`


```bash
export CR_PAT=ghp_xxxxxxxxxxxxxxxxxxxxxx

# login
echo $CR_PAT | docker login ghcr.io -u milanoid --password-stdin
```

### Tag and Push

Image format: `ghcr.io/OWNER/IMAGE_NAME:TAG`

```bash
# tag local image for ghcr.io
docker tag backup:1.0.0 ghcr.io/milanoid/backup:1.0.0

# push to ghcr
docker push ghcr.io/milanoid/backup:1.0.0
```


### Build and Push

```bash
docker build -t ghcr.io/milanoid/backup:1.0.0 .
docker push ghcr.io/milanoid/backup:1.0.0
```

Pushed images in https://github.com/milanoid?tab=packages - by default it's private.


### Pulling on other machine

```bash
docker pull ghcr.io/milanoid/backup:1.0.0
Trying to pull ghcr.io/milanoid/backup:1.0.0...
Error: internal error: unable to copy from source docker://ghcr.io/milanoid/backup:1.0.0: initializing source docker://ghcr.io/milanoid/backup:1.0.0: Requesting bearer token: received unexpected HTTP status: 403 Forbidden
```

- need to either login (see above) or make the package _public_

## Challenge

**Task**: Containerize a greeting script with configurable messages.

1. Create a directory `greeter`
    
2. Create `greet`:
    
    ```
    #!/bin/bash
    echo "================================"
    echo "  ${GREETING:-Hello}, ${NAME:-World}!"
    echo "  Running in container: $(hostname)"
    echo "================================"
    ```
    
3. Write a Dockerfile that:
    
    - Uses `ubuntu:24.04` as base
        
    - Sets WORKDIR to `/app`
        
    - Copies the script
        
    - Makes it executable
        
    - Sets default ENV values for GREETING and NAME
        
    - Runs the script
        
4. Build as `greeter:2.0.0`
    
5. Run it with default values
    
6. Run it with custom values: `-e GREETING=Welcome -e NAME=Docker`
    
7. Push it to the GitHub Container Registry
    
8. Remove your local image
    
9. Pull the image from the GHCR.
    

**Verify**: You should see different messages based on environment variables.