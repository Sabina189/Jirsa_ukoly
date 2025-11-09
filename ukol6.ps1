# První část

Write-Host "=== Náhodná čísla a jejich druhé mocniny ==="
$cisla = @()

for ($i = 0; $i -lt 10; $i++) {
    $cislo = Get-Random -Minimum 10 -Maximum 101
    $cisla += $cislo
}

Write-Host ("{0,-5} {1,10}" -f "Číslo", "Mocnina")
Write-Host ("{0,-5} {1,10}" -f "-----", "--------")

foreach ($c in $cisla) {
    $mocnina = [math]::Pow($c, 2)
    Write-Host ("{0,-5} {1,10}" -f $c, $mocnina)
}

Write-Host "`n"


# Druhá část

Write-Host "=== Seřazení znaků v textu ==="
$text = "Kobyla má malý bok"

$znaky = $text.ToCharArray() | Sort-Object
$serazene = -join $znaky

Write-Host "Původní text: $text"
Write-Host "Seřazené znaky: $serazene"
Write-Host "`n"


# Třetí část

Write-Host "=== Hledání palindromů ze součinů dvou trojciferných čísel ==="

function JePalindrom($cislo) {
    $text = $cislo.ToString()
    return $text -eq ($text.ToCharArray() -join "" -replace ".","$&" | ForEach-Object { } ) -and ($text -eq -join ($text.ToCharArray()[-1..0]))
}

function JePalindrom($cislo) {
    $text = $cislo.ToString()
    return $text -eq -join ($text.ToCharArray()[-1..0])
}

$minPal = [int]::MaxValue
$maxPal = 0
$minA = $minB = $maxA = $maxB = 0

for ($a = 100; $a -le 999; $a++) {
    for ($b = $a; $b -le 999; $b++) {
        $soucin = $a * $b
        if (JePalindrom $soucin) {
            if ($soucin -lt $minPal) {
                $minPal = $soucin
                $minA, $minB = $a, $b
            }
            if ($soucin -gt $maxPal) {
                $maxPal = $soucin
                $maxA, $maxB = $a, $b
            }
        }
    }
}

Write-Host "Nejmenší palindrom: $minPal (vznikl jako $minA * $minB)"
Write-Host "Největší palindrom: $maxPal (vznikl jako $maxA * $maxB)"
