#!/bin/bash

# QwenPaw 健康检查脚本
# 支持 QWENPAW_PORT 环境变量，并处理 K8s 注入的非纯数字值

HEALTH_CHECK_TIMEOUT=5

# 检查 QWENPAW_PORT 是否为有效端口号
# K8s 可能注入类似 "tcp://10.43.3.33:8088" 的值，需要清理
if [ -n "${QWENPAW_PORT}" ]; then
    if [[ ! "${QWENPAW_PORT}" =~ ^[0-9]+$ ]]; then
        unset QWENPAW_PORT
    fi
fi

# v2.0.0.post1+ 提供就绪探针 /api/healthz（启动中返回 503，就绪返回 200）
HEALTH_CHECK_URL="http://127.0.0.1:${QWENPAW_PORT:-8088}/api/healthz"

# HTTP 健康检查
if curl -f -s --max-time "${HEALTH_CHECK_TIMEOUT}" "${HEALTH_CHECK_URL}" >/dev/null 2>&1; then
    exit 0
fi

# 健康检查失败
exit 1
