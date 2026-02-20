# ==================== 构建阶段 ====================
FROM python:3.12-slim AS builder

# 设置构建参数
ARG COPAW_VERSION="latest"

# 设置工作目录
WORKDIR /build

# 安装构建依赖和升级 pip
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gcc \
        g++ \
        && rm -rf /var/lib/apt/lists/* \
    && python -m pip install --no-cache-dir --upgrade pip setuptools wheel

# 安装 CoPaw 及其依赖
RUN pip install --no-cache-dir copaw

# ==================== 运行阶段 ====================
FROM python:3.12-slim

# 设置标签
LABEL maintainer="copaw@example.com"
LABEL description="CoPaw - Personal Assistant based on AgentScope"
LABEL version="${COPAW_VERSION}"

# 设置环境变量
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    # CoPaw 特定环境变量
    COPAW_WORKING_DIR="/data/copaw" \
    COPAW_CONFIG_FILE="config.json" \
    COPAW_LOG_LEVEL="INFO"

# 安装运行时依赖
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        && rm -rf /var/lib/apt/lists/*

# 从构建阶段复制 Python 包
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# 创建非 root 用户
RUN groupadd -r copaw && \
    useradd -r -g copaw -d /data/copaw -s /sbin/nologin -c "CoPaw user" copaw

# 设置 copaw 用户对 Python 包目录的写权限（用于 providers.json）
RUN chown -R copaw:copaw /usr/local/lib/python3.12/site-packages/copaw

# 创建工作目录并设置权限
RUN mkdir -p /data/copaw && \
    chown -R copaw:copaw /data/copaw

# 设置工作目录
WORKDIR /data/copaw

# 复制启动脚本和健康检查脚本
COPY --chown=copaw:copaw scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY --chown=copaw:copaw scripts/healthcheck.sh /usr/local/bin/healthcheck.sh

# 设置脚本权限
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/healthcheck.sh

# 切换到非 root 用户
USER copaw

# 暴露端口
EXPOSE 8088

# 设置数据卷
VOLUME ["/data/copaw"]

# 入口点
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# 默认命令（监听所有网络接口）
CMD ["copaw", "app", "--host", "0.0.0.0"]
