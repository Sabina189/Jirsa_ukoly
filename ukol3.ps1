
param(
    [string]$ExportPath = "./reports",
    [string]$FaxLocation = "Umístění faxu - příklad",
    [switch]$RenameCToSystem
)

# Kontrola práv
$current = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($current)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Tento skript musí být spuštěn jako správce."; exit 1
}

if (-not (Test-Path $ExportPath)) { New-Item -Path $ExportPath -ItemType Directory -Force | Out-Null }

# 1) Tiskárny
Write-Host "[1/4] Tiskárny — vlastnosti třídy a umístění Faxu..."
try {
    $class = Get-CimClass -ClassName Win32_Printer -ErrorAction Stop
    $class.CimClassProperties | Export-Csv -Path (Join-Path $ExportPath 'printer_class_properties.csv') -NoTypeInformation

    $printers = Get-CimInstance -ClassName Win32_Printer | Select-Object Name,Location,PortName,PrinterStatus
    $printers | Export-Csv -Path (Join-Path $ExportPath 'printers_list.csv') -NoTypeInformation

    # Změna umístění Faxu
    $fax = $printers | Where-Object { $_.Name -eq 'Fax' }
    if ($fax) {
        $fax.Location = $FaxLocation
        Set-CimInstance -InputObject (Get-CimInstance -ClassName Win32_Printer -Filter "Name='Fax'") -Property @{ Location = $FaxLocation }
        Write-Host "Umístění tiskárny 'Fax' změněno na: $FaxLocation"
    } else {
        Write-Host "Tiskárna 'Fax' nebyla nalezena."
    }
}
catch { Write-Warning "Chyba při zpracování tiskáren: $_" }

# 2) Disk C: 
Write-Host "[2/4] Kontrola a případné přejmenování disku C:..."
try {
    $c = Get-CimInstance -ClassName Win32_Volume -Filter "DriveLetter='C:'" -ErrorAction Stop
    $info = [PSCustomObject]@{ DriveLetter = $c.DriveLetter; Label = $c.Label; Capacity = $c.Capacity }
    if ($RenameCToSystem -and $c.Label -ne 'Systém') {
        Set-CimInstance -InputObject $c -Property @{ Label = 'Systém' }
        Write-Host "Disk C: přejmenován na 'Systém'."
        $info.Label = 'Systém'
    }
    $info | Export-Csv -Path (Join-Path $ExportPath 'volumeC_info.csv') -NoTypeInformation
}
catch { Write-Warning "Chyba při zpracování disku C:: $_" }

# 3) Nepoužité účty 
Write-Host "[3/4] Vyhledávám účty, které se nikdy nepřihlásily..."
try {
    $users = Get-LocalUser | Where-Object { -not $_.LastLogon }
    $never = $users | Select-Object Name, Enabled, LastLogon
    $never | Export-Csv -Path (Join-Path $ExportPath 'local_never_loggedon.csv') -NoTypeInformation
}
catch { Write-Warning "Chyba při čtení Get-LocalUser: $_" }

# 4) Uzamčené účty 
Write-Host "[4/4] Vyhledávám uzamčené účty..."
try {
    $locked = Get-CimInstance -ClassName Win32_UserAccount -Filter "LocalAccount=True AND Lockout=True" -ErrorAction Stop |
              Select-Object Name,Domain,Lockout,Disabled
    $locked | Export-Csv -Path (Join-Path $ExportPath 'local_locked_accounts.csv') -NoTypeInformation
}
catch { Write-Warning "Chyba při čtení Win32_UserAccount: $_" }

Write-Host "\nHotovo. Výsledky jsou v $(Resolve-Path $ExportPath)"
