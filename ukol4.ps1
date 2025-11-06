Get-ItemProperty -Path 'Registry::HKEY_USERS\.DEFAULT\Control Panel\Keyboard' -Name 'InitialKeyboardIndicators'
Set-ItemProperty -Path 'Registry::HKEY_USERS\.DEFAULT\Control Panel\Keyboard' -Name 'InitialKeyboardIndicators' -Value '2'

New-Item -Path 'HKCU:\Hrátky s PowerShellem' -Force
$user = $env:USERNAME
$user

$computer = $env:COMPUTERNAME
$computer

$date = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
$date

$psver = $PSVersionTable.PSVersion.ToString()
$psver

New-ItemProperty -Path 'HKCU:\Hrátky s PowerShellem' -Name 'UserName'      -PropertyType String -Value $user   -Force
New-ItemProperty -Path 'HKCU:\Hrátky s PowerShellem' -Name 'ComputerName'  -PropertyType String -Value $computer -Force
New-ItemProperty -Path 'HKCU:\Hrátky s PowerShellem' -Name 'DateSaved'     -PropertyType String -Value $date   -Force
New-ItemProperty -Path 'HKCU:\Hrátky s PowerShellem' -Name 'PowerShellVer' -PropertyType String -Value $psver  -Force

Get-ItemProperty -Path 'HKCU:\Hrátky s PowerShellem' | Format-List
