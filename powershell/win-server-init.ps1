# windows server 2022 init script
$powershell = "https://github.com/PowerShell/PowerShell/releases/download/v7.4.6/PowerShell-7.4.6-win-x64.msi"
$terminalURL = "https://github.com/microsoft/terminal/releases/download/v1.21.2911.0/Microsoft.WindowsTerminal_1.21.2911.0_x64.zip"
$nginxURL = "http://nginx.org/download/nginx-1.22.1.zip"
$vscodeURL = "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user"
$bashURL = "https://github.com/git-for-windows/git/releases/download/v2.46.1.windows.1/Git-2.46.1-64-bit.exe"
$nvmURL = "https://github.com/coreybutler/nvm-windows/releases/download/1.1.12/nvm-setup.exe"

$os = [System.Environment]::OSVersion.Version
if ($os.Major -lt 10) {
    Write-Output "the minnal os version is win10"
    exit(0)
}

## initialize directory
New-Item -ItemType Directory -Path "~/Desktop/workspace"
Set-Location "~/Desktop/workspace"

## 1. install chrome: go chrome download page
Start-Process "https://www.google.com/chrome/"

## 2. install powershell 7.4.3
Invoke-WebRequest -Uri $powershell  -OutFile "powershell.msi"
Start-Process ./powershell.msi -Wait
Remove-Item "powershell.msi"

## 3. install terminal
Invoke-WebRequest -Uri $terminalURL  -OutFile "terminal.zip"
# [System.IO.Compression.ZipFile]::ExtractToDirectory('./terminal.zip', './')
Expand-Archive -Path './terminal.zip'
Remove-Item "terminal.zip"

## 4. install nginx 1.22
Invoke-WebRequest -Uri $nginxURL  -OutFile "nginx.zip"
# [System.IO.Compression.ZipFile]::ExtractToDirectory("./nginx.zip", "./")
Expand-Archive -Path './nginx.zip'
Remove-Item "nginx.zip"

## 5. install vscode
Invoke-WebRequest -Uri $vscodeURL  -OutFile "vscode-install.exe"
Start-Process ./vscode-install.exe -Wait
Remove-Item "vscode-install.exe"

## 6. install git-bash
Invoke-WebRequest -Uri $bashURL  -OutFile "git-bash.exe"
Start-Process ./git-bash.exe -Wait
Remove-Item "git-bash.exe"

## 6. install nvm-windows
Invoke-WebRequest -Uri $nvmURL  -OutFile "nvm-setup.exe"
Start-Process ./nvm-setup.exe -Wait
Remove-Item "nvm-setup.exe"

# 1. install wsl

## write config
echo "[wsl2]
nestedVirtualization=true
networkingMode=mirrored #nat
dnsTunneling=true
autoProxy=true
firewall=false
[experimental]
autoMemoryReclaim=gradual # 可以在 gradual 、dropcache 、disabled 之间选择
sparseVhd=true" > ~/.wslconfig

# windows-server 2022
wsl --install
