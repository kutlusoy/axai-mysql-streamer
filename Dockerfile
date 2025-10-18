# ──────────────────────────────────────────────────────────────
# AxAI MySQL Streamer – Docker image
# Node 20 (alpine) – small footprint
# ──────────────────────────────────────────────────────────────
FROM node:20-alpine AS builder

# Create app directory
WORKDIR /app

# Install build dependencies
COPY package*.json ./
RUN npm ci --omit=dev

# Copy source code
COPY src ./src
COPY skill-manifest.json ./
COPY .env.example ./env.example

# ---------- Runtime ----------
FROM node:20-alpine

WORKDIR /app

# Copy only what we need from the builder stage
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/src ./src
COPY --from=builder /app/skill-manifest.json ./
COPY --from=builder /app/.env ./

EXPOSE 3000

ENV NODE_ENV=production

CMD ["node", "src/index.js"]
