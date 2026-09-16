#!/bin/sh
# 禁用抖音热更新 — 一键构建 deb（需 Theos 环境）
# 用法: ./build.sh   （在有 Theos 的机器上执行，输出 ../debs/）
set -e
cd "$(dirname "$0")"
export THEOS=${THEOS:-~/theos}
make clean >/dev/null 2>&1 || true
make package FINAL=1
mkdir -p ../debs
cp packages/*.deb ../debs/ 2>/dev/null || cp .theos/obj/*.deb ../debs/ 2>/dev/null || true
ls -la ../debs/*.deb 2>/dev/null | tail -3
echo "构建完成：com.xuuz.disablehotupdate"
