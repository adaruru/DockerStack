# Docker 監控堆疊

完整的 Prometheus + Grafana + Alertmanager 監控解決方案

## 架構組件

- **Prometheus** - 時序資料庫和監控核心 (Port: 9090)
- **Grafana** - 視覺化儀表板 (Port: 3000)
- **Alertmanager** - 告警管理系統 (Port: 9093)
- **Node Exporter** - 主機系統指標監控 (Port: 9100)
- **cAdvisor** - Docker 容器監控 (Port: 8080)

## 快速開始

### 0. 部署前準備 (⚠️ 必須執行)

**將 opt 目錄內容上傳到 VM：**

```bash
# 在 monitor 目錄下執行，一次上傳 opt 資料夾內的所有配置
cd Volumes/monitor
scp -r opt/* user@vm:/opt/
```

**在 VM 上創建數據目錄並設置權限：**

```bash
# SSH 登入 VM 後執行
cd /opt

# 創建數據目錄
mkdir -p prometheus-data
mkdir -p alertmanager-data

# 設置權限（重要！）
# Prometheus 和 Alertmanager 使用 UID 65534
chown -R 65534:65534 prometheus-data
chown -R 65534:65534 alertmanager-data

# 配置目錄也需要正確權限（容器需要讀取）
chown -R 65534:65534 prometheus-config
chown -R 65534:65534 alertmanager-config
chown -R 472:472 grafana-config
```

⚠️ **注意**：

- Grafana 數據使用 Docker Named Volume，會自動創建，無需手動建立
- 權限設置非常重要，否則容器無法讀寫數據
- VM 上的最終目錄結構為 `/opt/prometheus-config/`, `/opt/alertmanager-config/`, `/opt/grafana-config/`

### 1. 啟動所有服務

```bash
# 上傳 docker-compose.yml 到 VM
scp docker-compose.yml user@vm:/opt/

# SSH 到 VM 並啟動
ssh user@vm
cd /opt
docker-compose up -d
```

### 2. 檢查服務狀態

```bash
docker-compose ps
```

### 3. 訪問服務

- Grafana: http://localhost:3000
  - 預設帳號: itsower
  - 預設密碼: html5!its
- Prometheus: http://localhost:9090
- Alertmanager: http://localhost:9093
- cAdvisor: http://localhost:8080

## 配置說明

### 環境變數 (.env)

敏感資訊存放在 `.env` 檔案中，請勿提交到版本控制系統。

如需啟用郵件或 Slack 通知，請編輯 `.env` 檔案並取消註解相關設定。

### Prometheus 配置

- 主配置檔: `prometheus-config/prometheus.yml`
- 告警規則: `prometheus-config/rules/alert_rules.yml`

### Alertmanager 配置

- 主配置檔: `alertmanager-config/alertmanager.yml`

支援的通知方式：

- Email (SMTP)
- Slack
- Webhook

請編輯 `alertmanager-config/alertmanager.yml` 並取消註解相關配置。

### Grafana 配置

Grafana 已自動配置 Prometheus 作為資料源。

建議安裝的 Dashboard：

- Node Exporter Full (ID: 1860) - 主機監控
- Docker Container & Host Metrics (ID: 179) - 容器監控
- Prometheus Stats (ID: 3662) - Prometheus 監控

## 告警規則

已配置的告警包括：

**主機告警:**

- CPU 使用率過高 (> 80% / 95%)
- 記憶體使用率過高 (> 80% / 95%)
- 磁碟空間不足 (< 20% / 10%)
- 主機停機

**容器告警:**

- 容器 CPU/記憶體使用率過高
- 容器頻繁重啟
- 重要容器停止運行

**服務告警:**

- Prometheus/Grafana/Alertmanager 停機
- 配置重載失敗
- 目標抓取失敗

## 維護指令

### 查看日誌

```bash
# 查看所有服務日誌
docker-compose logs -f

# 查看特定服務日誌
docker-compose logs -f prometheus
docker-compose logs -f grafana
```

### 重新載入配置

```bash
# Prometheus (支援熱重載)
curl -X POST http://localhost:9090/-/reload

# Alertmanager (支援熱重載)
curl -X POST http://localhost:9093/-/reload

# Grafana 需要重啟
docker-compose restart grafana
```

### 停止服務

```bash
# 停止所有服務
docker-compose down

# 停止並刪除資料卷 (注意：會刪除所有監控資料)
docker-compose down -v
```

### 更新服務

```bash
# 拉取最新映像
docker-compose pull

# 重新啟動服務
docker-compose up -d
```

## 目錄結構

```text
Volumes/monitor/
├── docker-compose.yml              # Docker Compose 配置
├── .env                            # 環境變數 (敏感資訊)
├── .gitignore                      # Git 忽略檔案
├── README.md                       # 說明文件
├── opt/                            # 需上傳到 VM /opt/ 的所有內容
│   ├── prometheus-config/          # Prometheus 配置
│   │   ├── prometheus.yml          # Prometheus 主配置
│   │   └── rules/
│   │       └── alert_rules.yml     # 告警規則
│   ├── alertmanager-config/        # Alertmanager 配置
│   │   └── alertmanager.yml        # Alertmanager 配置
│   └── grafana-config/             # Grafana 配置
    └── provisioning/
        ├── datasources/            # 資料源自動配置
        │   └── prometheus.yml
        └── dashboards/             # Dashboard 自動載入
            └── default.yml
```

## 故障排除

### Prometheus 無法抓取目標

檢查服務是否在同一網路中：

```bash
docker network inspect monitor_monitoring
```

### Alertmanager 無法發送告警

1. 檢查 Alertmanager 配置是否正確
2. 確認 SMTP 或 Webhook 設定是否正確
3. 查看 Alertmanager 日誌：`docker-compose logs alertmanager`

### Grafana 無法連接 Prometheus

確認 Prometheus 服務正常運行：

```bash
curl http://localhost:9090/-/healthy
```

## 安全建議

1. 修改 `.env` 中的預設密碼
2. 限制服務只監聽 localhost (在生產環境)
3. 使用反向代理 (如 Nginx) 並啟用 HTTPS
4. 定期備份 Grafana Dashboard 和 Prometheus 配置

## 配置更新流程

### 更新 Prometheus 配置

當你在本地修改配置後，需要同步到 VM：

```bash
# 1. 上傳更新的配置
scp -r prometheus-config user@vm:/opt/

# 2. 熱重載配置（無需重啟容器）
curl -X POST http://vm-ip:9090/-/reload

# 或透過 docker exec
docker exec prometheus kill -HUP 1
```

### 更新 Alertmanager 配置

```bash
# 1. 上傳配置
scp -r alertmanager-config user@vm:/opt/

# 2. 熱重載
curl -X POST http://vm-ip:9093/-/reload
```

### 更新 Grafana 配置

```bash
# 1. 上傳配置
scp -r grafana-config user@vm:/opt/

# 2. 重啟 Grafana（provisioning 不支援熱重載）
docker-compose restart grafana
```

## 架構設計

1. ✅ `本地依賴配置`和`數據持久化`分離清楚
2. ✅ 統一命名規則 `{service}-config` / `{service}-data`
3. ✅ 使用絕對路徑避免相對路徑問題

### bind mont

區分本地依賴、數據持久化、起始資料

- Prometheus: `/opt/prometheus-config` 和 `/opt/prometheus-data`
- Alertmanager: `/opt/alertmanager-config` 和 `/opt/alertmanager-data`
- Grafana: `/opt/grafana-config` (配置)，`grafana-named-volumes` (數據 - Named Volume)
- 本地依賴: bind mont 全部使用 /opt/{ContainerName}-config
- 數據持久化: bind mont 全部使用 /opt/{ContainerName}-data
- 起始資料: 數據持久化且必須 Named Volume 使用 {ContainerName}-named-volumes, ex: grafana-named-volumes

### Named Volume

不考慮: 除非必要，不然不使用 Named Volume
