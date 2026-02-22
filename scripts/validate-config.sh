#!/bin/bash
# CoPaw Docker 配置验证脚本

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

log_section() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

# 统计变量
PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0

check_pass() {
    PASS_COUNT=$((PASS_COUNT + 1))
    log_info "✓ $1"
}

check_warn() {
    WARN_COUNT=$((WARN_COUNT + 1))
    log_warn "⚠ $1"
}

check_fail() {
    FAIL_COUNT=$((FAIL_COUNT + 1))
    log_error "✗ $1"
}

# 获取脚本所在目录的父目录（项目根目录）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

log_section "CoPaw Docker 配置验证"
echo ""

# 1. 检查 .env 文件
log_section "1. 环境配置检查"
if [ -f "$PROJECT_DIR/.env" ]; then
    check_pass ".env 文件存在"

    # 检查是否配置了 API Keys
    if grep -q "^MODELSCOPE_API_KEY=" "$PROJECT_DIR/.env" && \
       grep -q "^DASHSCOPE_API_KEY=" "$PROJECT_DIR/.env" && \
       grep -q "^OPENAI_API_KEY=" "$PROJECT_DIR/.env"; then

        # 检查是否有至少一个非空的 API Key
        MS_KEY=$(grep "^MODELSCOPE_API_KEY=" "$PROJECT_DIR/.env" | cut -d'=' -f2)
        DS_KEY=$(grep "^DASHSCOPE_API_KEY=" "$PROJECT_DIR/.env" | cut -d'=' -f2)
        OAI_KEY=$(grep "^OPENAI_API_KEY=" "$PROJECT_DIR/.env" | cut -d'=' -f2)

        if [ -n "$MS_KEY" ] || [ -n "$DS_KEY" ] || [ -n "$OAI_KEY" ]; then
            check_pass "至少配置了一个 LLM API Key"
        else
            check_warn "未配置任何 LLM API Key（服务可能无法响应对话）"
        fi
    fi
else
    check_fail ".env 文件不存在，请从 .env.example 复制"
fi
echo ""

# 2. 检查 Docker
log_section "2. Docker 环境检查"
if command -v docker &> /dev/null; then
    check_pass "Docker 已安装: $(docker --version | head -n1)"
else
    check_fail "Docker 未安装或不在 PATH 中"
fi

if docker compose version &> /dev/null; then
    check_pass "Docker Compose 已安装: $(docker compose version | head -n1)"
else
    check_fail "Docker Compose 未安装"
fi
echo ""

# 3. 检查端口占用
log_section "3. 端口检查"
if command -v netstat &> /dev/null; then
    if netstat -an | grep -q ":8088.*LISTEN" 2>/dev/null; then
        check_warn "端口 8088 已被占用"
    else
        check_pass "端口 8088 可用"
    fi
elif command -v ss &> /dev/null; then
    if ss -ln | grep -q ":8088" 2>/dev/null; then
        check_warn "端口 8088 已被占用"
    else
        check_pass "端口 8088 可用"
    fi
else
    log_warn "无法检查端口占用（缺少 netstat/ss 命令）"
fi
echo ""

# 4. 检查配置文件
log_section "4. 配置文件检查"
if [ -f "$PROJECT_DIR/docker-compose.yml" ]; then
    check_pass "docker-compose.yml 存在"
else
    check_fail "docker-compose.yml 不存在"
fi

if [ -f "$PROJECT_DIR/Dockerfile" ]; then
    check_pass "Dockerfile 存在"
else
    check_fail "Dockerfile 不存在"
fi

if [ -f "$PROJECT_DIR/scripts/entrypoint.sh" ]; then
    check_pass "entrypoint.sh 存在"
else
    check_fail "entrypoint.sh 不存在"
fi

if [ -f "$PROJECT_DIR/scripts/healthcheck.sh" ]; then
    check_pass "healthcheck.sh 存在"
else
    check_fail "healthcheck.sh 不存在"
fi
echo ""

# 5. 检查 Docker 资源
log_section "5. Docker 资源检查"
if docker info &> /dev/null; then
    check_pass "Docker daemon 运行正常"

    # 检查数据卷
    if docker volume ls | grep -q "copaw-data"; then
        check_pass "数据卷 copaw-data 已存在"
    else
        check_pass "数据卷 copaw-data 不存在（首次启动会自动创建）"
    fi

    # 检查网络
    if docker network ls | grep -q "copaw-network"; then
        check_pass "网络 copaw-network 已存在"
    else
        check_pass "网络 copaw-network 不存在（首次启动会自动创建）"
    fi

    # 检查是否有运行中的容器
    if docker ps | grep -q "copaw"; then
        check_warn "CoPaw 容器正在运行"
    else
        check_pass "没有运行中的 CoPaw 容器"
    fi
else
    check_fail "Docker daemon 未运行或无权限访问"
fi
echo ""

# 6. 系统资源检查
log_section "6. 系统资源检查"
if command -v free &> /dev/null; then
    TOTAL_MEM=$(free -m | awk '/^Mem:/{print $2}')
    if [ "$TOTAL_MEM" -gt 1024 ]; then
        check_pass "可用内存: ${TOTAL_MEM}MB"
    else
        check_warn "可用内存不足: ${TOTAL_MEM}MB（建议至少 1024MB）"
    fi
fi

if command -v df &> /dev/null; then
    DISK_AVAIL=$(df -m "$PROJECT_DIR" | awk 'NR==2{print $4}')
    if [ "$DISK_AVAIL" -gt 1024 ]; then
        check_pass "可用磁盘空间: ${DISK_AVAIL}MB"
    else
        check_warn "可用磁盘空间较少: ${DISK_AVAIL}MB"
    fi
fi
echo ""

# 7. 操作系统检测
log_section "7. 系统信息"
if [ -f /etc/os-release ]; then
    . /etc/os-release
    check_pass "操作系统: $NAME $VERSION"
else
    check_pass "操作系统: $(uname -s)"
fi
check_pass "架构: $(uname -m)"
echo ""

# 总结
log_section "验证总结"
echo -e "${GREEN}通过: $PASS_COUNT${NC}"
echo -e "${YELLOW}警告: $WARN_COUNT${NC}"
echo -e "${RED}失败: $FAIL_COUNT${NC}"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    log_info "配置验证通过！可以运行 docker compose up -d 启动服务"
    exit 0
else
    log_error "发现 $FAIL_COUNT 个错误，请修复后再试"
    exit 1
fi
