
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM base AS final
COPY ./publish/Web .

ENTRYPOINT ["dotnet", "Web.dll"]