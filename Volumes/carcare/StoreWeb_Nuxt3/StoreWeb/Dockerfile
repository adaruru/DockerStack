FROM node:20.19.4-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000

RUN corepack enable && corepack prepare pnpm@10.5.0 --activate

# 使用 pipeline build 的 output
COPY ./carcare-storeweb/.output /.output
COPY ./carcare-storeweb/package.json .
COPY ./carcare-storeweb/pnpm-lock.yaml .
# 保留 node_modules 再 runner 執行，避免可能的 runtime error
RUN pnpm install --prod

EXPOSE 3000

CMD ["node", ".output/server/index.mjs"]