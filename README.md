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
│   ├── migrate-legacy-dir.sh  # 旧版 .copaw 目录迁移脚本
│   ├── patch-sandbox-landlock-probe.py # 构建期修正容器内 Landlock 探测
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
    ├── plugin_runtime/        # 频道插件依赖安装目标（v2.3.0+，按 py<X.Y>-<os>-<arch> 分桶）
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
    │       ├── channel_state/ # 频道子进程状态（Matrix 加密身份/设备密钥、投递回执，v2.3.0+）
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
>
> **v2.3.0 工作目录变化**：新增 `plugin_runtime/`（频道插件依赖目标，本镜像已预装 `channels`）与 `workspaces/<id>/channel_state/`（频道子进程状态，如 Matrix 加密身份与投递回执，**备份时请一并包含**）；`config.json` 新增 `channel_plugin_state` 字段。

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
docker compose exec qwenpaw qwenpaw acp --agent-mode code  # 指定新建会话的初始执行模式（v2.3.0+）

# QwenPaw Hub（v2.2.0+，需 qwenpaw[hub]）
docker compose exec qwenpaw qwenpaw hub                # 启动多用户 Hub 服务

# 频道插件与依赖（v2.3.0+）
docker compose exec qwenpaw qwenpaw plugins preset apply channels-full  # 发布全部官方频道源码
docker compose exec qwenpaw qwenpaw plugins preset apply light          # 仅发布历史已启用的频道
docker compose exec qwenpaw qwenpaw plugins prepare-upgrade             # 为已启用频道预装依赖
docker compose exec qwenpaw qwenpaw plugins dependency-upgrade status <operation_id>  # 共享依赖升级维护

# 历史库维护（v2.3.0+，需先停止对应 Agent）
docker compose exec qwenpaw qwenpaw history check /data/qwenpaw/workspaces/default/history.db
docker compose exec qwenpaw qwenpaw history check /data/qwenpaw/workspaces/default/history.db --repair-fts

# 频道回执核查（v2.3.0+）
docker compose exec qwenpaw qwenpaw channels receipts --channel dingtalk list --limit 100
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
- `plugins/` - 插件安装目录（含 v2.3.0 起自动发布的官方频道插件源码）
- `plugin_runtime/` - 频道插件依赖安装目标（v2.3.0+）
- `workspaces/default/` - 默认代理工作区（v0.1.0+）
  - `active_skills/` - 当前激活的技能
  - `customized_skills/` - 用户自定义技能
  - `plugins/` - 插件扩展（v1.0.2+）
  - `drivers/` - 外部能力驱动卡（MCP/ACP 等，v2.0.0+ 取代旧 mcp_clients/）
  - `credentials.yaml` - 驱动/邮箱加密凭据（v2.2.0+）
  - `history.db` - 滚动上下文工作历史（SQLite，每个工作区一份，v2.0.0+）
  - `channel_state/` - 频道子进程状态（Matrix 加密身份/设备密钥、投递回执，v2.3.0+）
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

### 4. Agent 无法执行命令，报错 `Sandbox is enabled but unavailable`

在控制台「设置 → 安全」里打开了**沙箱开关**（`security.sandbox_enabled=true`）后，Code Mode 的 `run_code` 每次都会报：

```
Script failed: Sandbox is enabled but unavailable
```

原因是上游探测逻辑在容器内误判了 Landlock（镜像已内置修正脚本，自本项目构建的镜像不会出现该问题）：

- Linux 沙箱后端按 `bubblewrap > Landlock > none` 顺序探测。容器内通常没有 `bwrap`，且默认不安装它（user namespace 在默认 seccomp 下也被禁）。
- 回退到 Landlock 时，上游 `_probe_linux_landlock()` 第 2 步要求能读 `/sys/kernel/security/lsm`。容器默认不挂载 securityfs，该文件不存在，探测直接返回 `supported=False`。
- 而内核 Landlock 实际可用。此时 `run_code`（fail-closed 工具）走 `ResourceGovernor.execution_sandbox_config()`，遇到「开关打开但后端不可用」直接抛异常，于是所有命令失败。

镜像在构建阶段执行 [scripts/patch-sandbox-landlock-probe.py](scripts/patch-sandbox-landlock-probe.py)，回移上游 PR `fix/landlock-probe-without-securityfs` 的修复：把 LSM 列表降级为 best-effort 证据，读不到时不再短路第 3 步的 `landlock_create_ruleset` 系统调用探测；可读但不含 `landlock` 仍判定不支持；未知架构既无 syscall 号也无 LSM 证据时拒绝猜测。产物与上游 PR 分支的文件逐字节一致（`2ec1c73a…`），并通过该 PR 的全部 11 项回归测试。探测成功后 `run_code` 与 Bash 都会正常进入 Landlock 沙箱（工作区可读写，工作区外写入被内核拒绝）。

> **该补丁只针对 QwenPaw 2.3.0**。脚本会先核对已安装版本与上游文件 SHA-256，两者不符就拒绝修改并让镜像构建失败——升级 QwenPaw 时需要先审阅新版本的探测逻辑，再更新脚本里的 `TARGET_SHA256`。注意 2.2.2 与 2.3.0 的 `sandbox/config.py` 字节完全相同，所以仅靠文件哈希无法区分版本，脚本额外校验了包版本号。

可这样确认沙箱是否生效：

```bash
# 1. 探测结果应为 supported=True / mode=landlock
docker compose exec qwenpaw python -c \
  "from qwenpaw.sandbox import probe_sandbox_support as p; print(p())"

# 2. 控制台状态接口应返回 effective=true
curl -s http://localhost:8088/api/config/security/sandbox
```

如果仍在用旧镜像，或自建镜像时跳过了该补丁脚本，有两个临时规避方案：

```bash
# 方案 A：关闭沙箱开关（命令直接执行，不隔离）
#   控制台「设置 → 安全」关闭沙箱，或修改 config.json：
#   "security": { "sandbox_enabled": false }

# 方案 B：把宿主机 securityfs 只读挂入容器，让上游探测能读到 LSM 列表
#   在 docker-compose.yml 的 volumes 中追加（仅 Linux 宿主有效）：
#   - /sys/kernel/security:/sys/kernel/security:ro
```

> 说明：`bwrap` 在默认 Docker seccomp 策略下无法创建 user namespace（本镜像实测 `unshare -U` 返回 `Operation not permitted`），因此容器内的沙箱后端实际是 Landlock，而不是 bubblewrap。

### 5. API Key 无效

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
- **预装扩展**: `channels`（v2.3.0+，频道 SDK 全部内置）

构建参数：

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `QWENPAW_VERSION` | `latest` | QwenPaw 版本 |
| `QWENPAW_EXTRAS` | （空） | 额外扩展，逗号分隔，如 `local,hub,qwenpaw-data` |
| `QWENPAW_INCLUDE_CHANNELS` | `true` | 是否预装 `channels` 扩展。设为 `false` 可减小镜像（实测解压后小 147MB、镜像层约小 13MB），但启用频道时需联网安装依赖 |

```bash
# 默认构建（含频道支持）
docker build -t qwenpaw:latest .

# 带本地模型支持
docker build --build-arg QWENPAW_EXTRAS=local -t qwenpaw:local .

# 极简镜像（不预装频道 SDK）
docker build --build-arg QWENPAW_INCLUDE_CHANNELS=false -t qwenpaw:slim .
```

---

## 新功能支持

> 历史版本更新详见 [docs/qwenpaw-info.md](docs/qwenpaw-info.md)。

### v2.3.0 更新（最新，2026-11-11）

> **重大版本**。核心变化是**频道全面插件化并改为子进程隔离运行**，所有频道 SDK 也从核心依赖中移出。本项目镜像已相应预装 `channels` 扩展，频道开箱即用。

#### 新增
- **Piccolo 本地决策模型** — 新增 4B/9B/27B 三档本地决策模型，用于工具审批与上下文压缩，提供 BF16/Q8_0 推荐配置，支持 Hugging Face 或 ModelScope 下载源。审批与压缩需单独启用，本地运行时每次只跑一个模型 (#8463, #8573)
- **Advisor Mode** — 顾问模型与执行模型协作：开始前制定计划，执行中可按需咨询，工具连续失败时调整计划 (#7569)；新增 `/advisor` 聊天命令
- **Python Code Mode（实验性）** — 可在一段脚本中组合已启用工具，支持并发调用与按序输出文本/媒体。工具仍遵循原有权限检查，且**不会**自动开启沙箱 (#8224)
- **ChatGPT 订阅登录** — 本机部署可登录 ChatGPT 订阅账号，无需 Platform API Key 即可选用账号可用模型 (#8437)
- **决策模型审批** — 新增独立于对话模型的 TypeSafe/JEV 决策模型配置，用于辅助工具审批；明确禁止的操作仍被拦截，判断不确定或服务失败时转人工审批 (#8205, #8283, #8360)
- **ReMe 0.4.2.0** — 支持图片记忆、自动标签与按标签检索；图片记忆、自动打标、决策压缩默认关闭 (#8347)；新增 OpenViking 记忆插件 (#7613)
- **控制台/桌面** — 社区帖子浏览与评论 (#7903)；可选 OpenUI 插件在回复中渲染交互式表单 (#8239, #8248)；收件箱"仅看未读"筛选 (#8484)；桌面多窗口共享后台服务 (#8373)；审批/回复完成/后台任务的浏览器与桌面通知 (#8504)
- **工具与频道** — 新增 Firecrawl 搜索提供商 (#8200)、Tavily 可选 API Key (#8204)、可选 Shell 内存保护 (#8574)、插件深浅色主题配色 (#8422)、Matrix 加密依赖随频道安装 (#8559)

#### 变更
- **官方频道插件化** — 除 `console` 外的官方频道改为插件，启用时启动独立子进程，已有频道配置保留 (#8187)
- **频道 SDK 移出核心依赖** — 41 项频道依赖移入新的 `channels` extra，`full` 现包含 `channels`
- **`/model` 语义变化** — `/model` 切换/重置现在改的是 **Agent 默认模型**，不再覆盖当前会话；已有会话模型覆盖的会话需在选择器中清除覆盖才会继承
- **搜索默认值** — 未保存搜索提供商时默认使用 AnySearch (#8536)
- **插件装卸加速** — 安装/更新/移除插件不再重建所有活动工作区，失败时回滚旧版本 (#7565)
- **历史库连接复用** — 同工作区内复用连接，降低每次请求开销 (#8482)
- **安装器版本要求延续** — 更新应用或安装插件仍要求 `pip>=26.2.2` 或 `uv>=0.13.4` (#8391)

#### 破坏性变更
- **移除旧版工作区 ZIP 上传/下载 API** — 旧接口可能覆盖使用中的 `history.db`。工作区备份请改用"备份与恢复"；普通文件传输与项目 ZIP 导入不受影响 (#8508)
- **内置工具 `lsp` / `ast_search` 已移除** — 依赖 `python-lsp-server`、`ast-grep-cli`、`html2text` 一并删除；已保存配置中的这两项会自动清理
- **频道 SDK 不再随核心包安装** — 见下方"对本项目镜像的影响"

#### 修复（部分）
- **控制台/聊天** — 按会话保存草稿并避免响应删除新输入 (#8362, #8272)；会话直达链接可切到正确 Agent (#8209)；修复切换会话时行内插件提交串会话 (#8330)；修复思考强度滑块显示与保存竞态 (#8287)；清空会话后 `/clear`、`/new` 不再回到对话 (#8600)；限制超大工具输出以改善慢网络加载 (#8229)
- **模型/运行时** — 统一使用会话生效模型做压缩、容量显示、标题生成 (#8465)；历史媒体过大时移除旧媒体后恢复执行 (#8395)；内联媒体总大小限制并优先保留新媒体 (#8034, #8066)；ACP 长任务保持连接不丢结果 (#8327)；兼容返回 HTTP 422 的旧版 MCP 服务 (#8051)
- **记忆/历史** — 自动记忆召回不再泄漏到可见对话与频道消息 (#7835)；备份时为使用中的 SQLite 生成快照，并新增历史检查与索引修复命令 (#8541)；修复 Windows 长路径/网络路径导致历史库失败 (#8587)
- **频道** — Matrix 会话恢复与设备密钥持久化，按身份隔离加密存储 (#8558, #8584)；钉钉长回复按 Markdown 分段发送 (#8341)；修复 CJK 标点附近强调格式 (#8067)
- **部署** — 修复反向代理子路径下的路由/资源/登录跳转 (#8316)；控制台对话流禁用 nginx 缓冲 (#8522)；Docker 构建补齐共享插件前端源码 (#8450)

> 完整 changelog：官方 [v2.2.2...v2.3.0](https://github.com/agentscope-ai/QwenPaw/compare/v2.2.2...v2.3.0)，含 17 位新贡献者。

#### 对本项目镜像的影响

- **镜像默认预装 `channels` 扩展** — Dockerfile 新增构建参数 `QWENPAW_INCLUDE_CHANNELS`（默认 `true`），会在 `QWENPAW_EXTRAS` 前自动拼接 `channels`。这样频道 SDK 全部内置，首次启用频道时**不会**联网安装依赖（实测启用 Telegram 时直接从 site-packages 解析依赖，`plugin_runtime/` 保持为空）。固定旧版本（< 2.3.0）时会自动跳过该 extra，避免装出无频道支持的镜像而不提示。如需极简镜像可设 `--build-arg QWENPAW_INCLUDE_CHANNELS=false`（实测解压后小 147MB、镜像层仅小约 13MB，因纯 Python wheel 压缩率高；但启用频道需外网）
- **频道发放预设改为 `channels-full`** — 入口脚本默认设置 `QWENPAW_CHANNEL_PRESET=channels-full`（官方镜像默认 `light`），启动时即把所有官方频道源码发布到 `plugins/`，控制台里可直接启用任意频道，无需等待安装。依赖已预装，因此这一步只复制源码、开销很小。如希望与官方行为一致可设 `QWENPAW_CHANNEL_PRESET=light`
- **工作目录新增 `plugin_runtime/`** — 频道插件运行期依赖的安装目标（本镜像已预装，通常为空或仅含少量运行时依赖）
- **工作区新增 `channel_state/`** — 频道子进程状态（Matrix 加密身份/设备密钥、投递回执库等），**请随工作区一并备份**
- **数据卷升级兼容** — 已有 `config.json` 不受影响，升级后原频道配置继续生效；`channel_plugin_state` 字段会在首次启动时自动补齐
- **无需改动健康检查** — 仍使用 `/api/healthz`（启动中就返回 503）

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
