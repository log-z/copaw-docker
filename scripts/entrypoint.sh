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
COPAW_WORKING_DIR="${COPAW_WORKING_DIR:-/data/copaw}"
COPAW_LOG_LEVEL="${COPAW_LOG_LEVEL:-INFO}"
COPAW_AUTO_INIT="${COPAW_AUTO_INIT:-true}"

# 显示配置信息
log_info "Starting CoPaw container..."
log_info "Working directory: ${COPAW_WORKING_DIR}"
log_info "Log level: ${COPAW_LOG_LEVEL}"

# 检查是否需要初始化
if [ ! -f "${COPAW_WORKING_DIR}/config.json" ]; then
    log_warn "Configuration file not found. Initializing CoPaw..."

    # 使用默认值初始化或使用用户提供的参数
    if [ "${COPAW_AUTO_INIT}" = "true" ]; then
        log_info "Running: copaw init --defaults"
        # 使用 yes 自动确认安全警告（非交互模式）
        yes "" | copaw init --defaults || {
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

# 显示必需的文件检查
REQUIRED_FILES=("config.json" "SOUL.md" "AGENTS.md")
missing_files=()
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "${COPAW_WORKING_DIR}/$file" ]; then
        missing_files+=("$file")
    fi
done

if [ ${#missing_files[@]} -gt 0 ]; then
    log_warn "Some required files are missing: ${missing_files[*]}"
    log_warn "You may need to run 'copaw init' to complete the setup."
fi

# 检查环境变量配置
if [ -n "${EMBEDDING_API_KEY}" ]; then
    log_info "Embedding API Key is configured."
else
    log_warn "EMBEDDING_API_KEY is not set. Memory search features may be limited."
fi

# 执行传入的命令
log_info "Executing command: $@"
exec "$@"
