FROM node:20-alpine AS builder
WORKDIR /app

RUN corepack enable && corepack prepare pnpm@latest --activate

COPY . .

RUN pnpm install
RUN pnpm build

FROM node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000

RUN corepack enable && corepack prepare pnpm@latest --activate

COPY --from=builder /app/.output .output
COPY --from=builder /app/package.json .
COPY --from=builder /app/pnpm-lock.yaml .
RUN pnpm install --prod

EXPOSE 3000

CMD ["node", ".output/server/index.mjs"]