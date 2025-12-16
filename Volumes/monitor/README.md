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
mkdir -p /opt/prometheus-data
mkdir -p /opt/alertmanager-data

# 設置權限（重要！）
# Prometheus 和 Alertmanager 使用 UID 65534
chown -R 65534:65534 /opt/prometheus-data
chown -R 65534:65534 /opt/alertmanager-data

# 配置目錄也需要正確權限（容器需要讀取）
chown -R 65534:65534 /opt/prometheus-config
chown -R 65534:65534 /opt/alertmanager-config
chown -R 472:472 /opt/grafana-config
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

## 維護問題

### ❌ **主要缺點**

### 1. **混合使用 Bind Mount 策略 - 不一致且容易混淆**

**問題**：

- **配置文件**：使用絕對路徑 `/var/{service}-config` (在 VM 上)
- **數據文件**：也使用絕對路徑 `/var/{service}-data` (在 VM 上)
- **Grafana 數據**：使用 Named Volume `grafana-data`

**缺點**：

```yaml
# Prometheus - 全用絕對路徑
- /var/prometheus-config:/etc/prometheus      # ✅ 絕對路徑
- /var/prometheus-data:/prometheus           # ✅ 絕對路徑

# Grafana - 混合策略
- grafana-data:/var/lib/grafana              # ⚠️ Named Volume
- /var/grafana-config:/etc/grafana/provisioning  # ✅ 絕對路徑
```

**影響**：

- 不一致性導致維護困難
- Grafana 數據無法輕鬆備份/遷移（需要用 `docker volume` 命令）
- 無法直接從主機訪問 Grafana 資料庫文件

------

### 2. **在 Windows 上完全無法運行**

**問題**：

```yaml
node_exporter:
  volumes:
    - /proc:/host/proc:ro      # ❌ Windows 上不存在
    - /sys:/host/sys:ro        # ❌ Windows 上不存在
    
cadvisor:
  volumes:
    - /:/rootfs:ro             # ❌ Windows 路徑不同
    - /var/lib/docker/:/var/lib/docker:ro  # ❌ Windows Docker Desktop 路徑不同
```

**你現在的環境是 Windows (`win32`)**，這些服務根本無法啟動。

### 3. **路徑命名衝突風險**

**問題**：

```
/var/prometheus-config
/var/prometheus-data
/var/alertmanager-config
/var/alertmanager-data
/var/grafana-config
```

`/var/` 是系統目錄，直接在下面創建這麼多目錄：

- 可能與系統文件衝突
- 權限問題（需要 root 權限）
- 不符合 Linux 文件系統慣例

**更好的做法**：

```
/opt/monitor/prometheus-config
/opt/monitor/prometheus-data
# 或
/data/monitor/...
```

------

### 4. **缺少權限管理**

**問題**：

- Prometheus 容器內運行用戶是 `nobody` (UID 65534)
- Grafana 容器內運行用戶是 `grafana` (UID 472)
- 直接掛載 `/var/xxx` 會遇到權限問題

**你沒有在配置中處理**：

```yaml
# 缺少這些
user: "1000:1000"  # 或適當的 UID
# 或需要手動 chown
```

------

### 5. **部署步驟複雜且容易出錯**

**當前流程**：

1. 手動 `scp` 上傳 3 個配置目錄
2. 手動 SSH 到 VM 創建 2 個數據目錄
3. 手動設置權限（README 沒寫）
4. 然後才能 `docker-compose up`

**風險**：

- 忘記上傳某個目錄 → 容器啟動失敗
- 權限錯誤 → 容器無法寫入數據
- 路徑打錯 → 難以排查

------

### 6. **配置更新流程不清楚**

**問題**：

- 本地修改配置後，如何同步到 VM？
- 需要再次 `scp` 嗎？
- 如何觸發 Prometheus 熱重載？

README 沒有說明配置更新流程。

------

### 7. **缺少權限的 console_libraries 和 consoles**

**Prometheus 配置**：

```yaml
command:
  - '--web.console.libraries=/etc/prometheus/console_libraries'
  - '--web.console.templates=/etc/prometheus/consoles'
```

但你的 `prometheus-config/` 目錄下可能沒有這些文件夾，會導致警告或錯誤。

### 8. **Grafana provisioning 路徑錯誤**

```yaml
- /var/grafana-config:/etc/grafana/provisioning
```

但實際本地結構是：

```
grafana-config/
└── provisioning/
    ├── datasources/
    └── dashboards/
```

應該掛載：

```yaml
- /var/grafana-config/provisioning:/etc/grafana/provisioning
```

或者改成：

```yaml
- /var/grafana-config:/etc/grafana
```

------

## ✅ **優點**

1. ✅ 配置和數據分離清楚
2. ✅ 統一命名規則 `{service}-config` / `{service}-data`
3. ✅ 使用絕對路徑避免相對路徑問題
4. ✅ README 有詳細部署說明

------

## 💡 **建議改進方案**

### 方案 A：全部改用相對路徑（推薦）

適合在本地或單一 VM 部署：

```yaml
volumes:
  - ./prometheus-config:/etc/prometheus
  - ./prometheus-data:/prometheus
```

### 方案 B：統一絕對路徑到專用目錄

```yaml
volumes:
  - /opt/docker/monitor/prometheus-config:/etc/prometheus
  - /opt/docker/monitor/prometheus-data:/prometheus
```

### 方案 C：全部改用 Named Volume

最 Docker 化的方式：

```yaml
volumes:
  - prometheus-config:/etc/prometheus
  - prometheus-data:/prometheus
```

然後用 Docker 命令管理。

------

## 🎯 **最關鍵的問題**

**你需要立即解決的**：

1. **Grafana 掛載路徑** - 確認是掛載 `/var/grafana-config` 還是 `/var/grafana-config/provisioning`
2. **權限處理** - 在 README 中說明需要設置權限
3. **路徑位置** - 考慮改用 `/opt/` 或 `/data/` 而非 `/var/`
