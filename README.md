<div align="center">

# CoPaw Docker 部署方案

[![GitHub Container Registry](https://img.shields.io/badge/GHCR-ghcr.io%2Flog--z%2Fcopaw--docker-blue?logo=docker&logoColor=white)](https://github.com/log-z/copaw-docker/pkgs/container/copaw-docker)
[![Docker Hub](https://img.shields.io/badge/Docker%20Hub-logz2%2Fcopaw-blue?logo=docker&logoColor=white)](https://hub.docker.com/r/logz2/copaw)

**支持一键构建和运行，相比官方镜像更小**

</div>

CoPaw 是一款个人 AI 助手，部署在你自己的环境中，支持多种聊天平台接入，具备强大的扩展能力。

更多信息请看官方仓库：[agentscope-ai/CoPaw](https://github.com/agentscope-ai/CoPaw)

---

## ⚠️ 安全警告 ⚠️

> **CoPaw v0.1.0+ 支持可选的 Web 认证功能。对于 v0.1.0 之前的版本或未启用认证时，切勿将服务端口暴露到公网！**

<details>
<summary><strong>v0.1.0+ Web 认证</strong>（推荐启用）</summary>

设置 `COPAW_AUTH_ENABLED=true` 启用 Web 认证：
- 首次访问显示注册页面
- 本地请求 (127.0.0.1) 自动绕过认证
- 支持环境变量自动注册（适用于自动化部署）
- 密码重置：`docker compose exec copaw copaw auth reset-password`

```bash
# 在 .env 文件中启用
COPAW_AUTH_ENABLED=true

# 可选：自动注册管理员账户（首次启动时生效）
COPAW_AUTH_USERNAME=admin
COPAW_AUTH_PASSWORD=your_secure_password
```
</details>

<details>
<summary><strong>v0.0.x 或未启用认证时</strong>，WebUI 管理界面<strong>没有登录验证机制</strong>，任何能访问该端口的人都可以完全控制你的 CoPaw 实例。点击展开安全建议。</summary>

- 默认端口 `8088` 仅应在**受信任的内网环境**或通过**反向代理 + 认证**等方式访问
- 如果必须远程访问，请使用以下安全措施之一：
  - 通过 SSH 隧道访问：`ssh -L 8088:localhost:8088 your-server`
  - 配置 Nginx/Caddy 等反向代理并添加 Basic Auth 或 OAuth 认证
  - 使用防火墙限制访问来源 IP
</details>

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
  -p 127.0.0.1:8088:8088 \
  -v copaw-data:/data/copaw \
  --restart unless-stopped \
  ghcr.io/log-z/copaw-docker:latest
```

访问控制台：http://localhost:8088

---

#### 方式二：使用 Docker Compose（推荐✨）

使用 Docker Compose 方便管理和配置。

##### 1. （可选）配置环境变量

如需提前配置 API Keys，可复制环境变量示例文件：

```bash
cp .env.example .env
```

编辑 `.env` 文件填入你的配置。也可以在应用启动后通过 Web UI 进行配置。

##### 2. 拉取并启动服务

```bash
docker compose pull      # 拉取或更新镜像
docker compose up -d     # 后台启动服务
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
│   └── test-startup.sh        # 启动流程测试脚本
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
├── copaw.secret -> copaw/.runtime    # 软链接指向 .runtime（兼容 SECRET_DIR）
└── copaw/
    ├── .runtime/              # 敏感配置目录
    │   ├── auth.json          # Web 认证数据（v0.1.0+）
    │   ├── envs.json          # 环境变量配置
    │   └── providers.json     # LLM 提供商配置
    ├── custom_channels/       # 用户自定义频道模块
    ├── mcp_clients/           # MCP 客户端配置
    ├── memory/                # Agent 记忆文件存储（含每日日志）
    ├── workspaces/            # 多代理工作区目录（v0.1.0+）
    │   └── default/           # 默认代理工作区
    │       ├── active_skills/ # 当前激活的技能
    │       ├── customized_skills/ # 用户自定义技能
    │       ├── AGENTS.md      # 详细工作流程与指南（必填）
    │       ├── PROFILE.md     # 身份和用户画像
    │       ├── SOUL.md        # Agent 核心身份与行为原则（必填）
    │       └── agent.json     # 代理配置
    ├── chats.json             # 会话列表
    ├── config.json            # 根配置文件（包含代理引用，v0.1.0+）
    ├── HEARTBEAT.md           # 心跳任务配置
    └── jobs.json              # 定时任务列表
```

> **v0.1.0 多工作区迁移**：现有配置会在首次启动时自动迁移到新的多工作区架构。

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

# 模型管理（云端提供商）
docker compose exec copaw copaw models list                    # 查看所有提供商
docker compose exec copaw copaw models config                  # 交互式配置
docker compose exec copaw copaw models config-key modelscope   # 配置 ModelScope API Key
docker compose exec copaw copaw models config-key dashscope    # 配置 DashScope API Key
docker compose exec copaw copaw models config-key anthropic    # 配置 Anthropic API Key（v0.0.5+）
docker compose exec copaw copaw models config-key gemini       # 配置 Gemini API Key（v0.0.6+）
docker compose exec copaw copaw models config-key lmstudio     # 配置 LM Studio（v0.0.7+）
docker compose exec copaw copaw models config-key deepseek     # 配置 DeepSeek（v0.1.0+）
docker compose exec copaw copaw models config-key minimax      # 配置 MiniMax（v0.1.0+）
docker compose exec copaw copaw models config-key kimi         # 配置 Kimi（v0.1.0+）
docker compose exec copaw copaw models config-key custom       # 配置自定义提供商
docker compose exec copaw copaw models set-llm                 # 切换活跃模型

# 模型管理（本地模型 - 需额外依赖）
docker compose exec copaw copaw models download <repo_id>      # 下载本地模型 (llama.cpp/MLX)
docker compose exec copaw copaw models local                   # 查看已下载模型
docker compose exec copaw copaw models remove-local <model_id> # 删除已下载模型
docker compose exec copaw copaw models ollama-pull <model>     # 拉取 Ollama 模型
docker compose exec copaw copaw models ollama-list             # 列出 Ollama 模型

# 频道管理
docker compose exec copaw copaw channels list       # 查看所有频道
docker compose exec copaw copaw channels config     # 交互式配置
docker compose exec copaw copaw channels install <key>    # 安装自定义频道
docker compose exec copaw copaw channels add <key>        # 添加频道到配置
docker compose exec copaw copaw channels remove <key>     # 删除自定义频道

# 技能管理
docker compose exec copaw copaw skills list         # 查看所有技能
docker compose exec copaw copaw skills config       # 交互式启用/禁用

# 定时任务
docker compose exec copaw copaw cron list           # 列出所有任务
docker compose exec copaw copaw cron create ...     # 创建任务
docker compose exec copaw copaw cron state <job_id> # 查看任务状态
docker compose exec copaw copaw cron pause <job_id> # 暂停任务
docker compose exec copaw copaw cron resume <job_id># 恢复任务
docker compose exec copaw copaw cron run <job_id>   # 立即执行一次

# 环境变量
docker compose exec copaw copaw env list            # 列出所有变量
docker compose exec copaw copaw env set KEY VALUE   # 设置变量
docker compose exec copaw copaw env delete KEY      # 删除变量

# 会话管理
docker compose exec copaw copaw chats list          # 列出所有会话
docker compose exec copaw copaw chats get <id>      # 查看会话详情
docker compose exec copaw copaw chats create ...    # 创建新会话
docker compose exec copaw copaw chats update <id> --name "新名称"  # 重命名会话
docker compose exec copaw copaw chats delete <id>   # 删除会话

# 维护
docker compose exec copaw copaw clean               # 清空工作目录（交互确认）
docker compose exec copaw copaw clean --yes         # 不确认直接清空

# 配置重载（无需重启容器，v0.0.5+）
docker compose exec copaw copaw daemon reload-config # 重新加载配置
docker compose exec copaw copaw daemon version      # 查看 CoPaw 版本

# 更新与认证（v0.1.0+）
docker compose exec copaw copaw update              # 更新 CoPaw 到最新版本（在容器中更新无意义）
docker compose exec copaw copaw auth reset-password # 重置 Web UI 密码

# Agent 与消息（v0.2.0+）
docker compose exec copaw copaw agents list         # 列出所有代理
docker compose exec copaw copaw agents enable <agent>  # 启用代理（v1.0.0+）
docker compose exec copaw copaw agents disable <agent> # 禁用代理（v1.0.0+）
docker compose exec copaw copaw message push        # 向频道推送消息
docker compose exec copaw copaw message send        # 向代理发送请求
```

---

## 环境变量说明

### CoPaw 基础配置

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `COPAW_WORKING_DIR` | `/data/copaw` | 工作目录（固定不可修改） |
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
| `ANTHROPIC_API_KEY` | Anthropic API Key（v0.0.5+ 新增） |
| `GEMINI_API_KEY` | Gemini API Key（v0.0.6+ 新增） |
| `DEEPSEEK_API_KEY` | DeepSeek API Key（v0.1.0+ 新增） |
| `MINIMAX_API_KEY` | MiniMax API Key（v0.1.0+ 新增） |
| `KIMI_API_KEY` | Kimi API Key（v0.1.0+ 新增） |

### Web 认证配置（v0.1.0+ 新增）

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `COPAW_AUTH_ENABLED` | `false` | 是否启用 Web 认证（启用后首次访问显示注册页面） |
| `COPAW_AUTH_USERNAME` | （空） | 自动注册管理员用户名（仅首次启动时生效） |
| `COPAW_AUTH_PASSWORD` | （空） | 自动注册管理员密码（仅首次启动时生效） |

### 模型重试配置（v0.0.7+ 新增）

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `COPAW_LLM_MAX_RETRIES` | `3` | LLM API 调用最大重试次数 |
| `COPAW_LLM_BACKOFF_BASE` | `1.0` | 重试退避基准时间（秒） |
| `COPAW_LLM_BACKOFF_CAP` | `30.0` | 最大退避时间上限（秒） |

### Web 服务配置

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `COPAW_CORS_ORIGINS` | `*` | CORS 允许的来源（v0.0.4+ 新增） |
| `COPAW_RUNNING_IN_CONTAINER` | `true` | 是否在容器内运行（自动检测，通常无需手动设置） |

---

## 数据持久化

> **⚠️ 重要提示**：本项目的 `copaw-data` 存储卷与 CoPaw 官方镜像的存储卷**不能通用**，原因是文件权限设置不一致。官方镜像可能使用不同的用户权限运行，直接挂载可能导致权限问题。

本项目使用 Docker 数据卷 `copaw-data` 持久化以下内容：

- `.runtime/` - 敏感配置目录
  - `auth.json` - Web 认证数据（v0.1.0+）
  - `envs.json` - 环境变量配置
  - `providers.json` - LLM 提供商配置
- `custom_channels/` - 用户自定义频道模块
- `memory/` - Agent 记忆文件
- `workspaces/default/` - 默认代理工作区（v0.1.0+）
  - `active_skills/` - 当前激活的技能
  - `customized_skills/` - 用户自定义技能
  - `AGENTS.md` - 详细的工作流程、规则和指南
  - `PROFILE.md` - 身份和用户画像
  - `SOUL.md` - 核心身份与行为原则
  - `agent.json` - 代理配置
- `chats.json` - 会话列表
- `config.json` - 根配置文件（包含代理引用，v0.1.0+）
- `HEARTBEAT.md` - 心跳配置
- `jobs.json` - 定时任务列表

容器重启后，所有数据都会保留。

> **v0.1.0 多工作区迁移**：现有配置会在首次启动时自动迁移到新的多工作区架构。

---

## 多模态消息支持

各频道对不同消息类型的支持情况：

| 频道 | 接收文本 | 接收图片 | 接收视频 | 接收音频 | 接收文件 | 发送文本 | 发送图片 | 发送视频 | 发送音频 | 发送文件 |
|------|:--------:|:--------:|:--------:|:--------:|:--------:|:--------:|:--------:|:--------:|:--------:|:--------:|
| 钉钉 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 飞书 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 企业微信 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 微信 iLink | 🚧 | 🚧 | 🚧 | 🚧 | 🚧 | 🚧 | 🚧 | 🚧 | 🚧 | 🚧 |
| Discord | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| iMessage | ✓ | ✓ | ✓ | ✓ | ✗ | ✓ | ✓ | ✓ | ✓ | ✗ |
| QQ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | 🚧 | 🚧 | 🚧 |
| Telegram | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Twilio Voice | ✓ | ✗ | ✗ | ✓ | ✗ | ✓ | ✗ | ✗ | ✓ | ✗ |
| MQTT | ✓ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ |
| Mattermost | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Matrix | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 小艺 | ✓ | ✓ | ✓ | ✗ | ✓ | ✓ | ✓ | ✗ | ✗ | ✓ |

> ✓ = 已支持；🚧 = 施工中；✗ = 不支持

---

## 端口说明

> ⚠️ **安全提醒**：v0.1.0 之前或未启用认证时，请勿将端口暴露到公网！环境变量启用 `COPAW_AUTH_ENABLED=true` 后可降低风险。

| 容器端口 | 主机端口 | 说明 |
|----------|----------|------|
| `8088` | `127.0.0.1:8088` | CoPaw Web 服务端口（v0.0.5+ 默认绑定 127.0.0.1） |

如需修改主机端口，编辑 `docker-compose.yml`：

```yaml
ports:
  - "9000:8088"  # 使用 9000 端口访问
  # 或 v0.1.0+ 启用认证后允许外部访问
  # - "0.0.0.0:8088:8088"
```

> **安全更新**：v0.0.5 起，默认端口绑定改为 `127.0.0.1` 以提高安全性。v0.1.0+ 启用认证后可降低风险。

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
- **Node.js 版本**: 24.x LTS（用于 MCP 功能）
- **工作目录**: `/data/copaw`
- **运行用户**: `copaw`（非 root）

---

## 新功能支持

### v1.0.0.post2 补丁修复

> 详见 [docs/copaw-info.md](docs/copaw-info.md)。

#### 新功能
- **Console MCP** - 控制台支持 MCP 配置

#### 优化
- **技能启动迁移优化** - 避免每次启动时重复迁移技能
- **技能池工作区同步移除** - 提高运行效率
- **技能列表刷新优化** - 优化技能列表加载性能
- **网站界面优化** - 改善列表标记可见性、控制台语言选项排序

#### Bug 修复
- **企业微信心跳重连** - 心跳失败时在独立任务中调度重连，避免阻塞
- **异步工具状态** - 修复异步工具状态显示问题
- **Provider 下载检查** - 下载前检查仓库是否存在
- **本地模型修复** - 修复本地模型相关问题

---

### v1.0.0.post1 补丁修复

> 详见 [docs/copaw-info.md](docs/copaw-info.md)。

#### 新功能
- **Console 选择 Agent** - 控制台支持选择特定 Agent 进行对话
- **多模态视频分析** - 多模态模型支持视频分析能力
- **运行时健壮性改进** - 提升运行时稳定性和可靠性

#### Bug 修复
- **暗黑模式斜杠命令对比度** - 修复暗黑模式下斜杠命令菜单的文字对比度
- **技能签名缓存** - 修复技能签名缓存，支持 requires 字段列表格式
- **Llama.cpp Windows GPU** - 修复 Windows 下 Nvidia GPU 支持，安装前检查 macOS 版本
- **钉钉定时任务** - sessionWebhook 过期时回退到 Open API
- **Thinking 模型工具防护** - 修复使用 thinking 模型时的工具防护问题
- **Windows Shell 命令** - 修复 Windows 下 shell 命令中的 `\n` 转义
- **anyio 版本锁定** - 避免 busy-wait 循环

---

### v1.0.0 新增功能

> 详见 [docs/copaw-info.md](docs/copaw-info.md)。

#### Multi-Agent System
- **Background Task Support** - Agent 间通信后台执行，支持任务追踪和取消（`--background` 标志）
- **Agent Enable/Disable Toggle** - 通过控制台 UI 和 API 启用/禁用 Agent
- **Unified Priority Queue & `/stop`** - 按频道/会话的优先级队列，`/stop` 取消运行中任务

#### Providers and Models
- **CoPaw Local Model** - 内置本地模型提供商，基于 llama.cpp，自动下载配置
- **Scoped Active Model** - 活跃模型可全局设置或按 Agent 单独设置
- **Global LLM Rate Limiter** - QPM 滑动窗口限速、并发控制、全局 429 协调

#### Security
- **System Reboot & Service Protection** - 阻止系统重启、关机、提权等危险命令
- **Chinese Prompt Injection Detection** - 中文正则模式检测提示注入

#### Channels
- **WeChat iLink Bot** - 新增微信个人频道（iLink Bot API）
- **Custom Channel HTTP Routes** - 自定义频道可注册 FastAPI 路由
- **Discord Bot Message Filtering** - 可配置是否处理其他 Bot 消息
- **DingTalk Widescreen Cards** - 钉钉宽屏 AI 卡片布局
- **WeCom Media Upload** - WebSocket 媒体上传，提高可靠性

#### Tools & Skills
- **Async Tool Execution** - 按工具粒度异步执行，自动注册后台任务辅助工具
- **Skill Pool Architecture** - 双层技能系统（共享池 + 按工作区技能）
- **Browser CDP Support** - Chrome DevTools Protocol 集成
- **Multi-Workspace Cookie Management** - 按工作区 Cookie 隔离和持久化

#### Console & UI
- **Multimodal Preview** - 图片/音频/视频/文件附件预览
- **Chat Session Labels** - 聊天会话显示频道标签和图标
- **Command Suggestions** - `/clear`、`/compact`、`/approve`、`/deny` 命令建议
- **Console Visual Refresh** - 控制台样式全面更新
- **Download Page** - 桌面安装包下载页面

#### Context & Memory
- **Context Management v2.0** - 上下文和记忆管理重大重构
- **Improved Truncation Logic** - 50KB Markdown 保护，更清晰的截断提示

---

### v0.2.0 新增功能

> 详见 [docs/copaw-info.md](docs/copaw-info.md)。

#### Agent
- **Inter-Agent Communication** - `copaw agents` 和 `copaw message` CLI 命令，支持代理间通信
- **Built-in QA Agent** - 内置 QA 代理，回答 CoPaw 安装使用问题
- **Config Auto-Repair** - config.json 损坏时自动修复

#### Security
- **File Access Guard** - 敏感文件/目录访问保护
- **Tool Guard Enhanced** - 并行工具执行时的正确防护

#### Channels
- **Feishu SDK Migration** - 迁移到官方 lark-oapi SDK，支持区域选择器（中国/国际版）
- **XiaoYi File & Image** - 小艺频道支持文件和图片

#### Console & UI
- **Audio, Video & Speech Input** - 控制台支持发送和显示音频、视频、语音附件
- **Stream Reconnection** - 页面刷新自动重连流式会话
- **Web Account Management** - 侧边栏更改用户名密码

#### 其他
- **Faster CLI Startup** - CLI 命令延迟加载，启动更快
- **Stable Prompts for KV Cache** - 提高 LLM KV 缓存命中率

---

### 控制台功能

服务启动后访问 http://localhost:8088/ 进入控制台，包含以下功能模块：

| 组 | 功能 | 说明 |
|----|------|------|
| 聊天 | 聊天 | 和 CoPaw 对话、管理会话、切换模型、多模态支持、SSE 流式响应、音视频支持（v0.2.0+）、多模态预览（v1.0.0+）、频道标签（v1.0.0+）、命令建议（v1.0.0+）、选择 Agent 对话（v1.0.0.post1+） |
| 控制 | 频道 | 启用/禁用频道、填入凭据、快速文档链接、飞书区域选择器（v0.2.0+） |
| 控制 | 会话 | 筛选、重命名、删除会话 |
| 控制 | 定时任务 | 创建/编辑/删除任务、立即执行 |
| 智能体 | 工作区 | 编辑人设文件、查看记忆、上传/下载、代理选择器 |
| 智能体 | 技能 | 启用/禁用/创建/**导入**/AI优化/删除技能、安全扫描、Skill Pool 双层架构（v1.0.0+） |
| 智能体 | MCP | 启用/禁用/创建/删除 MCP 客户端、控制台 MCP 配置（v1.0.0.post2+） |
| 智能体 | 运行配置 | 修改最大迭代次数和最大输入长度、LLM 重试配置（v0.2.0+） |
| 智能体 | 上下文管理 | 调整压缩比例、保留比例、工具结果压缩设置 |
| 智能体 | 工具 | 启用/禁用内置工具、批量切换、glob_search/grep_search |
| 设置 | 模型 | 配置提供商（含自定义提供商）、管理本地/Ollama/LM Studio 模型、选择模型、搜索过滤（v0.2.0+）、CoPaw Local Model（v1.0.0+）、视频分析（v1.0.0.post1+） |
| 设置 | 环境变量 | 添加/编辑/删除环境变量（敏感值遮罩） |
| 设置 | 安全 | Tool Guard 安全规则管理、文件访问保护（v0.2.0+）、系统重启/服务保护（v1.0.0+）、中文提示注入检测（v1.0.0+） |
| 设置 | Token 使用 | 追踪各提供商 token 使用量 |
| 设置 | 语音转录 | 语音转录设置 |
| 设置 | 主题 | 暗黑模式切换 |
| 设置 | 账户 | 更改用户名密码（v0.2.0+，认证启用时） |

**Skills Hub 导入**：支持从社区平台导入技能
- `https://skills.sh/...`
- `https://clawhub.ai/...`
- `https://skillsmp.com/...`
- `https://github.com/...`
- LobeHub
- ModelScope Skill Hub

### 相关链接

- [CoPaw 官方仓库](https://github.com/agentscope-ai/CoPaw) - 官方 GitHub 仓库
- [CoPaw 官方文档](http://copaw.agentscope.io/docs/)
- [docs/copaw-info.md](docs/copaw-info.md) - CoPaw 官方文档信息汇总
- [AgentScope](https://github.com/agentscope-ai/agentscope) - CoPaw 基础框架

---

## License

本项目基于 CoPaw 的官方部署方案构建。CoPaw 由 [AgentScope 团队](https://github.com/agentscope-ai) 开发，采用 [Apache License 2.0](https://github.com/agentscope-ai/CoPaw/blob/main/LICENSE) 开源许可。
