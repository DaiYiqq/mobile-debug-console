# android/ —— APK 工程

用 **WebView 壳** 把单文件工具打包成 Android 应用：无网络权限需求（仅对「上传接口」开放 INTERNET），
所有数据仍只存本机 WebView 的 localStorage。

| 路径 | 说明 |
|---|---|
| `app/AndroidManifest.xml` | 包名 `com.daiyiqq.mobiledebugconsole`，minSdk 21（Android 5.0+），targetSdk 34 |
| `app/java/.../MainActivity.java` | WebView 容器：开启 JS / DOM Storage / 本地文件访问，处理返回键 |
| `app/assets/index.html` | 构建时由 `手机调试工作台.html` 同步（勿手改） |
| `app/res/` | 图标（mipmap 各密度）与字符串 |
| `release.keystore` | **公开测试签名钥匙**（storepass/keypass 均为 `mobiledebug`），保证构建可复现；不要用于其他应用 |

## 构建

```powershell
pwsh scripts/build-apk.ps1
```

脚本会自动下载 Android SDK 组件（platform-35 + build-tools r34，约 125 MB）、
同步资产、编译、dex、打包、zipalign 并签名，产物为
`release/mobile-debug-console-android.apk`。

## 已知限制

- 网页内「上传接口」从 `file://` 跨源请求受 WebView 安全策略限制，个别 ROM 可能被拦；
  需要稳定上传时用浏览器 PWA 版或自己提供允许跨域的接口。
- 首次启动 WebView 可能需要系统组件更新（老设备）。
