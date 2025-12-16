# Docker 監控堆疊

完整的 Prometheus + Grafana + Alertmanager 監控解決方案

## 架構組件

- **Prometheus** - 時序資料庫和監控核心 (Port: 9090)
- **Grafana** - 視覺化儀表板 (Port: 3000)
- **Alertmanager** - 告警管理系統 (Port: 9093)
- **Node Exporter** - 主機系統指標監控 (Port: 9100)
- **cAdvisor** - Docker 容器監控 (Port: 8080)

## 快速開始

### 1. 啟動所有服務

```bash
cd Volumes/monitor
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

- 主配置檔: `prometheus/prometheus.yml`
- 告警規則: `prometheus/rules/alert_rules.yml`

### Alertmanager 配置

- 主配置檔: `alertmanager/alertmanager.yml`

支援的通知方式：
- Email (SMTP)
- Slack
- Webhook

請編輯 `alertmanager/alertmanager.yml` 並取消註解相關配置。

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

```
Volumes/monitor/
├── docker-compose.yml          # Docker Compose 配置
├── .env                        # 環境變數 (敏感資訊)
├── .gitignore                  # Git 忽略檔案
├── README.md                   # 說明文件
├── prometheus/
│   ├── prometheus.yml          # Prometheus 主配置
│   └── rules/
│       └── alert_rules.yml     # 告警規則
├── alertmanager/
│   └── alertmanager.yml        # Alertmanager 配置
└── grafana/
    └── provisioning/
        ├── datasources/        # 資料源自動配置
        │   └── prometheus.yml
        └── dashboards/         # Dashboard 自動載入
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

## 參考資源

- [Prometheus 文件](https://prometheus.io/docs/)
- [Grafana 文件](https://grafana.com/docs/)
- [Alertmanager 文件](https://prometheus.io/docs/alerting/latest/alertmanager/)
