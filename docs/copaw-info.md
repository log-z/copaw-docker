# CoPaw 官方文档信息汇总

> 本文档汇总了 CoPaw 官方文档的关键信息，方便后续调整需求时快速获取。
>
> 官方文档：http://copaw.agentscope.io/docs/
>
> **更新日期**: 2026-03-25

---

## 重要更新 (2026-03-25)

### v0.2.0 新增功能 (最新)

#### Agent
- **Inter-Agent Communication** - 添加 `copaw agents` 和 `copaw message` CLI 命令，用于列出代理、向频道推送消息、在代理之间发送请求
- **Built-in QA Agent** - 预配置的 QA 代理，用于回答 CoPaw 安装和使用问题
- **Configurable LLM Auto-Retry** - LLM 重试行为现在可以在控制台设置页面为每个代理单独配置
- **Summarization Improvements** - 当代理达到最大迭代次数并进入摘要模式时，会追加"round ended"通知来引导用户
- **Config Auto-Repair** - 如果 `config.json` 损坏或有轻微语法错误，会在加载时自动修复；无法恢复的文件会用唯一后缀备份，CoPaw 以默认设置启动

#### Security
- **File Access Guard** - 添加可配置的敏感文件和目录拒绝列表，启用后代理的工具将被阻止读取或写入这些路径
- **Tool Guard Enhanced** - 工具防护现在增强，在多个工具并行运行时能正确工作

#### Channels
- **Feishu / Lark SDK Migration** - 飞书频道迁移到官方 `lark-oapi` SDK，支持原生异步调用，并添加区域选择器（飞书中国 vs Lark 国际版）
- **XiaoYi File & Image Support** - 小艺频道支持文件和图片

#### Console & UI
- **Audio, Video & Speech Input** - 控制台聊天支持发送和显示音频、视频和语音附件
- **Stream Reconnection** - 如果在代理仍在响应时页面刷新，控制台会自动重新连接到正在进行的流式会话并保留用户输入文本
- **Web Account Management** - 用户可从控制台侧边栏更改用户名和密码
- **Model Provider Search** - 模型提供商设置页面添加搜索框，支持按名称筛选
- **Chat Scrollbar** - 聊天对话区域添加样式化滚动条

#### Providers
- **Multimodal Capability Probing** - 模型现在可以探测图像和视频支持能力，系统提示包含活动模型的多模态能力提示
- **Gemini Tool Image Support** - Gemini 模型现在正确处理工具返回的图像

#### Skills & Tools
- **Enhanced Grep & Glob Search** - 内置的 grep 和 glob 工具现在跳过大型目录，强制执行输出大小和时间限制
- **Workspace-Relative Tool Output** - 截图、PDF、浏览器快照等工具输出文件现在保存在代理的工作区目录下

#### Core & Lifecycle
- **Stable Prompts for KV Cache** - 环境上下文只包含当前日期而不是完整时间戳，提高 LLM KV 缓存命中率
- **Faster CLI Startup** - CLI 命令现在延迟加载，`copaw --help` 和子命令启动更快

#### Channels 优化
- **QQ Channel Refactor** - 简化 QQ 频道实现并添加全面单元测试
- **Smart Text Chunking for QQ & WeCom** - QQ 和企业微信长消息现在在自然边界自动分割
- **QQ WebSocket Reconnect** - 重连尝试现在可配置，并修复清理逻辑

#### Bug 修复
- **Shell Command Hang on Windows** - 修复 Windows 上运行 shell 命令时的挂起问题
- **Shell Stderr Visibility** - 当 shell 命令成功但仅写入 stderr 时，输出现在包含在工具响应中
- **Anthropic Overloaded Retry** - Anthropic "overloaded" 响应（HTTP 529）现在自动重试
- **Channel Message Processing Leak** - 修复频道消息处理中可能导致错误后消息停止处理的锁泄漏
- **Agent List** - 修复代理列表为空时的崩溃
- **Console Static Files** - 修复从不同工作目录启动 CoPaw 时控制台 UI 无法加载的问题
- **Token Usage Lock** - 修复并发请求下可能导致事件循环冻结的阻塞锁
- **Memory Timezone** - 内存摘要现在使用用户配置的时区进行每日笔记命名
- **Cron Job Cancellation** - 取消的定时任务现在正确报告其终止状态
- **MCP Startup Resilience** - 单个 MCP 客户端连接失败不再阻止整个应用启动

---

### v0.1.0.post1 补丁修复

#### Bug 修复
- **Anthropic HTTP 529 重试** - 添加 HTTP 529 到可重试状态码，处理 Anthropic 过载错误
- **token_usage 异步锁** - 用 asyncio.Lock 替换 threading.Lock，修复并发问题
- **Swagger 文档路由** - 修复 Swagger 文档路由被 SPA 通配符覆盖的问题
- **cron 任务取消状态** - 正确处理 CancelledError，取消的任务报告正确状态
- **Windows shell 命令** - 修复 Windows 上的 shell 命令执行问题
- **迁移问题** - 修复 media/emb_cache/.md 迁移问题
- **MCP 失败跳过** - MCP 启动失败时正确跳过而非阻塞

#### 新功能
- **XiaoYi 频道媒体支持** - 小艺频道支持文件和图片
- **/approve 匹配放宽** - 放宽 /approve 命令匹配规则

#### 性能优化
- **控制台静态目录** - 修复非仓库目录启动时静态资源解析问题
- **同步文件操作** - 用同步文件操作替换 aiofiles，减少异步开销

---

### v0.1.0 新增功能

#### 架构
- **多代理/多工作区架构** - 支持同时运行多个代理，每个代理有独立的工作区（配置、记忆、技能、工具），控制台代理选择器可切换
- **上下文管理** - Token 计数、`/dump_history` 和 `/load_history` 命令、可配置历史长度限制、内存压缩进度指示

#### 安全
- **技能安全扫描** - 安装前检测提示注入、命令注入、硬编码密钥、数据泄露风险
- **破坏性 Shell 命令检测** - 检测危险命令（磁盘格式化、fork 炸弹、反向 shell、提权）
- **Web 认证** - 可选 Web 认证，单用户注册、Token 登录、本地绕过、CLI 密码重置、环境变量自动注册

#### 频道
- **企业微信频道** - 完整支持，媒体、二维码访问、控制台配置 UI
- **小艺频道** - 华为 A2A 协议频道
- **钉钉 AI 卡片回复** - 支持 AI 卡片增量流式回复，不可用时降级到 webhook/markdown

#### 技能与工具
- **LobeHub 技能导入** - 从 LobeHub 直接导入技能
- **ModelScope Skill Hub** - 从 ModelScope 技能中心导入技能
- **内置技能版本同步** - 自动同步更新同时保留用户自定义
- **Guidance 技能** - 回答 CoPaw 安装配置问题的内置技能
- **ZIP 技能导入** - 上传 ZIP 包导入技能
- **内置工具** - 新增 `glob_search` 和 `grep_search` 文件搜索工具
- **view_image 工具** - LLM 可分析本地图片进行多模态对话

#### 多模态
- **控制台多模态聊天** - 控制台支持发送图片和文件
- **非多模态 LLM 媒体降级** - 非多模态 LLM 收到媒体时自动移除媒体块重试
- **音频转录** - 通过 Whisper API 或本地 Whisper 转录语音消息，支持音频格式转换，控制台语音转录设置页面

#### 提供商
- **Gemini Provider** - 内置 Google Gemini 支持
- **DeepSeek Provider** - 内置 DeepSeek 支持
- **MiniMax Provider** - 内置 MiniMax 支持（国际版和中国版分离端点）
- **Kimi Provider** - 内置 Kimi 支持（中国版和国际版分离端点）

#### CLI 与部署
- **`copaw update` 命令** - 自动检测环境并从 PyPI 升级 CoPaw
- **Docker Compose** - 官方支持 docker-compose.yml 部署
- **Docker 镜像** - 包含额外频道依赖

#### 控制台
- **暗黑模式** - 全页面支持（浅色/深色/跟随系统）
- **流式聊天** - SSE 流式响应，支持重连和中断

#### 其他
- **时区配置** - 控制台时区选择器，用于系统提示、定时任务、心跳，多平台自动检测
- **OS 信息** - 系统提示包含操作系统信息

---

### v0.0.7 新增功能 (保留)

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

### v0.0.6 新增功能 (保留)

#### 桌面应用
- **原生桌面安装包** - Windows 一键安装程序和 macOS `.app` 应用包
- **`copaw desktop` 命令** - 在原生 webview 窗口中打开 CoPaw，自动启动服务

#### 国际化
- **俄语支持** - 完整的控制台 UI、Agent 配置文件翻译
- **日语支持** - 完整的控制台 UI 翻译

#### 频道与通信
- **MQTT 频道** - 新增 IoT 和消息队列集成支持
- **Telegram 访问控制** - DM/群组访问策略，用户白名单，自定义拒绝消息
- **QQ Markdown 支持** - 富文本消息，自动降级为纯文本
- **QQ 富媒体支持** - 图片、视频、音频、文件附件的接收和解析
- **统一白名单控制** - 扩展到 Discord 和飞书频道
- **Discord 媒体发送** - 支持发送图片、视频、音频、文件
- **飞书表格渲染** - Markdown 表格转换为原生交互式消息卡片
- **飞书富文本消息** - 支持接收飞书帖子类型富文本消息
- **钉钉媒体扩展** - 扩展音视频格式支持
- **Docker 频道启用** - Telegram 和 Discord 在 Docker 镜像中默认启用

#### 模型与 AI
- **Gemini Thinking Model** - 保留推理内容（extra_content 字段）
- **MLX 后端优化** - 消息规范化处理，兼容 MLX tokenizer
- **本地/云端 LLM 路由** - 智能模型选择策略

#### 控制台与 UI
- **环境变量安全** - 敏感值密码式遮罩，支持显示/隐藏切换
- **环境变量批量删除** - 支持单个和批量删除
- **内置工具管理** - 专门的 Tools 页面，开关切换内置工具
- **自定义系统提示词** - 从工作区 Markdown 文件组合自定义系统提示词

#### 内存与配置
- **ReMeLight 迁移** - 从 ReMeCopaw 重构内存系统
- **可配置内存压缩** - 新的压缩策略，可调参数
- **智能工具输出截断** - 自动截断文件读取和 shell 命令输出，防止上下文溢出

### v0.0.5 新增功能
- **Twilio Voice 频道** - 语音频道集成，支持 Cloudflare tunnel
- **Telegram CLI 配置** - 交互式命令行工具配置 Telegram 频道
- **Anthropic 提供商** - 新增内置模型提供商
- **DeepSeek Reasoner 支持** - 保留 reasoning_content 用于推理模式
- **版本更新通知** - 自动版本检测与更新提示
- **Daemon 模式** - `copaw daemon` CLI 管理后台服务
- **Agent 中断 API** - `interrupt()` 方法取消活跃回复任务
- **MCP 客户端自动恢复** - 自动重连关闭的 MCP 会话
- **Windows 一键安装** - `install.bat` 脚本支持
- **频道文档链接** - 每个频道卡片上的快速 "Doc" 按钮
- **iMessage 附件支持** - 支持发送图片、音频、视频文件
- **消息过滤配置** - 每频道隐藏工具执行步骤和思考内容
- **Docker 配置持久化** - providers.json 和 envs.json 自动迁移到 SECRET_DIR

### v0.0.4 新增功能
- **Telegram 频道支持** - 新增 Telegram 机器人频道
- **OpenAI & Azure OpenAI** - 新增内置模型提供商
- **阿里云 coding-plan 提供商** - 新增模型提供商
- **CORS 配置** - 新增 `COPAW_CORS_ORIGINS` 环境变量
- **心跳监控面板** - 控制台新增监控 UI
- **音频文件支持** - 钉钉和飞书频道支持音频文件

### v0.0.3 新增功能
- **MCP 支持** - 连接外部 MCP 服务器扩展能力
- **本地模型支持增强** - llama.cpp、MLX、Ollama 集成
- **一键安装脚本** - 跨平台安装支持
- **阿里云 ECS 一键部署** - 云端部署选项
- **控制台功能增强** - 技能导入/创建、工作区上传下载、运行配置

### CLI 新增命令
- `copaw agents list` - 列出所有代理 (v0.2.0)
- `copaw message push/send` - 推送消息/发送请求 (v0.2.0)
- `copaw update` - 自动更新 CoPaw (v0.1.0)
- `copaw auth reset-password` - 重置 Web UI 密码 (v0.1.0)
- `copaw desktop` - 打开桌面应用窗口 (v0.0.6)
- `copaw daemon` - 管理后台服务 (v0.0.5)
- `copaw models config-key gemini` - 配置 Gemini (v0.0.6)
- `copaw models config-key minimax` - 配置 MiniMax (v0.1.0)
- `copaw models config-key deepseek` - 配置 DeepSeek (v0.1.0)
- `copaw models config-key kimi` - 配置 Kimi (v0.1.0)
- `copaw models config-key lmstudio` - 配置 LM Studio (v0.0.7)
- `copaw models download/remove-local` - 本地模型管理 (llama.cpp/MLX)
- `copaw models ollama-pull/ollama-list/ollama-remove` - Ollama 模型管理
- `copaw channels install/add/remove` - 自定义频道管理
- `copaw cron get/pause/resume/state` - 定时任务状态管理
- `copaw chats create/update/delete` - 会话管理

---

## 项目概述

### CoPaw 是什么？

CoPaw 是一款**个人助理型产品**，部署在你自己的环境中。

- **多通道对话** — 通过钉钉、飞书、QQ、Discord、iMessage、Telegram、Twilio Voice、MQTT、Mattermost、Matrix 等与你对话
- **定时执行** — 按你的配置自动运行任务
- **能力由 Skills 决定** — 内置定时任务、PDF 与表单、Word/Excel/PPT 文档处理、新闻摘要、文件阅读等，还可在 Skills 中自定义扩展
- **数据全在本地** — 不依赖第三方托管

### 你怎么用 CoPaw？

使用方式可以概括为两类：

1. **在聊天软件里对话** — 在钉钉、飞书、QQ、Discord、iMessage、Telegram、Twilio Voice、MQTT、Mattermost 或 Matrix 里发消息，CoPaw 在同一 app 内回复
2. **定时自动执行** — 按设定时间自动运行任务

### 技术基础

CoPaw 由 [AgentScope 团队](https://github.com/agentscope-ai) 基于以下项目构建：
- [AgentScope](https://github.com/agentscope-ai/agentscope)
- [AgentScope Runtime](https://github.com/agentscope-ai/agentscope-runtime)
- [ReMe](https://github.com/agentscope-ai/ReMe)

部分灵感来源于 [OpenClaw](https://openclaw.ai/)，感谢 [anthropics/skills](https://github.com/anthropics/skills) 提供 Agent Skills 规范与示例。

---

## 快速开始

### 环境要求

- **Python 版本**: >= 3.10, < 3.14

### 安装方式

#### 方式一：一键安装（推荐）

无需预装 Python — 安装脚本通过 `uv` 自动管理一切。

**macOS / Linux：**
```bash
curl -fsSL https://copaw.agentscope.io/install.sh | bash
```

**Windows（CMD）：**
```cmd
curl -fsSL https://copaw.agentscope.io/install.bat -o install.bat && install.bat
```

**Windows（PowerShell）：**
```powershell
irm https://copaw.agentscope.io/install.ps1 | iex
```

**可选参数：**
```bash
# 安装指定版本
curl -fsSL ... | bash -s -- --version 0.0.5

# 从源码安装（开发/测试用）
curl -fsSL ... | bash -s -- --from-source

# 安装本地模型支持
bash install.sh --extras llamacpp    # llama.cpp（跨平台）
bash install.sh --extras mlx         # MLX（Apple Silicon）
bash install.sh --extras ollama      # Ollama（需 Ollama 服务运行）
```

#### 方式二：pip 安装

```bash
pip install copaw
```

可选：先创建并激活虚拟环境再安装（`python -m venv .venv`，Linux/macOS 下 `source .venv/bin/activate`，Windows 下 `.venv\Scripts\Activate.ps1`）。

#### 方式三：桌面应用 (v0.0.6 新增，Beta)

如果你不习惯使用命令行，可以下载并使用 CoPaw 的桌面应用版本，无需手动配置 Python 环境或执行命令。

**特点**：
- ✅ **零配置**：下载后双击即可运行，无需安装 Python 或配置环境变量
- ✅ **跨平台**：支持 Windows 10+ 和 macOS 14+ (推荐 Apple Silicon)
- ✅ **可视化**：自动打开浏览器界面，无需手动输入地址
- ⚠️ **Beta 阶段**：功能持续完善中，欢迎反馈问题

**下载地址**：[GitHub Releases](https://github.com/agentscope-ai/CoPaw/releases)
- Windows: `CoPaw-Setup-<version>.exe`
- macOS: `CoPaw-<version>-macOS.zip`

#### 方式四：魔搭创空间一键配置（无需安装）

1. 前往 [魔搭](https://modelscope.cn/register) 注册并登录
2. 打开 [CoPaw 创空间](https://modelscope.cn/studios/fork?target=AgentScope/CoPaw)，一键配置即可使用

> **重要**：使用创空间请将空间设为**非公开**，否则你的 CoPaw 可能被他人操纵。

#### 方式五：Docker

镜像在 **Docker Hub**（`agentscope/copaw`）。镜像 tag：`latest`（稳定版）、`pre`（PyPI 预发布版）。

国内用户也可选用阿里云 ACR：`agentscope-registry.ap-southeast-1.cr.aliyuncs.com/agentscope/copaw`（tag 相同）。

```bash
docker pull agentscope/copaw:latest
docker run -p 127.0.0.1:8088:8088 -v copaw-data:/app/working agentscope/copaw:latest
```

> **安全更新**：v0.0.5 起，默认端口绑定改为 `127.0.0.1` 以提高安全性。

然后在浏览器打开 http://127.0.0.1:8088/ 进入控制台。配置、记忆与 Skills 保存在 `copaw-data` 卷中。

#### 方式六：部署到阿里云 ECS

打开 [CoPaw 阿里云 ECS 部署链接](https://computenest.console.aliyun.com/service/instance/create/cn-hangzhou?type=user&ServiceId=service-1ed84201799f40879884)，按页面提示填写部署参数。

### 初始化

**方式 1：快速用默认配置（不交互）**
```bash
copaw init --defaults
```

**方式 2：交互式初始化**
```bash
copaw init
```

交互流程按顺序配置：
- 心跳 — 间隔、目标、可选活跃时间段
- 工具详情 — 是否在频道消息中显示工具调用细节
- 语言 — Agent 人设文件使用 zh 或 en
- 频道 — 可选配置 iMessage / Discord / DingTalk / Feishu / QQ / Telegram / Twilio / MQTT / Mattermost / Matrix / Console
- LLM 提供商 — 选择提供商、输入 API Key、选择模型（必选）
- 技能 — 全部启用 / 不启用 / 自定义选择
- 环境变量 — 可选添加工具所需的键值对
- HEARTBEAT.md — 在默认编辑器中编辑心跳检查清单

### 启动服务

```bash
# 默认 127.0.0.1:8088
copaw app

# 自定义地址
copaw app --host 0.0.0.0 --port 9090

# 代码改动自动重载（开发用）
copaw app --reload

# 多 worker 模式
copaw app --workers 4

# 详细日志
copaw app --log-level debug
```

### Daemon 模式 (v0.0.5 新增)

管理后台 CoPaw 服务：

```bash
copaw daemon status      # 状态（配置、工作目录、记忆服务）
copaw daemon restart     # 打印说明（在对话中用 /daemon restart 可进程内重载）
copaw daemon reload-config # 重新读取并校验配置
copaw daemon version     # 版本与路径
copaw daemon logs [-n N]  # 最近 N 行日志（默认 100）
```

### 控制台

服务启动后，在浏览器打开 `http://127.0.0.1:8088/` 即可进入**控制台** — 一个用于对话、频道、定时任务、技能、模型等的 Web 管理界面。

### 验证安装

```bash
curl -N -X POST "http://localhost:8088/api/agent/process" \
  -H "Content-Type: application/json" \
  -d '{"input":[{"role":"user","content":[{"type":"text","text":"你好"}]}],"session_id":"session123"}'
```

---

## 工作目录结构

默认工作目录：`~/.copaw`

```
~/.copaw/
├── config.json              # 根配置，包含代理引用 (v0.1.0+)
├── workspaces/              # 多代理工作区目录 (v0.1.0+)
│   └── default/             # 默认代理工作区
│       ├── agent.json       # 代理配置
│       ├── SOUL.md          # （必需）核心身份与行为原则
│       ├── AGENTS.md        # （必需）详细的工作流程、规则和指南
│       ├── PROFILE.md       # 身份和用户画像
│       ├── active_skills/   # 当前激活的技能
│       └── customized_skills/ # 用户自定义的技能
├── HEARTBEAT.md             # 心跳每次要问 CoPaw 的内容
├── jobs.json                # 定时任务列表
├── chats.json               # 会话列表（文件存储模式）
├── providers.json           # LLM 提供商配置（v0.0.5+ 迁移到 SECRET_DIR）
├── envs.json                # 环境变量配置（v0.0.5+ 迁移到 SECRET_DIR）
├── custom_channels/         # 自定义频道模块
├── memory/                  # Agent 记忆文件（自动管理）
│   ├── MEMORY.md            # 长期有效的关键信息
│   └── YYYY-MM-DD.md        # 每日日志
├── mcp_clients/             # MCP 客户端配置
└── .runtime/                # SECRET_DIR (v0.1.0+)
    ├── providers.json       # LLM 提供商配置
    ├── envs.json            # 环境变量配置
    └── auth.json            # Web 认证数据 (v0.1.0+)
```

**v0.1.0 多工作区迁移**：现有配置会在首次启动时自动迁移到新的多工作区架构。

**v0.0.5 Docker 持久化目录**：

为了解决 Docker 容器重启后配置丢失的问题，v0.0.5 将敏感配置迁移到持久化目录：

| 文件 | 旧位置 | 新位置 (SECRET_DIR) |
|------|--------|---------------------|
| providers.json | `~/.copaw/` | `{SECRET_DIR}/providers.json` |
| envs.json | `~/.copaw/` | `{SECRET_DIR}/envs.json` |

自动迁移逻辑会在首次启动时执行，旧文件会被软链接到新位置。

---

## 频道配置

### 支持的频道

| 频道 | 说明 | 凭据字段 |
|------|------|----------|
| **dingtalk** | 钉钉 | `client_id`, `client_secret`, `open`, `allow_from` (v0.0.5+) |
| **feishu** | 飞书 / Lark (v0.2.0 迁移至 lark-oapi SDK) | `app_id`, `app_secret`, `encrypt_key`, `verification_token`, `media_dir`, `region` (china/international) |
| **qq** | QQ 机器人 | `app_id`, `client_secret` |
| **discord** | Discord 机器人 | `bot_token`, `http_proxy`, `http_proxy_auth` |
| **imessage** | macOS iMessage | `db_path`, `poll_sec` |
| **telegram** | Telegram 机器人 | `bot_token` (v0.0.5+ 支持 CLI 配置) |
| **wecom** | 企业微信 (v0.1.0 新增) | 企业微信 AI Bot SDK 配置 |
| **xiaoyi** | 小艺 (v0.1.0 新增) | 华为 A2A 协议配置 |
| **mqtt** | MQTT 消息队列 (v0.0.6 新增) | `host`, `port`, `transport`, `qos`, `subscribe_topic`, `publish_topic` |
| **twilio voice** | Twilio 语音 (v0.0.5 新增) | `account_sid`, `auth_token`, `phone_number` |
| **mattermost** | Mattermost (v0.0.7 新增) | `url`, `token`, `team_name` |
| **matrix** | Matrix 协议 (v0.0.7 新增) | `homeserver`, `user_id`, `access_token` |
| **console** | 控制台 | （只需开关） |

### 频道通用字段

| 字段 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enabled` | bool | `false` | 是否启用该频道 |
| `bot_prefix` | string | `""` | 可选命令前缀（如 `[BOT]`） |
| `filter_tool_messages` | bool | `false` | 隐藏工具执行步骤 (v0.0.5 新增) |
| `filter_thinking` | bool | `false` | 隐藏思考内容 (v0.0.5 新增) |

### 多模态消息支持

| 频道 | 接收文本 | 接收图片 | 接收视频 | 接收音频 | 接收文件 | 发送文本 | 发送图片 | 发送视频 | 发送音频 | 发送文件 |
|------|:--------:|:--------:|:--------:|:--------:|:--------:|:--------:|:--------:|:--------:|:--------:|:--------:|
| 钉钉 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 飞书 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 企业微信 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Discord | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ (v0.0.6+) | ✓ (v0.0.6+) | ✓ (v0.0.6+) | ✓ (v0.0.6+) |
| iMessage | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ (v0.0.5+) | ✓ (v0.0.5+) | ✓ (v0.0.5+) | ✗ |
| QQ | ✓ | ✓ (v0.0.6+) | ✓ (v0.0.6+) | ✓ (v0.0.6+) | ✓ (v0.0.6+) | ✓ | ✓ (v0.0.7+) | 🚧 | 🚧 | 🚧 |
| Telegram | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Twilio Voice | ✓ | ✗ | ✗ | ✓ | ✗ | ✓ | ✗ | ✗ | ✓ | ✗ |
| MQTT | ✓ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ |
| Mattermost | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Matrix | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| 小艺 | ✓ | ✓ (v0.2.0+) | ✓ (v0.2.0+) | ✗ | ✓ (v0.2.0+) | ✓ | ✓ (v0.2.0+) | ✗ | ✗ | ✓ (v0.2.0+) |

> ✓ = 已支持；🚧 = 施工中；✗ = 不支持

---

## 模型提供商

### 内置提供商

| 提供商 | ID | 默认 Base URL |
|--------|-------|---------------|
| ModelScope（魔搭） | `modelscope` | `https://api-inference.modelscope.cn/v1` |
| DashScope（灵积） | `dashscope` | `https://dashscope.aliyuncs.com/compatible-mode/v1` |
| OpenAI | `openai` | `https://api.openai.com/v1` |
| Azure OpenAI | `azure_openai` | （你自己填） |
| Anthropic (v0.0.5 新增) | `anthropic` | `https://api.anthropic.com` |
| Gemini (v0.0.6 新增) | `gemini` | `https://generativelanguage.googleapis.com` |
| LM Studio (v0.0.7 新增) | `lmstudio` | `http://localhost:1234/v1` |
| DeepSeek (v0.1.0 新增) | `deepseek` | `https://api.deepseek.com` |
| MiniMax (v0.1.0 新增) | `minimax` | 国际版/中国版分离端点 |
| Kimi (v0.1.0 新增) | `kimi` | 中国版/国际版分离端点 |
| Aliyun coding-plan | `codingplan` | （你自己填） |
| 自定义 | `custom` | （你自己填） |

### 本地提供商

#### llama.cpp / MLX

```bash
# 安装后端
pip install 'copaw[llamacpp]'  # llama.cpp（跨平台）
pip install 'copaw[mlx]'       # MLX（Apple Silicon）

# 下载模型
copaw models download Qwen/Qwen3-4B-GGUF
copaw models download Qwen/Qwen3-4B --backend mlx

# 从 ModelScope 下载
copaw models download Qwen/Qwen2-0.5B-Instruct-GGUF --source modelscope

# 查看已下载模型
copaw models local

# 删除已下载模型
copaw models remove-local <model_id>
```

**选项说明**：
| 选项 | 简写 | 默认值 | 说明 |
|------|------|--------|------|
| `--backend` | `-b` | `llamacpp` | 目标后端（llamacpp 或 mlx） |
| `--source` | `-s` | `huggingface` | 下载源（huggingface 或 modelscope） |
| `--file` | `-f` | （自动） | 指定文件名，省略时自动选择 |

#### Ollama

Ollama 集成本地 Ollama 守护进程，动态加载其中的模型。

**前置条件**：
- 从 [ollama.com](https://ollama.com/) 安装 Ollama
- 安装 Ollama SDK：`pip install 'copaw[ollama]'`

```bash
# 下载 Ollama 模型
copaw models ollama-pull mistral:7b
copaw models ollama-pull qwen2.5:3b

# 查看 Ollama 模型
copaw models ollama-list

# 删除 Ollama 模型
copaw models ollama-remove mistral:7b

# 在配置流程中使用
copaw models config           # 选择 Ollama → 从模型列表中选择
copaw models set-llm          # 切换到其他 Ollama 模型
```

**与本地模型的区别**：
- 模型来自 Ollama 守护进程（不由 CoPaw 下载）
- 使用 `ollama-pull` / `ollama-remove` 而非 `download` / `remove-local`
- 通过 Ollama CLI 或 CoPaw 添加/删除模型时，模型列表自动更新

支持的热门模型：`mistral:7b`、`qwen3:8b` 等

---

## CLI 命令参考

### 快速上手

```bash
# 初始化
copaw init --defaults   # 不交互，用默认值
copaw init              # 交互式初始化

# 启动服务
copaw app
```

### Daemon 模式 (v0.0.5 新增)

```bash
copaw daemon status          # 状态（配置、工作目录、记忆服务）
copaw daemon restart         # 打印说明
copaw daemon reload-config   # 重新读取并校验配置
copaw daemon version         # 版本与路径
copaw daemon logs [-n 50]    # 最近 N 行日志（默认 100）
```

### 模型管理

```bash
copaw models list                    # 查看所有提供商
copaw models config                  # 完整交互式配置
copaw models config-key <provider>   # 配置 API Key
copaw models config-key gemini       # 配置 Gemini API Key (v0.0.6+)
copaw models config-key lmstudio     # 配置 LM Studio (v0.0.7+)
copaw models config-key deepseek     # 配置 DeepSeek (v0.1.0+)
copaw models config-key minimax      # 配置 MiniMax (v0.1.0+)
copaw models config-key kimi         # 配置 Kimi (v0.1.0+)
copaw models set-llm                 # 切换活跃模型
copaw models download <repo_id>      # 下载本地模型
copaw models local                   # 查看已下载模型
copaw models ollama-pull <model>     # 下载 Ollama 模型
```

### 更新与认证 (v0.1.0 新增)

```bash
copaw update                         # 自动更新 CoPaw
copaw auth reset-password            # 重置 Web UI 密码
```

### Agent 与消息 (v0.2.0 新增)

```bash
copaw agents list                    # 列出所有代理
copaw message push <channel> <user>  # 向频道推送消息
copaw message send <agent> <msg>     # 向代理发送请求
```

### 桌面应用 (v0.0.6 新增)

```bash
copaw desktop                        # 打开 CoPaw 桌面应用窗口
```

### 频道管理

```bash
copaw channels list                  # 查看所有频道（密钥脱敏）
copaw channels config                # 交互式配置
copaw channels install <key>         # 安装自定义频道模块
copaw channels add <key>             # 添加频道到 config
copaw channels remove <key>          # 删除自定义频道（--keep-config 保留配置）
```

### 定时任务

```bash
copaw cron list                      # 列出所有任务
copaw cron get <job_id>              # 查看任务配置详情
copaw cron create --type text --name "每日早安" --cron "0 9 * * *" \
  --channel dingtalk --target-user "xxx" --text "早上好！"
copaw cron state <job_id>            # 查看运行状态
copaw cron delete <job_id>           # 删除任务
copaw cron pause <job_id>            # 暂停任务
copaw cron resume <job_id>           # 恢复任务
copaw cron run <job_id>              # 立即执行一次
```

### 会话管理

```bash
copaw chats list                     # 列出所有会话
copaw chats get <id>                 # 查看会话详情
copaw chats create --session-id "xxx" --user-id "xxx" --name "My Chat"
copaw chats update <id> --name "新名称"
copaw chats delete <id>              # 删除会话
```

### 技能管理

```bash
copaw skills list                    # 看有哪些技能
copaw skills config                  # 交互式开关
```

---

## 官方文档导航

| 页面 | 说明 | 链接 |
|------|------|------|
| 项目介绍 | CoPaw 是什么、能做什么 | http://copaw.agentscope.io/docs/intro |
| 快速开始 | 安装和启动指南 | http://copaw.agentscope.io/docs/quickstart |
| 桌面应用 | 桌面应用使用指南 (v0.0.6+) | http://copaw.agentscope.io/docs/desktop |
| 控制台 | 控制台使用说明 | http://copaw.agentscope.io/docs/console |
| 频道配置 | 钉钉/飞书/QQ/Discord/iMessage/Telegram/Twilio/MQTT 配置 | http://copaw.agentscope.io/docs/channels |
| Skills | 技能扩展说明 | http://copaw.agentscope.io/docs/skills |
| MCP | MCP 客户端配置 | http://copaw.agentscope.io/docs/mcp |
| 记忆 | 记忆系统说明 | http://copaw.agentscope.io/docs/memory |
| 心跳 | 心跳配置说明 | http://copaw.agentscope.io/docs/heartbeat |
| 配置与工作目录 | 详细配置说明 | http://copaw.agentscope.io/docs/config |
| CLI | 命令行工具说明 | http://copaw.agentscope.io/docs/cli |
| FAQ 常见问题 | 社区常见问题汇总 | http://copaw.agentscope.io/docs/faq |
| 问题反馈与交流 | 社区支持 | http://copaw.agentscope.io/docs/community |
| 开源与贡献 | 贡献指南 | http://copaw.agentscope.io/docs/contributing |

---

## 相关项目

- [CoPaw 官方仓库](https://github.com/agentscope-ai/CoPaw) - CoPaw 主项目
- [AgentScope](https://github.com/agentscope-ai/agentscope)
- [AgentScope Runtime](https://github.com/agentscope-ai/agentscope-runtime)
- [ReMe](https://github.com/agentscope-ai/ReMe)
- [OpenClaw](https://openclaw.ai/) - 部分灵感来源
- [anthropics/skills](https://github.com/anthropics/skills) - Agent Skills 规范与示例

---

## 官方 Docker 镜像

CoPaw 官方也提供 Docker 镜像，可直接使用：

```bash
docker pull agentscope/copaw:latest
docker run -p 127.0.0.1:8088:8088 -v copaw-data:/app/working agentscope/copaw:latest
```

> **注**：本项目（copaw-docker）与官方镜像的主要区别在于：
> - 官方镜像：由 AgentScope 团队维护，简单直接
> - 本项目：增加了更多自动化功能（自动初始化、健康检查）、工作流测试、镜像发布等

---

## 社区支持

如有问题或交流，可通过以下方式联系官方：

| 平台 | 说明 |
|------|------|
| Discord | [加入 Discord 社区](https://discord.gg/agentscope) |
| 钉钉 | 搜索群组加入 |
| GitHub Issues | [提交问题](https://github.com/agentscope-ai/CoPaw/issues) |

---

## License

CoPaw 采用 [Apache License 2.0](https://github.com/agentscope-ai/CoPaw/blob/main/LICENSE) 开源许可。
