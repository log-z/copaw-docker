# QwenPaw 官方文档信息汇总

> 本文档汇总了 QwenPaw 官方文档的关键信息，方便后续调整需求时快速获取。
>
> 官方文档：http://qwenpaw.agentscope.io/docs/
>
> **更新日期**: 2026-05-19

---

## 重要更新 (2026-05-19)

### v1.1.8 (2026-05-19)

#### 新功能

**插件与工具**
- **官方插件分发** - 从网站浏览和下载官方插件，或在控制台插件管理器中一键安装 (#4482)
- **QwenPaw Pet 桌面宠物** - 桌面宠物伴侣插件，含动画宠物窗口 (#4418, #4516)
- **CloudPaw 阿里云部署** - 新插件，支持多 Agent 编排、IaC 驱动的云资源配置和 A2A 流式集成 (#4362, #4423, #4506, #4524)
- **浏览器健壮性** - 改进浏览器稳定性，含崩溃恢复、空闲超时保护和退出自动清理 (#4306, #4350)
- **浏览器标签元数据** - `tabs` 操作现在返回每个打开标签的 URL 和标题 (#4438)

**会话与控制台**
- **收件箱批量操作** - 重新设计收件箱，支持批量选择和批量删除消息 (#4358, #4493)
- **固定会话抽屉** - 将会话抽屉固定，保持与聊天并排显示 (#4414, #4416, #4517)

**模型与提供商**
- **自定义 HTTP 头和认证模式** - 所有提供商支持自定义请求头编辑和认证模式选择（API Key vs Bearer Token）(#4413)
- **每模型 Token 限制** - `max_tokens` 和 `max_input_length` 现在可在 Settings → Models 中按模型配置 (#4417)

**Agent 系统**
- **`/make-skill` 命令** - 将当前聊天会话转换为可复用技能的新魔法命令 (#4282)
- **印尼语 Agent 模板** - Agent 人设 Markdown 模板和 `Asia/Jakarta` 时区 (#4287)
- **Cron 任务超时** - 可配置 Cron 任务超时时间（默认 120 秒）(#4425)

**安全**
- **技能路径安全** - 防止技能目录操作中的路径遍历攻击 (#4335)
- **备份信任控制** - 导入/恢复时验证备份完整性，含信任确认对话框，加强远程访问控制 (#4409, #4429)
- **AgentMd 路径遍历防护** - 防止 Agent 记忆文件操作中的路径遍历 (#4511)
- **插件 API 认证** - 插件管理 API 现在需要认证 (#4513)

**频道**
- **Matrix E2EE 验证** - 密码和访问令牌登录，支持 E2EE 开关和 SAS 设备验证 (#4120)
- **Telegram 流式输出** - 实时流式回复，支持推理指示器 (#4318)
- **钉钉流式卡片** - 通过 AI 卡片实时流式回复（仅卡片消息模式）(#4420)
- **飞书 CardKit 流式输出** - 通过 CardKit 实时流式回复 (#4480)

#### 变更

- **控制台头部导航** - 头部链接整合为文档下拉菜单，含教程、功能演示、变更日志和 FAQ (#3875)
- **飞书二维码域名** - 二维码 API 接受查询参数 (#4504)
- **流式任务超时** - 从 300 秒增加到 1800 秒，支持长时间运行的流式 Agent 任务 (#4510)

#### Bug 修复

**频道**
- **企业微信重复占位符** - 抑制快速连续消息时重复的"Thinking..."流 (#4427)
- **微信轮询关闭** - 修复退出时崩溃和微信轮询线程的紧凑错误循环 (#4490)
- **QQ 重连循环** - 防止 IP 白名单拒绝时的高频重连 (#4503)

**技能**
- **QA Agent 文档打包** - QA Agent 现在在所有安装方式（pip、Docker、桌面）中正确工作 (#4280)
- **技能 Hub URL 验证** - 修复带 `www.` 前缀的 URL 技能导入失败 (#4359)

**提供商与模型**
- **每模型速率限制器** - 一个模型的速率限制不再阻塞其他模型的请求 (#4487)
- **每模型 Token 用量** - Token 用量摘要现在包含按模型的明细和提示/完成 Token 计数 (#4476)

**控制台与 UI**
- **SSE 连接泄漏** - 修复页面导航时 SSE 连接未关闭的问题，防止耗尽浏览器连接限制 (#4488)
- **Cron 验证错误** - Cron 创建/更新返回本地化的可操作错误信息 (#4495)
- **会话记忆持久化** - `/mission` 和 `/skill` 信息响应现在持久化到会话记忆，页面刷新后保留 (#4523)

#### 文档

- **网站功能演示** - 文档演示画廊，含技能、doctor 和 Mission 模式的操作视频 (#4507)

---

### v1.1.7 (2026-05-14)

#### 新功能

**工具与 MCP**
- **Browser Use 批量操作** - 单次工具调用中执行多个浏览器步骤（导航、点击、输入、截图等）(#4139)
- **Browser Use 文件下载** - 通过点击页面元素或直接获取 URL 下载文件 (#4261)
- **GPT Image 2 参考图片** - GPT Image 2 插件支持通过 URL 或本地路径上传 1-16 张参考图片 (#4194)
- **外部 Agent 异步执行** - `delegate_external_agent` 支持异步流式执行，含任务列表、状态查询和可配置超时 (#4197)
- **Shell 可执行文件配置** - 可通过配置选项选择运行命令的 Shell (#4215)
- **远程 MCP OAuth 2.1** - 通过 OAuth 2.1 with PKCE 认证远程 MCP 服务器 (#4256)

**插件**
- **控制台插件管理** - 从 Settings UI 通过本地路径、ZIP 上传或 URL 安装和卸载插件 (#4214, #4266)
- **Qwen-Image 和 Wan 2.7 插件** - 新增图像生成/编辑和视频生成插件 (#4248)
- **插件 HTTP API 路由** - 插件可注册自定义 HTTP API 端点 (#4255)

**会话与控制台**
- **多文件附件** - 聊天输入支持单条消息选择多个文件 (#4206)
- **印尼语支持** - 完整 Bahasa Indonesia 本地化支持 (#4219)
- **收件箱** - 新的集中式 Inbox，含 Approvals 和 Push Messages 标签页，用于管理工具审批和查看 Cron 执行结果及追踪 (#4210, #4305)
- **Cron 任务增强** - 支持一次性定时执行、日历视图、内置模板、每任务执行历史和运行追踪、投递到 Inbox (#4210)

**频道**
- **飞书语音气泡** - 通过飞书发送的音频文件渲染为原生语音气泡 (#4202)
- **钉钉引用消息** - 钉钉中带引用消息的回复包含引用文本和媒体到 Agent 上下文 (#4209)
- **飞书二维码创建机器人** - 在频道设置 UI 中通过扫描二维码创建飞书/Lark 机器人 (#4236)
- **企业微信流式输出** - 企业微信频道可选流式回复，支持实时消息投递和推理指示器 (#4271)

#### 变更

- **模型选择器重设计** - 悬停下拉替换为按提供商分组的可搜索平面列表 (#3876)
- **浮动聊天按钮** - 聊天导航从侧边栏菜单移至 Agent 选择器旁的固定按钮 (#4240, #4273)
- **Agent 统计会话发现** - 通过直接遍历频道子目录简化会话文件查找 (#4250)

#### 性能优化

- **异步 FastAPI 依赖** - 模型和提供商管理器依赖转为异步，消除不必要的线程池调度 (#4229)
- **文件读取大小限制** - 最大文件读取大小从 1 GB 降低到 200 MB，按实际文件大小预分配 (#4272, #4276)
- **Keyring 超时** - Keyring 操作新增 10 秒超时，防止凭据管理器挂起阻塞启动 (#4263)

#### Bug 修复

**提供商与模型**
- **火山引擎模型 ID** - 修正模型 ID 以匹配实际 API 端点，更新能力标志 (#4169)
- **提供商元数据保留** - 获取提供商信息时不再丢失元数据 (#4200)
- **格式错误的工具调用过滤** - 流式解析器过滤掉空 ID 或空名称的工具调用块 (#4234)

**频道**
- **企业微信审批卡片操作员** - 已解决的审批卡片显示操作员名称 (#4233)
- **飞书 WebSocket 保活** - 检测并恢复静默 WebSocket 连接丢失 (#4241)

**控制台与 UI**
- **会话历史路由** - 修复会话历史消失和消息路由到错误会话的问题 (#4203)
- **Plan Panel 暗黑模式** - 改善 Plan Panel 暗黑模式文字对比度 (#4190)
- **移动端侧边栏** - 窄屏下侧边栏自动折叠 (#4225)
- **用户消息换行** - 用户消息保留换行符 (#4231)
- **Token 使用日期标签** - 日期范围跨年时图表标签显示年份前缀 (#4268)
- **桌面端外部链接** - 链接在桌面构建中正确打开 (#4270)

---

### v1.1.6 (2026-05-09)

#### 新功能

**Agent 系统**
- **Windows 诊断增强** - `qwenpaw doctor` 新增 Windows 环境检查，包括长路径支持、PowerShell 语言模式和工作目录路径长度 (#4032)
- **Agent 状态 API** - 新增 `GET /agents/{agentId}/agent-status` 端点，报告 Agent 运行时状态、运行任务数和时间戳 (#4107)
- **Cron 会话隔离** - Cron 任务新增 `share_session` 选项，禁用时每次运行创建隔离会话上下文 (#4117)
- **GPT Image 2 插件** - 新增通过 OpenAI GPT Image 2 API 生成图像的工具插件 (#3911)
- **配置驱动 Agent 名称** - 使用配置的 Agent 配置文件名称替代硬编码默认值 (#4140)

**会话与控制台**
- **Whisper 语音输入** - 用服务端 Whisper 转录替换浏览器原生 Web Speech API，跨浏览器更可靠 (#3574)
- **Token 使用趋势图** - Token Usage 设置页面新增按模型和按 Token 类型的趋势折线图 (#4080, #4094)
- **技能批量启禁用** - 技能批量操作工具栏新增启用和禁用按钮，含每技能错误报告 (#4091)
- **Mermaid 图表渲染** - `mermaid` 语言标签的 Markdown 代码块渲染为交互式图表 (#4146)
- **巴西葡萄牙语完善** - 后端语言设置新增完整 pt-BR 本地化支持 (#4143)

**提供商**
- **火山引擎提供商** - 新增 Volcano Engine 为内置 OpenAI 兼容提供商，含标准和 Coding Plan 端点 (#3994)
- **DashScope 区域选择** - DashScope Base URL 可从预设区域端点修改 (#4074)
- **阿里云 Token 计划提供商** - 新增 Aliyun Token Plan 为内置提供商 (#4122)

**频道**
- **飞书发送者上下文** - 飞书发送者昵称传递到 Agent 环境上下文 (#4098)
- **企业微信交互式审批卡片** - Tool Guard 审批请求渲染为交互式模板卡片 (#4112)

**安全**
- **规则级自动拒绝** - 单个安全规则可配置为自动拒绝工具调用 (#4046)

**技能与 CLI**
- **技能测试 CLI** - 新增 `qwenpaw skills test` 命令验证技能内容和运行安全扫描 (#3999)

#### 性能优化

- **聊天历史导航** - 跳过非箭头键的历史查找，缓存用户消息列表避免重复扫描 (#4130)
- **QR 轮询清理** - 认证完成或二维码过期时立即停止轮询并清除状态指示器 (#4148)
- **控制台渲染稳定** - 消除审批轮询状态比较和聊天运行时选项的重复渲染 (#4110, #4153)

#### Bug 修复

**频道**
- **微信 Cron 缓冲刷新** - 绕过正常完成路径的 Cron/主动发送立即刷新微信合并缓冲区 (#4106)
- **Markdown 表格拆分** - 在消息分片间重复表头和分隔行，保持 Markdown 表格结构 (#4119)

**Agent 系统**
- **外部 Agent 超时** - `delegate_external_agent` 新增安全默认超时（60s），防止无限挂起 (#3928)
- **Agent 配置热重载** - Agent 配置文件变更触发优雅重载，含任务排空 (#4064)
- **Agent 配置持久化** - 修复控制台 Agent 配置编辑器保存时丢失嵌套设置的问题 (#4157)

**MCP**
- **MCP 客户端生命周期泄漏** - 修复 `close()` 可能跳过停止后台重连任务的问题 (#4152)

**控制台与 UI**
- **SSE 代理安全性** - 通过清理不可编码内容防止格式错误的代理文本导致 SSE 流崩溃 (#3553)
- **默认 Agent 显示名称** - 所有 UI 界面尊重自定义默认 Agent 名称 (#4073)
- **文件预览路径** - 修复文件预览路径中冗余 URL 前缀剥离导致的 URL 断裂 (#4089)

**基础设施**
- **Docker 备份恢复** - 通过交换目录内容而非重命名，正确恢复 Docker 卷挂载点上的 secrets (#3916)
- **音频块路径** - 为 `file://` URL 音频块返回解析后的文件系统路径 (#4048)
- **日志轮转** - 所有平台统一使用 `RotatingFileHandler` 进行日志轮转 (#4076)
- **环回代理绕过** - 企业代理环境下绕过环回 API 健康检查的代理环境变量 (#4092)
- **Conda 打包** - 运行 `conda-pack` 前恢复打包工具，防止打包管道中断 (#4093)

#### 文档
- **WSL2 超时 FAQ** - 新增 WSL2 NAT 模式下 `APITimeoutError` 处理的 FAQ 条目 (#4005)

---

### v1.1.5.post2 补丁修复 (2026-05-06)

#### 新功能

**会话**
- **会话标题异步生成** - 通过 LLM 异步生成聊天会话标题 (#3829)

**国际化**
- **巴西葡萄牙语支持** - 新增 Brazilian Portuguese (pt-BR) 本地化 (#4009)

**技能**
- **技能安装/卸载 CLI** - 新增 `qwenpaw skills install` 和 `qwenpaw skills uninstall` 命令 (#4053)

#### 优化

- **MCP 执行超时修正** - MCP 客户端 `sse_read_timeout` 现用作工具执行超时，而非 HTTP 连接超时 (#4061)
- **控制台重复渲染** - 解决控制台重复渲染问题 (#4052)

#### Bug 修复

**频道**
- **Telegram 网络重试** - Telegram 频道新增网络重试机制 (#4039)
- **音频文件路径解析** - 修复 `file://` URL 音频块返回解析后的路径 (#4021)
- **审批命令修复** - 修复 `/approve` 简写忽略 `request_id` 参数的问题 (#4014)

**提供商**
- **Anthropic max_token** - 增加 Anthropic 兼容模型的 `max_token` 限制 (#4054)

**技能**
- **技能加载健壮性** - 增强对已迁移或格式错误的技能及技能池条目的容错加载 (#4016)

---

### v1.1.5.post1 补丁修复 (2026-04-30)

#### 新功能

**频道**
- **飞书交互式审批** - 引入 FeishuCardHandler，将 Tool Guard 审批升级为交互式按钮 (#3941)
- **飞书审批文档提示** - 当 card.action.trigger 未订阅时，在审批卡片上显示文档链接 (#3982)
- **企业微信群聊会话共享** - 新增 `share_session_in_group` 开关控制群聊会话共享 (#3948)

#### 安全更新
- **路径遍历防护** - 拒绝绝对静态文件路径，防止路径遍历攻击 (#3973)

#### Bug 修复

**频道**
- **企业微信流式响应卡顿** - 保持占位符流活跃，防止 "Thinking..." 状态卡住 (#3950)
- **企业微信重连优化** - 避免双重重连竞争和跨循环断开连接 (#3963)

**控制台与 UI**
- **工具调用代码块换行** - 修复工具调用输入/输出块中 CodeMirror 换行问题 (#3960)

---

### v1.1.5 (2026-04-29)

#### 新功能

**Agent 系统**
- **上下文压缩回退** - 当 LLM 上下文压缩失败或被禁用时，上下文管理器自动提高保留阈值重试，保留更多近期对话轮次 (#3882)
- **自适应模型重试** - 运行时从 API 失败中学习每个模型的特性，主动适配后续请求 (#3874)
- **ACP Agent 重命名与删除** - 可从 WebUI 重命名和删除 ACP Agent (#3859)

**频道**
- **QQ 语音与 ASR 支持** - QQ 频道检测语音消息文件扩展名，使用平台 ASR 转录（如可用）(#3845)

#### 优化

- **Agent 统计导航** - Agent 统计页面移至侧边栏 Workspace 分组下 (#3754)
- **Dockerfile 清理** - `pip install` 后删除构建目录，使镜像更精简 (#3638)
- **Chat 组件升级** - 升级 `@agentscope-ai/chat`，修复 `stopChat` 问题 (#3917)

#### 性能优化

- **配置加载缓存** - 根配置和每 Agent 配置文件使用 mtime 缓存失效 (#3865)
- **技能清单缓存** - 技能清单按文件路径和 mtime 缓存，减少热路径磁盘读取 (#3910)
- **模型 API 去重** - 聊天页面并发的 `listProviders` 和 `getActiveModels` 请求自动去重 (#3897)
- **控制台聊天性能** - 聊天会话列表使用 `react-window` 虚拟化，搜索渐进加载并显示进度指示 (#3908, #3912)

#### Bug 修复

**频道**
- **频道中审批修复** - 修复 `/approve` 和 `/deny` 命令在频道中不工作的问题 (#3832, #3896)
- **企业微信 @提及命令** - 修复企业微信群聊中 bot 被 @提及时斜杠命令失败的问题 (#3903)
- **飞书表情事件** - 为飞书消息表情反应事件注册空操作处理器 (#3890)
- **QQ WebSocket 重连** - QQ 频道在可恢复的 WebSocket 错误时自动重连 (#3872)

**控制台与 UI**
- **每标签页 Agent 选择** - 修复 Agent 选择在浏览器标签页间泄漏的问题 (#3857, #3867)
- **备份导入图标** - 备份导入按钮更新为导入图标 (#3909)

**Agent 系统**
- **时区名称规范化** - 非标准时区名称映射到规范的 IANA 标识符 (#3858)
- **ACP 回退继承** - 回退 Agent 配置现在继承主配置中的 ACP 配置 (#3834)
- **MCP 执行超时** - MCP 客户端超时现在传递到工具执行 (#3904)

---

### v1.1.4.post2 补丁修复 (2026-04-25)

#### Bug 修复

**频道**
- **频道中审批不生效** - 修复 Tool Guard 审批在频道中不工作的问题 (#3832)

---

### v1.1.4.post1 补丁修复 (2026-04-25)

#### 优化

**记忆**
- **CJK 感知查询分词** - 记忆搜索新增 CJK（中日韩）感知的查询分词，提升中文等语言的搜索精度 (#3811)

#### 内部优化
- **回退 Vite 升级** - 回退控制台构建工具 Vite 从 v8 到 v6 的升级 (#3812)

---

### v1.1.4

#### 新功能

**Agent 系统**
- **Memory & Context 重构** - 长期记忆模块重构，支持可插拔后端、每 N 轮对话自动记忆摘要、自动记忆检索、新的上下文管理接口 (#3548)
- **Plan 模式** - 可选的结构化规划模式，使用 `/plan` 创建分步任务计划，Agent 按计划执行，控制台实时显示计划面板 (#3686, #3787)

**提供商**
- **DeepSeek V4 模型** - 新增 DeepSeek V4 Flash 和 V4 Pro 内置模型 (#3797)

**安全**
- **可配置 Shell 混淆检测** - 在安全设置页面单独开关每条 Shell 混淆检测规则，每条规则标记风险类型 (#3694, #3715, #3781)
- **Auth-Bypass 主机白名单** - 可配置 `allow_no_auth_hosts` 列表，允许指定 IP 无需认证访问 API，含 IP 验证和控制台安全警告 (#3739)

**工具**
- **浏览器启动参数** - `browser_use` 支持自定义 Chromium 标志和浏览器可执行文件路径 (#3556)
- **Shell 命令超时** - 按 Agent 配置 `execute_shell_command` 的默认超时时间 (#3732)

**控制台与 UI**
- **每 Agent 模型分配** - 从 Settings → Agents 为每个 Agent 单独指定 LLM 模型 (#3599)
- **会话查看按钮** - Sessions 表格新增"View"操作，直接跳转到对应聊天会话 (#3615)
- **会话右键菜单** - 右键聊天会话项，快速打开、重命名、置顶/取消置顶和删除 (#3770)

**频道**
- **SIP 语音频道** - 新增 SIP 电话频道，双模式后端 — pyVoIP（开发）和 LiveKit（生产）(#3449)
- **钉钉语音识别** - 使用钉钉内置语音识别替代本地下载和转码音频 (#3681)
- **Telegram 命令菜单** - 在 Telegram 机器人命令菜单中暴露 `/model` 和 `/stop` (#3714)
- **QQ 引用消息支持** - 解析回复/引用元数据，将引用文本和附件注入 Agent 请求 (#3735)
- **钉钉 Markdown 消息** - 较短回复使用钉钉 Open API Markdown 格式，渲染更丰富 (#3771)
- **钉钉定时消息类型** - 定时/循环发送使用独立消息类型，允许 Cron 使用卡片消息同时交互聊天使用 Markdown (#3778)
- **微信交互式配置向导** - CLI 频道设置流程中的交互式 `configure_weixin` 向导 (#3699)

#### 优化

- **Tool Guard 审批系统重构** - 控制台交互式审批卡片、跨会话审批路由（从主会话审批子 Agent 工具调用）、可配置执行级别（Strict/Smart/Auto/Off）、REST API 和 `/approval` CLI 命令 (#3656, #3737)
- **动态插件注册** - 用运行时 `import.meta.glob` 替换构建时生成的 host 模块注册表 (#3676, #3692, #3696)
- **Docker 构建改进** - `config.json` 初始化从镜像构建移至容器入口点，`pip` 替换为 `uv` 加速安装 (#3698, #3723, #3769)
- **Agent 语言同步** - 新 Agent 继承控制台 UI 语言 (#3720)
- **Agent 选择持久化** - Agent 选择状态保存在 `localStorage`，浏览器重启后恢复 (#3772)
- **Token 用量缓冲** - 异步缓冲 Token 用量记录，定期刷盘 (#3766)

#### Bug 修复

**频道**
- **过滤工具消息** - 对进行中内容事件遵循 `filter_tool_messages` 设置 (#3660)
- **文件 URL 编码** - `file://` URL 中对非 ASCII 字符进行百分号编码，修复 Windows 和 CJK 路径 (#3625)
- **微信发送响应** - 修复微信 `send_text` 在空或非字典 API 响应时失败 (#3685)
- **微信图标映射** - 修复 `wechat` 频道键未映射到正确微信图标 (#3691)
- **微信 QR 登录超时** - 延长微信二维码轮询超时至 60 秒，读取超时时重试 (#3700)

**控制台与 UI**
- **Agent 统计** - 修复图表库导入错误导致的页面崩溃和切换 Agent 时统计不刷新 (#3724, #3743)

**提供商**
- **重复模型警告** - 添加已存在模型 ID 时显示本地化警告 (#3773)
- **Anthropic 文件块** - 将 Anthropic 格式历史中不支持的文件块转为文本占位符，防止 API 错误 (#3786)

**打包**
- **Discord.py Conda-Unpack** - 将 `discord.py` 加入 conda-unpack 重装列表，修复 Windows 路径损坏 (#3730)

#### 文档
- **Memory-Evolving & Proactive Agent** - 新增 Memory-Evolving 和 Proactive Agent 功能的专门文档页面 (#3755, #3764)
- **Agent Team 实践指南** - 新增 Agent Team 协作的完整实践指南 (#3784)
- **ACP 集成文档** - 重构并完善 ACP 集成文档，控制台内嵌文档链接 (#3741)
- **Docker 备份卷** - 新增 Docker 卷挂载的备份与恢复文档 (#3736)
- **备份图示更新** - 更新备份文档图示 (#3678)

---

### v1.1.3.post1 补丁修复 (2026-04-22)

#### Bug 修复
- **Windows Defender 兼容** - 回退改动以避免触发 Windows Defender 误报 (#3717)
- **桌面端文件下载** - pywebview 文件下载改用原生保存对话框 (#3719)

---

### v1.1.3

#### 新功能

**Agent 系统**
- **备份与恢复** - 备份和恢复系统，创建 agent、skills、memory、sessions 的作用域快照，支持按 agent 选择、导入/导出 zip 文件 (#3534, #3655)
- **ACP Server** - 通过 `qwenpaw acp` 将 QwenPaw agents 暴露为 ACP（Agent Communication Protocol）端点（stdio）(#3487, #3589, #3595)
- **Agent 主动消息** - Agent 可主动发送消息，使用会话记忆和屏幕上下文提供及时信息 (#3466, #3643)
- **跨提供商消息规范化** - 对话中无缝切换 LLM 提供商，自动清理和规范化提供商特定的消息字段 (#3530)

**控制台与 UI**
- **控制台插件系统** - 可扩展的控制台插件架构，第三方插件可注入侧边栏页面、注册路由、共享主机模块 (#3357, #3512, #3631)
- **Agent 统计页面** - 新的仪表板，包含会话和消息趋势图、token 使用量、频道分布饼图 (#3365, #3608, #3632)

**技能**
- **技能页面改进** - 重新设计的 Skills 和 Skill Pool 页面，支持批量选择/管理、分离的搜索和过滤控件 (#3616, #3634)
- **内置技能语言切换** - 所有内置技能支持中英文变体，从 Skill Pool 页面切换语言 (#3558, #3644)

**安全**
- **Shell 混淆防护** - 新的 Tool Guard guardian，检测 shell 命令混淆模式 (#3400, #3668)
- **增强的 Tool Guard 响应** - Tool guard 消息现在包含风险严重级别和本地化的阻止/审批原因解释 (#3515)

**提供商**
- **本地模型管理** - 为本地模型（llama.cpp）配置自定义服务器端口，实时监控服务器日志 (#3596, #3604)
- **OpenRouter 多模态检测** - OpenRouter 模型现在自动报告多模态能力（图片/视频支持）(#3584, #3604)
- **Aliyun Coding Plan 国际版** - 支持 Aliyun Coding Plan 提供商国际区域 (#3609)

**频道**
- **QQ 即时确认** - QQ 频道可配置即时回复，在 agent 处理请求时立即确认用户 (#3246)
- **Telegram 输入指示器** - 工具执行期间输入指示器保持活跃，提供持续的视觉反馈 (#3585)
- **钉钉回复 @提及** - 钉钉群聊回复时自动 @提及原始发送者 (#3591)
- **频道健康检查与重启 API** - 按 agent 的 HTTP 端点检查单个频道健康状态并热重启频道 (#3649)

**CLI**
- **更新提供商 Base URL** - `qwenpaw providers update` 现在支持从命令行更新提供商 Base URL (#3536)

#### 优化

- **Debug 页面重新设计** - Debug 页面移至 Settings 下，改进组件结构、专用日志查看器、暗黑模式样式修复 (#3539, #3547, #3590)
- **`make_plan` 技能更新** - 清理过时的文档引用，简化技能 (#3535)
- **统一频道媒体目录** - 所有频道现在一致地从 agent 工作区解析 `media_dir`，确保跨频道类型的文件存储隔离 (#3610)

#### Bug 修复

**控制台与 UI**
- **预览 URL 前缀** - 修复文件预览路径中的重复 URL 前缀 (#3355)
- **Markdown 渲染** - 修复工作区文件编辑器中的 Markdown 渲染和代码块复制样式 (#3639)
- **表格滚动** - 修复 Sessions 和 Cron Jobs 页面的表格滚动 (#3654)

**频道**
- **企业微信附件访问** - 修复服务器部署中企业微信附件访问失败 (#3079)
- **企业微信文件上传** - 修复企业微信文件上传中的事件循环阻塞，支持 `send_file_to_user` 相对路径 (#3128)
- **企业微信重复消息** - 修复企业微信群聊消息的重复聊天条目 (#3529)
- **企业微信截图文件名** - 修复企业微信截图文件名中的 CJK 字符导致下载失败 (#3633)

---

### v1.1.2

#### 新功能

**Agent 系统**
- **Mission 模式** - `/mission` 命令支持自主多阶段任务执行，Agent 可迭代规划、执行和自我修正，支持 `/mission status` 和 `/mission list` 监控运行中的任务 (#3364, #3480)
- **纯文本自动续推** - 启用后，当模型仅返回文本而未调用工具时，Agent 自动重试最多两轮额外推理 (#3107)
- **自定义 Agent ID** - 从控制台或 API 创建 Agent 时可指定自定义 ID (#3333)
- **ACP 外部 Agent 委托** - 通过 `delegate_external_agent` 工具将任务委托给外部编码 Agent（OpenCode、Qwen、Claude Code、Codex），含权限守卫和实时流式输出 (#3340)
- **Agent CLI 创建** - 通过 `qwenpaw agents create` 从命令行创建 Agent，支持模板选择（`default`、`local`、`qa`）和工作区初始化 (#3385)

**CLI**
- **`qwenpaw doctor`** - 诊断命令，检查环境、配置、提供商、频道、技能、MCP、记忆、安全等，支持 `doctor fix` 自动修复 (#3371)
- **`qwenpaw skills info`** - 从命令行查看技能详情（启用状态、频道、路径、描述），同时新增聊天中 `/skills` 斜杠命令 (#3459)

**记忆**
- **Memory Dream** - 定时长期记忆整理，"dream" Agent 周期性去重和重组 `MEMORY.md` (#2177)
- **递归文件监视器** - 新增 `recursive_file_watcher` 选项，在记忆索引中包含子目录文件 (#3347)

**控制台与 UI**
- **技能导入中心** - 重新设计导入模态框，支持 URL 验证、市场集成和冲突覆盖确认 (#2412, #3415, #3482)
- **Debug 页面** - 设置中新增 Debug 页面，实时查看后端日志文件 (#3478)

**频道**
- **微信引用消息** - 引用/回复消息现可解析，支持文本、图片、语音、文件和视频 (#3483)

#### 优化

- **提供商排序** - 设置中提供商列表按可用性排序 (#3458)
- **Agent 通信工具** - Agent 间通信工具拆分为 `chat_with_agent`（同步）和新的 `submit_to_agent` / `check_agent_task`（异步后台任务）(#3485)

#### Bug 修复

**控制台与 UI**
- `/clear` 现在正确清除控制台聊天历史 (#3348)
- Token 用量按日期表格现在按最新日期排序 (#3387)
- Cron 任务 ID 提示文本修正为系统生成的 UUID (#3404)
- ArrowUp 消息历史在斜杠命令建议可见时不再触发 (#3444)

**提供商**
- 图片 MIME 规范化：`image/jpg` 统一为 `image/jpeg` 防止严格 API 拒绝 (#3313)
- 多模态工具调用排序：提升的图片消息不再破坏 OpenAI 和 Anthropic 要求的连续工具结果块 (#3299)
- 提供商类身份：修复从多个导入路径加载同一提供商时的 Pydantic 类身份崩溃 (#3431)

**Agent 系统**
- 后台任务追踪：通过 AgentApp API 分发的后台任务现由 `TaskTracker` 追踪，防止重载或关闭时被取消 (#3305)
- 记忆压缩防护：记忆压缩钩子不再在每个推理步骤中运行两次 (#3461)

**频道**
- Discord 线程路由：Discord 线程消息现路由到正确的线程会话而非父频道 (#3144)
- 微信输入指示器：输入指示器不再泄漏后台任务，完成或出错时可靠停止 (#3488)

---

### v1.1.1.post1 补丁修复

#### Bug 修复
- **Cron Job ID 提示文本** - 修正定时任务 ID 信息提示文本 (#3404)
- **Ollama 提供商连接测试** - 修复 Ollama 提供商连接测试问题 (#3391)
- **LM Studio 连接测试超时** - 修复 LM Studio 提供商连接测试超时问题 (#3412)

#### 内部优化
- **Matrix 频道路径处理** - 使用 `WORKING_DIR` 常量简化路径处理 (#3406)

---

### v1.1.1

#### 新功能

**模型与提供商**
- **OpenRouter 提供商** - 内置 OpenRouter 提供商，支持模型发现、系列浏览、按模态和价格筛选 (#1192)
- **OpenCode (Zen) 提供商** - 内置 OpenAI 兼容的 OpenCode 提供商，提供免费模型 (#2463)
- **模型 ID 自动补全** - 添加模型时模型 ID 选择下拉自动补全，默认为所有提供商启用模型发现 (#3175, #3341)

**多代理系统**
- **内置 Agent 协作工具** - 新增 `list_agents` 和 `chat_with_agent` 内置工具，支持 Agent 间通信，含专用技能和简化 CLI 命令 (#3292)

**频道**
- **Matrix 频道重写** - 端到端加密 (E2EE)、@提及处理、消息历史支持和 Markdown 渲染 (#2509)
- **飞书引用消息** - 回复链消息处理，支持文本、帖子、图片和文件内容提取 (#3207)
- **钉钉 QR 认证** - 控制台中钉钉频道设置支持二维码设备流认证 (#3315)

**安全**
- **扩展 Shell 命令防护** - 新增防护规则覆盖 `$IFS` 注入、控制字符、Unicode 空白字符、`/proc/*/environ` 访问、危险 `jq` 标志和 Zsh 风险内置命令 (#3303)

**工具与技能**
- **ClawHub 技能需求格式** - 支持 ClawHub 格式的技能需求，含多元数据命名空间解析 (#3310)
- **媒体 URL 查看** - `view_image` 和 `view_video` 工具现支持 HTTP/HTTPS URL 直接查看媒体，无需下载 (#3358)

#### 优化

**模型与提供商**
- **多模态探测统一** - Anthropic、Gemini 和 OpenAI 的图像支持探测共享统一评估路径，改进误报检测 (#3367)
- **模型切换消息规范化** - 请求时规范化消息，切换模型提供商时保留媒体附件 (#3359)
- **Anthropic 媒体去重** - 工具结果中重复的 base64 媒体替换为文本占位符，防止超出 Anthropic 消息大小限制 (#3372)

**频道**
- **钉钉 SDK 迁移** - 频道迁移至阿里云官方 SDK，处理期间显示 emoji 反馈，AI 卡片模式支持媒体发送 (#3236, #3337, #3374)
- **飞书 WebSocket 稳定性** - 重构事件循环处理，改进跨线程重连可靠性 (#3360)
- **微信回复限制警告** - 频道设置现显示微信 iLink 的 context_token 回复限制警告 (#3376)

**工具与技能**
- **浏览器托管 CDP** - 默认浏览器启动策略改为托管 CDP，自动检测 Chromium、端口分配和进程生命周期管理 (#3164)

**控制台与 UI**
- **模型管理重设计** - 提供商模型管理模态框重设计，支持能力标签、模型搜索和简化卡片布局 (#3273, #3294)
- **Agent 配置标签页** - Agent 配置页面从堆叠卡片重构为标签页界面 (#3354)
- **技能选择 UI** - 改进技能选择，支持标签建议、长名称工具提示、优化加载行为和批量选择操作 (#3320, #3362, #3373)
- **下载页面** - 网站下载页面重构，按稳定版和预览版分组 (#3353)

#### Bug 修复

**频道**
- **QQ WebSocket 关闭** - `stop()` 不再因强制关闭 WebSocket 而阻塞 8 秒 (#3188)

**控制台与 UI**
- 修复暗黑模式下聊天会话置顶按钮对比度 (#3267)
- 标题中 Markdown 链接现可在应用内导航而非打开新标签页 (#3186)
- 网站贡献者布局中文区域对齐 (#3332)

**提供商**
- 修复 Windows 上本地模型下载失败 (`[Errno 22] Invalid argument`) (#3321)
- 为 vLLM 兼容性省略 `tool_choice=auto`，避免未启用 `--enable-auto-tool-choice` 时出现 400 错误 (#3295)

#### 文档
- **RESTful API 教程** - 全面的 REST API 教程，涵盖聊天端点、认证、多轮会话、流式和 Agent 切换 (#3335)
- **技能聊天命令** - 在命令文档中添加技能聊天命令参考 (#3330)

---

### v1.0.2

#### 新功能

**核心**
- **插件系统** - 从工作区 `plugins/` 文件夹安装扩展 (#3101, #3131, #3132)
- **`qwenpaw task` 命令** - 从终端运行一次性任务，无需启动 Web 服务 (#3031)
- **`/model` 聊天命令** - 在聊天中切换模型、列出可用模型、恢复默认、查看模型详情，无需打开设置页 (#3133)

**模型与提供商**
- **SiliconFlow** - 内置 SiliconFlow OpenAI 兼容 API，提供中国和国际端点 (#2886)
- **QwenPaw Local 改进** - 支持图像和视频模型、更丰富的控制台设置、Windows 上更可靠的下载和能力检测 (#3021, #3087, #3140)

**安全**
- **密钥加密存储** - API Key 等敏感值在磁盘上加密；加密密钥尽可能存储在操作系统钥匙串中 (#3025)

**控制台与 UI**
- **聊天输入历史** - 使用上下箭头键浏览之前的用户输入 (#2466)
- **聊天搜索** - 跨会话搜索消息文本 (#2842)
- **置顶会话** - 置顶对话使其保持在列表顶部 (#3137)
- **每 Agent 聊天记忆** - 切换 Agent 时恢复上次打开的聊天 (#3155)
- **视觉优化** - 内置工具图标和提供商 Logo 显示在模型旁 (#3061, #3130)

**技能与工具**
- **技能命令** - `/skills` 显示频道已启用的技能；输入 `/<技能名>` 打开或运行技能 (#3150)
- **技能池标签** - 使用标签组织共享技能池 (#2837, #3069)
- **MCP 工具发现** - 通过 HTTP API 查询已连接 MCP 服务器的工具名称、描述和参数 (#3149)

**频道**
- **QQ 富媒体发送** - 在各种消息类型中一致地发送文件和富媒体 (#3012)
- **企业微信引用上下文** - 收到的消息保留引用/回复上下文，Agent 可看到引用内容 (#3024)

#### 优化

- **时区选择器** - 区域名称跟随所选 UI 语言 (#2497)
- **文件大小显示** - 控制台中全面使用人类可读的文件大小格式 (#2808)
- **控制台启动** - 较重的设置页面按需加载，首屏打开更快 (#3122)
- **大量技能列表** - 拥有多个技能池技能时滚动和交互更流畅 (#3141, #3158)
- **提供商连接测试** - 状态消息使用用户语言显示 (#2913)
- **错误码统一** - 频道、API 和 CLI 间更一致的错误码 (#3110)

#### Bug 修复

**频道**
- **iMessage** - 私聊现在正确遵循 DM 策略和白名单 (#2491)
- **Discord** - 长回复不再破坏 Markdown 代码块 (#2976)
- **飞书** - 重连和运行多个 Agent 不再因共享锁或事件循环混乱而出错 (#3095, #3145)

**工具与技能**
- **MCP** - 关闭或重连客户端后不再导致 CPU 飙升 (#3106)
- **浏览器自动化** - 存在重复元素时点击正确目标；文档更清晰地解释选择器 (#3023)
- **Shell 工具** - 包含引用文本的命令保留换行符 (#3070)
- **技能** - 损坏或非对象的技能元数据不再导致需求解析崩溃 (#3072)

---

### v1.0.1

#### 新功能

**模型与提供商**
- **Zhipu 模型提供商** - 内置支持智谱 AI 模型 (#2858)
- **多模态视频分析** - 多模态模型扩展支持视频文件，自动提取和分析 (#2627)
- **模型级生成参数** - 通过模型设置为每个模型单独配置生成参数 (#2892)
- **QwenPaw Local 自动更新** - 本地模型提供商自动更新机制，含版本检查和下载 (#2889)
- **宽松工具调用解析器** - 放宽工具调用解析，处理格式错误的 JSON，提高 LLM 输出兼容性 (#2832)

**控制台与 UI**
- **Agent 拖拽排序** - 通过拖放界面持久化调整 Agent 顺序 (#2695)
- **聊天会话状态指示器** - 显示每个聊天会话的活跃/非活跃状态 (#2803)
- **首选会话置顶** - 自动将首选聊天会话移到会话列表顶部 (#2864)
- **暗黑模式系统选项** - 暗黑模式切换增加跟随系统偏好选项 (#2678)
- **自动切换默认 Agent** - 所选 Agent 被删除或禁用时自动切换到默认 Agent (#2640)

**技能与工具**
- **技能批量操作** - 支持跨 Agent 批量删除、下载和广播技能 (#2743)
- **禁用 Agent 时停止服务** - 禁用 Agent 时自动停止后台服务释放资源 (#2746)
- **技能 requires 列表格式** - 技能 requires 字段支持列表格式 (#2504)

**频道**
- **OneBot v11 频道** - 新增 NapCat/QQ 频道，反向 WebSocket 服务器，完整 QQ 协议支持，包括个人账号和群消息 (#2870)
- **钉钉 AI 卡片（工作区追踪器）** - 工作区追踪器路径下支持 AI 卡片，重构共享核心 (#2741)
- **飞书 DONE 表情反应** - 工作区路径下支持飞书 DONE 表情反应 (#2727)
- **统一无文本防抖** - 工作区追踪器和传统路径统一防抖逻辑 (#2724)
- **企业微信服务端二维码** - 替换 JavaScript SDK 弹窗为服务端二维码生成和通用 OAuth 提供商模式 (#2891)
- **微信文件上传与输入指示** - 改进微信频道的文件上传可靠性和输入指示器 (#2597)

**上下文与记忆**
- **手动压缩附加指令** - 通过 `/compact` 命令手动触发记忆压缩时支持提供额外上下文 (#2694)

#### 优化

**控制台与 UI**
- **网站界面现代化** - 重大视觉更新，改进国际化、现代化样式和用户体验 (#2645, #2722)
- **语言选择器排序** - 重新排列下拉语言选项以改善用户体验 (#2673)
- **国际化时间显示** - 使用 dayjs relativeTime 替换自定义时间格式，支持正确的国际化 (#2800)
- **技能卡片与列表视图** - 增强技能管理 UI，卡片布局和暗黑模式支持 (#2714, #2794)
- **MCP 控制台 UI 刷新** - 重新设计 MCP 客户端卡片和技能池界面 (#2652)

#### Bug 修复

**频道**
- **钉钉定时任务 Webhook** - 修复 sessionWebhook 过期处理，自动回退到 Open API (#2617)
- **钉钉白名单** - 修复频道白名单过滤 (#2718)
- **企业微信 WebSocket 可靠性** - 修复心跳重连的任务调度和 Windows 守护进程 stdio 流 (#2651, #2760)
- **QQ 重连状态重置** - 修复 WebSocket 会话恢复时的重连状态管理 (#2827)

**控制台与 UI**
- **斜杠命令菜单对比度** - 修复暗黑模式文字对比度 (#2600)
- **模型选择器消息通知** - 修复模型选择器组件中缺失的消息通知 (#2612)
- **控制台 None 输出防护** - 防止 None 值发送到控制台频道 (#2608)
- **文件时间戳显示** - 修复工作区文件时间戳显示 "NaNd ago" 错误 (#2793)
- **聊天会话标题保持** - 修复流式消息时标题被覆盖的问题 (#2847)
- **控制台本地化** - 修复控制台组件本地化问题 (#2662)
- **Google Fonts 加载** - 使用 Google Fonts CDN 修复 Inter、Lato 和 Newsreader 字体加载 (#2867)

**技能与工具**
- **技能需求解析** - 使用安全格式化器解析需求，防止格式化错误 (#2630)
- **Windows 工具兼容性** - 修复浏览器启动参数和 Windows 平台 shell 命令换行处理 (#2635, #2861)
- **浏览器空闲看门狗** - 修复 browser_use 空闲看门狗自取消问题 (#2843)
- **Thinking 模型工具防护** - 修复使用 thinking 模型时的工具防护兼容性 (#2631)

**提供商**
- **QwenPaw Local 改进** - 修复 GPU 默认设置、探测图片检测、仓库验证和 Windows 模型下载 (#2688, #2735)
- **Llama.cpp Windows NVIDIA GPU** - 修复 Windows 下 llama.cpp 使用 NVIDIA GPU 和安装前 macOS 版本检查 (#2625)

#### 文档
- **README 锚点链接** - 修复 README 目录中的锚点链接 (#2614)
- **QwenPaw-Flash 部署 FAQ** - 改进 QwenPaw-Flash 部署常见问题 (#2661)
- **技能文档** - 更新技能文档以反映技能池架构变更 (#2767)
- **WebView2 安装说明** - 添加 Windows WebView2 安装说明和 Web 认证详情 (#2836)

---

### v1.0.0.post3 补丁修复

#### 重要变更
- **移除源码仓库 AGENTS.md** - 项目源码中移除 AGENTS.md 开发指南，用户工作区不受影响 (#2745)

#### 新功能
- **技能批量操作** - 支持批量删除、广播和下载技能 (#2743)
- **暗黑模式系统选项** - 控制台暗黑模式切换增加跟随系统选项 (#2678)
- **飞书 DONE 反应（工作区路径）** - 工作区追踪器路径下支持飞书 DONE 表情反应 (#2727)
- **统一无文本防抖** - 工作区追踪器和传统路径统一无文本防抖逻辑 (#2724)
- **钉钉 AI 卡片（工作区路径）** - 工作区追踪器路径下支持 AI 卡片，重构共享核心 (#2741)
- **Agent 禁用时停止服务** - 禁用 Agent 时自动停止相关服务 (#2746)

#### Bug 修复
- **钉钉白名单** - 修复钉钉频道白名单问题 (#2718)
- **QwenPaw Local GPU 默认启用** - 修复本地模型默认使用 GPU、探测图片问题和 Windows 桌面模型下载 (#2735)
- **企业微信 Windows 守护进程** - 修复 Windows 守护进程下企业微信 WebSocket 线程的 stdio 流问题 (#2760)
- **qwenpaw 命令（exe）** - 修复 exe 中无 qwenpaw 命令的问题 (#2759)
- **技能名称样式** - 修复技能名称显示问题 (#2765)

#### 样式优化
- **技能与技能池** - 技能和技能池的暗黑模式样式优化 (#2714)

---

### v1.0.0.post2 补丁修复

#### 新功能
- **Console MCP** - 控制台支持 MCP 配置 (#2652)

#### 优化
- **技能启动迁移优化** - 避免每次启动时重复迁移技能 (#2649)
- **技能池工作区同步移除** - 移除技能池工作区同步以提高效率 (#2659)
- **技能列表刷新优化** - 优化技能列表和刷新性能 (#2687)
- **网站界面优化** - 改善列表标记可见性、控制台语言选项排序 (#2645, #2648, #2673)

#### Bug 修复
- **企业微信心跳重连** - 心跳失败时在独立任务中调度重连，避免阻塞 (#2651)
- **异步工具状态修复** - 修复异步工具状态显示问题 (#2676)
- **Provider 下载检查** - 下载前检查仓库是否存在 (#2688)
- **本地模型修复** - 修复本地模型相关问题 (#2662)

#### 依赖更新
- **reme-ai** - 更新至 0.3.1.8 (#2654)

#### 文档
- **QwenPaw-Flash 部署 FAQ** - 改进 QwenPaw-Flash 部署常见问题 (#2661)

---

### v1.0.0.post1 补丁修复

#### 新功能
- **Console 选择 Agent 对话** - 控制台支持选择特定 Agent 进行对话 (#2640)
- **多模态视频分析** - 多模态模型支持视频分析能力 (#2627)
- **Console 消息增强** - 控制台消息功能优化 (#2604, #2612)
- **运行时健壮性改进** - 提升运行时稳定性和可靠性 (#2616)
- **Windows Shell 命令修复** - 修复 Windows 下 shell 命令中的 `\n` 转义问题 (#2635)

#### Bug 修复
- **暗黑模式斜杠命令对比度** - 修复暗黑模式下斜杠命令菜单的文字对比度问题 (#2600)
- **技能签名缓存与 requires 字段** - 修复技能签名缓存，支持 requires 字段的列表格式，使用安全格式化器解析 (#2504, #2620, #2630)
- **Llama.cpp Windows GPU** - 修复 Windows 下使用 Nvidia GPU 的问题，安装前检查 macOS 版本 (#2625)
- **钉钉定时任务 Webhook 回退** - sessionWebhook 过期时回退到 Open API 处理定时任务 (#2617)
- **Thinking 模型工具防护** - 修复使用 thinking 模型时的工具防护问题 (#2631)
- **迁移异常处理** - 改进迁移过程的异常处理 (#2618)
- **anyio 版本锁定** - 锁定 anyio 版本以避免 busy-wait 循环 (#2634)
- **聊天记忆加载** - 优化变量命名和记忆加载逻辑 (#2638)
- **企业微信心跳重连** - 回退心跳失败时的重连修复 (#2641)

---

### v1.0.0 正式版

#### Multi-Agent System
- **Background Task Support** - Agent 间通信的后台执行模式，支持任务追踪、状态轮询和取消，通过 CLI `--background` 标志启用 (#2345)
- **Agent Enable/Disable Toggle** - 通过控制台 UI 和 API 启用或禁用 Agent (#2249)
- **Unified Priority Queue System & `/stop` Command** - 按频道、按会话的优先级队列系统，`/stop` 命令可取消运行中的任务并清除队列中的消息 (#2411)

#### Providers and Models
- **QwenPaw Local Model** - 内置本地模型提供商，使用 llama.cpp 引擎，支持自动下载、配置和自定义仓库 (#2419, #2476)
- **Scoped Active Model Selection** - 活跃模型可在 Settings 全局设置或在 Chat 中按 Agent 单独设置 (#2278)
- **Global LLM Rate Limiter** - QPM（每分钟查询数）滑动窗口限速、并发信号量控制、全局 429 暂停协调和防惊群抖动 (#2282)

#### Security
- **System Reboot & Service Protection** - 工具防护规则阻止系统重启、关机、服务控制、广泛进程终止和提权命令 (#2333)
- **Chinese Prompt Injection Detection** - 扩展技能安全扫描器，支持中文正则模式检测提示注入和越狱尝试 (#2381)

#### Console & UI
- **Download Page** - 桌面安装包下载页面，含镜像站点 (#2555)
- **Multimodal Preview** - 图片、音频、视频和文件附件在历史消息和流式响应中显示预览 URL (#2297, #2332)
- **Chat Session Labels** - 聊天会话显示频道标签和图标，便于识别消息来源 (#2483)
- **Command Suggestions** - 斜杠命令建议（`/clear`、`/compact`、`/approve`、`/deny`）(#2415)
- **Console Visual Refresh** - 控制台样式全面更新，整体布局改进和主题调整 (#2228 等)

#### Channels
- **WeChat iLink Bot** - 新增微信个人频道，使用 iLink Bot API (#2260)
- **Custom Channel HTTP Routes** - 自定义频道可注册 FastAPI 路由用于 Webhook 和自定义端点 (#2140)
- **Discord Bot Message Filtering** - 新增配置选项控制是否处理来自其他 Bot 的消息 (#2122)
- **DingTalk Widescreen Cards** - 支持钉钉宽屏 AI 卡片布局 (#2238)
- **WeCom Media Upload** - 基于 WebSocket 的媒体上传，替代 HTTP 下载路径，提高可靠性 (#2401)

#### Tools & Skills
- **Async Tool Execution** - 按工具粒度的异步执行标志，自动注册后台任务辅助工具（`view_task`、`wait_task`、`cancel_task`）(#2391)
- **Skill Pool Architecture** - 双层技能系统，共享技能池 + 按 Agent 工作区技能 (#2173, #2436, #2440, #2477, #2480)
- **Browser CDP Support** - Chrome DevTools Protocol 集成，连接运行中的 Chrome 实例、端口扫描、缓存清理和远程浏览器附加 (#2294)
- **Multi-Workspace Cookie Management** - 浏览器自动化使用按工作区的持久化用户数据目录，实现 Cookie 隔离和跨重启持久化 (#2131)

#### Context and Memory
- **Context Management v2.0** - 上下文和记忆管理重大重构，嵌套配置模型、新的压缩钩子、工具结果压缩、重写摘要提示和主动记忆搜索 (#2300, #2410, #2519, #2525)
- **Improved Truncation Logic** - 增强文件截断，支持高达 50KB 的 Markdown 保护，更清晰的 LLM 截断提示 (#2449)

#### Internationalization
- **Server-Side Language Persistence** - UI 语言偏好持久化到服务器端设置 (#2408)
- **Expanded Multi-Language Support** - 更多控制台 UI 组件支持多语言 (#2478, #2508)

#### Bug 修复
- **WeCom Heartbeat Reconnection** - WebSocket 心跳失败时自动重连，防止永久断连 (#2515)（v1.0.0.post1 已回退）
- **Feishu WebSocket Reconnection** - 指数退避自动重连、静默断连健康监控、过期消息过滤 (#2311, #2376)
- **Feishu Multi-Instance Message Routing** - 序列化 WebSocket 启动和 app_id 验证，防止多实例跨工作区消息错误路由 (#2244)
- **Discord Duplicate Messages** - 有界缓存已处理消息 ID，防止 WebSocket 重连后重复处理 (#2253)
- **Telegram Timeout** - 增加读取和连接超时，防止长轮询过早超时 (#2280)
- **QQ Voice Message Conversion** - AMR/AMR-WB 音频文件使用更大的 ffmpeg 探测参数以正确检测编解码器 (#2248)
- **DingTalk Cron Reminders** - 修复 sessionWebhook 路由和持久化 Webhook 存储用于定时任务提醒 (#2392)
- **Local Loopback Address** - CLI 在服务器绑定 `0.0.0.0` 时持久化 `127.0.0.1`，使其他 CLI 命令正确连接 (#2241)
- **Cross-Platform File Encoding** - 使用 `utf-8-sig` 读写文件，兼容 Windows (#2403)
- **Streaming Grep Search** - Grep 搜索逐行读取文件并使用滑动窗口，大幅降低大文件内存使用 (#2344)

---

### v0.2.0.post1 补丁修复

#### 新功能
- **Tool 调用解析增强** - 支持从 thinking 和 text 内容中解析 tool 调用
- **Console 聊天增强** - 控制台聊天功能优化
- **钉钉宽屏 AI 卡片** - 新增 `card_auto_layout` 配置，支持宽屏 AI 卡片自动布局
- **浏览器多工作区 Cookie 管理** - 多工作区下的 Cookie 隔离管理
- **Agent 启用/禁用切换** - Agent 管理支持启用和禁用操作
- **Heartbeat Cron 表达式** - 心跳支持使用 cron 表达式配置

#### Bug 修复
- **本地回环地址持久化** - 修正本地回环地址的持久化处理
- **QQ 语音消息转换** - 使用 AMR 专用 ffmpeg 参数进行 QQ 语音消息转换
- **Discord 重复消息处理** - 防止 WebSocket 重连时的重复消息处理
- **飞书跨工作区消息路由** - 修复多实例部署时跨工作区消息错误路由问题
- **Console 文件上传** - 修复控制台文件上传类型问题
- **Cron 任务字段** - 修正 cron 任务的可选/必填字段
- **Telegram 超时** - 防止 Telegram 消息过早超时
- **多 Agent 模型配置** - 修复多 Agent 模型配置和多标签页隔离问题

---

### v0.2.0 新增功能

#### Agent
- **Inter-Agent Communication** - 添加 `qwenpaw agents` 和 `qwenpaw message` CLI 命令，用于列出代理、向频道推送消息、在代理之间发送请求
- **Built-in QA Agent** - 预配置的 QA 代理，用于回答 QwenPaw 安装和使用问题
- **Configurable LLM Auto-Retry** - LLM 重试行为现在可以在控制台设置页面为每个代理单独配置
- **Summarization Improvements** - 当代理达到最大迭代次数并进入摘要模式时，会追加"round ended"通知来引导用户
- **Config Auto-Repair** - 如果 `config.json` 损坏或有轻微语法错误，会在加载时自动修复；无法恢复的文件会用唯一后缀备份，QwenPaw 以默认设置启动

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
- **Faster CLI Startup** - CLI 命令现在延迟加载，`qwenpaw --help` 和子命令启动更快

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
- **Console Static Files** - 修复从不同工作目录启动 QwenPaw 时控制台 UI 无法加载的问题
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
- **Guidance 技能** - 回答 QwenPaw 安装配置问题的内置技能
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
- **`qwenpaw update` 命令** - 自动检测环境并从 PyPI 升级 QwenPaw
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
- **模型重试** - LLM API 调用在瞬态错误时自动重试，指数退避，通过 `QWENPAW_LLM_MAX_RETRIES`、`QWENPAW_LLM_BACKOFF_BASE`、`QWENPAW_LLM_BACKOFF_CAP` 配置
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
- **`qwenpaw desktop` 命令** - 在原生 webview 窗口中打开 QwenPaw，自动启动服务

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
- **Daemon 模式** - `qwenpaw daemon` CLI 管理后台服务
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
- **CORS 配置** - 新增 `QWENPAW_CORS_ORIGINS` 环境变量
- **心跳监控面板** - 控制台新增监控 UI
- **音频文件支持** - 钉钉和飞书频道支持音频文件

### v0.0.3 新增功能
- **MCP 支持** - 连接外部 MCP 服务器扩展能力
- **本地模型支持增强** - llama.cpp、MLX、Ollama 集成
- **一键安装脚本** - 跨平台安装支持
- **阿里云 ECS 一键部署** - 云端部署选项
- **控制台功能增强** - 技能导入/创建、工作区上传下载、运行配置

### CLI 新增命令
- `qwenpaw agents list` - 列出所有代理 (v0.2.0)
- `qwenpaw agents create` - 创建新 Agent，支持模板选择 (v1.1.2)
- `qwenpaw acp` - 启动 ACP Server，暴露 agent 为 ACP 端点 (v1.1.3)
- `qwenpaw approval` - 管理工具调用审批 (v1.1.4)
- `qwenpaw agents enable/disable` - 启用/禁用代理 (v1.0.0)
- `qwenpaw doctor` - 诊断检查与自动修复 (v1.1.2)
- `qwenpaw skills info` - 查看技能详情 (v1.1.2)
- `qwenpaw skills test` - 验证技能内容和安全扫描 (v1.1.6)
- `qwenpaw skills install` - 安装技能 (v1.1.5.post2)
- `qwenpaw skills uninstall` - 卸载技能 (v1.1.5.post2)
- `qwenpaw message push/send` - 推送消息/发送请求 (v0.2.0)
- `qwenpaw message send --background` - 后台发送代理请求 (v1.0.0)
- `qwenpaw update` - 自动更新 QwenPaw (v0.1.0)
- `qwenpaw auth reset-password` - 重置 Web UI 密码 (v0.1.0)
- `qwenpaw desktop` - 打开桌面应用窗口 (v0.0.6)
- `qwenpaw daemon` - 管理后台服务 (v0.0.5)
- `qwenpaw models config-key gemini` - 配置 Gemini (v0.0.6)
- `qwenpaw models config-key minimax` - 配置 MiniMax (v0.1.0)
- `qwenpaw models config-key deepseek` - 配置 DeepSeek (v0.1.0)
- `qwenpaw models config-key kimi` - 配置 Kimi (v0.1.0)
- `qwenpaw models config-key lmstudio` - 配置 LM Studio (v0.0.7)
- `qwenpaw models config-key siliconflow` - 配置 SiliconFlow (v1.0.2)
- `qwenpaw models config-key zhipu` - 配置智谱 (v1.0.1)
- `qwenpaw models config-key openrouter` - 配置 OpenRouter (v1.1.1)
- `qwenpaw models config-key opencode` - 配置 OpenCode/Zen (v1.1.1)
- `qwenpaw providers update` - 更新提供商配置，含 Base URL (v1.1.3)
- `qwenpaw models download/remove-local` - 本地模型管理 (llama.cpp/MLX)
- `qwenpaw models ollama-pull/ollama-list/ollama-remove` - Ollama 模型管理
- `qwenpaw channels install/add/remove` - 自定义频道管理
- `qwenpaw cron get/pause/resume/state` - 定时任务状态管理
- `qwenpaw chats create/update/delete` - 会话管理

---

## 项目概述

### QwenPaw 是什么？

QwenPaw 是一款**个人助理型产品**，部署在你自己的环境中。

- **多通道对话** — 通过钉钉、飞书、QQ、Discord、iMessage、Telegram、Twilio Voice、MQTT、Mattermost、Matrix、微信 iLink 等与你对话
- **定时执行** — 按你的配置自动运行任务
- **能力由 Skills 决定** — 内置定时任务、PDF 与表单、Word/Excel/PPT 文档处理、新闻摘要、文件阅读等，还可在 Skills 中自定义扩展
- **数据全在本地** — 不依赖第三方托管

### 你怎么用 QwenPaw？

使用方式可以概括为两类：

1. **在聊天软件里对话** — 在钉钉、飞书、QQ、Discord、iMessage、Telegram、Twilio Voice、MQTT、Mattermost、Matrix 或微信 iLink 里发消息，QwenPaw 在同一 app 内回复
2. **定时自动执行** — 按设定时间自动运行任务

### 技术基础

QwenPaw 由 [AgentScope 团队](https://github.com/agentscope-ai) 基于以下项目构建：
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
curl -fsSL https://qwenpaw.agentscope.io/install.sh | bash
```

**Windows（CMD）：**
```cmd
curl -fsSL https://qwenpaw.agentscope.io/install.bat -o install.bat && install.bat
```

**Windows（PowerShell）：**
```powershell
irm https://qwenpaw.agentscope.io/install.ps1 | iex
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
pip install qwenpaw
```

可选：先创建并激活虚拟环境再安装（`python -m venv .venv`，Linux/macOS 下 `source .venv/bin/activate`，Windows 下 `.venv\Scripts\Activate.ps1`）。

#### 方式三：桌面应用 (v0.0.6 新增，Beta)

如果你不习惯使用命令行，可以下载并使用 QwenPaw 的桌面应用版本，无需手动配置 Python 环境或执行命令。

**特点**：
- ✅ **零配置**：下载后双击即可运行，无需安装 Python 或配置环境变量
- ✅ **跨平台**：支持 Windows 10+ 和 macOS 14+ (推荐 Apple Silicon)
- ✅ **可视化**：自动打开浏览器界面，无需手动输入地址
- ⚠️ **Beta 阶段**：功能持续完善中，欢迎反馈问题

**下载地址**：[GitHub Releases](https://github.com/agentscope-ai/QwenPaw/releases)
- Windows: `QwenPaw-Setup-<version>.exe`
- macOS: `QwenPaw-<version>-macOS.zip`

#### 方式四：魔搭创空间一键配置（无需安装）

1. 前往 [魔搭](https://modelscope.cn/register) 注册并登录
2. 打开 [QwenPaw 创空间](https://modelscope.cn/studios/fork?target=AgentScope/QwenPaw)，一键配置即可使用

> **重要**：使用创空间请将空间设为**非公开**，否则你的 QwenPaw 可能被他人操纵。

#### 方式五：Docker

镜像在 **Docker Hub**（`agentscope/qwenpaw`）。镜像 tag：`latest`（稳定版）、`pre`（PyPI 预发布版）。

国内用户也可选用阿里云 ACR：`agentscope-registry.ap-southeast-1.cr.aliyuncs.com/agentscope/qwenpaw`（tag 相同）。

```bash
docker pull agentscope/qwenpaw:latest
docker run -p 127.0.0.1:8088:8088 -v qwenpaw-data:/app/working agentscope/qwenpaw:latest
```

> **安全更新**：v0.0.5 起，默认端口绑定改为 `127.0.0.1` 以提高安全性。

然后在浏览器打开 http://127.0.0.1:8088/ 进入控制台。配置、记忆与 Skills 保存在 `qwenpaw-data` 卷中。

#### 方式六：部署到阿里云 ECS

打开 [QwenPaw 阿里云 ECS 部署链接](https://computenest.console.aliyun.com/service/instance/create/cn-hangzhou?type=user&ServiceId=service-1ed84201799f40879884)，按页面提示填写部署参数。

### 初始化

**方式 1：快速用默认配置（不交互）**
```bash
qwenpaw init --defaults
```

**方式 2：交互式初始化**
```bash
qwenpaw init
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
qwenpaw app

# 自定义地址
qwenpaw app --host 0.0.0.0 --port 9090

# 代码改动自动重载（开发用）
qwenpaw app --reload

# 多 worker 模式
qwenpaw app --workers 4

# 详细日志
qwenpaw app --log-level debug
```

### Daemon 模式 (v0.0.5 新增)

管理后台 QwenPaw 服务：

```bash
qwenpaw daemon status      # 状态（配置、工作目录、记忆服务）
qwenpaw daemon restart     # 打印说明（在对话中用 /daemon restart 可进程内重载）
qwenpaw daemon reload-config # 重新读取并校验配置
qwenpaw daemon version     # 版本与路径
qwenpaw daemon logs [-n N]  # 最近 N 行日志（默认 100）
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

默认工作目录：`~/.qwenpaw`

```
~/.qwenpaw/
├── config.json              # 根配置，包含代理引用 (v0.1.0+)
├── workspaces/              # 多代理工作区目录 (v0.1.0+)
│   └── default/             # 默认代理工作区
│       ├── agent.json       # 代理配置
│       ├── SOUL.md          # （必需）核心身份与行为原则
│       ├── AGENTS.md        # （必需）详细的工作流程、规则和指南
│       ├── PROFILE.md       # 身份和用户画像
│       ├── active_skills/   # 当前激活的技能
│       ├── customized_skills/ # 用户自定义的技能
│       └── plugins/          # 插件扩展 (v1.0.2+)
├── HEARTBEAT.md             # 心跳每次要问 QwenPaw 的内容
├── jobs.json                # 定时任务列表
├── chats.json               # 会话列表（文件存储模式）
├── providers.json           # LLM 提供商配置（v0.0.5+ 迁移到 SECRET_DIR）
├── envs.json                # 环境变量配置（v0.0.5+ 迁移到 SECRET_DIR）
├── custom_channels/         # 自定义频道模块
├── memory/                  # Agent 记忆文件（自动管理）
│   ├── MEMORY.md            # 长期有效的关键信息
│   └── YYYY-MM-DD.md        # 每日日志
├── mcp_clients/             # MCP 客户端配置
├── .backups/                # BACKUP_DIR: 备份存储目录
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
| providers.json | `~/.qwenpaw/` | `{SECRET_DIR}/providers.json` |
| envs.json | `~/.qwenpaw/` | `{SECRET_DIR}/envs.json` |

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
| **wechat-ilink** | 微信 iLink Bot (v1.0.0 新增) | iLink Bot API 配置 |
| **onebot-v11** | OneBot v11 / NapCat QQ (v1.0.1 新增) | 反向 WebSocket 服务器配置，支持个人账号和群消息 |
| **xiaoyi** | 小艺 (v0.1.0 新增) | 华为 A2A 协议配置 |
| **mqtt** | MQTT 消息队列 (v0.0.6 新增) | `host`, `port`, `transport`, `qos`, `subscribe_topic`, `publish_topic` |
| **twilio voice** | Twilio 语音 (v0.0.5 新增) | `account_sid`, `auth_token`, `phone_number` |
| **sip** | SIP 语音 (v1.1.4 新增) | SIP 配置，双模式后端（pyVoIP 开发 / LiveKit 生产） |
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
| 微信 iLink (v1.0.0) | 🚧 | 🚧 | 🚧 | 🚧 | 🚧 | 🚧 | 🚧 | 🚧 | 🚧 | 🚧 |
| OneBot v11 / NapCat (v1.0.1) | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | 🚧 | 🚧 |
| Discord | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ (v0.0.6+) | ✓ (v0.0.6+) | ✓ (v0.0.6+) | ✓ (v0.0.6+) |
| iMessage | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ (v0.0.5+) | ✓ (v0.0.5+) | ✓ (v0.0.5+) | ✗ |
| QQ | ✓ | ✓ (v0.0.6+) | ✓ (v0.0.6+) | ✓ (v0.0.6+) | ✓ (v0.0.6+) | ✓ | ✓ (v0.0.7+) | 🚧 | 🚧 | ✓ (v1.0.2+) |
| Telegram | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Twilio Voice | ✓ | ✗ | ✗ | ✓ | ✗ | ✓ | ✗ | ✗ | ✓ | ✗ |
| SIP Voice (v1.1.4) | ✓ | ✗ | ✗ | ✓ | ✗ | ✓ | ✗ | ✗ | ✓ | ✗ |
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
| QwenPaw Local Model (v1.0.0 新增) | `qwenpaw-local` | 本地 llama.cpp 引擎 |
| SiliconFlow (v1.0.2 新增) | `siliconflow` | 中国版/国际版分离端点 |
| Zhipu / 智谱 (v1.0.1 新增) | `zhipu` | `https://open.bigmodel.cn/api/paas/v4` |
| OpenRouter (v1.1.1 新增) | `openrouter` | `https://openrouter.ai/api/v1` |
| OpenCode / Zen (v1.1.1 新增) | `opencode` | OpenAI 兼容端点，提供免费模型 |
| Aliyun coding-plan | `codingplan` | （你自己填） |
| Volcano Engine / 火山引擎 (v1.1.6 新增) | `volcengine` | OpenAI 兼容端点，含标准和 Coding Plan 端点 |
| Aliyun Token Plan (v1.1.6 新增) | `aliyun-token-plan` | （阿里云 Token 计划端点） |
| 自定义 | `custom` | （你自己填） |

### 本地提供商

#### llama.cpp / MLX

```bash
# 安装后端
pip install 'qwenpaw[llamacpp]'  # llama.cpp（跨平台）
pip install 'qwenpaw[mlx]'       # MLX（Apple Silicon）

# 下载模型
qwenpaw models download Qwen/Qwen3-4B-GGUF
qwenpaw models download Qwen/Qwen3-4B --backend mlx

# 从 ModelScope 下载
qwenpaw models download Qwen/Qwen2-0.5B-Instruct-GGUF --source modelscope

# 查看已下载模型
qwenpaw models local

# 删除已下载模型
qwenpaw models remove-local <model_id>
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
- 安装 Ollama SDK：`pip install 'qwenpaw[ollama]'`

```bash
# 下载 Ollama 模型
qwenpaw models ollama-pull mistral:7b
qwenpaw models ollama-pull qwen2.5:3b

# 查看 Ollama 模型
qwenpaw models ollama-list

# 删除 Ollama 模型
qwenpaw models ollama-remove mistral:7b

# 在配置流程中使用
qwenpaw models config           # 选择 Ollama → 从模型列表中选择
qwenpaw models set-llm          # 切换到其他 Ollama 模型
```

**与本地模型的区别**：
- 模型来自 Ollama 守护进程（不由 QwenPaw 下载）
- 使用 `ollama-pull` / `ollama-remove` 而非 `download` / `remove-local`
- 通过 Ollama CLI 或 QwenPaw 添加/删除模型时，模型列表自动更新

支持的热门模型：`mistral:7b`、`qwen3:8b` 等

---

## CLI 命令参考

### 快速上手

```bash
# 初始化
qwenpaw init --defaults   # 不交互，用默认值
qwenpaw init              # 交互式初始化

# 启动服务
qwenpaw app
```

### Daemon 模式 (v0.0.5 新增)

```bash
qwenpaw daemon status          # 状态（配置、工作目录、记忆服务）
qwenpaw daemon restart         # 打印说明
qwenpaw daemon reload-config   # 重新读取并校验配置
qwenpaw daemon version         # 版本与路径
qwenpaw daemon logs [-n 50]    # 最近 N 行日志（默认 100）
```

### 模型管理

```bash
qwenpaw models list                    # 查看所有提供商
qwenpaw models config                  # 完整交互式配置
qwenpaw models config-key <provider>   # 配置 API Key
qwenpaw models config-key gemini       # 配置 Gemini API Key (v0.0.6+)
qwenpaw models config-key lmstudio     # 配置 LM Studio (v0.0.7+)
qwenpaw models config-key deepseek     # 配置 DeepSeek (v0.1.0+)
qwenpaw models config-key minimax      # 配置 MiniMax (v0.1.0+)
qwenpaw models config-key kimi         # 配置 Kimi (v0.1.0+)
qwenpaw models config-key siliconflow  # 配置 SiliconFlow (v1.0.2+)
qwenpaw models config-key openrouter   # 配置 OpenRouter (v1.1.1+)
qwenpaw models config-key opencode     # 配置 OpenCode/Zen (v1.1.1+)
qwenpaw models set-llm                 # 切换活跃模型
qwenpaw models download <repo_id>      # 下载本地模型
qwenpaw models local                   # 查看已下载模型
qwenpaw models ollama-pull <model>     # 下载 Ollama 模型
```

### 更新与认证 (v0.1.0 新增)

```bash
qwenpaw update                         # 自动更新 QwenPaw
qwenpaw auth reset-password            # 重置 Web UI 密码
```

### Agent 与消息 (v0.2.0 新增)

```bash
qwenpaw agents list                    # 列出所有代理
qwenpaw agents create                  # 创建新 Agent (v1.1.2 新增)
qwenpaw agents enable/disable <agent>  # 启用/禁用代理 (v1.0.0 新增)
qwenpaw message push <channel> <user>  # 向频道推送消息
qwenpaw message send <agent> <msg>     # 向代理发送请求
qwenpaw message send <agent> <msg> --background  # 后台发送请求 (v1.0.0 新增)
qwenpaw task <prompt>                  # 运行一次性任务，无需 Web 服务 (v1.0.2 新增)
```

### 桌面应用 (v0.0.6 新增)

```bash
qwenpaw desktop                        # 打开 QwenPaw 桌面应用窗口
```

### 频道管理

```bash
qwenpaw channels list                  # 查看所有频道（密钥脱敏）
qwenpaw channels config                # 交互式配置
qwenpaw channels install <key>         # 安装自定义频道模块
qwenpaw channels add <key>             # 添加频道到 config
qwenpaw channels remove <key>          # 删除自定义频道（--keep-config 保留配置）
```

### 定时任务

```bash
qwenpaw cron list                      # 列出所有任务
qwenpaw cron get <job_id>              # 查看任务配置详情
qwenpaw cron create --type text --name "每日早安" --cron "0 9 * * *" \
  --channel dingtalk --target-user "xxx" --text "早上好！"
qwenpaw cron state <job_id>            # 查看运行状态
qwenpaw cron delete <job_id>           # 删除任务
qwenpaw cron pause <job_id>            # 暂停任务
qwenpaw cron resume <job_id>           # 恢复任务
qwenpaw cron run <job_id>              # 立即执行一次
```

### 诊断 (v1.1.2 新增)

```bash
qwenpaw doctor                         # 诊断检查（环境、配置、提供商、频道等）
qwenpaw doctor fix                     # 自动修复发现的问题
```

### 审批管理 (v1.1.4 新增)

```bash
qwenpaw approval                       # 管理工具调用审批（Tool Guard）
```

### 聊天命令

| 命令 | 说明 | 版本 |
|------|------|------|
| `/plan` | 创建分步任务计划（Plan 模式）| v1.1.4 |
| `/mission` | 自主多阶段任务执行 | v1.1.2 |
| `/model` | 切换模型、列出可用模型 | v1.0.2 |
| `/skills` | 查看已启用技能 | v1.0.2 |
| `/stop` | 取消运行中任务 | v1.0.0 |
| `/clear` | 清除聊天历史 | v0.1.0 |
| `/compact` | 手动触发记忆压缩 | v0.1.0 |
| `/approve` | 批准被阻止的工具调用 | v0.0.7 |
| `/deny` | 拒绝工具调用 | v0.0.7 |

### 会话管理

```bash
qwenpaw chats list                     # 列出所有会话
qwenpaw chats get <id>                 # 查看会话详情
qwenpaw chats create --session-id "xxx" --user-id "xxx" --name "My Chat"
qwenpaw chats update <id> --name "新名称"
qwenpaw chats delete <id>              # 删除会话
```

### 技能管理

```bash
qwenpaw skills list                    # 看有哪些技能
qwenpaw skills config                  # 交互式开关
qwenpaw skills info                    # 查看技能详情 (v1.1.2 新增)
qwenpaw skills test                    # 验证技能内容和运行安全扫描 (v1.1.6 新增)
qwenpaw skills install                 # 安装技能 (v1.1.5.post2 新增)
qwenpaw skills uninstall               # 卸载技能 (v1.1.5.post2 新增)
```

---

## 官方文档导航

| 页面 | 说明 | 链接 |
|------|------|------|
| 项目介绍 | QwenPaw 是什么、能做什么 | http://qwenpaw.agentscope.io/docs/intro |
| 快速开始 | 安装和启动指南 | http://qwenpaw.agentscope.io/docs/quickstart |
| 桌面应用 | 桌面应用使用指南 (v0.0.6+) | http://qwenpaw.agentscope.io/docs/desktop |
| 控制台 | 控制台使用说明 | http://qwenpaw.agentscope.io/docs/console |
| 频道配置 | 钉钉/飞书/QQ/Discord/iMessage/Telegram/Twilio/MQTT 配置 | http://qwenpaw.agentscope.io/docs/channels |
| Skills | 技能扩展说明 | http://qwenpaw.agentscope.io/docs/skills |
| MCP | MCP 客户端配置 | http://qwenpaw.agentscope.io/docs/mcp |
| 记忆 | 记忆系统说明 | http://qwenpaw.agentscope.io/docs/memory |
| 心跳 | 心跳配置说明 | http://qwenpaw.agentscope.io/docs/heartbeat |
| 配置与工作目录 | 详细配置说明 | http://qwenpaw.agentscope.io/docs/config |
| CLI | 命令行工具说明 | http://qwenpaw.agentscope.io/docs/cli |
| FAQ 常见问题 | 社区常见问题汇总 | http://qwenpaw.agentscope.io/docs/faq |
| 问题反馈与交流 | 社区支持 | http://qwenpaw.agentscope.io/docs/community |
| 开源与贡献 | 贡献指南 | http://qwenpaw.agentscope.io/docs/contributing |

---

## 相关项目

- [QwenPaw 官方仓库](https://github.com/agentscope-ai/QwenPaw) - QwenPaw 主项目
- [AgentScope](https://github.com/agentscope-ai/agentscope)
- [AgentScope Runtime](https://github.com/agentscope-ai/agentscope-runtime)
- [ReMe](https://github.com/agentscope-ai/ReMe)
- [OpenClaw](https://openclaw.ai/) - 部分灵感来源
- [anthropics/skills](https://github.com/anthropics/skills) - Agent Skills 规范与示例

---

## 官方 Docker 镜像

QwenPaw 官方也提供 Docker 镜像，可直接使用：

```bash
docker pull agentscope/qwenpaw:latest
docker run -p 127.0.0.1:8088:8088 -v qwenpaw-data:/app/working agentscope/qwenpaw:latest
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
| GitHub Issues | [提交问题](https://github.com/agentscope-ai/QwenPaw/issues) |

---

## License

QwenPaw 采用 [Apache License 2.0](https://github.com/agentscope-ai/QwenPaw/blob/main/LICENSE) 开源许可。
