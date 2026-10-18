# SPDX-License-Identifier: GPL-3.0-only
<#
  手机调试工作台 · Android APK 构建脚本（Windows PowerShell 7+）
  依赖：JDK 17+（提供 javac/keytool）、curl、tar、python3（仅用于把 classes.dex 放入 APK）。
  首次运行会自动下载 Android SDK 组件到 .apkbuild/（约 125 MB），之后复用。
  产物：release/mobile-debug-console-android.apk（v1 签名）。
#>
param(
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot),
    [string]$WorkDir  = (Join-Path $RepoRoot ".apkbuild")
)

$ErrorActionPreference = "Stop"
$sdkUrlPlatform = "https://dl.google.com/android/repository/platform-35_r02.zip"
$sdkUrlTools    = "https://dl.google.com/android/repository/build-tools_r34-windows.zip"

function Get-JdkBin {
    $candidates = @(
        (Join-Path $env:ProgramFiles "Java\latest\jdk-27\bin"),
        (Join-Path $env:ProgramFiles "Eclipse Adoptium\*\bin"),
        (Join-Path $env:LOCALAPPDATA "Programs\Eclipse Adoptium\*\bin")
    )
    foreach ($c in $candidates) {
        $hit = Get-ChildItem -Path $c -Directory -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($hit -and (Test-Path (Join-Path $hit.FullName "javac.exe"))) { return $hit.FullName }
        if (Test-Path (Join-Path $c "javac.exe")) { return $c }
    }
    throw "未找到 JDK（javac.exe），请安装 JDK 17+ 并重试"
}

$jdkBin = Get-JdkBin
$sdk = Join-Path $WorkDir "sdk"
$platform = Join-Path $sdk "platform\android-35\android.jar"
$bt = Join-Path $sdk "build-tools\android-14"
if (-not (Test-Path $platform) -or -not (Test-Path (Join-Path $bt "aapt.exe"))) {
    New-Item -ItemType Directory -Force -Path (Join-Path $sdk "dl") | Out-Null
    $zipP = Join-Path $sdk "dl\platform-35.zip"
    $zipT = Join-Path $sdk "dl\build-tools-34.zip"
    if (-not (Test-Path $zipP)) { curl.exe -sL -o $zipP $sdkUrlPlatform }
    if (-not (Test-Path $zipT)) { curl.exe -sL -o $zipT $sdkUrlTools }
    tar.exe -xf $zipP -C (Join-Path $sdk "platform")
    tar.exe -xf $zipT -C $bt
}
if (-not (Test-Path $platform)) { throw "android.jar 下载/解压失败" }

$app = Join-Path $RepoRoot "android\app"
$stage = Join-Path $WorkDir "stage"
Remove-Item -Path $stage -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $stage | Out-Null

# 同步资产：本体 HTML 作为 APK 内置页面
Copy-Item (Join-Path $RepoRoot "手机调试工作台.html") (Join-Path $app "assets\index.html") -Force

# 图标（若缺失，用根目录 icons/icon-512.png 缩放生成）
$iconSrc = Join-Path $RepoRoot "icons\icon-512.png"
$dpiSizes = @{ "mdpi" = 48; "hdpi" = 72; "xhdpi" = 96; "xxhdpi" = 144; "xxxhdpi" = 192 }
foreach ($dpi in $dpiSizes.Keys) {
    $dir = Join-Path $app ("res\mipmap-" + $dpi)
    if (-not (Test-Path (Join-Path $dir "ic_launcher.png"))) {
        throw "缺少图标 res/mipmap-$dpi/ic_launcher.png（运行 scripts/make-icons.py 后按 48/72/96/144/192 缩放生成）"
    }
}

& (Join-Path $bt "aapt.exe") package -f -M (Join-Path $app "AndroidManifest.xml") -S (Join-Path $app "res") -A (Join-Path $app "assets") -I $platform -F (Join-Path $stage "base.apk")
if ($LASTEXITCODE -ne 0) { throw "aapt 打包失败" }

& (Join-Path $jdkBin "javac.exe") --release 8 -classpath $platform -d (Join-Path $stage "classes") (Join-Path $app "java\com\daiyiqq\mobiledebugconsole\MainActivity.java")
if ($LASTEXITCODE -ne 0) { throw "javac 编译失败" }

New-Item -ItemType Directory -Force -Path (Join-Path $stage "dex") | Out-Null
& cmd.exe /d /s /c (Join-Path $bt "d8.bat") --lib $platform --min-api 21 --output (Join-Path $stage "dex") (Join-Path $stage "classes\com\daiyiqq\mobiledebugconsole\MainActivity.class")
if ($LASTEXITCODE -ne 0) { throw "d8 失败" }

python -c "import zipfile,sys; z=zipfile.ZipFile(sys.argv[1],'a',zipfile.ZIP_DEFLATED); z.write(sys.argv[2],'classes.dex'); z.close()" (Join-Path $stage "base.apk") (Join-Path $stage "dex\classes.dex")

& (Join-Path $bt "zipalign.exe") -f -p 4 (Join-Path $stage "base.apk") (Join-Path $stage "aligned.apk")

$ks = Join-Path $RepoRoot "android\release.keystore"
if (-not (Test-Path $ks)) {
    & (Join-Path $jdkBin "keytool.exe") -genkeypair -keystore $ks -alias mobiledebug -keyalg RSA -keysize 2048 -validity 10950 -storepass mobiledebug -keypass mobiledebug -dname "CN=Mobile Debug Console, OU=OpenSource, O=DaiYiqq, L=Changzhou, ST=Jiangsu, C=CN"
    if ($LASTEXITCODE -ne 0) { throw "keytool 生成密钥库失败" }
}

$out = Join-Path $RepoRoot "release\mobile-debug-console-android.apk"
& cmd.exe /d /s /c (Join-Path $bt "apksigner.bat") sign --ks $ks --ks-pass pass:mobiledebug --key-pass pass:mobiledebug --out $out (Join-Path $stage "aligned.apk")
if ($LASTEXITCODE -ne 0) { throw "apksigner 签名失败" }

Write-Host ("APK 构建完成：" + $out)
Write-Host "提示：release.keystore 为公开测试钥匙，仅用于本项目签名；请勿用于其他应用。"
