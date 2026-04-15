<div align="center">

# 如何从 CoPaw 迁移到 QwenPaw

</div>

> AgentScope 上游从 v1.1.0 起，将项目从 CoPaw 重命名为 QwenPaw（pip 包名、CLI 命令、配置目录等全部变更）。本文档帮助你将现有 CoPaw 部署迁移到 QwenPaw。

---

## 🔍 何时需要迁移？

如果你**正在使用本项目旧版 CoPaw 镜像**，则需要迁移：

| 镜像来源 | 迁移 | 说明 |
|----------|------|------|
| `ghcr.io/log-z/copaw-docker` | ✅ | 旧版镜像，需要迁移 |
| `logz2/copaw` | ✅ | 旧版镜像，需要迁移 |
| `ghcr.io/log-z/qwenpaw` | ❌ | 新版镜像，无需迁移 |
| `logz2/qwenpaw` | ❌ | 新版镜像，无需迁移 |
| `agentscope/copaw` | ❌ | 官方镜像不适用于此项目 |
| `agentscope/qwenpaw` | ❌ | 官方镜像不适用于此项目 |

简而言之：如果你的 `docker-compose.yml` 中 `image` 字段包含 `copaw`，就需要迁移。

---

## 📦 会迁移什么？

| 资源 | 是否迁移 | 说明 |
|------|---------|------|
| **存储卷** (`copaw-data`) | ✅ | 包含所有配置、工作区、运行时数据，都能完整保留 |
| **网络** | ❌ | 旧容器使用的网络不会迁移，新容器会创建 `qwenpaw-network` |
| **容器** | ❌ | 容器名从 `copaw` 变为 `qwenpaw`，会被重新创建 |

---

## 🚀 迁移步骤（Docker）

### 1. 停止旧版容器

基于旧版的 docker-compose.yaml 文件停止并移除容器，同时清理网络，只有存储卷会被保留：

```bash
docker compose down
```

如果你之前使用 `docker run` 部署，则手动停止并移除容器：

```bash
docker stop copaw && docker rm copaw
```

> 注意：`docker compose down` 或 `docker rm` **不会删除** `copaw-data` 存储卷，你的数据是安全的。

### 2. 更新 compose 文件

获取新版的 [`docker-compose.yml`](../docker-compose.yml) ，替换旧版本。
> 你可以拉取仓库最新代码，也可以直接下载它。

### 3. 启动新版容器

基于新版 docker-compose.yaml 文件启动容器：

```bash
docker compose up -d
```

如果使用 `docker run` 直接运行，请参照 [README.md](../README.md#方式一快速体验) 重新创建容器。

### 4. 环境变量变更

部分环境变量前缀从 `COPAW_` 变更为 `QWENPAW_`，请检查并更新 `.env` 文件（如果存在），例如：

| 旧变量名 | 新变量名 |
|----------|---------|
| `COPAW_PORT` | `QWENPAW_PORT` |
| `COPAW_AUTO_INIT` | `QWENPAW_AUTO_INIT` |
| `COPAW_LOG_LEVEL` | `QWENPAW_LOG_LEVEL` |
| `COPAW_VERSION` | `QWENPAW_VERSION` |

> 第三方 LLM 提供商的 API Key 变量名（如 `OPENAI_API_KEY`、`ANTHROPIC_API_KEY` 等）不受影响。

---

## 🚀 迁移步骤（K8s）

### 1. 调整存储卷

用户数据存储卷的挂载点从 `/data/copaw` 改为 `/data/qwenpaw` 。

### 2. 更换镜像名

使用新版镜像 `ghcr.io/log-z/qwenpaw` 或 `logz2/qwenpaw` 。

### 3. 环境变量变更

参考 Docker 迁移步骤。

---

## 🔧 实现方式

迁移过程无需手动操作数据卷，本项目镜像内置了完整的向后兼容机制，如果你对具体细节感兴趣可以继续阅读。

### 1. 数据卷名称保持不变

[docker-compose.yml](../docker-compose.yml) 中存储卷仍命名为 `copaw-data`，确保升级后能直接挂载旧数据：

```yaml
volumes:
  copaw-data:
    driver: local
    name: copaw-data
```

### 2. 容器内路径兼容符号链接

[Dockerfile](../Dockerfile) 中创建了 `copaw` → `qwenpaw` 的兼容符号链接，确保旧路径仍然可用：

```dockerfile
# 命令兼容：copaw 命令仍可使用
ln -sf /usr/local/bin/qwenpaw /usr/local/bin/copaw

# Python 包目录兼容
ln -sf /usr/local/lib/python3.13/site-packages/qwenpaw \
       /usr/local/lib/python3.13/site-packages/copaw

# 数据目录兼容
ln -sf /data/qwenpaw /data/copaw
ln -sf /data/qwenpaw/.runtime /data/copaw.secret
```

### 3. 配置目录自动迁移

[entrypoint.sh](../scripts/entrypoint.sh) 在每次启动时调用 [migrate-legacy-dir.sh](../scripts/migrate-legacy-dir.sh)，自动将旧的 `.copaw` 目录重命名为 `.qwenpaw`：

```bash
# 启动时自动执行
/usr/local/bin/migrate-legacy-dir.sh "/data/qwenpaw"
```

迁移脚本逻辑：

- 如果存在 `.copaw` 但不存在 `.qwenpaw` → 将 `.copaw` 重命名为 `.qwenpaw`
- 如果 `.copaw` 和 `.qwenpaw` 同时存在 → 将 `.copaw` 重命名为 `.copaw-bak`（避免冲突）
- 如果不存在 `.copaw` → 跳过，无需迁移

### 4. CLI 命令变更

容器内的管理命令从 `copaw` 变更为 `qwenpaw`（兼容符号链接确保 `copaw` 命令仍可使用）：

```bash
# 新命令
docker compose exec qwenpaw qwenpaw init --defaults
docker compose exec qwenpaw qwenpaw models config
docker compose exec qwenpaw qwenpaw channels config

# 旧命令（通过符号链接仍可使用）
docker compose exec qwenpaw copaw init --defaults
```
