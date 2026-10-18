#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-only
"""打包 release/ 下五个平台安装包（zip / tar.gz）并生成 SHA256SUMS.txt。

可复现构建：包内文件时间戳固定为 2026-10-18T00:00:00Z，gzip 头 mtime=0，
文件权限统一，任何平台（Windows / macOS / Linux CI）跑出来字节一致。仅标准库。
"""
import datetime
import gzip
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

FIXED = datetime.datetime(2026, 10, 18, tzinfo=datetime.timezone.utc)
FIXED_TS = int(FIXED.timestamp())


def zip_dir(src: Path, dst: Path) -> None:
    with zipfile.ZipFile(dst, "w", zipfile.ZIP_DEFLATED) as z:
        for f in sorted(src.rglob("*")):
            if not f.is_file():
                continue
            info = zipfile.ZipInfo(
                f.relative_to(src.parent).as_posix(),
                (FIXED.year, FIXED.month, FIXED.day, FIXED.hour, FIXED.minute, FIXED.second),
            )
            info.create_system = 3
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = 0o100644 << 16
            z.writestr(info, f.read_bytes())


def tar_dir(src: Path, dst: Path) -> None:
    with dst.open("wb") as raw, \
            gzip.GzipFile(fileobj=raw, mode="wb", mtime=0) as gz, \
            tarfile.open(fileobj=gz, mode="w") as t:
        for f in sorted(src.rglob("*")):
            if not f.is_file():
                continue
            info = t.gettarinfo(str(f), arcname=f.relative_to(src.parent).as_posix())
            info.mtime = FIXED_TS
            info.mode = 0o644
            info.uid = info.gid = 0
            info.uname = info.gname = ""
            with f.open("rb") as fh:
                t.addfile(info, fh)


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
    print("built:", ", ".join(f.name for f in outs))


if __name__ == "__main__":
    main()
