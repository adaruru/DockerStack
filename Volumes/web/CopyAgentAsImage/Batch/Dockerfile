
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build

WORKDIR /src

COPY . .
WORKDIR "/src/Batch"
RUN dotnet restore "Batch.csproj"
RUN dotnet build "Batch.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Batch.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENV DOTNET_ENVIRONMENT=Container
ENTRYPOINT ["dotnet", "Batch.dll"]