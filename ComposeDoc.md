# Compose Doc

## docker-compose run flow

dockercompose practice note

### run container

```powershell
# run container
docker-compose up

# run container 背景執行 Detached Mode 避免佔據當前終端
docker-compose up -d

# run container 指定 Project name 而不使用當前資料夾名稱
docker-compose -p carcare up -d

# Linux/macOS agent pipeline 指定 Project name
export COMPOSE_PROJECT_NAME=$(projectName)

# Windows agent pipeline 指定 Project name
# by powshershell
$env:COMPOSE_PROJECT_NAME = "$(projectName)"
# by cmd
set COMPOSE_PROJECT_NAME=$(projectName)

# 指定 compose 位置
docker-compose -f ./Web/docker-compose.yml up -d
docker-compose -f ./WinService/docker-compose.yml up -d
```

1. 可以版控 container 執行的參數(對外port、環境變數、是否背景執行等)
2. 依賴可執行的 image，執行 container 取代 Dockerfile cli
3. 組成 container 模式，故會形成叢集資料夾 container 分層方式顯示

複製 ReadingNote\Devops\.attach\.docker\Volumes
到 D:\Users\AmandaChou\git\github\DockerStack\Volumes

開始所有 compose file 的維護與執行

### before run

確定拿到的是最新的 image `docker-compose pull`

刪掉 **所有「未被容器使用的 image」**，包含你之前 build 或 pull 下來、但目前沒有 container 用到的

### after run

確定本地沒有用不到的 `image docker image prune -a -f`

## azure agent and docker registry

```powershell
cd C:\Users\Administrator\Volumes\azure-agent
# build image
docker build . -t azure-agent:dev
# run container
docker-compose up -d
```

## docker registry

1. cd 到 complose 位置

   `cd D:\Users\AmandaChou\git\github\DockerStack\Volumes\dockerrepos`

2. 檢查 complose 存在

   `ls`

3. 執行

   `docker-compose up -d`

4. 檢查容器是否執行

   `docker ps`

#### 查看現有 registry image

```powershell
curl http://localhost:5000/v2/_catalog
```

#### 查看現有 image 現有 tag

```powershell
curl http://localhost:5000/v2/imagename/tags/list
curl http://localhost:5000/v2/dparcore/tags/list
```

#### vs code ide 方式查看

extension 安裝 

![image-20250121101831751](.attach/.ComposeDoc/image-20250121101831751.png) 

新增連線

![image-20250121101954323](.attach/.ComposeDoc/image-20250121101954323.png) 

選擇 v2 

![image-20250121102051463](.attach/.ComposeDoc/image-20250121102051463.png) 

port 使用 container 對外 port 

![image-20250121102732098](.attach/.ComposeDoc/image-20250121102732098.png) 

沒有設置 username 與 passeword 就跳過

![image-20250121102804792](.attach/.ComposeDoc/image-20250121102804792.png) 

![image-20250121102814814](.attach/.ComposeDoc/image-20250121102814814.png) 

連上就可以看已經push 的 image

![image-20250121103154624](.attach/.ComposeDoc/image-20250121103154624.png) 

## BeGat

### BeGat compose build

```powershell
# cd 到 complose 位置
cd D:\Users\AmandaChou\git\github\DockerStack\Volumes\nuget

# 檢查 complose 存在
ls

# 執行
docker-compose up -d

# 檢查容器是否執行
docker ps
```

#### 檢測是否穩定運行

http://localhost:29/

#### 舊主機套件轉移

1. 將舊主機的套件複製packages

2. 套件移動到 Volumes\nuget\Packages

3. ps 路徑執行.`.\SyncSource.ps1`

   可能需要先執行 : Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned

   可能需要先下載 nuget.exe https://learn.microsoft.com/zh-tw/nuget/install-nuget-client-tools?tabs=windows

   可能需要去 %APPDATA%/NuGet/NuGet.Config 新增 <add key="63ITSbegat" value="http://192.168.10.10:29/v3/index.json" allowInsecureConnections="True" />

## Redis

### Redis compose build

```powershell
# cd 到 complose 位置
cd D:\Users\AmandaChou\git\github\DockerStack\Volumes\redis\

# 檢查 complose 存在
ls

# 執行
docker-compose up -d

# 檢查容器是否執行
docker ps

# 進入容器 cli 工具
docker exec -it carcare-redis redis-cli -a mysettingpassword

# 進測資
Set name "Amnda"
# 查測資
Get name
```

### 安裝 medis 檢查 redis 安裝狀況

https://github.com/liying2008/medis-binaries/releases

![image-20250611164635548](.attach/.ComposeDoc/image-20250611164635548.png)

## MySQL

### MySQL compose build

```powershell
# cd 到 complose 位置
cd D:\Users\AmandaChou\git\github\ReadingNote\Devops\DockerStack\Volumes\mysql

# 檢查 complose 存在
ls

# 執行
docker-compose up -d

# 檢查容器是否執行
docker ps
```

### 測試連線

![image-20250618151144552](.attach/.ComposeDoc/image-20250618151144552.png) 

連線失敗遇到

Public Key Retrieval is not allowed

調整設定

<img src=".attach/.ComposeDoc/image-20250618151241651.png" alt="image-20250618151241651" style="zoom: 63%;" /><img src=".attach/.ComposeDoc/image-20250618151308173.png" alt="image-20250618151308173" style="zoom:63%;" /> 

連線成功

![image-20250618151559990](.attach/.ComposeDoc/image-20250618151559990.png) 



## MSSQL

### MSSQL compose build

```powershell
# cd 到 complose 位置
cd D:\Users\AmandaChou\git\github\DockerStack\Volumes\mssql

# 檢查 complose 存在
ls

# 執行
docker-compose up -d

# 檢查容器是否執行
docker ps

# 進入容器
docker exec -it sqlserver_1437 bash

# 進入容器使用容器內 cli 工具
docker exec -it sqlserver_1437 /opt/mssql-tools18/bin/sqlcmd -S tcp:localhost  -U sa -P "mysettingpassword" -C
```

#### 測試 SSMS 連線

localhost,1436 

192.168.10.10,1436

sa

mysettingpassword

#### 檢查 mdf、ldf 掛載

![image-20250106140617970](.attach/.ComposeDoc/image-20250106140617970.png) 

#### 進入容器

 docker exec -it sqlserver_1437 bash

#### 進入容器 sql cmd

##### server 進入

docker exec -it sqlserver_1437 /opt/mssql-tools/bin/sqlcmd -S tcp:localhost  -U sa -P "mysettingpassword" -C

docker exec -it sqlserver_1437 /opt/mssql-tools18/bin/sqlcmd -S tcp:localhost  -U sa -P "mysettingpassword" -C

docker exec -it sqlserver_1437 /opt/mssql-tools18/bin/sqlcmd -S tcp:localhost  -U sa -P "mysettingpassword" -C -l 30

docker exec -it sqlserver_1437 /opt/mssql-tools18/bin/sqlcmd -S tcp:localhost,1433  -U sa -P "mysettingpassword" -C -l 30

##### 遠端進入

#### 查看檔案

#### 應用程式連線

1. bakpac 還原

   資料庫設定不見

   1. Autogrowth 設定、還原變為預設值

      ```sql
      SELECT
          name AS FileName,
          type_desc AS FileType,
          size / 128 AS CurrentSize_MB,
          growth AS GrowthSetting,
          is_percent_growth AS IsGrowthInPercent
      FROM
          sys.database_files;
      ```

   2. 其他gpt建議檢察(但我檢查沒有變化)

      ```sql
      SELECT name
      , recovery_model_desc
      , compatibility_level
      ,is_auto_close_on
      ,page_verify_option
      FROM sys.databases
      WHERE name = 'DPARCore2';
      ```

      

2. bak 或 bakpac 還原

   需要手動刪除 login

   刪不掉是因為有SCHEMA占用

   檢查占用

   ```sql
   SELECT name AS SchemaName
   FROM sys.schemas
   WHERE principal_id = USER_ID('dpar');
   ```

   刪除占用

   ```sql
   ALTER AUTHORIZATION ON SCHEMA::dpar_schema TO dbo;
   ```

   手動刪除使用者

3. 加回使用者連線

   ```sql
   USE [master]
   GO
   CREATE LOGIN [dpar] WITH PASSWORD=N'dpar', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
   GO
   USE [DPARCore2]
   GO
   CREATE USER [dpar] FOR LOGIN [dpar]
   GO
   USE [DPARCore2]
   GO
   ALTER ROLE [db_owner] ADD MEMBER [dpar]
   GO
   ```

   

## Verdaccio

![image-20241224161111074](.attach/.ComposeDoc/image-20241224161111074.png) 

A lightweight Node.js private proxy registry

#### Verdaccio compose build

```cmd
#進入有 compose 的 資料夾
cd D:\Users\AmandaChou\git\github\DockerStack\Volumes\verdaccio

#檢查檔案存在
ls

# run 起來
docker-compose up -d

# 檢查 docker 裡面有增加檔案
#1
docker exec -it verdaccio sh

#2 -a 才可以看到隱藏的檔案
ls -a /verdaccio/storage

```

檢查檔案存在

![image-20241224163723167](.attach/.ComposeDoc/image-20241224163723167.png) 

確保目錄中包含 `docker-compose.yml`

compose up 之後新增了一個 .verdaccio-db.json

![image-20241224173809899](.attach/.ComposeDoc/image-20241224173809899.png) 

#### Test into

http://localhost:4873/

local 的 port 4873 對應到 docker container 內部的port  4873

因為compose 設定如此
 ports:

   \- "4873:4873"

## Portainer 

user : admin

pass: itsowermysettingpassword

密碼 必須12字元

### Compose Error

1. port is already allocated

   對外 port 必須唯一，port  號占用會顯示錯誤，回頭修改 compose file

   ![image-20250106123750685](.attach/.ComposeDoc/image-20250106123750685.png) 

2. Docker login Fail

   當多視窗 cli 執行 docker compose 時，可能導致一個 process 背景取得 docker 的 user credential 而其他 process 無法登入

   應盡量避免多 cli 執行

   : failed to resolve reference "docker.io/verdaccio/verdaccio:latest": failed to authorize: failed to fetch oauth token: unexpected status from GET request to https://auth.docker.io/token?scope=repository%3Averdaccio%2Fverdaccio%3Apull&service=registry.docker.io: 401 Unauthorized

   ![image-20250106142240491](.attach/.ComposeDoc/image-20250106142240491.png) 

    `docker login -u loginDockerUser`

   然後輸入密碼

   ![image-20250106142336567](.attach/.ComposeDoc/image-20250106142336567.png) 





### compose Resource Limit

限制 container 

```yml
services:
  dparcore-web:
    image: 192.168.10.10:5000/dparcore:latest
    deploy:
      resources:
        limits:
          memory: 1024M 
          cpus: "1"
        reservations:
          memory: 256M
          cpus: "0.5"
```

### compose Log Limit

```yml
services:
  dparcore-web:
    image: 192.168.10.10:5000/dparcore:latest
    logging:
      driver: "json-file"
      options:
        max-size: "10M"
        max-file: 5
```
