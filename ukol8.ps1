$regPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
)

$regApps = foreach ($path in $regPaths) {
    if (Test-Path $path) {
        Get-ChildItem $path | ForEach-Object {
            $p = Get-ItemProperty $_.PSPath
            if ($p.DisplayName) {
                [PSCustomObject]@{
                    Name = $p.DisplayName
                    Version = $p.DisplayVersion
                    Publisher = $p.Publisher
                    InstallLocation = $p.InstallLocation
                    Source = "Registry"
                }
            }
        }
    }
}

function Resolve-Lnk($p) {
    try {
        $w = New-Object -ComObject WScript.Shell
        $s = $w.CreateShortcut($p)
        return $s.TargetPath
    } catch { return $null }
}

$startPaths = @(
    "$env:ProgramData\Microsoft\Windows\Start Menu\Programs",
    "$env:AppData\Microsoft\Windows\Start Menu\Programs"
)

$lnkApps = foreach ($sp in $startPaths) {
    if (Test-Path $sp) {
        Get-ChildItem $sp -Recurse -Filter *.lnk | ForEach-Object {
            $target = Resolve-Lnk $_.FullName
            if ($target -and (Test-Path $target)) {
                $v = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($target)
                [PSCustomObject]@{
                    Name = $v.ProductName ?? $_.BaseName
                    Version = $v.ProductVersion
                    Publisher = $v.CompanyName
                    InstallLocation = Split-Path $target
                    Source = "StartMenu"
                }
            }
        }
    }
}

$uwpApps = Get-AppxPackage | ForEach-Object {
    [PSCustomObject]@{
        Name = $_.Name
        Version = $_.Version
        Publisher = $_.Publisher
        InstallLocation = $_.InstallLocation
        Source = "UWP"
    }
}

$all = $regApps + $lnkApps + $uwpApps

$unique = $all | Group-Object Name, Version | ForEach-Object {
    $_.Group[0]
} | Sort-Object Name

$unique | Format-Table -AutoSize

$desktop = [Environment]::GetFolderPath("Desktop")
$path = Join-Path $desktop "software_list.csv"
$unique | Export-Csv $path -NoTypeInformation -Encoding UTF8
Write-Host "Seznam uložen do $path"
