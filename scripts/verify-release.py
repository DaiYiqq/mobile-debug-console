#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-only
"""校验安装包构建可复现：重新打包后，逐包解包比较每个文件的内容哈希。

压缩流字节会因 zlib / Python 版本不同而不同（跨平台无法字节一致），
因此按「解包后内容 + 文件名」做哈希比较，这是可复现构建的实质保证。
仅标准库。
"""
import hashlib
import subprocess
import sys
import tarfile
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
RELEASE = ROOT / "release"


def content_digest(p: Path) -> str:
    h = hashlib.sha256()
    if p.name.endswith(".zip"):
        with zipfile.ZipFile(p) as z:
            for n in sorted(z.namelist()):
                h.update(n.encode("utf-8"))
                h.update(z.read(n))
    else:
        with tarfile.open(p, "r:gz") as t:
            for m in sorted(t.getmembers(), key=lambda m: m.name):
                f = t.extractfile(m)
                h.update(m.name.encode("utf-8"))
                h.update(f.read() if f else b"")
    return h.hexdigest()


def main() -> int:
    pkgs = sorted([p for p in RELEASE.iterdir() if p.name.endswith((".zip", ".tar.gz"))])
    if len(pkgs) != 5:
        print("安装包数量不对：", len(pkgs))
        return 1
    before = {p.name: content_digest(p) for p in pkgs}
    subprocess.run([sys.executable, str(ROOT / "scripts" / "build-release.py")], check=True)
    after = {p.name: content_digest(p) for p in pkgs}
    ok = True
    for name in sorted(before):
        same = before[name] == after[name]
        if not same:
            ok = False
        print(("OK   " if same else "DIFF "), name)
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
