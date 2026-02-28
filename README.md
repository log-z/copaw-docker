# CoPaw Docker 部署

> CoPaw 的 Docker 部署方案，支持一键构建和运行。

## 关于 CoPaw

CoPaw 是一款**个人助理型产品**，部署在你自己的环境中。

- **多通道对话** — 通过钉钉、飞书、QQ、Discord、iMessage 等与你对话
- **定时执行** — 按你的配置自动运行任务
- **能力由 Skills 决定** — 内置定时任务、PDF 与表单、Word/Excel/PPT 文档处理、新闻摘要、文件阅读等，还可在 Skills 中自定义扩展
- **数据全在本地** — 不依赖第三方托管

官方仓库：https://github.com/agentscope-ai/CoPaw

---

## ⚠️ 安全警告 ⚠️

> **CoPaw 没有任何权限控制和登录功能，切勿将服务端口暴露到公网！**

- WebUI 管理界面**没有登录验证机制**，任何能访问该端口的人都可以完全控制你的 CoPaw 实例
- 默认端口 `8088` 仅应在**受信任的内网环境**或通过**反向代理 + 认证**等方式访问
- 如果必须远程访问，请使用以下安全措施之一：
  - 通过 SSH 隧道访问：`ssh -L 8088:localhost:8088 your-server`
  - 配置 Nginx/Caddy 等反向代理并添加 Basic Auth 或 OAuth 认证
  - 使用防火墙限制访问来源 IP

---

## 快速开始

### 前置要求

- Docker >= 20.10
- Docker Compose >= 2.0

### 使用方式选择

#### 方式一：快速体验

最简单的方式，直接使用 docker run 命令启动，适合快速体验。

```bash
docker run -d --name copaw \
  -p 8088:8088 \
  --restart unless-stopped \
  ghcr.io/log-z/copaw-docker:latest
```

访问控制台：http://localhost:8088

---

#### 方式二：使用 Docker Compose（推荐）

使用 Docker Compose 方便管理和配置。

##### 1. （可选）配置环境变量

如需提前配置 API Keys，可复制环境变量示例文件：

```bash
cp .env.example .env
```

编辑 `.env` 文件填入你的配置。也可以在应用启动后通过 Web UI 进行配置。

##### 2. 拉取并启动服务

```bash
docker compose pull
docker compose up -d
```

##### 3. 查看日志

```bash
docker compose logs -f copaw
```

##### 4. 访问控制台

浏览器打开：http://localhost:8088

---

#### 方式三：自行构建镜像

如果需要自定义镜像或预构建镜像不可用，可以自行构建。

##### 1. （可选）配置环境变量

同方式二。

##### 2. 修改 docker-compose.yml

编辑 `docker-compose.yml`，注释掉预构建镜像配置，取消注释构建配置：

```yaml
copaw:
  # image: ghcr.io/log-z/copaw-docker:latest  # 注释预构建镜像
  build:                                     # 取消注释构建配置
    context: .
    dockerfile: Dockerfile
  image: copaw:latest
```

##### 3. 构建镜像

```bash
docker compose build
```

##### 4. 启动服务、查看日志、访问控制台

同方式二。

---

## 项目结构

```
copaw/
├── .github/
│   └── workflows/
│       ├── dev-test.yml       # 开发环境测试工作流
│       ├── prod-test.yml      # 生产环境测试工作流
│       └── release-image.yml  # 发布镜像工作流
├── docs/
│   └── copaw-info.md          # CoPaw 官方文档信息汇总
├── scripts/
│   ├── entrypoint.sh          # 容器启动脚本（自动初始化检查）
│   ├── healthcheck.sh         # 健康检查脚本（Docker HEALTHCHECK）
│   ├── test-startup.sh        # 启动流程测试脚本
│   └── validate-config.sh     # 配置文件验证脚本（启动前检查环境）
├── .dockerignore              # Docker 构建忽略文件
├── .env.example               # 环境变量配置示例
├── .gitignore                 # Git 忽略文件配置
├── CLAUDE.md                  # Claude Code 工作指引
├── Dockerfile                 # 多阶段构建的 Docker 镜像定义
├── README.md                  # 本文件
└── docker-compose.yml         # Docker Compose 编排配置
```

### 数据卷结构（运行时生成）

```
copaw-data:/
└── copaw/
    ├── config.json            # 主配置文件（通道、心跳、语言等）
    ├── SOUL.md                # Agent 核心身份与行为原则（必填）
    ├── AGENTS.md              # 详细工作流程与指南（必填）
    ├── MEMORY.md              # 长期记忆存储
    ├── PROFILE.md             # 身份和用户画像
    ├── HEARTBEAT.md           # 心跳任务配置
    ├── jobs.json              # 定时任务列表
    ├── chats.json             # 会话列表
    ├── active_skills/         # 当前激活的技能
    ├── customized_skills/     # 用户自定义技能
    └── memory/                # Agent 记忆文件存储
```

---

## 常用命令

### 容器管理

```bash
# 启动服务
docker compose up -d

# 停止服务
docker compose stop

# 重启服务
docker compose restart

# 查看日志
docker compose logs -f copaw

# 进入容器
docker compose exec copaw bash

# 停止并删除容器
docker compose down
```

### 数据管理

```bash
# 查看数据卷
docker volume inspect copaw-data

# 备份数据
docker run --rm -v copaw-data:/data -v $(pwd):/backup \
    alpine tar czf /backup/copaw-backup-$(date +%Y%m%d).tar.gz -C /data .

# 恢复数据
docker run --rm -v copaw-data:/data -v $(pwd):/backup \
    alpine tar xzf /backup/copaw-backup-YYYYMMDD.tar.gz -C /data
```

### CoPaw 命令（在容器内执行）

```bash
# 初始化
docker compose exec copaw copaw init --defaults   # 默认配置（不交互）
docker compose exec copaw copaw init              # 交互式初始化

# 模型管理
docker compose exec copaw copaw models list                    # 查看所有提供商
docker compose exec copaw copaw models config                  # 交互式配置
docker compose exec copaw copaw models config-key modelscope   # 配置 API Key
docker compose exec copaw copaw models set-llm                 # 切换活跃模型

# 频道管理
docker compose exec copaw copaw channels list       # 查看所有频道
docker compose exec copaw copaw channels config     # 交互式配置

# 技能管理
docker compose exec copaw copaw skills list         # 查看所有技能
docker compose exec copaw copaw skills config       # 交互式启用/禁用

# 定时任务
docker compose exec copaw copaw cron list           # 列出所有任务
docker compose exec copaw copaw cron create ...     # 创建任务
docker compose exec copaw copaw cron run <job_id>   # 立即执行一次

# 环境变量
docker compose exec copaw copaw env list            # 列出所有变量
docker compose exec copaw copaw env set KEY VALUE   # 设置变量

# 会话管理
docker compose exec copaw copaw chats list          # 列出所有会话

# 维护
docker compose exec copaw copaw clean               # 清空工作目录（交互确认）
```

---

## 环境变量说明

### CoPaw 基础配置

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `COPAW_WORKING_DIR` | `/data/copaw` | 工作目录 |
| `COPAW_CONFIG_FILE` | `config.json` | 配置文件名 |
| `COPAW_HEARTBEAT_FILE` | `HEARTBEAT.md` | 心跳问题文件名 |
| `COPAW_JOBS_FILE` | `jobs.json` | 定时任务文件名 |
| `COPAW_CHATS_FILE` | `chats.json` | 会话列表文件名 |
| `COPAW_LOG_LEVEL` | `info` | 日志级别（debug/info/warning/error/critical） |
| `COPAW_MEMORY_COMPACT_THRESHOLD` | `100000` | 触发记忆压缩的字符阈值 |
| `COPAW_MEMORY_COMPACT_KEEP_RECENT` | `3` | 压缩后保留的最近消息数 |
| `COPAW_MEMORY_COMPACT_RATIO` | `0.7` | 触发压缩的阈值比例（相对于上下文窗口大小） |
| `COPAW_AUTO_INIT` | `true` | 是否自动初始化 |

### Embedding 服务配置

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `EMBEDDING_API_KEY` | （必填） | Embedding 服务的 API Key |
| `EMBEDDING_BASE_URL` | `https://dashscope.aliyuncs.com/compatible-mode/v1` | Embedding 服务地址 |
| `EMBEDDING_MODEL_NAME` | `text-embedding-v4` | Embedding 模型名称 |
| `EMBEDDING_DIMENSIONS` | `1024` | 向量维度 |
| `EMBEDDING_CACHE_ENABLED` | `true` | 是否启用 Embedding 缓存 |
| `FTS_ENABLED` | `true` | 是否启用 BM25 全文检索 |
| `MEMORY_STORE_BACKEND` | `auto` | 记忆存储后端（auto/local/chroma/sqlite） |

### 模型提供商配置

选择一个或多个提供商配置 API Key：

| 变量 | 说明 |
|------|------|
| `MODELSCOPE_API_KEY` | ModelScope（魔搭）API Key |
| `DASHSCOPE_API_KEY` | DashScope（灵积）API Key |
| `OPENAI_API_KEY` | OpenAI 兼容接口 API Key |
| `OPENAI_BASE_URL` | OpenAI 兼容接口地址 |
| `OPENAI_MODEL_NAME` | OpenAI 兼容模型名称 |

---

## 数据持久化

> **⚠️ 重要提示**：本项目的 `copaw-data` 存储卷与 CoPaw 官方镜像的存储卷**不能通用**，原因是文件权限设置不一致。官方镜像可能使用不同的用户权限运行，直接挂载可能导致权限问题。

本项目使用 Docker 数据卷 `copaw-data` 持久化以下内容：

- `config.json` - 主配置文件
- `SOUL.md` - 核心身份与行为原则
- `AGENTS.md` - 详细的工作流程、规则和指南
- `MEMORY.md` - 长期记忆
- `PROFILE.md` - 身份和用户画像
- `HEARTBEAT.md` - 心跳配置
- `jobs.json` - 定时任务列表
- `chats.json` - 会话列表
- `active_skills/` - 当前激活的技能
- `customized_skills/` - 用户自定义技能
- `memory/` - Agent 记忆文件

容器重启后，所有数据都会保留。

---

## 多模态消息支持

各频道对不同消息类型的支持情况：

| 频道 | 接收文本 | 接收图片 | 接收视频 | 接收音频 | 接收文件 | 发送文本 | 发送图片 | 发送视频 | 发送音频 | 发送文件 |
|------|:--------:|:--------:|:--------:|:--------:|:--------:|:--------:|:--------:|:--------:|:--------:|:--------:|
| 钉钉 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 飞书 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Discord | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | 🚧 | 🚧 | 🚧 | 🚧 |
| iMessage | ✓ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ |
| QQ | ✓ | 🚧 | 🚧 | 🚧 | 🚧 | ✓ | 🚧 | 🚧 | 🚧 | 🚧 |

> ✓ = 已支持；🚧 = 施工中；✗ = 不支持

---

## 端口说明

> ⚠️ **再次提醒**：请勿将端口暴露到公网！CoPaw WebUI 没有任何身份验证机制。

| 容器端口 | 主机端口 | 说明 |
|----------|----------|------|
| `8088` | `8088` | CoPaw Web 服务端口 |

如需修改主机端口，编辑 `docker-compose.yml`：

```yaml
ports:
  - "9000:8088"  # 使用 9000 端口访问
```

---

## 网络配置

默认使用 `copaw-network` 桥接网络。如需连接其他容器，可以：

```yaml
# 在 docker-compose.yml 中添加外部网络
networks:
  copaw-network:
    name: your-existing-network
    external: true
```

---

## 故障排除

### 1. 容器无法启动

检查日志：

```bash
docker compose logs copaw
```

### 2. 健康检查失败

检查服务是否正常运行：

```bash
docker compose ps
curl http://localhost:8088/
```

### 3. 数据丢失

数据存储在 Docker 卷中，除非手动删除卷，否则不会丢失。

检查卷状态：

```bash
docker volume ls | grep copaw
```

### 4. API Key 无效

确保 `.env` 文件中的 API Key 正确，并重启服务：

```bash
docker compose restart
```

---

## 镜像信息

### 预构建镜像

- **镜像地址**: `ghcr.io/log-z/copaw-docker:latest`
- **拉取命令**: `docker pull ghcr.io/log-z/copaw-docker:latest`
- **更新频率**: 随 CoPaw 官方版本更新

### 自行构建

- **基础镜像**: `python:3.12-slim`
- **Python 版本**: 3.12
- **工作目录**: `/data/copaw`
- **运行用户**: `copaw`（非 root）

---

## 更多信息

### 控制台功能

服务启动后访问 http://localhost:8088/ 进入控制台，包含以下功能模块：

| 组 | 功能 | 说明 |
|----|------|------|
| 聊天 | 聊天 | 和 CoPaw 对话、管理会话 |
| 控制 | 频道 | 启用/禁用频道、填入凭据 |
| 控制 | 会话 | 筛选、重命名、删除会话 |
| 控制 | 定时任务 | 创建/编辑/删除任务、立即执行 |
| 智能体 | 工作区 | 编辑人设文件、查看记忆、上传/下载 |
| 智能体 | 技能 | 启用/禁用/创建/删除技能 |
| 智能体 | MCP | 启用/禁用/创建/删除 MCP 客户端 |
| 智能体 | 运行配置 | 修改最大迭代次数和最大输入长度 |
| 设置 | 模型 | 配置提供商、管理模型、选择模型 |
| 设置 | 环境变量 | 添加/编辑/删除环境变量 |

### 相关链接

- [CoPaw 官方仓库](https://github.com/agentscope-ai/CoPaw) - 官方 GitHub 仓库
- [CoPaw 官方文档](http://copaw.agentscope.io/docs/)
- [docs/copaw-info.md](docs/copaw-info.md) - CoPaw 官方文档信息汇总
- [AgentScope](https://github.com/agentscope-ai/agentscope) - CoPaw 基础框架

---

## License

本项目基于 CoPaw 的官方部署方案构建。CoPaw 由 [AgentScope 团队](https://github.com/agentscope-ai) 开发，采用 [Apache License 2.0](https://github.com/agentscope-ai/CoPaw/blob/main/LICENSE) 开源许可。
