#!/bin/bash
set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 获取配置
COPAW_WORKING_DIR="/data/copaw"
COPAW_LOG_LEVEL="${COPAW_LOG_LEVEL:-INFO}"
COPAW_AUTO_INIT="${COPAW_AUTO_INIT:-true}"

# 检查 COPAW_PORT 是否为有效端口号
# K8s 可能注入类似 "tcp://10.43.3.33:8088" 的值，需要清理
if [ -n "${COPAW_PORT}" ]; then
    # 检查是否为纯数字（有效端口号）
    if [[ "${COPAW_PORT}" =~ ^[0-9]+$ ]]; then
        log_info "COPAW_PORT is valid: ${COPAW_PORT}"
    else
        log_warn "COPAW_PORT='${COPAW_PORT}' is not a valid port number (possibly injected by K8s Service). Unsetting..."
        unset COPAW_PORT
    fi
fi

# 设置端口（带默认值），并 export 以确保子进程能正确获取
export COPAW_PORT="${COPAW_PORT:-8088}"

# 显示配置信息
log_info "Starting CoPaw container..."
log_info "Working directory: ${COPAW_WORKING_DIR}"
log_info "Log level: ${COPAW_LOG_LEVEL}"
log_info "Port: ${COPAW_PORT}"

# 检查是否需要初始化
if [ ! -f "${COPAW_WORKING_DIR}/config.json" ]; then
    log_warn "Configuration file not found. Initializing CoPaw..."

    # 使用默认值初始化或使用用户提供的参数
    if [ "${COPAW_AUTO_INIT}" = "true" ]; then
        log_info "Running: copaw init --defaults --accept-security"
        copaw init --defaults --accept-security || {
            log_error "Initialization failed. Please check your configuration."
            exit 1
        }
        log_info "Initialization completed successfully."
    else
        log_warn "Skipping initialization. Please run 'copaw init' manually."
    fi
else
    log_info "Configuration file found at ${COPAW_WORKING_DIR}/config.json"
fi

# 检查环境变量配置
if [ -n "${EMBEDDING_API_KEY}" ]; then
    log_info "Embedding API Key is configured."
else
    log_warn "EMBEDDING_API_KEY is not set. Memory search features may be limited."
fi

# 确保 .runtime 目录存在
RUNTIME_DIR="${COPAW_WORKING_DIR}/.runtime"
if [ ! -d "${RUNTIME_DIR}" ]; then
    log_info "Creating runtime directory: ${RUNTIME_DIR}"
    mkdir -p "${RUNTIME_DIR}"
fi

# 检查并初始化 providers.json
PROVIDERS_FILE="${RUNTIME_DIR}/providers.json"
if [ ! -f "${PROVIDERS_FILE}" ]; then
    log_info "Initializing empty providers.json"
    echo "{}" > "${PROVIDERS_FILE}"
fi

# 检查并初始化 envs.json
ENVS_FILE="${RUNTIME_DIR}/envs.json"
if [ ! -f "${ENVS_FILE}" ]; then
    log_info "Initializing empty envs.json"
    echo "{}" > "${ENVS_FILE}"
fi

# 设置 .runtime 目录及其内容权限（仅 copaw 用户可访问）
# 目录权限 700，文件权限 600
log_info "Setting permissions for runtime directory"
chmod -R 700 "${RUNTIME_DIR}"
find "${RUNTIME_DIR}" -type f -exec chmod 600 {} \;

# 执行传入的命令
log_info "Executing command: $*"
exec "$@"
