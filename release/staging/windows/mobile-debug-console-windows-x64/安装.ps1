# SPDX-License-Identifier: GPL-3.0-only
# 手机调试工作台 · Windows 安装脚本
$ErrorActionPreference = 'Stop'
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
$Html = Join-Path $Here '手机调试工作台.html'
if (-not (Test-Path -LiteralPath $Html)) { Write-Host '未找到 手机调试工作台.html'; exit 1 }
$Dest = Join-Path $env:LOCALAPPDATA 'Programs\手机调试工作台'
New-Item -ItemType Directory -Force -Path $Dest | Out-Null
Copy-Item -LiteralPath $Html -Destination (Join-Path $Dest '手机调试工作台.html') -Force
$shell = New-Object -ComObject WScript.Shell
$desktop = [Environment]::GetFolderPath('Desktop')
$startMenu = [Environment]::GetFolderPath('Programs')
$target = Join-Path $Dest '手机调试工作台.html'
foreach ($lnk in @((Join-Path $desktop '手机调试工作台.lnk'), (Join-Path $startMenu '手机调试工作台.lnk'))) {
    $s = $shell.CreateShortcut($lnk)
    $s.TargetPath = $target
    $s.WorkingDirectory = $Dest
    $s.IconLocation = "$env:SystemRoot\System32\SHELL32.dll,154"
    $s.Description = '手机调试工作台（单文件离线调试面板）'
    $s.Save()
}
Write-Host ('安装完成：' + $Dest)
Write-Host '已创建桌面与开始菜单快捷方式。'
