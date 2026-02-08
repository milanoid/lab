### **Module 6: Multi-Container Applications (Guided Project)**

**Goal**: Build a multi-container application using Docker Compose - a dad joke dashboard where one container fetches jokes and another serves them.

## **What We’re Building**

A live dashboard with two containers:

```
┌─────────────────┐         ┌─────────────────┐
│     updater     │         │      nginx      │
│     (bash)      │         │                 │
│                 │         │                 │
│  fetch jokes    │         │   serve HTML    │
│  write HTML ────┼────────▶│                 │
└─────────────────┘         └─────────────────┘
         │                          │
         └──────── /html ───────────┘
              (shared volume)
```

- **updater**: Bash container that fetches dad jokes from an API every 30 seconds
    
- **nginx**: Serves the generated HTML page
    
- **shared volume**: Both containers access the same `/html` directory
    

---

## **6.1 Why Docker Compose?**

So far, we’ve run single containers. But real applications often need multiple containers working together:

- Web server + database
    
- API + cache + worker
    
- Frontend + backend + message queue
    

Managing these with individual `docker run` commands gets painful:

```bash
# Without Compose - messy and error-prone
docker network create myapp
docker volume create mydata
docker run -d --name db --network myapp -v mydata:/var/lib/postgresql/data postgres:16
docker run -d --name api --network myapp -e DATABASE_URL=postgres://db/app myapi:1.0.0
docker run -d --name web --network myapp -p 80:80 nginx:1.28
```

Docker Compose lets you define everything in one file:

```yaml
services:
  db:
    image: postgres:16
    volumes:
      - mydata:/var/lib/postgresql/data
  api:
    image: myapi:1.0.0
    environment:
      - DATABASE_URL=postgres://db/app
  web:
    image: nginx:1.28
    ports:
      - "80:80"

volumes:
  mydata:
```

Then start everything with one command: `docker compose up`

---

## **6.2 Project Setup**

Create a project directory:

```bash
mkdir joke-dashboard && cd joke-dashboard
```

We’ll create three files:

```bash
joke-dashboard/
├── docker-compose.yaml
├── Dockerfile.updater
└── updater
```

---

## **6.3 The Updater Script**

Create `updater`:

```bash
#!/bin/bash
# Fetch dad jokes and update the HTML page

API_URL="https://icanhazdadjoke.com/"
HTML_FILE="/html/index.html"

echo "Starting joke updater..."

while true; do
  # Fetch a random dad joke
  JOKE=$(curl -s "$API_URL" -H "Accept: text/plain")

  # Generate HTML
  cat > "$HTML_FILE" << EOF
<!DOCTYPE html>
<html>
<head>
  <title>Dad Joke Dashboard</title>
  <style>
    body {
      font-family: sans-serif;
      max-width: 600px;
      margin: 50px auto;
      padding: 20px;
      text-align: center;
    }
    .joke {
      font-size: 1.5em;
      margin: 40px 0;
      padding: 20px;
      background: #f0f0f0;
      border-radius: 10px;
    }
    .meta {
      color: #666;
      font-size: 0.9em;
    }
  </style>
</head>
<body>
  <h1>Dad Joke Dashboard</h1>
  <div class="joke">$JOKE</div>
  <p class="meta">Updated: $(date)</p>
  <p class="meta">Refreshes every 30 seconds</p>
</body>
</html>
EOF

  echo "Updated joke: $JOKE"
  sleep 30
done
```

---

## **6.4 The Updater Dockerfile**

Create `Dockerfile.updater`:

```Dockerfile
FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY updater .
RUN chmod +x updater

CMD ["./updater"]
```

---

## **6.5 Docker Compose File**

Create `docker-compose.yaml`:

```yaml
services:
  updater:
    build:
      context: .
      dockerfile: Dockerfile.updater
    volumes:
      - html:/html
    restart: unless-stopped

  web:
    image: nginx:1.28
    ports:
      - "8080:80"
    volumes:
      - html:/usr/share/nginx/html:ro
    restart: unless-stopped

volumes:
  html:
```

---

## **6.6 Run It**

```bash
# Start both containers
docker compose up -d

# View logs
docker compose logs -f

# Check running containers
docker compose ps
```

Open [http://localhost:8080](http://localhost:8080 "http://localhost:8080") in your browser. Refresh after 30 seconds to see a new joke.

### **Useful Commands**

```bash
# Stop everything
docker compose down

# Stop and remove volumes
docker compose down -v

# Rebuild after changes
docker compose up -d --build

# View logs for one service
docker compose logs -f updater

# Execute command in running container
docker compose exec updater bash
docker compose exec web nginx -t
```

---

## **6.7 How It Works**

1. **Docker Compose creates a network** - both containers can talk to each other by service name
    
2. **Creates a shared volume** - `html` volume mounted in both containers
    
3. **Starts updater** - fetches joke, writes HTML to volume
    
4. **Starts nginx** - serves HTML from the same volume
    
5. **Every 30 seconds** - updater fetches new joke, overwrites HTML
    
6. **Browser refresh** - shows new joke
    

### **The Volume Connection**

```
# updater writes here
volumes:
  - html:/html

# nginx reads from here
volumes:
  - html:/usr/share/nginx/html:ro
```

Same volume (`html`), different mount paths. The `:ro` means nginx mounts it read-only.

---

## **6.8 Best Practices: Running as Non-Root**

The simple version above runs both containers as root. This works, but production containers should run as non-root users to limit the impact of security breaches.

### **The Challenge**

Running as non-root with shared volumes is tricky:

- Docker volumes are created with root ownership
    
- Non-root users can’t write to root-owned directories
    
- Both containers need matching user IDs to share files
    

### **The Solution: Init Container Pattern**

Use a one-shot container to fix permissions before the main containers start:

```yaml
services:
  # One-shot container to fix volume permissions
  init:
    image: busybox
    command: chown -R 101:101 /html
    volumes:
      - html:/html

  updater:
    build:
      context: .
      dockerfile: Dockerfile.updater
    user: "101:101"
    volumes:
      - html:/html
    restart: unless-stopped
    depends_on:
      init:
        condition: service_completed_successfully

  web:
    image: nginxinc/nginx-unprivileged:1.28
    ports:
      - "8080:8080"
    volumes:
      - html:/usr/share/nginx/html:ro
    restart: unless-stopped
    depends_on:
      init:
        condition: service_completed_successfully

volumes:
  html:
```

### **Updated Dockerfile**

The Dockerfile also needs updates to follow best practices - multi-stage build and non-root user:

```Dockerfile
# Stage 1: Build/preparation stage
FROM ubuntu:24.04 AS builder

WORKDIR /build
COPY updater .
RUN chmod +x updater

# Stage 2: Runtime stage (minimal image)
FROM alpine:3.21

# Install only runtime dependencies
RUN apk add --no-cache curl ca-certificates bash

# Create non-root user matching UID 101 (nginx-unprivileged default)
RUN addgroup -g 101 appgroup && \
    adduser -u 101 -G appgroup -D appuser

WORKDIR /app

# Copy prepared script from builder stage
COPY --from=builder --chown=appuser:appgroup /build/updater .

USER appuser
CMD ["./updater"]
```

---

## **6.9 Why This Leads to Kubernetes**

Docker Compose is great for:

- Local development
    
- Simple deployments
    
- Single-host applications
    

But it can’t:

- Scale across multiple servers
    
- Automatically restart failed containers on other hosts
    
- Handle rolling updates without downtime
    
- Manage secrets securely
    
- Load balance traffic
    

That’s what Kubernetes does. The concepts you learned here (services, volumes, networking) translate directly to Kubernetes.

---

## **Summary**

- **Docker Compose** manages multi-container applications
    
- **One YAML file** defines all services, volumes, networks
    
- **Shared volumes** let containers exchange data
    
- **Service names** become hostnames for networking
    
- **Non-root containers** require careful permission handling (init container pattern)
    
- **This is the bridge to Kubernetes** - same concepts, more scale
    

---

## **Definitions**

**Docker Compose**: Tool for defining and running multi-container applications using a YAML file.

**Service**: A container definition in Docker Compose. One service = one container type (can be scaled to multiple instances).

**Volume**: Persistent storage shared between containers or preserved across restarts.

**Compose File**: The `docker-compose.yml` file that defines your application’s services, networks, and volumes.

**Init Container**: A container that runs to completion before the main containers start. Used for setup tasks like fixing permissions.

**nginx-unprivileged**: Official nginx image pre-configured to run as non-root (UID 101) on port 8080.

---


# issues


- docker-compose

```bash
docker compose up -d
>>>> Executing external compose provider "/usr/local/bin/docker-compose". Please see podman-compose(1) for how to disable this message. <<<<

[+] Running 0/1
 ⠋ web Pulling                                                                                                                                            0.0s
error getting credentials - err: exec: "docker-credential-osxkeychain": executable file not found in $PATH, out: ``
Error: executing /usr/local/bin/docker-compose up -d: exit status 1
```

```bash
# fix install
brew install docker-credential-helper
```