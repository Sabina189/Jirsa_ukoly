
# ---------------------------------------------------------------------
# A) Úprava profilu 
# ---------------------------------------------------------------------

$marker = '# === ÚKOL 2: EP a profil ==='

# Pokud profil neexistuje, vytvoří se
if (-not (Test-Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}

# Pokud marker v profilu ještě není, vloží se kód
if (-not (Select-String -Path $PROFILE -Pattern [regex]::Escape($marker) -Quiet)) {
@"
$marker
try {
    Write-Host "Execution Policy: $(Get-ExecutionPolicy)" -ForegroundColor Yellow
    Write-Host "Profile path: $PROFILE" -ForegroundColor Green
} catch {}
# === /ÚKOL 2 ===
"@ | Add-Content -Path $PROFILE

    Write-Host "Kód pro výpis EP a cesty byl přidán do profilu." -ForegroundColor Green
} else {
    Write-Host "Kód v profilu už existuje — nebylo potřeba nic měnit." -ForegroundColor Yellow
}

# Načtení profilu ihned po úpravě
. $PROFILE


# ---------------------------------------------------------------------
# B) Alias np (notepad.exe) a ct (control.exe)
# ---------------------------------------------------------------------

# Cílová složka a soubor pro JSON
$outDir = Join-Path $PSScriptRoot 'out'
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }
$aliasesFile = Join-Path $outDir 'aliases.json'

# Vytvoření aliasů
Set-Alias np notepad.exe
Set-Alias ct control.exe
Write-Host "Alias(y) vytvořeny: np → notepad.exe, ct → control.exe" -ForegroundColor Green

# Export aliasů do JSON
Get-Alias np,ct | Select Name,Definition | ConvertTo-Json | Set-Content $aliasesFile -Encoding UTF8
Write-Host "Alias(y) exportovány do: $aliasesFile" -ForegroundColor Cyan

# Smazání aliasů
Remove-Item alias:np, alias:ct -ErrorAction SilentlyContinue
Write-Host "Alias(y) smazány." -ForegroundColor Yellow

# Obnovení aliasů z JSON
(Get-Content $aliasesFile | ConvertFrom-Json) | ForEach-Object {
    Set-Alias $_.Name $_.Definition
}
Write-Host "Alias(y) obnoveny z JSON." -ForegroundColor Green

# Ověření aliasů
Get-Alias np,ct | Format-Table Name,Definition
