<div align="center">

# QwenPaw Docker 部署方案

[![GitHub Container Registry](https://img.shields.io/badge/GHCR-ghcr.io%2Flog--z%2Fqwenpaw-blue?logo=docker&logoColor=white)](https://github.com/log-z/copaw-docker/pkgs/container/qwenpaw)
[![Docker Hub](https://img.shields.io/badge/Docker%20Hub-logz2%2Fqwenpaw-blue?logo=docker&logoColor=white)](https://hub.docker.com/r/logz2/qwenpaw)

**支持一键构建和运行，相比官方镜像更小**

</div>

QwenPaw（原 CoPaw 项目）是一款个人 AI 助手，部署在你自己的环境中，支持多种聊天平台接入，具备强大的扩展能力。

更多信息请看官方仓库：[agentscope-ai/QwenPaw](https://github.com/agentscope-ai/QwenPaw)

> [!NOTE]
> 如果你正在使用旧版 CoPaw 镜像，请参阅 [如何从 CoPaw 迁移到 QwenPaw](docs/migrate-from-copaw.md) 。

---

##  安全警告 

> ⚠️ **QwenPaw 支持可选的安全认证功能。对于未启用的部署，切勿将服务端口暴露到公网！** ⚠️

<details>
<summary><strong>如何开启/禁用安全认证</strong></summary>

设置 `QWENPAW_AUTH_ENABLED=true` 启用安全认证，可降低风险：
- 首次访问显示注册页面
- 容器内部请求 (127.0.0.1) 自动绕过认证
- v1.1.4+: 可配置白名单允许信任 IP 免认证访问（受限于容器子网隔离，此配置意义不大）
- 密码重置：`docker compose exec qwenpaw qwenpaw auth reset-password`

```bash
# 在 .env 文件中启用
QWENPAW_AUTH_ENABLED=true

# 可选：自动注册管理员账户（首次启动时生效）
QWENPAW_AUTH_USERNAME=admin
QWENPAW_AUTH_PASSWORD=your_secure_password
```

设置 `QWENPAW_AUTH_ENABLED=false` 禁用安全认证：
```bash
# 在 .env 文件中禁用
QWENPAW_AUTH_ENABLED=false
```

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
docker run -d --name qwenpaw \
  -p 127.0.0.1:8088:8088 \
  -v copaw-data:/data/qwenpaw \
  --restart unless-stopped \
  ghcr.io/log-z/qwenpaw:latest
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
docker compose logs -f qwenpaw
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
qwenpaw:
  # image: ghcr.io/log-z/qwenpaw:latest  # 注释预构建镜像
  build:                                 # 取消注释构建配置
    context: .
    dockerfile: Dockerfile
  image: qwenpaw:latest
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
copaw-docker/
├── .github/
│   └── workflows/
│       ├── dev-test.yml       # 开发环境测试工作流
│       ├── prod-test.yml      # 生产环境测试工作流
│       ├── release-image.yml  # 发布镜像工作流
│       └── trivy-scan.yml     # Trivy 漏洞扫描工作流
├── docs/
│   └── qwenpaw-info.md        # QwenPaw 官方文档信息汇总
├── scripts/
│   ├── entrypoint.sh          # 容器启动脚本（自动初始化检查）
│   ├── healthcheck.sh         # 健康检查脚本（Docker HEALTHCHECK）
│   └── test-startup.sh        # 启动流程测试脚本
├── .dockerignore              # Docker 构建忽略文件
├── .env.example               # 环境变量配置示例
├── .gitattributes             # Git 属性配置
├── .gitignore                 # Git 忽略文件配置
├── CLAUDE.md                  # Claude Code 工作指引
├── Dockerfile                 # 多阶段构建的 Docker 镜像定义
├── LICENSE                    # 开源许可证
├── README.md                  # 本文件
├── docker-compose.override.yml # Docker Compose 覆盖配置
└── docker-compose.yml         # Docker Compose 编排配置
```

### 数据卷结构（运行时生成）

```
copaw-data:/
├── qwenpaw.backups -> qwenpaw/.backups   # 软链接指向 .backups（兼容 BACKUP_DIR）
├── qwenpaw.secret -> qwenpaw/.runtime    # 软链接指向 .runtime（兼容 SECRET_DIR）
└── qwenpaw/
    ├── .backups/              # 备份存储目录
    ├── .runtime/              # 敏感配置目录
    │   ├── auth.json          # 安全认证数据（v0.1.0+）
    │   ├── envs.json          # 环境变量配置
    │   └── providers.json     # LLM 提供商配置
    ├── memory/                # Agent 记忆文件存储（v2.0.0+ 由 ReMe v0.4.0 后端管理）
    ├── media/                 # 频道媒体默认目录（v2.0.0+）
    ├── local_models/          # 本地模型目录（含 bin/logs/models/tmp，v2.0.0+）
    ├── models/                # 本地模型数据目录
    ├── plugins/               # 插件安装目录（`qwenpaw plugin install`）
    ├── workspaces/            # 多代理工作区目录（v0.1.0+）
    │   └── default/           # 默认代理工作区
    │       ├── agent.json     # 代理配置
    │       ├── AGENTS.md      # 详细工作流程与指南（必填）
    │       ├── PROFILE.md     # 身份和用户画像
    │       ├── SOUL.md        # Agent 核心身份与行为原则（必填）
    │       ├── active_skills/     # 当前激活的技能
    │       ├── customized_skills/ # 用户自定义技能
    │       ├── plugins/       # 插件扩展（v1.0.2+）
    │       ├── drivers/       # 外部能力驱动卡（MCP/ACP 等，v2.0.0+ 取代旧 mcp_clients/）
    │       ├── credentials.yaml   # 驱动/邮箱加密凭据（v2.2.0+）
    │       ├── history.db     # 滚动上下文工作历史（SQLite + FTS5，每个工作区一份，v2.0.0+）
    │       └── media/         # 该工作区上传媒体
    ├── chats.json             # 会话列表
    ├── config.json            # 根配置文件（包含代理引用，v0.1.0+）
    ├── HEARTBEAT.md           # 心跳任务配置
    ├── jobs.json              # 定时任务列表
    └── token_usage.json       # Token 用量统计
```

> **v0.1.0 多工作区迁移**：现有配置会在首次启动时自动迁移到新的多工作区架构。
>
> **v2.0.0 工作目录变化**：新增 `history.db`（SQLite 滚动上下文，默认 30 天保留，启动时自动导入现有会话）；`memory/` 改由 ReMe v0.4.0 后端管理；记忆写入改为按轮次中间件执行，不再绑定到会话关闭。

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
docker compose logs -f qwenpaw

# 进入容器
docker compose exec qwenpaw bash

# 停止并删除容器
docker compose down
```

### 数据管理

```bash
# 查看数据卷
docker volume inspect copaw-data

# 备份数据
docker run --rm -v copaw-data:/data -v $(pwd):/backup \
    alpine tar czf /backup/qwenpaw-backup-$(date +%Y%m%d).tar.gz -C /data .

# 恢复数据
docker run --rm -v copaw-data:/data -v $(pwd):/backup \
    alpine tar xzf /backup/qwenpaw-backup-YYYYMMDD.tar.gz -C /data
```

### QwenPaw 命令（在容器内执行）

```bash
# 初始化
docker compose exec qwenpaw qwenpaw init --defaults   # 默认配置（不交互）
docker compose exec qwenpaw qwenpaw init              # 交互式初始化

# 模型管理（云端提供商）
docker compose exec qwenpaw qwenpaw models list                    # 查看所有提供商
docker compose exec qwenpaw qwenpaw models config                  # 交互式配置
docker compose exec qwenpaw qwenpaw models config-key modelscope   # 配置 ModelScope API Key
docker compose exec qwenpaw qwenpaw models config-key dashscope    # 配置 DashScope API Key
docker compose exec qwenpaw qwenpaw models config-key anthropic    # 配置 Anthropic API Key（v0.0.5+）
docker compose exec qwenpaw qwenpaw models config-key gemini       # 配置 Gemini API Key（v0.0.6+）
docker compose exec qwenpaw qwenpaw models config-key lmstudio     # 配置 LM Studio（v0.0.7+）
docker compose exec qwenpaw qwenpaw models config-key deepseek     # 配置 DeepSeek（v0.1.0+）
docker compose exec qwenpaw qwenpaw models config-key minimax      # 配置 MiniMax（v0.1.0+）
docker compose exec qwenpaw qwenpaw models config-key kimi-cn      # 配置 Kimi 国内站（v2.2.0+，旧 kimi 已拆分）
docker compose exec qwenpaw qwenpaw models config-key kimi-intl    # 配置 Kimi 国际站（v2.2.0+）
docker compose exec qwenpaw qwenpaw models config-key zhipu-cn     # 配置智谱（v2.2.0+，旧 zhipu 已拆分）
docker compose exec qwenpaw qwenpaw models config-key zhipu-intl   # 配置智谱国际站（v2.2.0+）
docker compose exec qwenpaw qwenpaw models config-key siliconflow-cn   # 配置 SiliconFlow 国内站（v2.2.0+）
docker compose exec qwenpaw qwenpaw models config-key siliconflow-intl # 配置 SiliconFlow 国际站（v2.2.0+）
docker compose exec qwenpaw qwenpaw models config-key volcengine-cn     # 配置火山引擎（v2.2.0+，另有 -codingplan/-agentplan 变体）
docker compose exec qwenpaw qwenpaw models config-key openrouter   # 配置 OpenRouter（v1.1.1+）
docker compose exec qwenpaw qwenpaw models config-key opencode     # 配置 OpenCode/Zen（v1.1.1+）
docker compose exec qwenpaw qwenpaw models config-key mimo         # 配置 Xiaomi MiMo（v1.1.11+，另有 mimo-tokenplan）
docker compose exec qwenpaw qwenpaw models config-key ollama       # 配置 Ollama 本地模型（v2.0.0+ 已内置）
docker compose exec qwenpaw qwenpaw models config-key custom       # 配置自定义提供商
docker compose exec qwenpaw qwenpaw models set-llm                 # 切换活跃模型

# 模型管理（本地模型 - 需额外依赖 qwenpaw[local]）
docker compose exec qwenpaw qwenpaw models download <repo_id>      # 下载本地模型仓库（huggingface/modelscope）
docker compose exec qwenpaw qwenpaw models local                   # 查看已下载模型
docker compose exec qwenpaw qwenpaw models remove-local <model_id> # 删除已下载模型
# 注：Ollama 模型请用外部命令 `ollama pull <model>`（v2.2.0 起已移除 ollama-pull/ollama-list）

# 频道管理
docker compose exec qwenpaw qwenpaw channels list           # 查看所有频道
docker compose exec qwenpaw qwenpaw channels config         # 交互式配置
docker compose exec qwenpaw qwenpaw channels send           # 向频道发送消息
# 注：旧版 `channels install/add/remove <key>` 已在 v2.2.0 移除，改用控制台或 plugins 管理自定义频道

# 技能管理
docker compose exec qwenpaw qwenpaw skills list         # 查看所有技能
docker compose exec qwenpaw qwenpaw skills config       # 交互式启用/禁用
docker compose exec qwenpaw qwenpaw skills info         # 查看技能详情（v1.1.2+）

# 定时任务
docker compose exec qwenpaw qwenpaw cron list            # 列出所有任务
docker compose exec qwenpaw qwenpaw cron create ...      # 创建任务
docker compose exec qwenpaw qwenpaw cron state <job_id>  # 查看任务状态
docker compose exec qwenpaw qwenpaw cron pause <job_id>  # 暂停任务
docker compose exec qwenpaw qwenpaw cron resume <job_id> # 恢复任务
docker compose exec qwenpaw qwenpaw cron run <job_id>    # 立即执行一次

# 环境变量
docker compose exec qwenpaw qwenpaw env list            # 列出所有变量
docker compose exec qwenpaw qwenpaw env set KEY VALUE   # 设置变量
docker compose exec qwenpaw qwenpaw env delete KEY      # 删除变量

# 会话管理
docker compose exec qwenpaw qwenpaw chats list          # 列出所有会话
docker compose exec qwenpaw qwenpaw chats get <id>      # 查看会话详情
docker compose exec qwenpaw qwenpaw chats create ...    # 创建新会话
docker compose exec qwenpaw qwenpaw chats update <id> --name "新名称"  # 重命名会话
docker compose exec qwenpaw qwenpaw chats delete <id>   # 删除会话

# 维护
docker compose exec qwenpaw qwenpaw clean               # 清空工作目录（交互确认）
docker compose exec qwenpaw qwenpaw clean --yes         # 不确认直接清空

# 配置重载（无需重启容器，v0.0.5+）
docker compose exec qwenpaw qwenpaw daemon reload-config # 重新加载配置
docker compose exec qwenpaw qwenpaw daemon version       # 查看 QwenPaw 版本

# 更新与认证（v0.1.0+）
docker compose exec qwenpaw qwenpaw update              # 更新 QwenPaw 到最新版本（在容器中更新无意义）
docker compose exec qwenpaw qwenpaw auth reset-password # 重置安全认证密码

# Agent 与消息（v0.2.0+）
docker compose exec qwenpaw qwenpaw agents list            # 列出所有代理
docker compose exec qwenpaw qwenpaw agents create          # 创建新代理（v1.1.2+）
docker compose exec qwenpaw qwenpaw agents delete          # 删除代理
docker compose exec qwenpaw qwenpaw agents chat            # 直接与代理对话
# 注：旧版 `agents enable/disable` 与 `message push/send` 已在 v2.2.0 移除，请在控制台配置

# 任务执行（v1.0.2+）
docker compose exec qwenpaw qwenpaw task <prompt>      # 运行一次性任务，无需 Web 服务

# 诊断（v1.1.2+）
docker compose exec qwenpaw qwenpaw doctor             # 诊断检查
docker compose exec qwenpaw qwenpaw doctor fix          # 自动修复问题

# ACP Server（v1.1.3+）
docker compose exec qwenpaw qwenpaw acp                # 启动 ACP Server

# QwenPaw Hub（v2.2.0+，需 qwenpaw[hub]）
docker compose exec qwenpaw qwenpaw hub                # 启动多用户 Hub 服务
```

---

## 环境变量说明

完整的环境变量列表及说明请参见 [.env.example](.env.example) 。

> **注意**：模型提供商的 API Key **不支持**通过环境变量配置，需通过以下方式设置：
> - WebUI 控制台 → Settings → Models
> - CLI 命令：`docker compose exec qwenpaw qwenpaw models config`

---

## 数据持久化

> **⚠️ 重要提示**：本项目的 `copaw-data` 存储卷与 QwenPaw 官方镜像的存储卷**不能通用**，原因是文件权限设置不一致。官方镜像可能使用不同的用户权限运行，直接挂载可能导致权限问题。

本项目使用 Docker 数据卷 `copaw-data` 持久化以下内容：

- `.backups/` - 备份存储目录
- `.runtime/` - 敏感配置目录
  - `auth.json` - 安全认证数据（v0.1.0+）
  - `envs.json` - 环境变量配置
  - `providers.json` - LLM 提供商配置
- `memory/` - Agent 记忆文件（v2.0.0+ 由 ReMe v0.4.0 后端管理）
- `media/` - 频道媒体默认目录（v2.0.0+）
- `workspaces/default/` - 默认代理工作区（v0.1.0+）
  - `active_skills/` - 当前激活的技能
  - `customized_skills/` - 用户自定义技能
  - `plugins/` - 插件扩展（v1.0.2+）
  - `drivers/` - 外部能力驱动卡（MCP/ACP 等，v2.0.0+ 取代旧 mcp_clients/）
  - `credentials.yaml` - 驱动/邮箱加密凭据（v2.2.0+）
  - `history.db` - 滚动上下文工作历史（SQLite，每个工作区一份，v2.0.0+）
  - `AGENTS.md` - 详细的工作流程、规则和指南
  - `PROFILE.md` - 身份和用户画像
  - `SOUL.md` - 核心身份与行为原则
  - `agent.json` - 代理配置
- `chats.json` - 会话列表
- `config.json` - 根配置文件（包含代理引用，v0.1.0+）
- `HEARTBEAT.md` - 心跳配置
- `jobs.json` - 定时任务列表
- `token_usage.json` - Token 用量统计

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
| OneBot v11 / NapCat (v1.0.1+) | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | 🚧 | 🚧 |
| Discord | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| iMessage | ✓ | ✓ | ✓ | ✓ | ✗ | ✓ | ✓ | ✓ | ✓ | ✗ |
| QQ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | 🚧 | 🚧 | ✓ (v1.0.2+) |
| Telegram | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Twilio Voice | ✓ | ✗ | ✗ | ✓ | ✗ | ✓ | ✗ | ✗ | ✓ | ✗ |
| SIP Voice (v1.1.4+) | ✓ | ✗ | ✗ | ✓ | ✗ | ✓ | ✗ | ✗ | ✓ | ✗ |
| MQTT | ✓ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ |
| Mattermost | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Matrix | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 小艺 | ✓ | ✓ | ✓ | ✗ | ✓ | ✓ | ✓ | ✗ | ✗ | ✓ |
| Slack (v2.0.0+) | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |

> ✓ = 已支持；🚧 = 施工中；✗ = 不支持

---

## 端口说明

> ⚠️ **安全提醒**：未启用认证时，请勿将端口暴露到公网！环境变量启用 `QWENPAW_AUTH_ENABLED=true` 后可降低风险。

| 容器端口 | 主机端口 | 说明 |
|----------|----------|------|
| `8088` | `127.0.0.1:8088` | QwenPaw Web 服务端口（v0.0.5+ 默认绑定 127.0.0.1） |

如需修改主机端口，编辑 `docker-compose.yml`：

```yaml
ports:
  - "9000:8088"  # 使用 9000 端口访问
  # 或 v0.1.0+ 启用认证后允许外部访问
  # - "0.0.0.0:8088:8088"
```

> **安全更新**：v0.0.5 起，默认端口绑定改为 `127.0.0.1` 以提高安全性。启用认证后可降低风险。

---

## 网络配置

默认使用 `qwenpaw-network` 桥接网络。如需连接其他容器，可以：

```yaml
# 在 docker-compose.yml 中添加外部网络
networks:
  qwenpaw-network:
    name: your-existing-network
    external: true
```

---

## 故障排除

### 1. 容器无法启动

检查日志：

```bash
docker compose logs qwenpaw
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
docker volume ls | grep qwenpaw
```

### 4. API Key 无效

确保 `.env` 文件中的 API Key 正确，并重启服务：

```bash
docker compose restart
```

---

## 镜像信息

### 预构建镜像

- **镜像地址**: `ghcr.io/log-z/qwenpaw:latest`
- **拉取命令**: `docker pull ghcr.io/log-z/qwenpaw:latest`
- **更新频率**: 随 QwenPaw 官方版本更新

### 自行构建

- **基础镜像**: `python:3.13-slim`
- **Python 版本**: 3.13
- **Node.js 版本**: 24.x LTS（用于 MCP 功能）
- **工作目录**: `/data/qwenpaw`
- **运行用户**: `qwenpaw`（非 root）

---

## 新功能支持

> 历史版本更新详见 [docs/qwenpaw-info.md](docs/qwenpaw-info.md)。

### v2.2.2.post1 更新（最新，2026-10-22）

> 补丁版本，只含两项安全修复，无功能性变更。官方镜像内的 Node.js 与 Python 依赖证书库均有更新。

#### 安全修复
- **Node.js 升级至 22.23.4** — 修复 Brotli 解码器越界写导致的远程代码执行（CVE-2026-111497，高危）与 keep-alive 套接字响应错序（CVE-2026-105481，中危）(#8371)。官方将 `.nvmrc` 作为 Node 版本唯一来源，Docker 构建在 Node 版本不匹配时直接失败，`NODE_IMAGE` 默认改为 `node:22.23.4-slim`
- **emSign/eMudhra 中间 CA 信任整改** — Python 依赖新增 `certifi>=2026.10.19`，安装脚本、插件依赖安装与镜像构建均强制该下限；安装与自更新要求 `pip>=26.2.2`、`uv>=0.13.4`，低于下限会被拒绝并提示升级 (#8370)

#### 对本项目镜像的影响
- 官方 `deploy/Dockerfile` 已移除 `python3-pip`、补充 `ca-certificates` 并执行 `update-ca-certificates`，同时在准备 Python 运行时后升级 `pip` 与 `certifi`
- 本项目 Dockerfile 原先装出的镜像里 `pip` 为 26.2.1、`certifi` 为 2026.07.22，**均低于新下限**；由于 v2.2.2.post1 的插件依赖安装会校验 `pip>=26.2.2`，不升级会导致插件依赖装不上。现已在 Dockerfile 的 `uv pip install` 中同时安装 `"pip>=26.2.2"` 与 `"certifi>=2026.10.19"`，构建后实测 `pip 26.2.2` / `certifi 2026.10.19`，`require_pip`、`require_uv` 校验均通过

> 完整 changelog：官方 [v2.2.2...v2.2.2.post1](https://github.com/agentscope-ai/QwenPaw/compare/v2.2.2...v2.2.2.post1)。

---

### v2.2.2 更新（2026-10-15）

> 新增主题调色板与聊天内终端、PawPort 跨 Harness 迁移导入、Hub 模型网关，并将记忆命令统一为 `/reme`。

#### 新增
- **控制台/工作区** — 六套主题调色板与自定义颜色/圆角（实时预览）(#7741)；聊天内需认证的多标签终端、每会话独立工作目录 (#7861)；控制台字号 12–20px 可调 (#8005)；多文件夹工作区可设为 Agent 默认 (#7789)；Agent 交付文件直接显示在回复下方 (#7750)
- **PawPort** — 从 Codex 和 Qoder 导入会话、记忆、技能、插件、MCP 设置、项目与定时任务，含兼容性检查与选择性重试 (#6960)
- **Creator 2.0.1 / Data 0.3.0** — Creator 媒体生产前可审查脚本、手动重生成不触发付费下游步骤、可恢复停滞项目 (#8121)；Data 集成分析工作区、交互式澄清、内联 HTML 报告，新增 `/data` 与 `/datasource` 命令 (#7637)
- **模型/记忆** — 统一模型发现、定价与选择，新增候选模型池与按会话模型/思考控制 (#7899)；单对话框配置自定义提供商 (#7826)；控制台可配置 ReMe 搜索重排序 (#6399)
- **Hub** — 新增 Hub 模型网关（集中管理组织模型、成员 Token 预算、用量看板、邀请注册）(#7779)；支持从 CLI 初始化首个 Hub 管理员（含纯本地部署）(#7696)
- **技能/工具/自动化/频道** — 新增 `view_audio` 音频理解工具 (#8083)；定时任务支持纯文本指令+指定模型、中断保留历史、收件箱查看超时结果 (#7776)；技能批量分发到工作区 (#7852)；技能可分配至自定义频道 (#7782)；技能市场源可作为插件装卸 (#8128)；飞书可折叠思考面板 (#7685)；Telegram Markdown 表格渲染为 Rich Messages (#7713)
- **本地模型** — 本地推荐 QwenPaw-Flash 9B/27B/35B-A3B (#8155)

#### 变更
- 记忆命令统一为 `/reme <action> key=value`，取代 `/dream`、`/memorize`、`/reme_status` (#7444)
- 会话历史重设计（按时间/来源/不分组视图、复制会话 ID），会话列表默认按来源分组 (#7665, #7688, #7788, #7846, #7972)；聊天文件抽屉移至右侧 (#7704)
- 视觉压缩仅作用于较早历史并保留最近两个用户轮次，可用 `recall_context` 检索原文 (#7703)；避免每请求全量历史库检查以降低长对话延迟 (#7639)
- 控制台按需加载聊天依赖与语言资源减少初始下载 (#7829)；后台工具输出仅在任务面板展开时流式 (#7831)；Make Skill 升级至 2.1 (#7753)；改进模型设置与设置导航/搜索 (#8017, #7956)

#### 修复
- **控制台/聊天/文件** — HTTP 部署下终端标签可用 (#8144, #8146)；恢复历史后保留 Agent 文件 (#7949)；排队消息绑定原 Agent 与会话 (#7382)；停止回复后正确标记中断的工具调用 (#7345)；`/compact` 在当前会话执行 (#7834)；粘贴长文本保留草稿 (#8119)；慢网络加载改进 (#7917)；限制后台轮询保持模型选择器响应 (#8221)；恢复越南语与巴西葡语选择 (#7752)
- **模型/运行时/安全** — 保留 EXIF 照片方向 (#8136)；遵循提供商解析的上下文窗口避免过早压缩 (#7652)；模型拒绝图片/媒体载荷后恢复会话 (#8010)；按模型能力过滤历史图片 (#8190)；更早回收旧媒体与工具结果 (#7965, #8193)；阻止 Windows 控制台事件终止服务 (#7910)；容器/服务中查找用户命令行工具 (#7057)；处理压缩的 MCP 错误响应 (#7787)；限制主密钥文件权限 (#7699)；技能名安装路径校验 (#8065)
- **记忆/Hub/部署** — 修复损坏的历史搜索索引并恢复保留清理 (#7655)；加强历史库写入/备份/恢复 (#6459)；优雅关闭等待待处理记忆任务 (#7760)；修复 Hub 本地运行时与持久化工作区 (#7833)；Hub 事务后关闭数据库连接 (#8038)；Docker 与桌面统一 Python 运行时 (#7751)

> 完整 changelog：官方 [v2.2.1...v2.2.2](https://github.com/agentscope-ai/QwenPaw/compare/v2.2.1...v2.2.2)，含 11 位新贡献者。

---

### 控制台功能

服务启动后访问 http://localhost:8088/ 进入控制台，包含以下功能模块：

| 组 | 功能 | 说明 |
|----|------|------|
| 聊天 | 聊天 | 和 QwenPaw 对话、管理会话、切换模型、多模态支持、SSE 流式响应、音视频支持（v0.2.0+）、多模态预览（v1.0.0+）、频道标签（v1.0.0+）、命令建议（v1.0.0+）、选择 Agent 对话（v1.0.0.post1+）、聊天搜索（v1.0.2+）、置顶会话（v1.0.2+）、输入历史（v1.0.2+）、Mission 模式（v1.1.2+）、Plan 模式（v1.1.4+）、会话右键菜单（v1.1.4+）、多文件附件（v1.1.7+）、浮动聊天按钮（v1.1.7+）、固定会话抽屉（v1.1.8+）、`/make-skill` 命令（v1.1.8+）、聊天输入草稿持久化（v1.1.9+）、Coding 模式（v1.1.9+）、斜杠命令建议优化（v1.1.11+）、简单模式（v1.1.12+）、宽屏模式（v1.1.12+）、每轮 Token 用量浮层（v1.1.12+）、用户输入队列（v1.1.12+）、会话标题过滤（v1.1.12+）、代码块语法高亮（v1.1.12+）、聊天历史右侧面板（v1.1.12.post1+） |
| 控制 | 频道 | 启用/禁用频道、填入凭据、快速文档链接、飞书区域选择器（v0.2.0+）、QQ 即时确认（v1.1.3+）、频道健康检查 API（v1.1.3+）、统一访问控制（v1.1.9+）、飞书话题回复（v1.1.10+）、飞书群组共享（v1.1.11+）、飞书交互式卡片（v1.1.11+）、QQ 二维码授权（v1.1.11+）、钉钉内联媒体（v1.1.11+） |
| 控制 | 会话 | 筛选、重命名、删除会话 |
| 控制 | 定时任务 | 创建/编辑/删除任务、立即执行、日历视图（v1.1.7+）、一次性执行（v1.1.7+）、执行历史（v1.1.7+）、可配置超时（v1.1.8+） |
| 智能体 | 工作区 | 编辑人设文件、查看记忆、上传/下载、代理选择器、标签页界面（v1.1.1+）、备份与恢复（v1.1.3+）、每 Agent 模型分配（v1.1.4+） |
| 智能体 | 技能 | 启用/禁用/创建/**导入**/AI优化/删除技能、安全扫描、Skill Pool 双层架构（v1.0.0+）、技能命令 `/<skill>` （v1.0.2+）、技能池标签（v1.0.2+）、技能选择改进（v1.1.1+）、技能导入中心（v1.1.2+）、技能页面重设计（v1.1.3+）、技能语言切换（v1.1.3+）、插件管理（v1.1.7+）、官方插件分发（v1.1.8+）、技能市场（v1.1.9+）、自进化技能创建（v1.1.11+）、技能标签批量下载（v1.1.11+）、多路径技能池（v1.1.11+） |
| 智能体 | MCP | 启用/禁用/创建/删除 MCP 客户端、控制台 MCP 配置（v1.0.0.post2+）、MCP 工具发现（v1.0.2+）、每服务器工具白名单（v1.1.11+） |
| 智能体 | 运行配置 | 修改最大迭代次数和最大输入长度、LLM 重试配置（v0.2.0+） |
| 智能体 | 上下文管理 | 调整压缩比例、保留比例、工具结果压缩设置 |
| 智能体 | 工具 | 启用/禁用内置工具、批量切换、glob_search/grep_search |
| 设置 | 模型 | 配置提供商（含自定义提供商）、管理本地/Ollama/LM Studio 模型、选择模型、搜索过滤（v0.2.0+）、QwenPaw Local Model（v1.0.0+）、视频分析（v1.0.0.post1+）、`/model` 聊天命令（v1.0.2+）、模型 ID 自动补全（v1.1.1+）、模型选择器重设计（v1.1.7+）、自定义 HTTP 头和认证模式（v1.1.8+）、每模型 Token 限制（v1.1.8+）、免费模型 OAuth（v1.1.11+）、Xiaomi MiMo 提供商（v1.1.11+）、模型页面改版（v1.1.12+） |
| 设置 | 环境变量 | 添加/编辑/删除环境变量（敏感值遮罩） |
| 设置 | 安全 | Tool Guard 安全规则管理、文件访问保护（v0.2.0+）、系统重启/服务保护（v1.0.0+）、中文提示注入检测（v1.0.0+）、扩展 Shell 命令防护（v1.1.1+）、Shell 混淆防护（v1.1.3+）、可配置 Shell 混淆检测规则（v1.1.4+）、Tool Guard 审批系统（v1.1.4+）、文件预览限制（v1.1.11+） |
| 设置 | Token 使用 | 追踪各提供商 token 使用量 |
| 设置 | 统计 | Agent 统计仪表板，会话/消息趋势、token 用量、频道分布（v1.1.3+） |
| 设置 | 语音转录 | 语音转录设置 |
| 设置 | 主题 | 暗黑模式切换 |
| 设置 | Debug | 实时查看后端日志（v1.1.2+，v1.1.3 重设计） |
| 设置 | 账户 | 更改用户名密码（v0.2.0+，认证启用时） |

**Skills Hub 导入**：支持从社区平台导入技能
- `https://skills.sh/...`
- `https://clawhub.ai/...`
- `https://skillsmp.com/...`
- `https://github.com/...`
- LobeHub
- ModelScope Skill Hub

### 相关链接

- [QwenPaw 官方仓库](https://github.com/agentscope-ai/QwenPaw) - 官方 GitHub 仓库
- [QwenPaw 官方文档](http://qwenpaw.agentscope.io/docs/)
- [docs/qwenpaw-info.md](docs/qwenpaw-info.md) - QwenPaw 官方文档信息汇总
- [AgentScope](https://github.com/agentscope-ai/agentscope) - QwenPaw 基础框架

---

## License

本项目基于 QwenPaw 的官方部署方案构建。QwenPaw 由 [AgentScope 团队](https://github.com/agentscope-ai) 开发，采用 [Apache License 2.0](https://github.com/agentscope-ai/QwenPaw/blob/main/LICENSE) 开源许可。
