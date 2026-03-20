#!/bin/bash
# =============================================================================
# CoPaw Docker 迁移辅助脚本
# =============================================================================
#
# ⚠️ DEPRECATED: 此脚本已在 CoPaw v0.1.0.post1+ 中废弃
#
#   CoPaw v0.1.0.post1 修复了迁移逻辑，改为从 WORKING_DIR（即 COPAW_WORKING_DIR
#   环境变量）读取文件，而非写死的 ~/.copaw 路径。Docker 环境中 COPAW_WORKING_DIR
#   已正确设置为 /data/copaw，迁移代码能直接找到文件，无需此脚本。
#
#   此脚本将在下个大版本中移除。
#
# =============================================================================
#
# 用途：
#   创建软链接以兼容 CoPaw 迁移代码中写死的 ~/.copaw 路径
#
# 适用版本：
#   从 CoPaw v0.1.0 以下版本迁移到 v0.1.0+
#
# 背景：
#   CoPaw v0.1.0 引入了多工作区架构，迁移逻辑在 migration.py 中：
#   - _LEGACY_DEFAULT_WORKING_DIR = Path("~/.copaw")  # 写死的路径
#   - 迁移时会从 ~/.copaw 查找文件并复制到 workspaces/default/
#
#   Docker 环境中：
#   - HOME=/data/copaw（copaw 用户的 home 目录）
#   - ~/.copaw 展开为 /data/copaw/.copaw
#   - 实际旧文件在 /data/copaw/ 根目录（WORKING_DIR）
#
#   因此迁移代码找不到需要迁移的文件。
#
# 解决方案：
#   在 ~/.copaw 目录中创建软链接，指向 WORKING_DIR 根目录的文件，
#   使迁移代码能够正确找到并复制这些文件。
#
# 迁移完成后：
#   脚本会检测 workspaces/default/AGENTS.md 是否存在，
#   如果存在则说明迁移已完成，清理遗留的软链接。
#
# =============================================================================

set -e

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# 获取参数
COPAW_WORKING_DIR="${1:-/data/copaw}"

# 写死的路径，与 CoPaw 源码 migration.py 保持一致
# 注意：~/.copaw 在 Docker 中展开为 /data/copaw/.copaw（HOME=/data/copaw）
LEGACY_DIR=~/.copaw
WORKSPACE_DIR="${COPAW_WORKING_DIR}/workspaces/default"

# 需要迁移的文件和目录（与 CoPaw 源码 migration.py 保持一致）
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

# 如果 .copaw 目录不存在，无需迁移
if [ ! -d "${LEGACY_DIR}" ]; then
    exit 0
fi

for item in ${MIGRATION_ITEMS}; do
    # 如果目标不存在且源存在，创建软链接
    if [ ! -e "${LEGACY_DIR}/${item}" ] && [ -e "${COPAW_WORKING_DIR}/${item}" ]; then
        log_info "Creating symlink: ${LEGACY_DIR}/${item} -> ${COPAW_WORKING_DIR}/${item}"
        ln -sf "${COPAW_WORKING_DIR}/${item}" "${LEGACY_DIR}/${item}"
    fi
done
