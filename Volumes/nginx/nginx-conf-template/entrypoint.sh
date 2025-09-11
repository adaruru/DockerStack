#!/bin/bash
set -e

# 確定環境變數 NGINX_CONFIG_PROJECT 已設定
if [ -z "$NGINX_CONFIG_PROJECT" ]; then
  echo "[ERROR] NGINX_CONFIG_PROJECT not set"
  exit 1
fi

# 確定環境變數 NGINX_CONFIG_ENV 已設定
if [ -z "$NGINX_CONFIG_ENV" ]; then
  echo "[ERROR] NGINX_CONFIG_ENV not set (Production|Uat|Sit required)"
  exit 1
fi

CONF_SRC="/etc/nginx/templates/default${NGINX_CONFIG_PROJECT}${NGINX_CONFIG_ENV}.conf"
CONF_DST="/etc/nginx/conf.d/default.conf"

if [ ! -f "$CONF_SRC" ]; then
  echo "[ERROR] Config file not found: $CONF_SRC"
  exit 1
fi

# 套用對應的 conf
cp "$CONF_SRC" "$CONF_DST"
echo "[INFO] Using config: $CONF_SRC -> $CONF_DST"

# 先執行一次 cert-sync.sh 確保憑證可用
echo "[INFO] Running initial cert-sync..."
/bin/bash /etc/cert-sync.sh || echo "[WARN] initial cert-sync failed, please check logs"

# 建立 cron 檔案，寫 log
CRON_FILE="/etc/cron.d/cert-sync"
echo "0 3 * * * root /bin/bash /etc/cert-sync.sh" > "$CRON_FILE"
chmod 0644 "$CRON_FILE"
crontab "$CRON_FILE"

echo "[INFO] Cron file created at $CRON_FILE"
echo "[INFO] Cron job logs will be written to $LOG_FILE"

# 啟動 cron
service cron start

# 執行 CMD (例如 nginx)
exec "$@"

# 建立泛用 nginx image，讀取 env 變數，決定使用哪一個 template
# template 必須命名為 default{$NGINX_CONFIG_ENV}{$NGINX_CONFIG_ENV}.conf
# 優點：
#  1.各專案 conf 檔案統一維護在同一個目錄，方便測試修改
#  2.受限於 image 泛用腳本，多專案更新 registary 只需要一個 image，較易管理
# 缺點：
#  1.受限於 image 泛用腳本，需額外判斷服務要不要使用憑證
#  2.受限於 image 泛用腳本，套用新環境要重新打包 image