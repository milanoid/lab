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


### Bundling dependencies


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

