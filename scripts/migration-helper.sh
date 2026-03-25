#!/bin/bash
# =============================================================================
# CoPaw Docker 迁移辅助脚本
# =============================================================================
#
# 用途：
#   清理旧版本迁移后遗留的软链接
#
# 背景：
#   CoPaw v0.1.0 引入了多工作区架构，早期版本的迁移逻辑需要在 ~/.copaw
#   目录中创建软链接。v0.1.0.post1+ 修复了迁移逻辑后不再需要创建软链接，
#   但需要清理遗留的软链接。
#
# 适用版本：
#   从 CoPaw v0.1.0 以下版本升级到 v0.1.0.post1+ 或更高版本
#
# =============================================================================

set -e

# 颜色输出
GREEN='\033[0;32m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

# 获取参数
COPAW_WORKING_DIR="${1:-/data/copaw}"

# 写死的路径，与 CoPaw 源码 migration.py 保持一致
# 注意：~/.copaw 在 Docker 中展开为 /data/copaw/.copaw（HOME=/data/copaw）
LEGACY_DIR=~/.copaw
WORKSPACE_DIR="${COPAW_WORKING_DIR}/workspaces/default"

# 需要清理的遗留软链接（与旧版迁移逻辑保持一致）
MIGRATION_ITEMS="sessions memory chats.json jobs.json AGENTS.md SOUL.md PROFILE.md HEARTBEAT.md MEMORY.md BOOTSTRAP.md active_skills customized_skills feishu_receive_ids.json dingtalk_session_webhooks.json"

# 检查是否已经迁移成功（通过检查目标目录中的 AGENTS.md）
if [ -f "${WORKSPACE_DIR}/AGENTS.md" ]; then
    log_info "Migration already completed. Cleaning up legacy symlinks..."

    for item in ${MIGRATION_ITEMS}; do
        if [ -L "${LEGACY_DIR}/${item}" ]; then
            log_info "Removing legacy symlink: ${LEGACY_DIR}/${item}"
            rm -f "${LEGACY_DIR}/${item}"
        fi
    done

    log_info "Legacy symlinks cleanup completed."
    exit 0
fi

# 未迁移或无需清理
exit 0
