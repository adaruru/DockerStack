FROM mcr.microsoft.com/azure-pipelines/vsts-agent:ubuntu-16.04

# 更新系統並安裝基本工具
RUN apt-get update && apt-get install -y \
    wget \
    apt-transport-https \
    apt-utils \
    && apt-get clean

# 添加 Microsoft 的包存儲庫
# RUN wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
#     dpkg -i packages-microsoft-prod.deb && \
#     apt-get update
# 添加 Microsoft 的包存儲庫 (適配 Ubuntu 16.04)
RUN wget https://packages.microsoft.com/config/ubuntu/16.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    apt-get update


# 定義需要安裝的 .NET SDK 通道
ENV DOTNET_SDK_CHANNELS="6.0"

# 安裝 .NET SDK
RUN curl -fsSL https://dot.net/v1/dotnet-install.sh -o dotnet-install.sh && \
    chmod +x dotnet-install.sh && \
    for channel in $DOTNET_SDK_CHANNELS; do \
        ./dotnet-install.sh --channel $channel --install-dir /usr/share/dotnet; \
    done && \
    rm dotnet-install.sh

# 驗證安裝
# RUN dotnet --list-sdks

# 安裝 Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# 驗證安裝
# RUN dotnet --version && node --version