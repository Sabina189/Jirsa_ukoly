$desktop = [Environment]::GetFolderPath("Desktop")
$soubor = Join-Path $desktop "teploty.txt"
$skriptCesta = "C:\Scripts\zapis-teplotu.ps1"

if (!(Test-Path "C:\Scripts")) {
    New-Item -ItemType Directory -Path "C:\Scripts" | Out-Null
}

$skriptObsah = @"
\$apiUrl = "https://api.open-meteo.com/v1/forecast?latitude=49.1951&longitude=16.6068&current_weather=true"

\$response = Invoke-RestMethod -Uri \$apiUrl

\$teplota = \$response.current_weather.temperature

\$desktop = [Environment]::GetFolderPath("Desktop")
\$soubor = Join-Path \$desktop "teploty.txt"

\$cas = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
\$radek = "\$cas - \$teplota °C"

Add-Content -Path \$soubor -Value \$radek
"@

Set-Content -Path $skriptCesta -Value $skriptObsah -Encoding UTF8

if (!(Test-Path $soubor)) {
    New-Item -ItemType File -Path $soubor | Out-Null
}

$taskName = "ZapisTeplotuBrno"
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File `"$skriptCesta`""
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Hours 1) -RepetitionDuration ([TimeSpan]::MaxValue)

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Description "Zapisuje teplotu v Brně každou hodinu" -User "$env:USERNAME" -RunLevel Lowest

Write-Host "Hotovo! Skript a úloha byly vytvořeny."
