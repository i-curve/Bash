# windows server 2022 初始化脚本
$powershell = "https://github.com/PowerShell/PowerShell/releases/download/v7.4.2/PowerShell-7.4.2-win-x64.msi"
$terminalURL = "https://github.com/microsoft/terminal/releases/download/v1.20.11271.0/Microsoft.WindowsTerminal_1.20.11271.0_x64.zip"
$nginxURL = "http://nginx.org/download/nginx-1.22.1.zip"
$vscodeURL = "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user"
$nvmURL = "https://github.com/coreybutler/nvm-windows/releases/download/1.1.12/nvm-setup.exe"
$devToolURL = "https://github.com/skeeto/w64devkit/releases/download/v1.23.0/w64devkit-1.23.0.zip"

$os = [System.Environment]::OSVersion.Version
if ($os.Major -lt 10) {
    Write-Output "当前系统版本不支持, 最低win10"
    exit(0)
}

## 初始化目录
New-Item -ItemType Directory -Path "~/Desktop/workspace"
Set-Location "~/Desktop/workspace"

## 1. 安装chrome, 打开到chrome下载页面
Start-Process "https://www.google.com/chrome/"

## 2. 安装powershell 7.4.2
Write-Output "install powershell"
Invoke-WebRequest -Uri $powershell  -OutFile "powershell.msi"
Start-Process ./powershell.msi -Wait
Remove-Item "powershell.msi"

## 3. 安装terminal
Write-Output "install terminal"
Invoke-WebRequest -Uri $terminalURL  -OutFile "terminal.zip"
# [System.IO.Compression.ZipFile]::ExtractToDirectory('./terminal.zip', './')
Expand-Archive -Path './terminal.zip'
Remove-Item "terminal.zip"

## 4. 安装 nginx 1.22
Write-Output "install nginx"
Invoke-WebRequest -Uri $nginxURL  -OutFile "nginx.zip"
# [System.IO.Compression.ZipFile]::ExtractToDirectory("./nginx.zip", "./")
Expand-Archive -Path './nginx.zip'
Remove-Item "nginx.zip"

## 5. 安装vscode
Write-Output "install vscode"
Invoke-WebRequest -Uri $vscodeURL  -OutFile "vscode-install.exe"
Start-Process ./vscode-install.exe -Wait
Remove-Item "vscode-install.exe"

## 6. install nvm-windows
Write-Output "install nvm-windows"
Invoke-WebRequest -Uri $nvmURL  -OutFile "nvm-install.exe"
Start-Process ./vscode-install.exe -Wait
Remove-Item "nvm-install.exe"

## 7. install devTools
Write-Output "insatll devTools"
Invoke-WebRequest -Uri $devToolURL  -OutFile "devTool.zip"
Expand-Archive -Path './devTool.zip'
Remove-Item "devTool.zip"

# 1. 安装wsl
# windows-server 2022
wsl --install
