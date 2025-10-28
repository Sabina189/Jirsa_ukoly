# Přísný režim a zastavení při chybě
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ==========================================================
# Pomocná funkce pro vizuální oddělení sekcí
# ==========================================================
function Show-Section([string]$Header) {
    $border = '=' * 80
    Write-Host "`n$border" -ForegroundColor DarkGray
    Write-Host $Header -ForegroundColor Cyan
    Write-Host $border -ForegroundColor DarkGray
}

# ==========================================================
# Události ze System logu (posledních 10 dní)
# ==========================================================
Show-Section "Události ze System logu (10 dní, Error→Warning fallback)"

$StartTime = (Get-Date).AddDays(-10)

# Pokus o načtení chyb (Level = 2)
$events = Get-WinEvent -FilterHashtable @{
    LogName   = 'System'
    Level     = 2
    StartTime = $StartTime
} -ErrorAction SilentlyContinue

if (-not $events -or $events.Count -eq 0) {
    Write-Host "Nebyly nalezeny žádné 'Chyba' události — zkouším 'Upozornění'..." -ForegroundColor Yellow

    # Pokus o načtení upozornění (Level = 3)
    $events = Get-WinEvent -FilterHashtable @{
        LogName   = 'System'
        Level     = 3
        StartTime = $StartTime
    } -ErrorAction SilentlyContinue

    if ($events -and $events.Count -gt 0) {
        Write-Host "Zobrazuji události typu 'Upozornění'." -ForegroundColor Green
    }
    else {
        Write-Host "Za posledních 10 dní nebyly nalezeny ani 'Chyba' ani 'Upozornění'." -ForegroundColor Yellow
    }
}
else {
    Write-Host "Nalezeny události typu 'Chyba'." -ForegroundColor Green
}

# Pokud jsou nějaké události, vypiš je
if ($events -and $events.Count -gt 0) {
    $events |
        Select-Object TimeCreated, Id, ProviderName, LevelDisplayName,
            @{ Name='Message'; Expression={ $_.Message -replace '\s+', ' ' } } |
        Format-Table -AutoSize -Wrap
}

# ==========================================================
# Konverze HEX → ASCII
# ==========================================================
Show-Section "Konverze HEX → ASCII"

$HexInput = "506f7765727368656c6c20697320617765736f6d6521"
Write-Host "Vstupní HEX: $HexInput" -ForegroundColor DarkCyan

# Validace vstupu
if ($HexInput -notmatch '^[0-9A-Fa-f]+$') {
    throw "HEX řetězec obsahuje neplatné znaky."
}
if ($HexInput.Length % 2 -ne 0) {
    throw "HEX řetězec musí mít sudý počet znaků."
}

# Konverze HEX → ASCII
$byteArray = for ($i = 0; $i -lt $HexInput.Length; $i += 2) {
    [Convert]::ToByte($HexInput.Substring($i, 2), 16)
}

$AsciiText = [System.Text.Encoding]::ASCII.GetString($byteArray)

Write-Host "Výstupní ASCII:" -ForegroundColor Green
Write-Host $AsciiText
