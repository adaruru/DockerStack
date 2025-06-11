FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM 192.168.10.20:5000/dparcoe-batch AS batch

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src

COPY . .
WORKDIR "/src/ITSFileService"
RUN dotnet restore "ITSFileService.csproj"
RUN dotnet build "ITSFileService.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "ITSFileService.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
COPY --from=batch /app/ /app/batch/
ENTRYPOINT ["dotnet", "ITSFileService.dll"]