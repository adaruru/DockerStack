FROM mcr.microsoft.com/dotnet/runtime:6.0 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src

COPY . .
WORKDIR "/src/WinService"
RUN dotnet restore "WinService.csproj"
RUN dotnet build "WinService.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "WinService.csproj" -c Release \
    -r linux-x64 \
    /p:SelfContained=true \
    /p:UseAppHost=true \
    -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

ENTRYPOINT ["./WinService"]