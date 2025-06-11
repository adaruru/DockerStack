# 舊的 NuGet.Server 是 feed v2
$source = "http://192.168.100.29/nuget"
# 目標 BaGet 是 feed v3
$destination = "http://192.168.10.20:29/v3/index.json"
$apiKey = "mysettingpassword"
$localPackagesPath = "Packages"

& nuget.exe setapikey $apiKey -Source $destination

# 列出 NuGet.Server source 的所有套件
Write-Host "list all source..."
$packages = (& nuget.exe list -AllVersions -Source $source).Split([Environment]::NewLine)

# 處理每個套件的下載與推送
foreach ($package in $packages) {
    if ($package -match "^\s*$") { continue } # 跳過空行
    $id = $package.Split(" ")[0].Trim()
    $version = $package.Split(" ")[1].Trim()

    # 本地套件路徑
    # 同步之前要先去 source 下載所有套件
    $path = [IO.Path]::Combine("packages",$id,$version,"${id}.${version}.nupkg")

      # 下載遠端套件到本地
    
    if (Test-Path $path) {
        Write-Host "push: $id $version"
        Write-Host "execute: nuget.exe push -Source $destination `"$path`""

        # 推送到 BaGet
        & nuget.exe push -Source $destination -ApiKey $apiKey $path
    } else {
        Write-Host "package not found: $path"
    }
}