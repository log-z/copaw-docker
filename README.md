# CoPaw Docker 部署

> CoPaw 的 Docker 部署方案，支持一键构建和运行。

## 关于 CoPaw

CoPaw 是一款**个人助理型产品**，部署在你自己的环境中。

- **多通道对话** — 通过钉钉、飞书、QQ、Discord、iMessage 等与你对话
- **定时执行** — 按你的配置自动运行任务
- **能力由 Skills 决定** — 内置定时任务、PDF 与表单、Word/Excel/PPT 文档处理、新闻摘要等
- **数据全在本地** — 不依赖第三方托管

官方文档：http://copaw.agentscope.io/docs/

---

## 快速开始

### 前置要求

- Docker >= 20.10
- Docker Compose >= 2.0

### 1. 配置环境变量

复制环境变量示例文件并根据需要修改：

```bash
cp .env.example .env
```

编辑 `.env` 文件，填入你的 API Keys：

```env
# Embedding 服务（用于记忆向量搜索）
EMBEDDING_API_KEY=your_embedding_api_key_here

# 模型提供商（选择一个或多个）
MODELSCOPE_API_KEY=your_modelscope_api_key_here
DASHSCOPE_API_KEY=your_dashscope_api_key_here
```

### 2. 构建镜像

```bash
docker-compose build
```

### 3. 启动服务

```bash
docker-compose up -d
```

### 4. 查看日志

```bash
docker-compose logs -f copaw
```

### 5. 访问控制台

浏览器打开：http://localhost:8088

---

## 项目结构

```
copaw/
├── Dockerfile                 # Docker 镜像定义
├── docker-compose.yml         # Docker Compose 配置
├── .dockerignore             # Docker 构建忽略文件
├── .env.example              # 环境变量配置示例
├── README.md                 # 本文件
├── docs/
│   └── copaw-info.md         # CoPaw 官方文档信息汇总
└── scripts/
    ├── entrypoint.sh         # 容器启动脚本
    └── healthcheck.sh        # 健康检查脚本
```

---

## 常用命令

### 容器管理

```bash
# 启动服务
docker-compose up -d

# 停止服务
docker-compose stop

# 重启服务
docker-compose restart

# 查看日志
docker-compose logs -f copaw

# 进入容器
docker-compose exec copaw bash

# 停止并删除容器
docker-compose down
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
# 重新初始化
docker-compose exec copaw copaw init --defaults

# 管理技能
docker-compose exec copaw copaw skills config

# 管理定时任务
docker-compose exec copaw copaw cron
```

---

## 环境变量说明

### CoPaw 基础配置

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `COPAW_WORKING_DIR` | `/data/copaw` | 工作目录 |
| `COPAW_CONFIG_FILE` | `config.json` | 配置文件名 |
| `COPAW_LOG_LEVEL` | `INFO` | 日志级别 |
| `COPAW_AUTO_INIT` | `true` | 是否自动初始化 |

### Embedding 服务配置

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `EMBEDDING_API_KEY` | （必填） | Embedding 服务的 API Key |
| `EMBEDDING_BASE_URL` | DashScope URL | Embedding 服务地址 |
| `EMBEDDING_MODEL_NAME` | `text-embedding-v4` | Embedding 模型名称 |
| `EMBEDDING_DIMENSIONS` | `1024` | 向量维度 |
| `FTS_ENABLED` | `true` | 是否启用 BM25 全文检索 |

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

## 端口说明

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
docker-compose logs copaw
```

### 2. 健康检查失败

检查服务是否正常运行：

```bash
docker-compose ps
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
docker-compose restart
```

---

## 镜像信息

- **基础镜像**: `python:3.12-slim`
- **Python 版本**: 3.12
- **工作目录**: `/data/copaw`
- **运行用户**: `copaw`（非 root）

---

## 更多信息

- [CoPaw 官方文档](http://copaw.agentscope.io/docs/)
- [docs/copaw-info.md](docs/copaw-info.md) - CoPaw 官方文档信息汇总

---

## License

本项目基于 CoPaw 的官方部署方案构建。CoPaw 由 [AgentScope 团队](https://github.com/agentscope-ai) 开发。
