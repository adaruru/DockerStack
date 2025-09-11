# save at etc/cert-sync.sh
# 每天凌晨 3 點跑一次
# 0 3 * * * /bin/bash /etc/cert-sync.sh >> /var/log/cert-sync.log 2>&1
#!/bin/bash
DOMAIN="*.itsower.com.tw"
API="http://192.168.100.63:9250/health?domain=$DOMAIN"
CERT_API="http://192.168.100.63:9250/cert?domain=$DOMAIN"
TARGET_DIR="/etc/carcare-cert/live"
LOG_FILE="/var/log/cert-sync.log"

# 把 stdout+stderr 同時送到 docker log & log 檔
exec > >(tee -a "$LOG_FILE" >/proc/1/fd/1) 2>&1

echo "[INFO] Checking cert status for domain=$DOMAIN"

resp=$(curl -s "$API")
status=$(echo "$resp" | jq -r .status)

if [ "$status" = "OK" ] || [ "$status" = "WARN" ]; then
    echo "[INFO] Cert status=$status, downloading..."
    rm -f live.zip # 移除舊檔
    mkdir -p "$TARGET_DIR" # 確保目錄存在
    curl -OJ "$CERT_API"
    unzip -o live.zip -d "$TARGET_DIR"

    # 檢查 nginx 是否已啟動
    if pgrep -x "nginx" > /dev/null; then
        echo "[INFO] Reloading nginx to apply new certificate..."
        nginx -s reload || echo "[WARN] nginx reload failed, please check"
    else
        echo "[INFO] nginx is not running yet (first boot), skip reload"
    fi
elif [ "$status" = "ERROR" ]; then
    echo "[ERROR] Certificate expired, manual intervention required!"
else
    echo "[ERROR] Unknown status: $status"
fi
