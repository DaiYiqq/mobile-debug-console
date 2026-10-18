#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
set -e
APP_NAME="手机调试工作台"
APP_ID="mobile-debug-console"
SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE="$HOME/.local/share/$APP_ID"
mkdir -p "$BASE"
cp "$SRC_DIR/手机调试工作台.html" "$BASE/手机调试工作台.html"
APPS="$HOME/.local/share/applications"
mkdir -p "$APPS"
DESKTOP="$APPS/$APP_ID.desktop"
cat > "$DESKTOP" <<EOF
[Desktop Entry]
Type=Application
Name=$APP_NAME
Name[zh_CN]=$APP_NAME
Comment=单文件、离线可用的手机调试面板
Comment[zh_CN]=单文件、离线可用的手机调试面板
Exec=xdg-open "$BASE/手机调试工作台.html"
Icon=utilities-terminal
Terminal=false
Categories=Utility;Development;
StartupNotify=false
EOF
chmod +x "$DESKTOP" 2>/dev/null || true
echo "安装完成：$BASE"
echo "应用菜单已添加「$APP_NAME」（如未出现，请注销重登或运行 update-desktop-database）"
