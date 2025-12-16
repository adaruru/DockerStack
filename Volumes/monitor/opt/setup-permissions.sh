#!/bin/bash
# 在 VM 的 /opt 目錄下執行此腳本來設置正確的權限
# 使用方法：cd /opt && sudo bash setup-permissions.sh

echo "==================================="
echo "Docker 監控堆疊權限設置腳本"
echo "==================================="
echo ""

# 檢查是否以 root 執行
if [ "$EUID" -ne 0 ]; then
  echo "❌ 錯誤：請使用 sudo 執行此腳本"
  echo "   sudo bash setup-permissions.sh"
  exit 1
fi

# 檢查是否在 /opt 目錄
if [ "$(pwd)" != "/opt" ]; then
  echo "⚠️  警告：建議在 /opt 目錄下執行此腳本"
  read -p "是否繼續？ (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

# 檢查目錄是否存在
echo "檢查目錄..."

DIRS_TO_CHECK=(
  "prometheus-config"
  "prometheus-data"
  "alertmanager-config"
  "alertmanager-data"
  "grafana-config"
)

for dir in "${DIRS_TO_CHECK[@]}"; do
  if [ ! -d "$dir" ]; then
    echo "⚠️  警告：目錄不存在 $dir"
    read -p "是否創建此目錄？ (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      mkdir -p "$dir"
      echo "✅ 已創建 $dir"
    fi
  fi
done

echo ""
echo "設置 Prometheus 權限..."
chown -R 65534:65534 prometheus-config
chown -R 65534:65534 prometheus-data
echo "✅ Prometheus (UID:65534)"

echo ""
echo "設置 Alertmanager 權限..."
chown -R 65534:65534 alertmanager-config
chown -R 65534:65534 alertmanager-data
echo "✅ Alertmanager (UID:65534)"

echo ""
echo "設置 Grafana 權限..."
chown -R 472:472 grafana-config
echo "✅ Grafana (UID:472)"

echo ""
echo "==================================="
echo "✅ 權限設置完成！"
echo "==================================="
echo ""
echo "目前權限狀態："
ls -la | grep -E "(prometheus|alertmanager|grafana)"
