FROM ubuntu:22.04
ENV TARGETARCH="linux-x64"
# Also can be "linux-arm", "linux-arm64".

# 更新系统和安装基本工具
RUN apt update && \
    apt upgrade -y && \
    apt install -y curl git jq libicu70 apt-transport-https ca-certificates gnupg lsb-release mono-complete
# nuget 依賴工具
RUN DEBIAN_FRONTEND=noninteractive TZ=Asia/Taipei apt install -y mono-complete

# 安裝 docker
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list && \
    apt update && apt install -y docker-ce-cli

# 安裝 Docker Compose
RUN curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

# 定義需要安裝的 .NET SDK 通道
ENV DOTNET_SDK_CHANNELS="6.0"

# 安裝 .NET SDK
RUN curl -fsSL https://dot.net/v1/dotnet-install.sh -o dotnet-install.sh && \
    chmod +x dotnet-install.sh && \
    for channel in $DOTNET_SDK_CHANNELS; do \
        ./dotnet-install.sh --channel $channel --install-dir /usr/share/dotnet; \
    done && \
    rm dotnet-install.sh
# 如果 agent 需要佈署 azure app, container 等服務
# 安裝 Azure CLI
RUN curl -fsSL https://aka.ms/InstallAzureCLIDeb | bash - && \
    apt-get update && \
    apt-get install -y azure-cli

# 設置環境變數
ENV DOTNET_ROOT=/usr/share/dotnet
ENV PATH="$DOTNET_ROOT:$PATH"
# 驗證 .NET SDK 安裝
RUN dotnet --list-sdks

# 安裝 Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# 驗證安裝
RUN dotnet --version && node --version

WORKDIR /azp/

COPY ./start.sh ./
RUN chmod +x ./start.sh

# Create agent user and set up home directory
RUN useradd -m -d /home/agent agent
RUN chown -R agent:agent /azp /home/agent

USER root
ENV AGENT_ALLOW_RUNASROOT="true"

# 确保 Docker CLI 能够正常运行
# USER root
# RUN echo "Agent configured to use Docker CLI."

ENTRYPOINT ["./start.sh"]