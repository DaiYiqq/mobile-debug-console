# 参与贡献（CONTRIBUTING）

感谢你愿意参与 手机调试工作台 的维护与开发。本项目以 GPL-3.0-only 开源，欢迎任何人提 Issue、参加讨论、提交 PR。

## 先读这些

- [行为准则](CODE_OF_CONDUCT.md)：所有参与者默认遵守。
- [安全报告](SECURITY.md)：发现安全问题请走私密渠道。

## 快速上手

1. Fork 本仓库并 clone 到本地。
2. 新建分支：`git checkout -b feat/你的改动`。
3. 改动、自测、提交、推送到你的 fork。
4. 发起 Pull Request，写清楚改了什么、为什么、怎么测的。

## 仓库结构

| 路径 | 说明 |
|---|---|
| `手机调试工作台.html` | **工具本体（唯一真源）**：单文件、零外部依赖，`file://` 可直接打开 |
| `index.html` | PWA 版入口，由本体 + PWA 注入生成，**不要手改** |
| `manifest.webmanifest` / `sw.js` / `icons/` | PWA 清单、Service Worker 与图标 |
| `release/staging/` | 各平台安装包的手写源文件（启动器 / 安装脚本） |
| `release/*.zip`、`*.tar.gz`、`SHA256SUMS.txt` | 构建产物（随仓库提交，方便直接下载） |
| `scripts/` | `make-icons.py` 图标生成、`sync-pwa.py` PWA 同步、`build-release.py` 打包 |
| `.github/` | Issue 模板与 PR 模板 |
| `使用说明.md` | 面向用户的操作手册 |

## 改功能

- 功能改动只改 `手机调试工作台.html`，保持单文件、零依赖、可 `file://` 打开。
- 改完运行 `python3 scripts/sync-pwa.py` 同步生成 `index.html`（幂等，可重复执行）。
- 改了 PWA 资源（sw.js / manifest / 图标）时，把 `sw.js` 里的 `VERSION` 加一以触发缓存更新；改图标后运行 `python3 scripts/make-icons.py`。
- 数据只允许写 `localStorage`；不引入第三方脚本、不联网。

## 测试

参考 README「五、测试方式与结果」的 25 项用例，至少覆盖：

- `file://` 打开无 console error，localStorage 可用性提示正确。
- 新建 / 编辑 / 删除三类档案各一次，复制结果正确。
- 移动视口 360px 无横向滚动。
- `http(s)` 场景刷新后数据仍在；备份导出 / 导入可回灌。

## 提交规范

使用 Conventional Commits，与仓库历史保持一致：

- `feat:` 新功能
- `fix:` 修复
- `docs:` 文档
- `chore:` 打包、脚本、杂项
- `refactor:` 重构（不改行为）

一条提交只做一件事；涉及「本体 → PWA 同步」的改动要放在同一次提交里。

## 发布安装包

```bash
python3 scripts/build-release.py   # 需要 Python 3.8+，仅标准库
```

会重新生成 `release/` 下五个平台包与 `SHA256SUMS.txt`，一并提交。

## 许可

本项目为 GPL-3.0-only。你提交的代码默认以相同许可随项目发布；版权仍归你（保留提交署名），不做版权转让。
