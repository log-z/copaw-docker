#!/bin/bash
# 迁移 legacy .copaw 目录
# 上游 constant.py 中 ~/.copaw 存在性检测优先级高于 QWENPAW_WORKING_DIR 环境变量
# 需要在 app 启动前将 .copaw 重命名，否则工作目录会被错误地解析为 /data/qwenpaw/.copaw

WORKING_DIR="${1:-/data/qwenpaw}"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

if [ ! -d "${WORKING_DIR}/.copaw" ]; then
    exit 0
fi

if [ -d "${WORKING_DIR}/.qwenpaw" ]; then
    log_warn "Both .copaw and .qwenpaw exist in ${WORKING_DIR}"
    log_warn "Renaming .copaw to .copaw-bak to avoid conflict"
    mv "${WORKING_DIR}/.copaw" "${WORKING_DIR}/.copaw-bak"
    log_info "Done. Legacy data backed up at ${WORKING_DIR}/.copaw-bak"
else
    log_warn "Detected legacy .copaw directory, renaming to .qwenpaw"
    mv "${WORKING_DIR}/.copaw" "${WORKING_DIR}/.qwenpaw"
    log_info "Done. Legacy directory renamed to ${WORKING_DIR}/.qwenpaw"
fi
