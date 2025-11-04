# Kontrola a nastavení NumLock pro přihlášení 

$numLockRegPath = "HKU\.DEFAULT\Control Panel\Keyboard"
$numLockValueName = "InitialKeyboardIndicators"

$currentValue = (Get-ItemProperty -Path $numLockRegPath -Name $numLockValueName).$numLockValueName

Write-Host "Aktuální hodnota NumLock při přihlášení: $currentValue"

if ($currentValue -ne "2") {
    Set-ItemProperty -Path $numLockRegPath -Name $numLockValueName -Value "2"
    Write-Host "NumLock nebyl zapnut. Hodnota byla nastavena na 2 (zapnuto)."
} else {
    Write-Host "NumLock je již zapnut při přihlášení."
}

# Vytvoření klíče Hrátky s PowerShellem a uložení informací 

$regPath = "HKCU:\Hrátky s PowerShellem"

if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath | Out-Null
    Write-Host "Klíč '$regPath' byl vytvořen."
}

$userName = $env:USERNAME
$computerName = $env:COMPUTERNAME
$currentDate = Get-Date -Format "dd.MM.yyyy HH:mm:ss"
$psVersion = $PSVersionTable.PSVersion.ToString()

New-ItemProperty -Path $regPath -Name "Uživatel" -Value $userName -PropertyType String -Force | Out-Null
New-ItemProperty -Path $regPath -Name "Počítač" -Value $computerName -PropertyType String -Force | Out-Null
New-ItemProperty -Path $regPath -Name "Datum" -Value $currentDate -PropertyType String -Force | Out-Null
New-ItemProperty -Path $regPath -Name "Verze PowerShellu" -Value $psVersion -PropertyType String -Force | Out-Null

# Výpis potvrzení 

Write-Host "`n--- Uložené informace ---"
Write-Host "Uživatel: $userName"
Write-Host "Počítač: $computerName"
Write-Host "Datum: $currentDate"
Write-Host "Verze PowerShellu: $psVersion"
Write-Host "------------------------------------"
Write-Host "Všechny údaje byly úspěšně zapsány do registru: $regPath"
