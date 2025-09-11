FROM nginx:stable

# 安裝 cron, curl, unzip, jq
RUN apt-get update && apt-get install -y \
    cron curl unzip jq \
    && rm -rf /var/lib/apt/lists/*

# 複製 conf 模板
COPY templates/ /etc/nginx/templates/

# 複製 cert-sync.sh
COPY cert-sync.sh /etc/cert-sync.sh
RUN chmod +x /etc/cert-sync.sh

# entrypoint 腳本 → 負責挑選 conf & 啟動 cron & nginx
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]