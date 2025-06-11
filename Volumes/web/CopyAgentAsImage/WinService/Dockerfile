
FROM mcr.microsoft.com/dotnet/runtime:6.0 AS base
WORKDIR /app

FROM base AS final
COPY ./publish/WinService .

ENTRYPOINT ["./WinService"]