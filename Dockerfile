FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm install --omit=dev

COPY src ./src
COPY skill-manifest.json ./

FROM node:20-alpine

WORKDIR /app

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/src ./src
COPY --from=builder /app/skill-manifest.json ./

EXPOSE 3000

ENV NODE_ENV=production

CMD ["node", "src/index.js"]