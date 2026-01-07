
$keywords = @("password", "token", "secret", "heslo", "klíč")

$checkIntervalSeconds = 20

$lastClipboard = $null

$detectionPattern = ($keywords | ForEach-Object { [regex]::Escape($_) }) -join "|"

$keywordRegex = [regex]::new($detectionPattern, 'IgnoreCase')


function Write-Highlighted {
    param(
        [string] $Text,
        [regex] $KeywordRegex
    )

    if ([string]::IsNullOrEmpty($Text)) {
        return
    }

    $foundMatches = $KeywordRegex.Matches($Text)

    if ($foundMatches.Count -eq 0) {
        # nic nenalezeno, vypíšeme řádek
        Write-Host $Text
        return
    }

    $pos = 0

    foreach ($match in $foundMatches) {
        if ($match.Index -gt $pos) {
            $plainPart = $Text.Substring($pos, $match.Index - $pos)
            Write-Host -NoNewline $plainPart
        }

        Write-Host -NoNewline $match.Value -ForegroundColor Yellow

        $pos = $match.Index + $match.Length
    }

    if ($pos -lt $Text.Length) {
        $rest = $Text.Substring($pos)
        Write-Host $rest
    } else {
        Write-Host ""
    }
}

# -----------------------------------------------------------

Write-Host "Monitoring clipboardu – ukonči pomocí Ctrl+C. 💾" -ForegroundColor Green
Write-Host "Sledují se klíčová slova: $($keywords -join ', ')" -ForegroundColor DarkGray
Write-Host "Kontrola probíhá každých $($checkIntervalSeconds) sekund (dle zadání)." -ForegroundColor DarkGray
Write-Host ""

while ($true) {
    try {
        # -Raw aby se zachovaly nové řádky jako jeden string
        $current = Get-Clipboard -Raw -ErrorAction Stop
    }
    catch {
        # Když je schránka prázdná / nepodporovaný formát, nebo dojde k chybě
        $current = $null
    }

    if ($current -ne $lastClipboard -and -not [string]::IsNullOrWhiteSpace($current)) {
        $lastClipboard = $current

        if ($keywordRegex.IsMatch($current)) {
            $time = Get-Date -Format "HH:mm:ss"
            Write-Host ""
            Write-Host "[$time] 🚨 NALEZENO KLÍČOVÉ SLOVO VE SCHRÁNCE:" -ForegroundColor Red
            Write-Host "==============================================" -ForegroundColor Red

            $lines = $current -split "`r?`n"
            foreach ($line in $lines) {
                Write-Highlighted -Text $line -KeywordRegex $keywordRegex
            }

            Write-Host "==============================================" -ForegroundColor Red
        }
    }

    Start-Sleep -Seconds $checkIntervalSeconds
}
