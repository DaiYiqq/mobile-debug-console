# 手机调试工作台（Mobile Debug Console）

一个单文件、离线可用的手机调试面板。把「远程连接」「代理配置」「文件传送」三件最常来回切的事放到同一屏，不需要安装、不需要联网、不上传任何数据。

- 主文件：`手机调试工作台.html`（约 42 KB，零外部依赖，`file://` 直接打开即可用）
- 适用环境：Android 手机浏览器（Chrome / Edge / Firefox / 厂商浏览器均可），桌面浏览器同样能用
- 数据存放：只写在本机浏览器的 `localStorage`，可导出 / 导入 JSON 备份
- 说明文档：`使用说明.md`（与本 README 内容互补，偏操作手册）

> **开源许可**：GPL-3.0-only —— 保守型强 copyleft，二次分发与衍生必须同样开源。
> **在线安装（PWA）**：<https://daiyiqq.github.io/mobile-debug-console/> —— Android / iOS / 桌面浏览器可直接「添加到主屏幕」，离线可用。
> **社区贡献**：欢迎 Issues / PR / Discussions，先读 [CONTRIBUTING.md](CONTRIBUTING.md) 与 [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)。

## 一、它解决什么问题

在手机上折腾远程机器时，实际动作往往是这样的：翻聊天记录找主机 IP → 拼一条 SSH 命令 → 复制 → 切到 Termux → 发现端口写错 → 再回来改；接着要开代理，又得去翻代理 App 看端口；最后要把打包好的文件传到别的机器，还得想地址怎么写。

这些知识本身不难，难的是它们散落在七八个地方，每次都要重新找一遍。这个工作台把它们收敛成三类「档案」：

1. 远程连接档案 —— 主机、端口、用户名、协议存一次，之后一键复制命令或一键唤起客户端。
2. 代理配置档案 —— HTTP / HTTPS / SOCKS5 代理存一次，一键复制 URL、host:port，或直接生成能粘进 Termux 的 `export` 环境变量。
3. 文件传送助手 —— 常用传送入口存一次；本机文件可算 SHA-256、调系统分享、下载副本，或直接 PUT/POST 到你自己的接口。

它只做「保存 + 生成 + 复制」，不代理流量、不上传数据、不含第三方脚本。因此非常适合放在内网排障、临时调试、离线环境下用。

## 二、怎么打开

### 方式 1：直接打开（最省事）

把 `手机调试工作台.html` 拷到手机任意目录（例如 `/sdcard/Download/`），用文件管理器点开，选择浏览器打开。之后从浏览器历史或文件管理器进入。

### 方式 2：添加到桌面（推荐，配本地静态服务）

多数浏览器只为 `http(s)` 页面提供「添加到主屏幕」，本地 `file://` 文件通常没有这个入口。这时在 Termux 里起一个只监听本机的静态服务：

```bash
mkdir -p ~/debugbench && cp /sdcard/Download/手机调试工作台.html ~/debugbench/index.html
cd ~/debugbench && python -m http.server 8088 --bind 127.0.0.1
```

然后用 Chrome 打开 `http://127.0.0.1:8088/`，菜单里选「添加到主屏幕」。代价是每次用之前要先启动这个服务。

### 方式 3：快捷方式类 App

装一个能创建网页 / 文件快捷方式的工具（如 Shortcut Maker 一类），指向这个 HTML 文件，效果等同于桌面图标。

### 方式 4：安装包 / PWA（开源后新增，推荐）

在线 PWA：用手机浏览器打开 <https://daiyiqq.github.io/mobile-debug-console/>，Chrome / Edge 菜单选「安装应用」，iOS 用 Safari「分享 → 添加到主屏幕」，得到独立图标、断网可用。

本地安装包：见 `release/` 目录（各包 SHA-256 见 `release/SHA256SUMS.txt`）：

| 平台 | 安装方式 | 安装包 |
|---|---|---|
| Android | PWA「安装应用」，或本地 html 用 Chrome 打开 | `release/mobile-debug-console-android.zip` |
| iOS / iPadOS | Safari 打开 Pages → 分享 → 添加到主屏幕 | `release/mobile-debug-console-ios.zip` |
| Windows | 解压后运行 `安装.bat`（创建桌面 + 开始菜单快捷方式） | `release/mobile-debug-console-windows-x64.zip` |
| macOS | `.app` 拖入「应用程序」（首次需按包内说明执行一次 chmod） | `release/mobile-debug-console-macos.zip` |
| Linux | 运行 `bash install.sh`（生成桌面应用菜单项，另附卸载脚本） | `release/mobile-debug-console-linux.tar.gz` |

> 数据是跟「浏览器 + 文件位置」绑定的。换浏览器、移动文件、清缓存都会读不到旧数据；页面顶部显示「仅本次有效」时说明当前环境根本不能存，记得先导出备份。

## 三、三个模块怎么用

### 1. 远程连接档案

每条档案保存：名称、协议（SSH / RDP / VNC）、主机、端口、用户名、自定义命令、备注。卡片上直接显示将要复制的内容。

- 复制：SSH 生成 `ssh -p 2222 user@host`（22 端口自动省略 `-p`）；RDP / VNC 复制 `host:port`。填了「自定义命令」就优先复制它。
- 打开：生成并跳转 `ssh://` / `rdp://full%20address=s:host:port` / `vnc://host:port`，交给手机上的 Termux、RD Client、VNC Viewer 等 App。
- 编辑弹层底部有「删除这条档案」。

示例（占位数据，工具首次打开会自带，可一键删除）：

| 名称 | 协议 | 主机 | 端口 | 复制出来的内容 |
|---|---|---|---|---|
| 家里 NAS | SSH | 192.168.1.10 | 22 | `ssh admin@192.168.1.10` |
| 云主机跳板 | SSH | 203.0.113.10 | 2222 | `ssh -p 2222 deploy@203.0.113.10` |
| Windows 办公机 | RDP | 192.168.1.20 | 3389 | `192.168.1.20:3389` |

### 2. 代理配置档案

保存类型（HTTP / HTTPS / SOCKS5）、主机、端口、可选用户名密码、备注。顶部「当前代理」面板显示你现在选中的那条。

- 复制 URL：`http://127.0.0.1:7890`，粘到代理 App、浏览器插件或 curl 的 `--proxy`。
- 复制 host:port：很多客户端只要这一段。
- 复制环境变量：直接粘进 Termux 就能让命令行走代理。

```bash
export http_proxy="http://127.0.0.1:7890"
export https_proxy="http://127.0.0.1:7890"
export all_proxy="http://127.0.0.1:7890"
export no_proxy="127.0.0.1,localhost"
```

验证：`curl -I https://example.com`，或 `curl https://api.ipify.org` 看出口 IP。

- 设为当前：只是在本工具里标记「现在用哪条」，方便复制；不会改变 Android 系统代理或任何 App 的设置。

示例：

| 名称 | 类型 | 地址 | 复制 URL |
|---|---|---|---|
| 本机 HTTP 代理 | HTTP | 127.0.0.1:7890 | `http://127.0.0.1:7890` |
| 局域网 SOCKS5 | SOCKS5 | 192.168.1.10:1080 | `socks5://192.168.1.10:1080` |

### 3. 文件传送助手

上半部分是「传送入口」：保存常用共享和目录（SMB / HTTP / FTP / 本机路径 / 其他），一键复制地址或唤起对应 App。

下半部分是「本机文件」：

- 选择文件：走系统文件选择器，可多选；文件只读进内存，刷新即清空。
- 自动算 SHA-256（超过 64 MB 跳过），用于校验传输前后是否一致。
- 分享：调用系统分享面板（Web Share API），可直接发到微信、网盘、邮件等。
- 下载副本：把文件重新交给浏览器下载，用来换个目录存一份。
- 上传：填「上传接口」地址后，按 PUT 或 POST 把文件发到你自己的接口，显示状态码、耗时和响应前 300 字；失败时显示错误类型和常见原因。

示例流程：选一个 `sample.log` → 看到 `17 B · text/plain · SHA-256 256e40d3…` → 上传接口填 `http://192.168.1.10:8080/upload` → 点「上传」→ 返回 `201 Created · 25 ms {"ok":true,"bytes":17}`。

## 四、数据与备份

底部「数据与备份」：

- 导出备份：下载 `调试工作台备份-YYYYMMDD-HHmm.json`。
- 复制备份 JSON：下载被拦时，直接把 JSON 复制到剪贴板，自己存到笔记或网盘。
- 导入备份：选 JSON 文件，整体替换当前数据。
- 删除示例数据：只删带「示例」标记的条目。
- 清空全部：清空所有档案，会二次确认。

## 五、测试方式与结果

测试环境：Chromium 148 headless，移动视口 360×720（DPR 2），页面以 `file://` 打开（即手机上「本地文件直接用浏览器打开」的场景），另起一个本地 HTTP 服务（`127.0.0.1:8099`）作为上传接口，通过 CDP 驱动真实点击与表单提交。共 25 项，全部通过。

| # | 用例 | 结果 |
|---|---|---|
| 1 | 页面加载无脚本错误 / 无 console error | 通过 |
| 2 | 三块示例数据渲染（3 远程 / 2 代理 / 3 入口） | 通过 |
| 3 | 标题与 meta 正确 | 通过 |
| 4 | `file://` 下 localStorage 可用性检测与状态胶囊 | 通过（显示「本机保存已开启」） |
| 5 | 表单新建 SSH 档案并生成 `ssh -p 2222 root@10.0.0.9` | 通过 |
| 6 | 端口 99999 被表单拦截并提示 | 通过 |
| 7 | RDP URI 编码 `rdp://full%20address=s%3A192.168.1.20%3A3389&username=s%3APC%5Cxiaoyi` | 通过 |
| 8 | SSH URI 编码 `ssh://root@10.0.0.9:2222` | 通过 |
| 9 | 复制写入剪贴板并回显到「最近复制」条 | 通过 |
| 10 | 设为当前代理 + 生成 URL 与 export 环境变量 | 通过 |
| 11 | 刷新页面后数据与当前代理仍在 | 通过 |
| 12 | 名称含 `<img onerror>` 时按纯文本渲染，无注入 | 通过 |
| 13 | SHA-256 与标准值一致（`abc` → `ba7816bf…0015ad`） | 通过 |
| 14 | 上传到自建接口返回 201 并用绿色结果框显示 | 通过 |
| 15 | 接口未放行 CORS 时显示「Failed to fetch」与原因提示 | 通过 |
| 16 | 备份 JSON 字段完整且可原样回灌 | 通过 |
| 17 | 360px 视口无横向滚动（scrollWidth = clientWidth = 360） | 通过 |
| 18 | 页面无任何外部资源请求（可完全离线） | 通过 |
| 19 | 弹层每个控件都有对应 label | 通过 |
| 20 | 上传地址与方法写入状态 | 通过 |
| 21 | 备份/导入/清空入口齐全 | 通过 |
| 22 | RDP 卡片「打开」链接正确 | 通过 |
| 23 | 编辑弹层内删除档案生效 | 通过 |
| 24 | 一键删除示例数据后标记清空、按钮隐藏 | 通过 |
| 25 | 强制禁用 localStorage 时降级为「仅本次有效」且功能可用 | 通过 |

另外做了两轮人工视觉检查（360×720 截图，深色与浅色两套主题）：卡片对齐、文字无截断重叠、按钮高度 36px 以上、弹层可滚动、浅色模式对比度正常。

未覆盖的部分：真机（Android Chrome / 厂商浏览器）上的 `rdp://`、`vnc://`、`ssh://` 唤起行为，以及系统分享面板，都需要在手机上实际点一次才能确认 —— 无头浏览器里没有这些 App 可接管。

## 六、已知限制

1. 改不了系统代理。网页没有权限改 Android 的 Wi-Fi 代理、VPN 或全局代理设置。这里做的是「保存 + 标记当前 + 复制成能粘的格式」，真正生效仍要在代理 App 或系统设置里粘贴一次。
2. 唤起客户端依赖已安装的 App。没装 RD Client / VNC Viewer / Termux 时，`rdp://`、`vnc://`、`ssh://` 打不开；个别浏览器会停在空白页或提示无法打开（数据已保存，返回即可）。
3. 上传需要自己的接口。网页不能凭空把文件送到另一台设备；「上传」是把文件 PUT/POST 到你填的地址。接口必须允许跨域（返回 `Access-Control-Allow-Origin`），否则浏览器读不到响应；HTTPS 页面调 HTTP 接口还会被拦。
4. 读不到手机任意目录。只能通过系统文件选择器挑文件，网页无法遍历 `/sdcard`；「本机路径」类入口只能复制文本，不能真的打开目录。
5. 分享依赖 Web Share API。不支持的浏览器会提示改用「下载副本」。
6. 密码是明文。代理的用户名/密码以明文存在本机 localStorage 里，共享设备或借给别人用时不要保存密码。
7. 数据跟「浏览器 + 文件位置」绑定。换浏览器、移动 HTML 文件、清缓存都会丢；`file://` 下部分浏览器直接禁用本地存储，此时顶部显示「仅本次有效」，只能当场用，务必导出备份。
8. 主屏幕快捷方式不保证。多数浏览器只对 `http(s)` 页面提供「添加到主屏幕」，本地文件请走第二节的方 2 或方式 3。
9. 没有二维码。为了保持单文件离线，不引第三方二维码库；需要扫码时复制文本，或用系统输入法的扫码 / 剪贴板中转。
10. 大文件不哈希。超过 64 MB 跳过 SHA-256，避免手机内存吃紧；上传和分享不受影响。
11. 单文件版不是 PWA。`手机调试工作台.html` 保持零依赖单文件；仓库另提供 PWA 版 `index.html`（配 `manifest.webmanifest` 与 `sw.js`，GitHub Pages 在线可安装、离线可用）。

## 七、给爱折腾的入口

页面留了一个只读调试接口，浏览器控制台可用：

```js
__bench.getState()                    // 当前全部数据
__bench.remoteUri({protocol:'rdp',host:'10.0.0.2',port:'3389',user:'me'})
__bench.proxyEnv({type:'socks5',host:'127.0.0.1',port:'1080',user:'',pass:''})
__bench.importText(jsonString)        // 直接灌一份配置
__bench.getStaged()                   // 当前已选文件与哈希
```

## 八、仓库文件

| 文件 / 目录 | 说明 |
|---|---|
| `手机调试工作台.html` | 工具本体（唯一真源），单文件、零外部依赖 |
| `index.html` | PWA 版入口（由本体经 `scripts/sync-pwa.py` 生成，勿手改） |
| `manifest.webmanifest` / `sw.js` | PWA 清单与 Service Worker |
| `icons/` | PWA 图标（`scripts/make-icons.py` 生成） |
| `release/` | 五个平台的安装包与 `SHA256SUMS.txt`；`release/staging/` 为启动器源文件 |
| `scripts/` | 图标生成 / PWA 同步 / 打包脚本 |
| `.github/` | Issue 模板与 PR 模板 |
| `CONTRIBUTING.md` | 贡献指南 |
| `CODE_OF_CONDUCT.md` | 行为准则（Contributor Covenant 2.1） |
| `SECURITY.md` | 安全漏洞报告渠道 |
| `LICENSE` | GPL-3.0-only 许可全文 |
| `README.md` / `使用说明.md` | 项目说明 / 操作手册 |

## 九、免责与安全

- 本工具不会连接任何外部服务，页面加载时不发任何网络请求。
- 所有档案只存在你自己浏览器的 `localStorage` 里；仓库中的示例数据全部使用 `192.168.x.x`、`10.0.0.x`、`203.0.113.x`、`127.0.0.1` 等文档保留地址，不含任何真实主机或账号。
- 若在这份档案里保存了真实凭据，请自行评估设备共享风险，并优先使用密钥登录而非密码。
作者：DaiYi(西夏墅高级中学高二4班）
联系方式：①QQ：1703205607
        ②微信：daiyi091004
        ③：QQ邮箱：1703205607@qq.com
        ④：Gemail邮箱：daiy91004@gmail.com
## 十、社区与贡献

本项目欢迎社区共同维护与开发：

- **讨论**：GitHub Discussions 聊想法、使用场景与路线图；
- **问题**：GitHub Issues 提交 bug 或功能请求（模板已配好）；
- **代码**：Fork → 分支 → PR，流程与规范见 [CONTRIBUTING.md](CONTRIBUTING.md)；
- **行为准则**：参与者默认遵守 [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)；
- **安全**：漏洞请走 [SECURITY.md](SECURITY.md) 的私密渠道。

## 十一、许可

本项目以 **GPL-3.0-only**（GNU 通用公共许可证第 3 版）开源，全文见 [LICENSE](LICENSE)。
选择这一「保守型」许可意味着：任何人都可以自由使用、修改、分发，但分发（包括修改后的版本）必须继续以 GPL-3.0 开源并保留声明。各源码文件以 `SPDX-License-Identifier: GPL-3.0-only` 标识。

> 若你希望改用更宽松的许可（如 MIT / Apache-2.0），请在 Discussions 发起提案，需征得所有贡献者同意。
