#!/bin/bash

# CoPaw 健康检查脚本
# CoPaw 固定监听 8088 端口

HEALTH_CHECK_TIMEOUT=5
HEALTH_CHECK_URL="http://127.0.0.1:8088/"

# HTTP 健康检查
if curl -f -s --max-time "${HEALTH_CHECK_TIMEOUT}" "${HEALTH_CHECK_URL}" >/dev/null 2>&1; then
    exit 0
fi

# 健康检查失败
exit 1
