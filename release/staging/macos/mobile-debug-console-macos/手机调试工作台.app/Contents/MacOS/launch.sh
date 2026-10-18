#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-only
DIR="$(cd "$(dirname "$0")/../Resources" 2>/dev/null && pwd)"
if [ -f "$DIR/手机调试工作台.html" ]; then
  open "$DIR/手机调试工作台.html"
else
  osascript -e 'display dialog "未找到 手机调试工作台.html" buttons {"好"} default button 1'
fi
