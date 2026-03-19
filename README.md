# CoPaw Docker 部署方案

> CoPaw 的 Docker 部署方案，支持一键构建和运行，相比官方镜像更小。

## 关于 CoPaw

CoPaw 是一款**个人助理型产品**，部署在你自己的环境中。

更多信息请看官方仓库：https://github.com/agentscope-ai/CoPaw

---

## ⚠️ 安全警告 ⚠️

> **CoPaw v0.1.0+ 支持可选的 Web 认证功能。对于 v0.1.0 之前的版本或未启用认证时，切勿将服务端口暴露到公网！**

<details>
<summary><strong>v0.1.0+ Web 认证</strong>（推荐启用）</summary>

设置 `COPAW_AUTH_ENABLED=true` 启用 Web 认证：
- 首次访问显示注册页面
- 本地请求 (127.0.0.1) 自动绕过认证
- 密码重置：`docker compose exec copaw copaw auth reset-password`

```bash
# 在 .env 文件中启用
COPAW_AUTH_ENABLED=true
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
├── copaw.secret -> copaw/.runtime    # 软链接指向 .runtime（兼容 SECRET_DIR）
└── copaw/
    ├── config.json            # 根配置文件（包含代理引用，v0.1.0+）
    ├── workspaces/            # 多代理工作区目录（v0.1.0+）
    │   └── default/           # 默认代理工作区
    │       ├── agent.json     # 代理配置
    │       ├── SOUL.md        # Agent 核心身份与行为原则（必填）
    │       ├── AGENTS.md      # 详细工作流程与指南（必填）
    │       ├── PROFILE.md     # 身份和用户画像
    │       ├── active_skills/ # 当前激活的技能
    │       └── customized_skills/ # 用户自定义技能
    ├── .runtime/              # 敏感配置目录
    │   ├── providers.json     # LLM 提供商配置
    │   ├── envs.json          # 环境变量配置
    │   └── auth.json          # Web 认证数据（v0.1.0+）
    ├── HEARTBEAT.md           # 心跳任务配置
    ├── jobs.json              # 定时任务列表
    ├── chats.json             # 会话列表
    ├── custom_channels/       # 用户自定义频道模块
    ├── mcp_clients/           # MCP 客户端配置
    └── memory/                # Agent 记忆文件存储（含每日日志）
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

- `config.json` - 根配置文件（包含代理引用，v0.1.0+）
- `workspaces/default/` - 默认代理工作区（v0.1.0+）
  - `agent.json` - 代理配置
  - `SOUL.md` - 核心身份与行为原则
  - `AGENTS.md` - 详细的工作流程、规则和指南
  - `PROFILE.md` - 身份和用户画像
  - `active_skills/` - 当前激活的技能
  - `customized_skills/` - 用户自定义技能
- `.runtime/` - 敏感配置目录
  - `providers.json` - LLM 提供商配置
  - `envs.json` - 环境变量配置
  - `auth.json` - Web 认证数据（v0.1.0+）
- `HEARTBEAT.md` - 心跳配置
- `jobs.json` - 定时任务列表
- `chats.json` - 会话列表
- `custom_channels/` - 用户自定义频道模块
- `memory/` - Agent 记忆文件

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
| Discord | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ (v0.0.6+) | ✓ (v0.0.6+) | ✓ (v0.0.6+) | ✓ (v0.0.6+) |
| iMessage | ✓ | ✓ (v0.0.5+) | ✓ (v0.0.5+) | ✓ (v0.0.5+) | ✗ | ✓ | ✓ (v0.0.5+) | ✓ (v0.0.5+) | ✓ (v0.0.5+) | ✗ |
| QQ | ✓ | ✓ (v0.0.6+) | ✓ (v0.0.6+) | ✓ (v0.0.6+) | ✓ (v0.0.6+) | ✓ | ✓ (v0.0.7+) | 🚧 | 🚧 | 🚧 |
| Telegram | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Twilio Voice | ✓ | ✗ | ✗ | ✓ | ✗ | ✓ | ✗ | ✗ | ✓ | ✗ |
| MQTT | ✓ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ |
| Mattermost | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Matrix | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |

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
- **Node.js 版本**: 20.x LTS（用于 MCP 功能）
- **工作目录**: `/data/copaw`
- **运行用户**: `copaw`（非 root）

---

## 新功能支持

### v0.1.0 新增功能 (最新)

#### 架构
- **多代理/多工作区架构** - 支持同时运行多个代理，每个代理有独立的工作区（配置、记忆、技能、工具）
- **上下文管理** - Token 计数、`/dump_history` 和 `/load_history` 命令、可配置历史长度限制

#### 安全
- **技能安全扫描** - 安装前检测提示注入、命令注入、硬编码密钥、数据泄露风险
- **破坏性命令检测** - 检测危险 shell 命令（磁盘格式化、fork 炸弹、反向 shell 等）
- **Web 认证** - 可选 Web 认证，单用户注册、Token 登录、本地绕过

#### 频道
- **企业微信频道** - 完整支持，媒体、二维码访问、控制台配置 UI
- **小艺频道** - 华为 A2A 协议频道
- **钉钉 AI 卡片回复** - 支持 AI 卡片增量流式回复

#### 技能与工具
- **LobeHub / ModelScope 技能导入** - 从社区平台直接导入技能
- **内置技能版本同步** - 自动同步更新同时保留用户自定义
- **Guidance 技能** - 回答 CoPaw 安装配置问题的内置技能
- **ZIP 技能导入** - 上传 ZIP 包导入技能
- **内置工具** - 新增 `glob_search` 和 `grep_search` 文件搜索工具
- **view_image 工具** - LLM 可分析本地图片

#### 多模态
- **控制台多模态聊天** - 控制台支持发送图片和文件
- **音频转录** - 通过 Whisper API 或本地 Whisper 转录语音消息

#### 提供商
- **DeepSeek Provider** - 内置支持
- **MiniMax Provider** - 内置支持（国际版和中国版）
- **Kimi Provider** - 内置支持（中国版和国际版）

#### 控制台
- **暗黑模式** - 全页面支持（浅色/深色/跟随系统）
- **流式聊天** - SSE 流式响应，支持重连和中断

#### 其他
- **时区配置** - 控制台时区选择器
- **OS 信息** - 系统提示包含操作系统信息
- **`copaw update` 命令** - 自动更新 CoPaw

---

### v0.0.7 功能 (保留)

#### 安全功能
- **Tool Guard** - 工具执行前安全层，扫描工具参数中的危险模式（如 shell 命令中的 rm、mv）。危险调用被阻止直到用户通过 `/approve` 批准；被拒绝的工具始终被阻止。新增 Security 设置页面管理规则和审批。

#### 频道与通信
- **Mattermost 频道** - 完整集成，支持 DM 和线程对话，文本/图片/文件/视频/音频，输入指示器，可配置访问策略
- **Matrix 频道** - 使用 matrix-nio 的 Matrix 协议集成，支持文本/图片/视频/音频/文件消息
- **Require Mention 过滤** - 群组消息在 bot 被 @提及时才会响应，通过 `require_mention` 为 Discord、钉钉、飞书、Telegram 配置
- **Telegram Markdown 渲染** - Markdown 到 Telegram HTML 转换，发送失败时自动降级为纯文本
- **飞书表情反应** - 处理成功完成时自动添加"DONE"表情反应
- **飞书富文本媒体** - 解析帖子类型富文本消息中的媒体文件
- **QQ 图片消息** - 通过 `[Image: url]` 标签发送图片

#### 模型与 AI 功能
- **模型重试** - LLM API 调用在瞬态错误时自动重试，指数退避，通过 `COPAW_LLM_MAX_RETRIES`、`COPAW_LLM_BACKOFF_BASE`、`COPAW_LLM_BACKOFF_CAP` 配置
- **LM Studio 提供商** - 新增内置模型提供商，含配置 UI
- **Token 使用追踪** - 端到端 token 追踪，含 Token Usage 设置页面、API 和 `get_token_usage` 工具
- **提供商高级配置** - `generate_kwargs` 编辑器用于自定义生成参数；无 API Key 的提供商（Ollama、LM Studio）正确显示为已配置

#### 控制台与 UI
- **工作区拖放** - 拖放重新排序已启用的系统提示文件
- **聊天模型选择** - Chat 页面上的模型选择下拉菜单
- **Agent 语言选择器** - 直接从控制台更改 agent 语言
- **工具批量切换** - Tools 页面上的"全部启用"/"全部禁用"按钮
- **聊天 URL 路由** - 通过 `/chat/:chatId` 直接 URL 访问
- **上下文管理 UI** - 调整压缩比例、保留比例、工具结果压缩设置
- **导航时保留聊天** - 切换页面时聊天保持挂载

#### 技能
- **AI 技能优化** - "AI Optimize"按钮使用活动模型重写技能内容
- **技能卡片描述** - 技能卡片显示 SKILL.md frontmatter 中的描述

#### 安装与平台
- **自动 PyPI 镜像** - 自动镜像选择，中国用户回退到阿里云镜像
- **Docker Secret 目录** - 添加 `/app/working.secret` 用于持久化提供商设置

---

### 控制台功能

服务启动后访问 http://localhost:8088/ 进入控制台，包含以下功能模块：

| 组 | 功能 | 说明 |
|----|------|------|
| 聊天 | 聊天 | 和 CoPaw 对话、管理会话、切换模型（v0.0.7+）、多模态支持（v0.1.0+）、SSE 流式响应（v0.1.0+） |
| 控制 | 频道 | 启用/禁用频道、填入凭据、快速文档链接（v0.0.5+） |
| 控制 | 会话 | 筛选、重命名、删除会话 |
| 控制 | 定时任务 | 创建/编辑/删除任务、立即执行 |
| 智能体 | 工作区 | 编辑人设文件、查看记忆、上传/下载、代理选择器（v0.1.0+） |
| 智能体 | 技能 | 启用/禁用/创建/**导入**/AI优化（v0.0.7+）/删除技能、安全扫描（v0.1.0+） |
| 智能体 | MCP | 启用/禁用/创建/删除 MCP 客户端 |
| 智能体 | 运行配置 | 修改最大迭代次数和最大输入长度 |
| 智能体 | 上下文管理 | 调整压缩比例、保留比例、工具结果压缩设置（v0.0.7+） |
| 智能体 | 工具 | 启用/禁用内置工具、批量切换（v0.0.6+）、glob_search/grep_search（v0.1.0+） |
| 设置 | 模型 | 配置提供商（含自定义提供商）、管理本地/Ollama/LM Studio 模型、选择模型 |
| 设置 | 环境变量 | 添加/编辑/删除环境变量（敏感值遮罩 v0.0.6+） |
| 设置 | 安全 | Tool Guard 安全规则管理（v0.0.7+） |
| 设置 | Token 使用 | 追踪各提供商 token 使用量（v0.0.7+） |
| 设置 | 语音转录 | 语音转录设置（v0.1.0+） |
| 设置 | 主题 | 暗黑模式切换（v0.1.0+） |

**Skills Hub 导入**（v0.0.5+）：支持从社区平台导入技能
- `https://skills.sh/...`
- `https://clawhub.ai/...`
- `https://skillsmp.com/...`
- `https://github.com/...`
- LobeHub（v0.1.0+）
- ModelScope Skill Hub（v0.1.0+）

### 相关链接

- [CoPaw 官方仓库](https://github.com/agentscope-ai/CoPaw) - 官方 GitHub 仓库
- [CoPaw 官方文档](http://copaw.agentscope.io/docs/)
- [docs/copaw-info.md](docs/copaw-info.md) - CoPaw 官方文档信息汇总
- [AgentScope](https://github.com/agentscope-ai/agentscope) - CoPaw 基础框架

---

## License

本项目基于 CoPaw 的官方部署方案构建。CoPaw 由 [AgentScope 团队](https://github.com/agentscope-ai) 开发，采用 [Apache License 2.0](https://github.com/agentscope-ai/CoPaw/blob/main/LICENSE) 开源许可。
