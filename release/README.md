# release/ —— 各平台安装包

本目录由 `scripts/build-release.py` 生成；手写源文件在 `release/staging/`。
各包内含同一份 `手机调试工作台.html`（本体）与对应平台的启动器 / 安装脚本。

| 文件 | 平台 | 安装方式 |
|---|---|---|
| `mobile-debug-console-windows-x64.zip` | Windows | 解压运行 `安装.bat`（创建桌面 + 开始菜单快捷方式）；或双击 `启动工作台.bat` 免安装使用 |
| `mobile-debug-console-android.zip` | Android | 本地 html + 安装说明；推荐 PWA 在线安装 |
| `mobile-debug-console-ios.zip` | iOS / iPadOS | 本地 html + 安装说明；推荐 Safari 添加到主屏幕 |
| `mobile-debug-console-macos.zip` | macOS | 脚本壳 `.app`，拖入「应用程序」；首次需按包内说明执行一次 `chmod +x` |
| `mobile-debug-console-linux.tar.gz` | Linux | `bash install.sh` 安装到 `~/.local` 并生成 `.desktop` 菜单项；`bash uninstall.sh` 卸载 |

`SHA256SUMS.txt` 为全部安装包的 SHA-256 校验值，下载后请核对。

## 重新构建

```bash
python3 scripts/build-release.py   # Python 3.8+，仅标准库
```

## 说明

当前安装包采用「原生零依赖」方案（浏览器打开 + 平台快捷方式 / 启动器）。
真·APK / IPA / .exe 壳属于后续增强（Android 可用 WebView 壳、Windows 可用 WebView2 或 Electron），
欢迎社区贡献对应流水线，详见 CONTRIBUTING.md。
