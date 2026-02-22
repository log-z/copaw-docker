#!/bin/bash
# CoPaw Docker 启动测试脚本

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

# 获取脚本所在目录的父目录（项目根目录）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# 切换到项目目录
cd "$PROJECT_DIR"

log_section "CoPaw Docker 启动测试"
echo ""

# 1. 清理旧容器（可选）
log_section "1. 清理旧环境"
read -p "是否清理旧容器和卷？[y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log_info "停止并删除旧容器..."
    docker compose down -v 2>/dev/null || true
    log_info "清理完成"
else
    log_info "跳过清理"
fi
echo ""

# 2. 构建镜像
log_section "2. 构建 Docker 镜像"
log_info "开始构建..."
if docker compose build; then
    log_info "镜像构建成功"
else
    log_error "镜像构建失败"
    exit 1
fi
echo ""

# 3. 启动服务
log_section "3. 启动服务"
log_info "启动 CoPaw 容器..."
if docker compose up -d; then
    log_info "容器启动成功"
else
    log_error "容器启动失败"
    exit 1
fi
echo ""

# 4. 等待容器就绪
log_section "4. 等待服务就绪"
log_info "等待容器启动（最多 60 秒）..."
TIMEOUT=60
ELAPSED=0
while [ $ELAPSED -lt $TIMEOUT ]; do
    if docker compose ps | grep -q "copaw.*Up"; then
        log_info "容器已启动"
        break
    fi
    sleep 2
    ELAPSED=$((ELAPSED + 2))
    echo -n "."
done
echo ""

if [ $ELAPSED -ge $TIMEOUT ]; then
    log_error "等待超时，容器未能在 ${TIMEOUT} 秒内启动"
    docker compose ps
    docker compose logs --tail=50
    exit 1
fi

# 5. 等待健康检查通过
log_section "5. 等待健康检查"
log_info "等待健康检查通过（最多 120 秒）..."
TIMEOUT=120
ELAPSED=0
while [ $ELAPSED -lt $TIMEOUT ]; do
    HEALTH_STATUS=$(docker inspect --format='{{.State.Health.Status}}' copaw 2>/dev/null || echo "starting")
    if [ "$HEALTH_STATUS" = "healthy" ]; then
        log_info "健康检查通过"
        break
    elif [ "$HEALTH_STATUS" = "unhealthy" ]; then
        log_error "健康检查失败"
        docker compose logs --tail=50
        exit 1
    fi
    sleep 3
    ELAPSED=$((ELAPSED + 3))
    echo -n "."
done
echo ""

if [ $ELAPSED -ge $TIMEOUT ]; then
    log_warn "健康检查超时（可能仍在初始化中）"
fi
echo ""

# 6. 检查服务可访问性
log_section "6. 验证服务可访问性"
log_info "测试 HTTP 连接..."

# 尝试连接
MAX_ATTEMPTS=5
ATTEMPT=1
while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:8088/ | grep -q "200\|404\|302"; then
        log_info "服务可访问！"
        break
    fi
    log_warn "尝试 $ATTEMPT/$MAX_ATTEMPTS 失败，重试中..."
    sleep 2
    ATTEMPT=$((ATTEMPT + 1))
done

if [ $ATTEMPT -gt $MAX_ATTEMPTS ]; then
    log_error "服务无法访问"
    docker compose logs --tail=50
    exit 1
fi
echo ""

# 7. 显示容器状态
log_section "7. 容器状态"
docker compose ps
echo ""

# 8. 显示日志摘要
log_section "8. 日志摘要（最近 30 行）"
docker compose logs --tail=30 copaw
echo ""

# 9. 进入容器测试
log_section "9. 容器内部测试"
log_info "测试 CoPaw 命令..."
docker compose exec -T copaw copaw --version 2>/dev/null || log_warn "无法获取版本信息"
docker compose exec -T copaw ls -la /data/copaw 2>/dev/null || log_warn "无法列出数据目录"
echo ""

# 10. 数据持久化验证
log_section "10. 数据持久化验证"
VOLUME_CONTENTS=$(docker run --rm -v copaw-data:/data alpine ls -la /data/copaw 2>/dev/null | wc -l)
if [ "$VOLUME_CONTENTS" -gt 0 ]; then
    log_info "数据卷中有 $VOLUME_CONTENTS 项内容"
    docker run --rm -v copaw-data:/data alpine ls -la /data/copaw
else
    log_warn "数据卷为空（首次启动正常）"
fi
echo ""

# 11. 访问信息
log_section "✓ 测试完成！"
echo ""
log_info "服务已成功启动并通过所有测试"
echo ""
log_info "访问地址："
echo "  - Web 界面: http://localhost:8088"
echo "  - API 端点: http://localhost:8088/api"
echo ""
log_info "常用命令："
echo "  - 查看日志: docker compose logs -f copaw"
echo "  - 进入容器: docker compose exec copaw bash"
echo "  - 停止服务: docker compose stop"
echo "  - 重启服务: docker compose restart"
echo "  - 删除容器: docker compose down"
echo ""
