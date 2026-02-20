# CoPaw 官方文档信息汇总

> 本文档汇总了 CoPaw 官方文档的关键信息，方便后续调整需求时快速获取。
>
> 官方文档：http://copaw.agentscope.io/docs/

---

## 项目概述

### CoPaw 是什么？

CoPaw 是一款**个人助理型产品**，部署在你自己的环境中。

- **多通道对话** — 通过钉钉、飞书、QQ、Discord、iMessage 等与你对话
- **定时执行** — 按你的配置自动运行任务
- **能力由 Skills 决定** — 内置定时任务、PDF 与表单、Word/Excel/PPT 文档处理、新闻摘要、文件阅读等，还可在 Skills 中自定义扩展
- **数据全在本地** — 不依赖第三方托管

### 技术基础

CoPaw 由 [AgentScope 团队](https://github.com/agentscope-ai) 基于以下项目构建：
- [AgentScope](https://github.com/agentscope-ai/agentscope)
- [AgentScope Runtime](https://github.com/agentscope-ai/agentscope-runtime)
- [ReMe](https://github.com/agentscope-ai/ReMe)

---

## 快速开始

### 环境要求

- **Python 版本**: >= 3.10, <= 3.13

### 安装步骤

```bash
# 步骤一：安装
pip install copaw

# 步骤二：初始化（两种方式）
# 方式1：快速用默认配置
copaw init --defaults

# 方式2：交互式初始化
copaw init

# 步骤三：启动服务
copaw app
```

### 服务访问

- **默认监听地址**: `127.0.0.1:8088`
- **控制台**: 浏览器访问 `http://127.0.0.1:8088/`

### 验证安装

```bash
curl -N -X POST "http://localhost:8088/agent/process" \
  -H "Content-Type: application/json" \
  -d '{"input":[{"role":"user","content":[{"type":"text","text":"你好"}]}],"session_id":"session123"}'
```

---

## 工作目录结构

默认工作目录：`~/.copaw`

```
~/.copaw/
├── config.json              # 频道开关与鉴权、心跳设置、语言等
├── HEARTBEAT.md             # 心跳每次要问 CoPaw 的内容
├── jobs.json                # 定时任务列表
├── chats.json               # 会话列表（文件存储模式）
├── active_skills/           # 当前激活的技能
├── customized_skills/       # 用户自定义的技能
├── memory/                  # Agent 记忆文件（自动管理）
├── SOUL.md                  # （必需）核心身份与行为原则
├── AGENTS.md                # （必需）详细的工作流程、规则和指南
├── MEMORY.md                # 长期有效的关键信息
├── PROFILE.md               # 身份和用户画像
└── memory/
    └── YYYY-MM-DD.md        # 每日日志
```

---

## 环境变量配置

### CoPaw 基础环境变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `COPAW_WORKING_DIR` | `~/.copaw` | 工作目录 |
| `COPAW_CONFIG_FILE` | `config.json` | 配置文件名（相对工作目录） |
| `COPAW_HEARTBEAT_FILE` | `HEARTBEAT.md` | 心跳问题文件名 |
| `COPAW_JOBS_FILE` | `jobs.json` | 定时任务文件名 |
| `COPAW_CHATS_FILE` | `chats.json` | 会话列表文件名 |
| `COPAW_LOG_LEVEL` | `info` | 日志级别（debug/info/warning/error/critical） |
| `COPAW_MEMORY_COMPACT_THRESHOLD` | `100000` | 触发记忆压缩的字符阈值 |
| `COPAW_MEMORY_COMPACT_KEEP_RECENT` | `5` | 压缩后保留的最近消息数 |
| `COPAW_CONSOLE_STATIC_DIR` | （自动检测） | 控制台前端静态文件路径 |

### Embedding 配置

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `EMBEDDING_API_KEY` | （空） | Embedding 服务的 API Key |
| `EMBEDDING_BASE_URL` | `https://dashscope.aliyuncs.com/compatible-mode/v1` | Embedding 服务的 URL |
| `EMBEDDING_MODEL_NAME` | `text-embedding-v4` | Embedding 模型名称 |
| `EMBEDDING_DIMENSIONS` | `1024` | 向量维度 |
| `FTS_ENABLED` | `true` | 是否启用 BM25 全文检索 |

---

## 频道配置

### 支持的频道

| 频道 | 说明 |
|------|------|
| **dingtalk** | 钉钉 |
| **feishu** | 飞书 / Lark |
| **qq** | QQ 机器人 |
| **discord** | Discord 机器人 |
| **imessage** | macOS iMessage |
| **console** | 控制台（默认启用） |

### 频道通用字段

| 字段 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enabled` | bool | `false` | 是否启用该频道 |
| `bot_prefix` | string | `""` | 可选命令前缀（如 `/paw`） |

### 频道专属字段

#### 钉钉 (dingtalk)

| 字段 | 说明 |
|------|------|
| `client_id` | 钉钉应用的 Client ID |
| `client_secret` | 钉钉应用的 Client Secret |

#### 飞书 (feishu)

| 字段 | 说明 |
|------|------|
| `app_id` | 飞书 App ID |
| `app_secret` | 飞书 App Secret |
| `encrypt_key` | 事件加密密钥（可选） |
| `verification_token` | 事件验证令牌（可选） |
| `media_dir` | 接收到的媒体文件存放目录 |

#### QQ 机器人 (qq)

| 字段 | 说明 |
|------|------|
| `app_id` | QQ 机器人 App ID |
| `client_secret` | QQ 机器人 Client Secret |

#### Discord (discord)

| 字段 | 说明 |
|------|------|
| `bot_token` | Discord Bot Token |
| `http_proxy` | HTTP 代理地址 |
| `http_proxy_auth` | 代理认证字符串 |

#### iMessage (imessage)

| 字段 | 说明 |
|------|------|
| `db_path` | iMessage 数据库路径（默认 `~/Library/Messages/chat.db`） |
| `poll_sec` | 轮询间隔（秒，默认 1.0） |

---

## config.json 完整结构

```json
{
  "channels": {
    "imessage": {
      "enabled": false,
      "bot_prefix": "",
      "db_path": "~/Library/Messages/chat.db",
      "poll_sec": 1.0
    },
    "discord": {
      "enabled": false,
      "bot_prefix": "",
      "bot_token": "",
      "http_proxy": "",
      "http_proxy_auth": ""
    },
    "dingtalk": {
      "enabled": false,
      "bot_prefix": "",
      "client_id": "",
      "client_secret": ""
    },
    "feishu": {
      "enabled": false,
      "bot_prefix": "",
      "app_id": "",
      "app_secret": "",
      "encrypt_key": "",
      "verification_token": "",
      "media_dir": "~/.copaw/media"
    },
    "qq": {
      "enabled": false,
      "bot_prefix": "",
      "app_id": "",
      "client_secret": ""
    },
    "console": {
      "enabled": true,
      "bot_prefix": ""
    }
  },
  "agents": {
    "defaults": {
      "heartbeat": {
        "every": "30m",
        "target": "main",
        "activeHours": null
      }
    },
    "language": "zh",
    "installed_md_files_language": "zh"
  },
  "last_api": {
    "host": "127.0.0.1",
    "port": 8088
  },
  "last_dispatch": null,
  "show_tool_details": true
}
```

---

## 心跳配置

### 心跳字段说明

| 字段 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `every` | string | `"30m"` | 运行间隔。支持 `Nh`、`Nm`、`Ns` 组合，如 `"1h"`、`"30m"`、`"2h30m"`、`"90s"` |
| `target` | string | `"main"` | `"main"` = 只在主会话运行；`"last"` = 把结果发到最后一个发消息的频道/用户 |
| `activeHours` | object/null | `null` | 可选活跃时段，设置后心跳只在该时段内运行 |

### activeHours 字段（不为 null 时）

| 字段 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `start` | string | `"08:00"` | 开始时间（HH:MM，24 小时制） |
| `end` | string | `"22:00"` | 结束时间（HH:MM，24 小时制） |

---

## 模型提供商

### 内置提供商

| 提供商 | ID | 默认 Base URL | API Key 前缀 |
|--------|-------|---------------|--------------|
| ModelScope（魔搭） | `modelscope` | `https://api-inference.modelscope.cn/v1` | `ms` |
| DashScope（灵积） | `dashscope` | `https://dashscope.aliyuncs.com/compatible-mode/v1` | `sk` |
| 自定义 | `custom` | （你自己填） | （任意） |

### 提供商配置

每个提供商需要设置：
- `base_url` - API 地址
- `api_key` - 你的 API Key

然后选择激活哪个提供商和模型：
- `provider_id` - 使用哪个提供商（如 `dashscope`）
- `model` - 使用哪个模型（如 `qwen3-max`）

---

## Agent Prompt 文件说明

| 文件 | 读写属性 | 核心职责 | 关键内容 |
|------|----------|----------|----------|
| **SOUL.md** | 只读 | 定义 Agent 的价值观与行为准则 | 真心帮忙不敷衍；有自己的观点不盲从；先自己想办法再问人；尊重隐私不越权 |
| **PROFILE.md** | 读写 | 记录 Agent 的身份和用户画像 | Agent 侧：名字、定位、风格、能力范围；用户侧：名字、时区、偏好、背景 |
| **BOOTSTRAP.md** | 一次性 | 新 Agent 的首次运行引导流程 | ① 自我介绍 → ② 了解用户 → ③ 写入 PROFILE.md → ④ 阅读 SOUL.md → ⑤ 自我删除 |
| **AGENTS.md** | 只读 | Agent 的完整工作规范 | 记忆系统读写规则；安全与权限；工具调用规范；Heartbeat 触发逻辑；操作边界 |
| **MEMORY.md** | 读写 | 存储 Agent 的工具设置与经验教训 | SSH 配置与连接信息；本地环境路径/版本；用户个性化设置与偏好 |
| **HEARTBEAT.md** | 读写 | 定义 Agent 的后台巡检任务 | 空文件 → 不巡检；写入任务 → 按配置间隔自动执行清单 |

---

## CLI 命令参考

### 初始化

```bash
# 快速用默认配置
copaw init --defaults

# 交互式初始化
copaw init

# 强制覆盖现有配置
copaw init --force
```

### 启动服务

```bash
copaw app
```

### 技能管理

```bash
# 交互式开关技能
copaw skills config
```

### 定时任务

```bash
# 管理定时任务
copaw cron
```

---

## API 接口

### Agent 处理接口

- **路径**: `POST /agent/process`
- **内容类型**: `application/json`
- **支持**: SSE 流式响应

### 请求示例

```bash
curl -N -X POST "http://localhost:8088/agent/process" \
  -H "Content-Type: application/json" \
  -d '{
    "input": [
      {
        "role": "user",
        "content": [
          {
            "type": "text",
            "text": "你好"
          }
        ]
      }
    ],
    "session_id": "session123"
  }'
```

---

## 官方文档导航

| 页面 | 说明 | 链接 |
|------|------|------|
| 项目介绍 | CoPaw 是什么、能做什么 | http://copaw.agentscope.io/docs/intro |
| 快速开始 | 安装和启动指南 | http://copaw.agentscope.io/docs/quickstart |
| 控制台 | 控制台使用说明 | http://copaw.agentscope.io/docs/console |
| 频道配置 | 钉钉/飞书/QQ/Discord/iMessage 配置 | http://copaw.agentscope.io/docs/channels |
| Skills | 技能扩展说明 | http://copaw.agentscope.io/docs/skills |
| 记忆 | 记忆系统说明 | http://copaw.agentscope.io/docs/memory |
| 心跳 | 心跳配置说明 | http://copaw.agentscope.io/docs/heartbeat |
| 配置与工作目录 | 详细配置说明 | http://copaw.agentscope.io/docs/config |
| CLI | 命令行工具说明 | http://copaw.agentscope.io/docs/cli |
| 问题反馈与交流 | 社区支持 | http://copaw.agentscope.io/docs/community |
| 开源与贡献 | 贡献指南 | http://copaw.agentscope.io/docs/contributing |

---

## 相关项目

- [AgentScope](https://github.com/agentscope-ai/agentscope)
- [AgentScope Runtime](https://github.com/agentscope-ai/agentscope-runtime)
- [ReMe](https://github.com/agentscope-ai/ReMe)
- [OpenClaw](https://openclaw.ai/) - 部分灵感来源
- [anthropics/skills](https://github.com/anthropics/skills) - Agent Skills 规范与示例

---

> **更新日期**: 2026-02-18
> **官方文档版本**: 基于访问 http://copaw.agentscope.io/docs/ 获取的信息
