#!/bin/bash

# CoPaw 健康检查脚本

# 获取配置
COPAW_HOST="${COPAW_HOST:-0.0.0.0}"
COPAW_PORT="${COPAW_PORT:-8088}"
HEALTH_CHECK_TIMEOUT=5
HEALTH_CHECK_URL="http://127.0.0.1:${COPAW_PORT}/"

# 尝试 HTTP 健康检查
if command -v curl >/dev/null 2>&1; then
    if curl -f -s --max-time "${HEALTH_CHECK_TIMEOUT}" "${HEALTH_CHECK_URL}" >/dev/null 2>&1; then
        exit 0
    fi
fi

# 备选：检查进程是否运行
if pgrep -f "copaw" >/dev/null 2>&1; then
    exit 0
fi

# 健康检查失败
exit 1
