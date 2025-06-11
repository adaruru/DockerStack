FROM ubuntu:20.04 AS base

WORKDIR /azp/

# 安裝必要工具
RUN apt-get update && apt-get install -y \
    libicu70\    
    curl \
    jq \
    apt-transport-https \
    ca-certificates \
    software-properties-common \
    unzip \
    git \
    docker.io && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 定義需要安裝的 .NET SDK 通道
ENV DOTNET_SDK_CHANNELS="6.0 8.0"

# 安裝 .NET SDK
RUN curl -fsSL https://dot.net/v1/dotnet-install.sh -o dotnet-install.sh && \
    chmod +x dotnet-install.sh && \
    for channel in $DOTNET_SDK_CHANNELS; do \
        ./dotnet-install.sh --channel $channel --install-dir /usr/share/dotnet; \
    done && \
    rm dotnet-install.sh

# 驗證安裝
RUN dotnet --list-sdks

RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# 驗證安裝
RUN dotnet --version && node --version

# 安裝 Azure Pipelines Agent
FROM base AS agent-setup
RUN curl -fsSL https://vstsagentpackage.azureedge.net/agent/3.220.5/vsts-agent-linux-x64-3.220.5.tar.gz | tar -xz -C /azp

# 設定 Azure DevOps Agent 啟動腳本
COPY start.sh .
RUN chmod +x start.sh

# 允許容器內部執行 Docker
VOLUME ["/var/lib/docker"]
RUN usermod -aG docker $(whoami)

# 最終構建階段
FROM agent-setup AS final

# 設定進入點
ENTRYPOINT ["/azp/start.sh"]
ENV TARGETARCH="linux-x64"
# Also can be "linux-arm", "linux-arm64".

WORKDIR /azp/

# 安裝必要工具
RUN apt-get update && apt-get install -y \
    libicu70\    
    curl \
    jq \
    apt-transport-https \
    ca-certificates \
    software-properties-common \
    unzip \
    git \
    docker.io && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 定義需要安裝的 .NET SDK 通道
ENV DOTNET_SDK_CHANNELS="6.0 8.0"

# 安裝 .NET SDK
RUN curl -fsSL https://dot.net/v1/dotnet-install.sh -o dotnet-install.sh && \
    chmod +x dotnet-install.sh && \
    for channel in $DOTNET_SDK_CHANNELS; do \
        ./dotnet-install.sh --channel $channel --install-dir /usr/share/dotnet; \
    done && \
    rm dotnet-install.sh

# 驗證安裝
RUN dotnet --list-sdks

RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# 驗證安裝
RUN dotnet --version && node --version

# 安裝 Azure Pipelines Agent
FROM base AS agent-setup
RUN curl -fsSL https://vstsagentpackage.azureedge.net/agent/3.220.5/vsts-agent-linux-x64-3.220.5.tar.gz | tar -xz -C /azp

# 設定 Azure DevOps Agent 啟動腳本
COPY start.sh .
RUN chmod +x start.sh

# 允許容器內部執行 Docker
VOLUME ["/var/lib/docker"]
RUN usermod -aG docker $(whoami)

# 最終構建階段
FROM agent-setup AS final

# 設定進入點
ENTRYPOINT ["/azp/start.sh"]