#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-only
"""打包 release/ 下五个平台安装包（zip / tar.gz）并生成 SHA256SUMS.txt。仅标准库。"""
import hashlib
import tarfile
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
RELEASE = ROOT / "release"
STAGING = RELEASE / "staging"

ZIP_DIRS = {
    "windows": "mobile-debug-console-windows-x64",
    "android": "mobile-debug-console-android",
    "ios": "mobile-debug-console-ios",
    "macos": "mobile-debug-console-macos",
}
TAR_DIRS = {"linux": "mobile-debug-console-linux"}


def zip_dir(src: Path, dst: Path) -> None:
    with zipfile.ZipFile(dst, "w", zipfile.ZIP_DEFLATED) as z:
        for f in sorted(src.rglob("*")):
            if f.is_file():
                z.write(f, f.relative_to(src.parent).as_posix())


def tar_dir(src: Path, dst: Path) -> None:
    with tarfile.open(dst, "w:gz") as t:
        for f in sorted(src.rglob("*")):
            if f.is_file():
                t.add(f, arcname=f.relative_to(src.parent).as_posix())


def main() -> None:
    outs = []
    for key, dname in ZIP_DIRS.items():
        src = STAGING / key / dname
        if not src.exists():
            raise SystemExit(f"缺少 {src}")
        out = RELEASE / f"{dname}.zip"
        zip_dir(src, out)
        outs.append(out)
    for key, dname in TAR_DIRS.items():
        src = STAGING / key / dname
        if not src.exists():
            raise SystemExit(f"缺少 {src}")
        out = RELEASE / f"{dname}.tar.gz"
        tar_dir(src, out)
        outs.append(out)
    lines = []
    for f in sorted(outs):
        h = hashlib.sha256(f.read_bytes()).hexdigest()
        lines.append(f"{h}  {f.name}")
    (RELEASE / "SHA256SUMS.txt").write_text("\n".join(lines) + "\n", encoding="utf-8")
    print("打包完成：", ", ".join(f.name for f in outs))


if __name__ == "__main__":
    main()
