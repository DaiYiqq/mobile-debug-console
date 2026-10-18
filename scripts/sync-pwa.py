#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-only
"""从 手机调试工作台.html 生成 PWA 入口 index.html（幂等，可重复执行）。"""
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "手机调试工作台.html"
DST = ROOT / "index.html"

HEAD_INJECT = (
    '<link rel="manifest" href="./manifest.webmanifest">\n'
    '<link rel="icon" href="./icons/icon-192.png" sizes="192x192">\n'
    '<link rel="apple-touch-icon" href="./icons/icon-512.png">\n'
)
BODY_INJECT = (
    "<script>if('serviceWorker' in navigator){"
    "navigator.serviceWorker.register('./sw.js').catch(function(){});}"
    "</script>\n"
)
SPDX = "<!-- SPDX-License-Identifier: GPL-3.0-only -->\n"


def build() -> None:
    html = SRC.read_text(encoding="utf-8")
    assert "</head>" in html and "</body>" in html, "找不到 </head> / </body>"
    # 幂等：先剥离上次注入的内容
    for marker in (HEAD_INJECT, BODY_INJECT, SPDX):
        html = html.replace(marker, "")
    html = html.replace("</head>", HEAD_INJECT + "</head>", 1)
    html = html.replace("</body>", BODY_INJECT + "</body>", 1)
    html = "<!DOCTYPE html>\n" + SPDX + html[len("<!DOCTYPE html>\n"):]
    DST.write_text(html, encoding="utf-8")
    print(f"已生成 {DST}")


if __name__ == "__main__":
    build()
