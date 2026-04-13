# ==================== QwenPaw Docker 镜像 ====================
#
# 构建参数说明:
#   QWENPAW_VERSION  - QwenPaw 版本 (默认: latest)
#   QWENPAW_EXTRAS   - 可选扩展，用逗号分隔 (例如: llamacpp,mlx,ollama)
#
# 使用示例:
#   # 基础镜像（仅云端模型，包含 Node.js 用于 MCP）
#   docker build --build-arg QWENPAW_VERSION=latest -t qwenpaw:latest .
#
#   # 带本地模型支持 (llama.cpp)
#   docker build --build-arg QWENPAW_VERSION=latest --build-arg QWENPAW_EXTRAS=llamacpp -t qwenpaw:local .
#
#   # 带多个本地模型支持
#   docker build --build-arg QWENPAW_EXTRAS=llamacpp,ollama -t qwenpaw:full .
#
# 注意:
#   - 本地模型支持会显著增加镜像大小，请按需选择
#   - Node.js 24.x LTS 已预装用于 MCP 功能，约增加 150MB

# ==================== 构建阶段 ====================
FROM python:3.12-slim AS builder

# 设置构建参数
ARG QWENPAW_VERSION="latest"
ARG QWENPAW_EXTRAS=""

# 设置工作目录
WORKDIR /build

# 安装构建依赖和升级 pip
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gcc \
        g++ \
        && rm -rf /var/lib/apt/lists/* \
    && python -m pip install --no-cache-dir --upgrade pip setuptools wheel

# 安装 QwenPaw 及其依赖（支持动态版本指定和扩展）
RUN if [ "$QWENPAW_VERSION" = "latest" ]; then \
      if [ -z "$QWENPAW_EXTRAS" ]; then \
        pip install --no-cache-dir qwenpaw; \
      else \
        pip install --no-cache-dir "qwenpaw[$QWENPAW_EXTRAS]"; \
      fi \
    else \
      if [ -z "$QWENPAW_EXTRAS" ]; then \
        pip install --no-cache-dir qwenpaw==${QWENPAW_VERSION}; \
      else \
        pip install --no-cache-dir "qwenpaw[$QWENPAW_EXTRAS]==${QWENPAW_VERSION}"; \
      fi \
    fi

# ==================== 运行阶段 ====================
FROM python:3.12-slim

# 重新声明构建参数，使其可用于 LABEL
ARG QWENPAW_VERSION="latest"

# 设置标签
LABEL maintainer="log-z@github.com"
LABEL description="QwenPaw - Personal Assistant based on AgentScope"
LABEL version="${QWENPAW_VERSION}"

# 设置环境变量
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    # QwenPaw 特定环境变量
    QWENPAW_WORKING_DIR="/data/qwenpaw" \
    QWENPAW_CONFIG_FILE="config.json" \
    QWENPAW_LOG_LEVEL="INFO" \
    QWENPAW_RUNNING_IN_CONTAINER=1 \
    QWENPAW_PORT=8088 \
    TZ=Asia/Shanghai

# 创建非 root 用户（在安装软件之前创建，避免 GID 被占用）
# 固定 UID/GID 为 999
RUN groupadd -r -g 999 qwenpaw && \
    useradd -r -u 999 -g 999 -d /data/qwenpaw -s /sbin/nologin -c "QwenPaw user" qwenpaw

# 安装运行时依赖
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        && rm -rf /var/lib/apt/lists/*

# 安装 Node.js 24.x LTS (用于 MCP 功能支持) 并升级 npm 修复漏洞
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_24.x nodistro main" > /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends nodejs && \
    npm install -g npm@latest && \
    npm cache clean --force && \
    rm -rf /var/lib/apt/lists/*

# 安装 Chromium 及依赖（无头模式，用于 MCP 浏览器功能）
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        chromium \
        chromium-driver \
        fonts-liberation \
        fonts-noto-color-emoji \
        fonts-wqy-zenhei \
        fonts-wqy-microhei \
        && rm -rf /var/lib/apt/lists/* \
        && sed -i 's/^CHROMIUM_FLAGS=""/CHROMIUM_FLAGS="--no-sandbox"/' /usr/bin/chromium

# 设置 Chromium 相关环境变量
ENV CHROME_BIN=/usr/bin/chromium \
    CHROME_PATH=/usr/bin/chromium \
    PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH=/usr/bin/chromium \
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1

# 从构建阶段复制 Python 包
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# 通过软链接实现持久化设置
RUN mkdir -p /data/qwenpaw/.runtime && \
    ln -sf /data/qwenpaw/.runtime /data/qwenpaw.secret

# 兼容旧版 CoPaw 命名（因为从 v1.1.0 开始 CoPaw 改名为 QwenPaw）
RUN ln -sf /usr/local/bin/qwenpaw /usr/local/bin/copaw && \
    ln -sf /usr/local/lib/python3.12/site-packages/qwenpaw /usr/local/lib/python3.12/site-packages/copaw && \
    ln -sf /data/qwenpaw /data/copaw

# 设置目录所有权
RUN chown -R qwenpaw:qwenpaw /usr/local/lib/python3.12/site-packages/qwenpaw && \
    chown -R qwenpaw:qwenpaw /data/qwenpaw

# 设置工作目录
WORKDIR /data/qwenpaw

# 复制启动脚本和健康检查脚本
COPY --chown=qwenpaw:qwenpaw scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY --chown=qwenpaw:qwenpaw scripts/healthcheck.sh /usr/local/bin/healthcheck.sh

# 设置脚本权限
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/healthcheck.sh

# 切换到非 root 用户
USER qwenpaw

# 暴露端口
EXPOSE 8088

# 设置数据卷
VOLUME ["/data/qwenpaw"]

# 入口点
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# 默认命令（监听所有网络接口，使用 QWENPAW_PORT 环境变量）
CMD ["sh", "-c", "qwenpaw app --host 0.0.0.0 --port ${QWENPAW_PORT}"]
