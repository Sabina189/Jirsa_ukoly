param (
    [string]$Url,
    [int]$Delka
)

# Pokud chybí parametry, vypiš stručnou nápovědu a ukonči
if (-not $Url -or -not $Delka) {
    Write-Host "`nPOUŽITÍ:" -ForegroundColor Yellow
    Write-Host "  .\Extraktor.ps1 -Url <odkaz> -Delka <číslo>"
    Write-Host "PŘÍKLAD:"
    Write-Host "  .\Extraktor.ps1 -Url 'https://www.seznam.cz' -Delka 8`n"
    exit
}

try {
    # Stažení obsahu webu (pouze text, ignoruje chyby certifikátů)
    $web = Invoke-WebRequest -Uri $Url -UseBasicParsing -ErrorAction Stop
    
    # Odstranění HTML tagů a extrakce slov (včetně diakritiky)
    $text = $web.Content -replace '<[^>]+>', ' '
    $slova = [regex]::Matches($text, '\b\w+\b') | ForEach-Object { $_.Value.ToLower() }

    # Filtrace: unikátní slova o konkrétní délce, seřazeno abecedně
    $vysledek = $slova | Where-Object { $_.Length -eq $Delka } | Sort-Object -Unique

    # Výpis výsledků
    if ($vysledek) {
        Write-Host "`nUnikátní slova o délce $Delka z adresy $Url`:" -ForegroundColor Cyan
        $vysledek -join ", "
        Write-Host "`nCelkem nalezeno: $($vysledek.Count)" -ForegroundColor Gray
    } else {
        Write-Host "Na stránce nebyla nalezena žádná slova o délce $Delka." -ForegroundColor Yellow
    }
}
catch {
    Write-Host "CHYBA: Nepodařilo se načíst stránku. Zkontrolujte URL nebo připojení." -ForegroundColor Red
}
