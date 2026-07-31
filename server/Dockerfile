# Multi-stage build (section 17 item 8).
# development: hot-ish dev image used by docker-compose.
# production: minimal runtime with compiled JS only.

FROM node:20-alpine AS base
WORKDIR /app
COPY package.json package-lock.json ./

FROM base AS development
RUN npm ci --no-audit --no-fund
COPY tsconfig.json vitest.config.ts prisma.config.ts ./
COPY prisma ./prisma
COPY src ./src
RUN npx prisma generate
CMD ["npx", "tsx", "src/main.ts"]

FROM base AS build
RUN npm ci --no-audit --no-fund
COPY tsconfig.json tsconfig.build.json prisma.config.ts ./
COPY prisma ./prisma
COPY src ./src
RUN npx prisma generate && npx tsc -p tsconfig.build.json

FROM node:20-alpine AS production
WORKDIR /app
ENV NODE_ENV=production
COPY package.json package-lock.json ./
# Prisma runs once at deploy time to create/update the schema. Keep its CLI
# available in the runtime image; the application still runs as the unprivileged
# `node` user afterwards.
RUN npm ci --no-audit --no-fund
COPY prisma.config.ts ./
COPY prisma ./prisma
COPY --from=build /app/dist ./dist
# Prisma 7 writes the generated client into @prisma/client itself (v6 used
# node_modules/.prisma). Copying the stale path would leave the runtime
# with the package but none of the generated code.
COPY --from=build /app/node_modules/.prisma ./node_modules/.prisma
COPY --from=build /app/node_modules/@prisma/client ./node_modules/@prisma/client
USER node
CMD ["node", "dist/main.js"]
