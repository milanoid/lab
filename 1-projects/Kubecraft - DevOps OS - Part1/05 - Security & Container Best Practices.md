
## 5.1 Why Container Security Matters

Containers provide isolation, but they're not magic:

- they share host kernel
- a vulnerability in an image is a vulnerability in production
- misconfigured containers can expose the host
- running as _root_ in a container is dangerous


There are 2 areas to focus:

1. Image security: What goes INTO your image
2. Runtime security: How containers are RUN

## 5.2 Running as Non-Root

By default, containers run as root. This is a security risk.

```bash
docker run nginx:1.28 whoami
root
```

There are usually "unprivileged" images:

```bash
docker run nginxinc/nginx-unprivileged:1.28 whoami
nginx
```

For custom images, create a user:

```Dockerfile
FROM ubuntu:24.04

RUN apt-get update && apt-get install -y nginx && \
	rm -rf /var/lib/apt/lists/*
# Create a non-root user
RUN useradd --create-home appuser

# Switch to non-root user
USER appuser

CMD ["nginx", "-g", "daemon off;"]
```


```bash
# build
docker build -t my-nginx .

# check user
docker run my-nginx:latest whoami
appuser

# run
docker logs b448121c19b2
2026/02/06 13:42:58 [warn] 1#1: the "user" directive makes sense only if the master process runs with super-user privileges, ignored in /etc/nginx/nginx.conf:1
2026/02/06 13:42:58 [emerg] 1#1: mkdir() "/var/lib/nginx/body" failed (13: Permission denied)

```


## 5.3 Multi-Stage Builds

- to produce smaller, more secure images
- separates build-time dependencies from runtime

```Dockerfile
# Stage 1 - Build
FROM ubuntu:24.04 AS builder
# .... install build tools, generate files ...

# Stage 2 - Runtime
FROM nginx:1.28
COPY --from=builder /build/output /usr/share/nginx/html
```

Example

```bash
# generate-status
#!/bin/bash
# Generate a static HTML status page

cat << EOF
<!DOCTYPE html>
<html>
<head><title>System Status</title></head>
<body>
<h1>System Status</h1>
<p>Generated: $(date)</p>
<p>Hostname: $(hostname)</p>
</body>
</html>
EOF
```

```Dockerfile
# Stage 1: Generate HTML
FROM ubuntu:24.04 AS builder

WORKDIR /build
COPY generate-status .
RUN chmod +x generate-status && ./generate-status > index.html

# Stage 2: Serve with nginx (unprivileged)
FROM nginxinc/nginx-unprivileged:1.28

COPY --from=builder /build/index.html /usr/share/nginx/html/index.html

EXPOSE 8080
```


```bash
# run in detached mode
docker run -d status:latest

# run curl in the container
docker exec beautiful_colden curl -s http://localhost:8080
<!DOCTYPE html>
<html>
<head><title>System Status</title></head>
<body>
<h1>System Status</h1>
<p>Generated: Fri Feb  6 13:55:02 UTC 2026</p>
<p>Hostname: buildkitsandbox</p>
</body>
</html>


# run with exposing port
docker run -d -p 8080:8080 status:latest

# I run the docker in `ssh ubuntu`
# to see it in my browser (Mac):
ssh -L 8080:localhost:8080 ubuntu

# can open in Mac's browser now at:
http://localhost:8080/
```

## Choosing Base Images

`-alpine`, `-slim` or similar are the smaller ones

- alpine is the smallest
- sometimes needs extra packages to install to run an app (`musl libc` not `glibx`)


# 5.5 Best Practices checklist


### Image Security

- use a specific image tag
- run as non-root user
- use multi-stage builds
- choose minimal base image
- don't install unnecessary packages
- scan images for vulnerabilities

### Runtime Security

- Pin versions for base images and packages
- Order instructions from least to most frequently changed
- Combine RUN commands to reduce layers
- Use `.dockerignore` to exclude unnecessary files
- Don't store secrets in images (user runtime injection)
- Add HEALTHCHECKS for production images

## 5.7 Health Checks

```Dockerfile
FROM nginx:1.28

# Install curl for helth checks
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

EXPOSE 80
```

```bash
# docker ps
4785a1624c90   health:latest   "/docker-entrypoint.…"   2 seconds ago    Up 2 seconds (health: starting)   80/tcp                                        modest_lovelace


4785a1624c90   health:latest   "/docker-entrypoint.…"   24 seconds ago   Up 24 seconds (healthy)   80/tcp                                        modest_lovelace
```



## 5.8 Putting It All Together

```bash
milan@ubuntu:~/devops01/status-page$ ls
Dockerfile  generate-page .dockerignore
```


```Dockerfile
# Stage 1: Generate static HTML
FROM ubuntu:24.04 AS builder

WORKDIR /build
COPY generate-page .
RUN chmod +x generate-page && ./generate-page > index.html

# Stage 2: Production nginx (unprivileged - runs as non-root)
FROM nginxinc/nginx-unprivileged:1.28

# Labels
LABEL org.opencontainers.image.source="https://github.com/user/repo"
LABEL org.opencontainers.image.version="1.0.0"

# Copy generated HTML
COPY --from=builder /build/index.html /usr/share/nginx/html/index.html

# Document port (unprivileged nginx uses 8080)
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/ || exit 1
```


```bash
# generate-page
#!/bin/bash
# Generate a status page with system info

cat << EOF
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Server Status</title>
  <style>
    body { font-family: sans-serif; margin: 40px; }
    .status { color: green; }
  </style>
</head>
<body>
  <h1>Server Status</h1>
  <p class="status">Online</p>
  <p>Built: $(date)</p>
  <p>Build Host: $(hostname)</p>
</body>
</html>
EOF
```


```bash
# .dockerignore
.git
*.md
Dockerfile
.dockerignore
```