FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
USER $APP_UID
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM base AS final
COPY ./publish/StoreApi .

ENTRYPOINT ["dotnet", "StoreApi.dll"]