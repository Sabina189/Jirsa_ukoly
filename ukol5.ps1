
function Format-FileSize {
    param([long]$Bytes)

    $units = "B", "KB", "MB", "GB", "TB", "PB"
    $index = 0
    while ($Bytes -ge 1024 -and $index -lt ($units.Length - 1)) {
        $Bytes /= 1024
        $index++
    }
    "{0:N2} {1}" -f $Bytes, $units[$index]
}

function Show-Directory {
    param([string]$Path)

    Clear-Host
    Write-Host "=================================================="
    Write-Host " Prohlížeč adresářů"
    Write-Host " Aktuální cesta: $Path"
    Write-Host "=================================================="

    try {
        $files = Get-ChildItem -Path $Path -File -ErrorAction Stop
        $dirs  = Get-ChildItem -Path $Path -Directory -ErrorAction Stop
    }
    catch {
        Write-Host "CHYBA: Přístup k adresáři byl odepřen." -ForegroundColor Red
        Write-Host "Stiskněte 'U' pro návrat o úroveň výš." -ForegroundColor Yellow
        return @()
    }

    if ($files.Count -gt 0) {
        $sorted = $files | Sort-Object Length
        $smallest = $sorted[0]
        $largest  = $sorted[-1]

        Write-Host ("Celkem souborů : {0}" -f $files.Count)
        Write-Host ("Nejmenší soubor: {0} ({1})" -f $smallest.Name, (Format-FileSize $smallest.Length))
        Write-Host ("Největší soubor : {0} ({1})" -f $largest.Name, (Format-FileSize $largest.Length))
    } else {
        Write-Host "Celkem souborů : 0"
        Write-Host "Nejmenší soubor: N/A"
        Write-Host "Největší soubor : N/A"
    }

    Write-Host "--- Podadresáře ---"
    if ($dirs.Count -eq 0) {
        Write-Host "(Tento adresář neobsahuje žádné podadresáře)"
    } else {
        for ($i = 0; $i -lt $dirs.Count; $i++) {
            Write-Host ("{0,2}. {1}" -f ($i + 1), $dirs[$i].Name)
        }
    }

    Write-Host "--------------------------------------------------"
    Write-Host "[Číslo] - Vstoupit | [U] - O úroveň výš | [Q] - Konec"
    Write-Host "--------------------------------------------------"

    return $dirs
}

$currentPath = (Get-Location).Path

while ($true) {
    $dirs = Show-Directory -Path $currentPath
    $input = (Read-Host "Vaše volba").ToLower()

    switch ($input) {
        'q' {
            Write-Host "Konec programu."
            break
        }
        'u' {
            try {
                $parent = Split-Path $currentPath -Parent
                if ($parent -and (Test-Path $parent)) {
                    $currentPath = $parent
                    Set-Location $currentPath
                } else {
                    Write-Host "Jste v kořenovém adresáři, nelze jít výš." -ForegroundColor Yellow
                    Start-Sleep 1
                }
            } catch {
                Write-Host "CHYBA: Nelze přejít o úroveň výš." -ForegroundColor Red
                Start-Sleep 1
            }
        }
        default {
            if ($input -match '^\d+$') {
                $index = [int]$input - 1
                if ($index -ge 0 -and $index -lt $dirs.Count) {
                    $currentPath = $dirs[$index].FullName
                    Set-Location $currentPath
                } else {
                    Write-Host "Neplatné číslo. Zkuste to znovu." -ForegroundColor Red
                    Start-Sleep 1
                }
            } else {
                Write-Host "Nerozumím příkazu '$input'." -ForegroundColor Red
                Start-Sleep 1
            }
        }
    }
}
