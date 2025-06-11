#!/bin/bash
set -e

# 檢查必要的環境變數是否已設置
if [ -z "$AZP_URL" ]; then
  echo "Error: AZP_URL is not set"
  exit 1
fi

if [ -z "$AZP_TOKEN" ]; then
  echo "Error: AZP_TOKEN is not set"
  exit 1
fi

if [ -z "$AZP_POOL" ]; then
  AZP_POOL=Default
fi

# 清理舊的 Agent（如果存在）
cleanup() {
  echo "Cleaning up Azure DevOps Agent..."
  ./config.sh remove --unattended || true
}
trap cleanup EXIT

# 配置 Agent
echo "1. Configuring Azure DevOps Agent..."
./config.sh --unattended \
    --url "$AZP_URL" \
    --auth pat \
    --token "$AZP_TOKEN" \
    --pool "$AZP_POOL" \
    --agent "${AZP_AGENT_NAME:-$(hostname)}" \
    --replace \
    --acceptTeeEula

# 啟動 Agent
echo "2. Starting Azure DevOps Agent..."
exec ./bin/Agent.Listener run
