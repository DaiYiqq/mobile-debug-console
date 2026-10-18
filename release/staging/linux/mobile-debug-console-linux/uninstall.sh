#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
set -e
APP_ID="mobile-debug-console"
rm -rf "$HOME/.local/share/$APP_ID"
rm -f "$HOME/.local/share/applications/$APP_ID.desktop"
echo "已卸载 手机调试工作台。"
