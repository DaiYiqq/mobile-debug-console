# SPDX-License-Identifier: GPL-3.0-only
<#
  手机调试工作台 · Windows 便携版 EXE 构建脚本（jpackage app-image，内置运行时，免装 Java）
  产物：release/mobile-debug-console-windows-portable.zip（仅作 Release 附件，不入库）
#>
param([string]$RepoRoot = (Split-Path -Parent $PSScriptRoot), [string]$WorkDir = (Join-Path $RepoRoot ".apkbuild\winapp"))
$ErrorActionPreference = "Stop"
$jdk = (Get-ChildItem (Join-Path $env:ProgramFiles "Java\latest\jdk-*") -Directory | Select-Object -First 1).FullName
if (-not $jdk) { throw "需要 JDK 17+（含 jpackage）" }
$src = Join-Path $WorkDir "src\com\daiyiqq\mobiledebugconsole"
New-Item -ItemType Directory -Force -Path $src, (Join-Path $WorkDir "res\assets"), (Join-Path $WorkDir "classes\assets") | Out-Null
Copy-Item (Join-Path $RepoRoot "手机调试工作台.html") (Join-Path $WorkDir "res\assets\index.html") -Force
@'
package com.daiyiqq.mobiledebugconsole;

import java.awt.Desktop;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;

public class Launcher {
    public static void main(String[] args) throws Exception {
        String base = System.getenv("LOCALAPPDATA");
        if (base == null || base.isEmpty()) base = System.getProperty("user.home");
        Path dir = Paths.get(base, "MobileDebugConsole");
        Files.createDirectories(dir);
        Path html = dir.resolve("index.html");
        try (InputStream in = Launcher.class.getResourceAsStream("/assets/index.html")) {
            if (in == null) throw new IllegalStateException("缺少内置 index.html");
            Files.copy(in, html, StandardCopyOption.REPLACE_EXISTING);
        }
        Desktop.getDesktop().browse(html.toUri());
    }
}
'@ | Set-Content -Encoding UTF8 -Path (Join-Path $src "Launcher.java")
& (Join-Path $jdk "bin\javac.exe") -encoding UTF-8 -d (Join-Path $WorkDir "classes") (Join-Path $src "Launcher.java")
Copy-Item (Join-Path $WorkDir "res\assets\index.html") (Join-Path $WorkDir "classes\assets\index.html") -Force
"Manifest-Version: 1.0
Main-Class: com.daiyiqq.mobiledebugconsole.Launcher

" | Set-Content -Path (Join-Path $WorkDir "classes\META-INF\MANIFEST.MF") -NoNewline -Encoding ascii
& (Join-Path $jdk "bin\jar.exe") cfm (Join-Path $WorkDir "launcher.jar") (Join-Path $WorkDir "classes\META-INF\MANIFEST.MF") -C (Join-Path $WorkDir "classes") "."
Remove-Item (Join-Path $WorkDir "out") -Recurse -Force -ErrorAction SilentlyContinue
& (Join-Path $jdk "bin\jpackage.exe") --type app-image --name MobileDebugConsole --app-version 1.0.0 --input $WorkDir --main-jar launcher.jar --main-class com.daiyiqq.mobiledebugconsole.Launcher --dest (Join-Path $WorkDir "out") --java-options "-Dfile.encoding=UTF-8" --description "手机调试工作台（单文件离线调试面板）"
$zip = Join-Path $RepoRoot "release\mobile-debug-console-windows-portable.zip"
tar.exe -a -c -f $zip -C (Join-Path $WorkDir "out") MobileDebugConsole
Write-Host ("Windows 便携版完成：" + $zip)
