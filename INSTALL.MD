# Installation Guide – AxAI MySQL Streamer
This document walks you through **two deployment options:**

|Option|When to use|
|------|-----------|
|**A – Separate Docker container** (recommended)|You want isolation, independent scaling, or already run AnythingLLM in its own container.|
|**B – Same container as AnythingLLM**|You have a single-container setup and want to keep everything together (e.g., for a quick demo).|	

Both options share the same environment-variable configuration and use the same source code.

---

## 📋 Prerequisites
|Requirement|Tested version|
|-----------|--------------|
|**Docker Engine**|24.x (or newer)|
|**Docker Compose** (optional)|2.24+|
|**Node.js** – only needed if you want to run locally for development (v20.x)||
|**MySQL Server**|8.x (running on the same Windows host or extern, port 3306), **IMPORTANT: Read-Only User**|
|**AnythingLLM**|Any recent release (running on Docker)|

NOTE – The MySQL server can be on the same host or reachable via the network. The skill container will connect using the credentials you provide in the .env file.

---

## 1️⃣ Clone the Repository
```
git clone https://github.com/kutlusoy/axai-mysql-streamer.git
cd axai-mysql-streamer
```
---

## 2️⃣ Configure Environment Variables
Copy the example file and edit the values to match your MySQL instance.
```
cp .env.example .env
```

|Variable|Description|Example|
|--------|-----------|-------|
|MYSQL_HOST|MySQL host (Docker can resolve host.docker.internal to the Windows host)|host.docker.internal|
|MYSQL_PORT|MySQL port (default 3306)|3306|
|MYSQL_USER|MySQL user with **ONLY SELECT rights**|axai_user|
|MYSQL_PASSWORD|Password for DB_USER|SuperSecret!|
|MYSQL_DATABASE|Default database to use|axai_db|
|SKILL_API_KEY|Secret that AnythingLLM must send with each request|replace_this_with_a_strong_random_string|
|PORT|Port the skill will listen on inside the container|3000|
|LOG_LEVEL|pino log level (debug, info, warn, error)|info|

**Tip:** When you run the container in the same Docker network as AnythingLLM, you can keep **MYSQL_HOST=host.docker.internal**. If you run the MySQL server in a separate container, replace it with the container name (e.g., mysql).

---

## 3️⃣ Choose a Deployment Mode
### Option A – Separate Container (Recommended)
3A.1 3A.1 Docker Compose (quickest)

A ready-made docker-compose.yml is included.

```
version: "3.9"

services:
  anything-llm:
    image: anythingllm/anythingllm:latest
    container_name: anything-llm
    ports:
      - "3001:3001"               # AnythingLLM UI
    environment:
      - NODE_ENV=production
    volumes:
      - ./anything-llm-data:/app/data
    depends_on:
      - axai-mysql-streamer

  axai-mysql-streamer:
    build: .
    container_name: axai-mysql-streamer
    ports:
      - "3000:3000"
    env_file:
      - .env                     # <-- your MySQL credentials go here
    restart: unless-stopped
```

**Steps:**
```
# Build & start the skill
docker compose up -d
```

The service will be reachable at http://localhost:3000 from the host.

3A.2 Manual Docker Build / Run (if you prefer a single command)
```
# Build the image
docker build -t axai-mysql-streamer:latest .

# Run the container
docker run -d \
  --name axai-mysql-streamer \
  -p 3000:3000 \
  --env-file .env \
  axai-mysql-streamer:latest
```

---

### Option B – Inside the Same Container as AnythingLLM
If you already have an AnythingLLM Dockerfile, you can copy the skill’s source into that image and expose the skill on a different internal port (e.g., 3001).

**Typical steps:**

01. Add the skill directory to your AnythingLLM repo (e.g., custom-skills/axai-mysql-streamer).
02. Update the AnythingLLM Dockerfile (or Docker Compose) to copy the skill files and install its dependencies:

```
# Inside the AnythingLLM Dockerfile
COPY ./custom-skills/axai-mysql-streamer /app/custom-skills/axai-mysql-streamer
WORKDIR /app/custom-skills/axai-mysql-streamer
RUN npm ci --omit=dev   # install only production deps
```

03. Expose an extra port (e.g., 3001) in the docker-compose.yml:
```
services:
  anythingllm:
    ports:
      - "3000:3000"   # AnythingLLM UI
      - "3001:3001"   # AxAI MySQL Streamer
```

04. Start the skill as a background process from within the same container (e.g., via a supervisor like pm2 or a simple & in the entrypoint). Example using pm2:
```
# Inside the container, after installing pm2 globally
pm2 start /app/custom-skills/axai-mysql-streamer/src/index.js --name axai-mysql-streamer --watch
```

05. Verify:
```
curl http://localhost:3001/
```

**Caution:** Running both services in the same container makes scaling harder and can obscure logs. Use this approach only for testing or very small deployments.

---

## 4️⃣ Verify the Service
```
curl http://localhost:3000/
# Expected output:
# {"status":"ok","version":"1.0.0"}
```

If you used Option B (same container), replace 3000 with the port you exposed (e.g., 3001).

---

## 5️⃣ Register the Skill in AnythingLLM
01. Open AnythingLLM UI → Settings → Custom Skills.
02. Click “Add New Skill”.
03. Fill in the form:
    - **Skill Name** – AxAI MySQL Streamer (or whatever you set in .env).
    - **Manifest URL** – http://<HOST_OR_IP>:3000/skill-manifest.json
      
      *If you used the same container: http://host.docker.internal:3000/skill-manifest.json*
    - **Endpoint URL** – http://<HOST_OR_IP>:3000/run (same rule as above).
04. Click Save. AnythingLLM will fetch the manifest, list all .sql files found in queries/, and make them callable from chat.

---

## 6️⃣ Adding / Updating Queries
01. Create a new .sql file in the queries/ folder.

*First line can be a comment (-- Description) that will appear as the skill’s description.*
02. No restart needed – the skill watches the folder and automatically reloads the manifest when a new file appears.
03. In AnythingLLM, click “Reload Manifest” (top-right of the Custom Skills page) to make the new action visible instantly.

---

## 7️⃣ Updating the Skill (new version)
01. Pull the latest code:
```
git pull
```

02. Re-build the image (if you use Docker Compose):
```
docker compose build axai-mysql-streamer
docker compose up -d
```
03. The manifest URL stays the same; Nothing else needs to be changed in AnythingLLM.

---

## 8️⃣ Clean-Up
To stop and remove the containers:
```
docker compose down   # if you used compose
# or
docker rm -f axai-mysql-streamer
docker rmi axai-mysql-streamer:latest   # optional
```

---

## 📦 Summary of Commands
|Step|Command (Option A)|Command (Option B)|
|----|------------------|------------------|
|Build image|docker compose build|No separate build|
|Run container|docker compose up -d|docker compose up -d (AnythingLLM) + start skill inside|
|Verify|curl http://localhost:3000/|curl http://localhost:3001/|
|Add query|cp myquery.sql queries/|Same|
|Reload manifest (AnythingLLM)|UI → Reload|UI → Reload|
|Stop & remove|docker compose down|docker compose down (Everything)|

---

## 🙏 Final Remarks
- The skill is deliberately stateless – each request opens a fresh MySQL connection, runs the query, streams results, and closes the connection.
- All configuration lives in .env, making it easy to adapt to different environments (dev, staging, production).
- Because the skill is containerized, you can scale it independently (run multiple replicas behind a reverse proxy) if your LLM starts issuing many concurrent queries.


Enjoy building data-aware LLM experiences with AxAI MySQL Streamer! 🚀