# Multi-stage build (section 17 item 8).
# development: hot-ish dev image used by docker-compose.
# production: minimal runtime with compiled JS only.

FROM node:20-alpine AS base
WORKDIR /app
COPY package.json package-lock.json ./

FROM base AS development
RUN npm ci --no-audit --no-fund
COPY tsconfig.json vitest.config.ts ./
COPY prisma ./prisma
COPY src ./src
RUN npx prisma generate
CMD ["npx", "tsx", "src/main.ts"]

FROM base AS build
RUN npm ci --no-audit --no-fund
COPY tsconfig.json ./
COPY prisma ./prisma
COPY src ./src
RUN npx prisma generate && npx tsc -p tsconfig.json

FROM node:20-alpine AS production
WORKDIR /app
ENV NODE_ENV=production
COPY package.json package-lock.json ./
RUN npm ci --omit=dev --no-audit --no-fund
COPY --from=build /app/dist ./dist
COPY --from=build /app/node_modules/.prisma ./node_modules/.prisma
USER node
CMD ["node", "dist/main.js"]
