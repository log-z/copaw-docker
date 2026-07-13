# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Docker deployment project for QwenPaw, a personal assistant product based on AgentScope. QwenPaw supports multi-channel conversations (DingTalk, Feishu, QQ, Discord, iMessage, Telegram, Twilio Voice, SIP Voice, MQTT, Mattermost, Matrix, WeChat iLink, Slack) and runs locally with user-configured LLM providers.

**Key Technologies**: Python 3.13, Docker, Docker Compose, AgentScope 2.0 framework (since v2.0.0)

**Official Documentation**: http://qwenpaw.agentscope.io/docs/

**Official Repository**: https://github.com/agentscope-ai/QwenPaw

**Detailed Feature Reference**: [docs/qwenpaw-info.md](docs/qwenpaw-info.md)

---

## Critical Warnings

### Security Warning

> **QwenPaw v0.1.0+ supports optional Web authentication. When authentication is disabled, NEVER expose the service port to the public internet!**

- **With authentication enabled**: Set `QWENPAW_AUTH_ENABLED=true` to enable Web authentication (disabled by default)
  - First access shows registration page
  - Local requests (127.0.0.1) automatically bypass authentication
  - v1.1.4+: Configurable `allow_no_auth_hosts` whitelist for trusted IP access without auth
  - Auto-register admin via environment variables: `QWENPAW_AUTH_USERNAME` and `QWENPAW_AUTH_PASSWORD`
  - Password reset: `docker compose exec qwenpaw qwenpaw auth reset-password`
- **When authentication disabled**:
  - The WebUI management interface has **no login authentication**
  - Default port `8088` should only be accessed in **trusted internal networks**
  - If remote access is required, use SSH tunnel or reverse proxy with authentication

### Data Volume Compatibility

> The `copaw-data` storage volume is **NOT compatible** with the official QwenPaw image due to different file permission settings.

---

## Common Commands

### Build and Run

```bash
docker compose build                              # Build the image
docker compose build --build-arg QWENPAW_VERSION=2.0.0.post1  # Build with specific version
docker compose up -d                              # Start the service
docker compose logs -f qwenpaw                    # View logs
docker compose stop / restart                     # Stop/Restart
docker compose down                               # Stop and remove containers
```

### Container Interaction

```bash
docker compose exec qwenpaw bash                    # Enter container shell
docker compose exec qwenpaw qwenpaw init --defaults   # Initialize with defaults
docker compose exec qwenpaw qwenpaw models config     # Configure LLM provider
docker compose exec qwenpaw qwenpaw channels config   # Configure channels
docker compose exec qwenpaw qwenpaw agents list       # List all agents (v0.2.0+)
docker compose exec qwenpaw qwenpaw agents create     # Create new agent (v1.1.2+)
docker compose exec qwenpaw qwenpaw agents enable <agent>  # Enable agent (v1.0.0+)
docker compose exec qwenpaw qwenpaw doctor             # Run diagnostics (v1.1.2+)
docker compose exec qwenpaw qwenpaw message push      # Push message to channel (v0.2.0+)
docker compose exec qwenpaw qwenpaw task <prompt>     # Run one-off task, no web server (v1.0.2+)
docker compose exec qwenpaw qwenpaw acp               # Start ACP Server (v1.1.3+)
docker compose exec qwenpaw qwenpaw providers update  # Update provider config incl. base URL (v1.1.3+)
docker compose exec qwenpaw qwenpaw cron update       # Edit existing cron job (v2.0.0+)
docker compose exec qwenpaw qwenpaw tui               # Full-screen terminal UI (v2.0.0+)
```

### Data Management

```bash
# Backup data
docker run --rm -v copaw-data:/data -v $(pwd):/backup \
    alpine tar czf /backup/qwenpaw-backup-$(date +%Y%m%d).tar.gz -C /data .

# Restore data
docker run --rm -v copaw-data:/data -v $(pwd):/backup \
    alpine tar xzf /backup/qwenpaw-backup-YYYYMMDD.tar.gz -C /data
```

---

## Architecture

### Dockerfile Structure (Multi-stage Build)

- **Builder stage**: `python:3.13-slim`, installs build tools and `pip install qwenpaw`
  - Supports `QWENPAW_VERSION` build argument (default: `latest`)
- **Runtime stage**: Runtime dependencies only, runs as non-root user `qwenpaw`

### Container Startup Flow

```
docker compose up → entrypoint.sh → check config.json
    → (if missing) qwenpaw init --defaults
    → validate SOUL.md, AGENTS.md
    → qwenpaw app --host 0.0.0.0 → listens on 0.0.0.0:8088
```

> **v2.0.0 note**: Kernel refactored on AgentScope 2.0 (Runtime 2.0). Long-term memory is now backed by ReMe v0.4.0; scrolling context uses a SQLite `history.db` (FTS5) with 30-day default retention and auto-import of existing sessions on startup. A `none` memory backend option can fully disable memory for lightweight deployments.

### Data Persistence

All data stored in Docker volume `copaw-data` at `/data/qwenpaw`:

| File/Directory | Purpose |
|----------------|---------|
| `config.json` | Root configuration (v0.1.0+) |
| `workspaces/default/` | Default agent workspace (v0.1.0+) |
| `workspaces/default/plugins/` | Plugin extensions (v1.0.2+) |
| `history.db` | Scrolling context work history, SQLite + FTS5 (v2.0.0+) |
| `.runtime/` | SECRET_DIR: providers.json, envs.json, auth.json |
| `.backups/` | BACKUP_DIR: backup zip files |

See [docs/qwenpaw-info.md](docs/qwenpaw-info.md) for complete directory structure.

### Environment Variables

Key variables (see [.env.example](.env.example) for full list):

| Variable | Description |
|----------|-------------|
| `QWENPAW_AUTH_ENABLED` | Enable Web authentication (default: `false`, v1.1.0+) |
| `QWENPAW_AUTH_USERNAME` | Auto-register admin username (v1.1.0+) |
| `QWENPAW_AUTH_PASSWORD` | Auto-register admin password (v1.1.0+) |
| `QWENPAW_AUTO_INIT` | Auto initialization (default: true, Docker entrypoint only) |
| `QWENPAW_PORT` | Listening port (default: `8088`) |
| `QWENPAW_LLM_MAX_RETRIES` | LLM API retry attempts (default: `3`) |
| `QWENPAW_LLM_MAX_CONCURRENT` | Max concurrent LLM calls (default: `10`) |
| `QWENPAW_LLM_MAX_QPM` | Max queries per minute (default: `600`) |
| `EMBEDDING_API_KEY` | Embedding API key for vector memory search |
| `TAVILY_API_KEY` | Tavily search API key for web search skill |

> **Note:** LLM provider API keys (DashScope, OpenAI, Anthropic, etc.) are NOT configured via environment variables. Use the WebUI (Settings → Models) or CLI (`qwenpaw models config`) instead.

---

## CI/CD Workflows

| Workflow | Purpose | Trigger |
|----------|---------|---------|
| [dev-test.yml](.github/workflows/dev-test.yml) | Test development builds | Push to `dev` |
| [prod-test.yml](.github/workflows/prod-test.yml) | Test production image | Push to `main` |
| [release-image.yml](.github/workflows/release-image.yml) | Build and publish | Release creation |

---

## Image Information

- **Repository**: `ghcr.io/log-z/qwenpaw:latest`
- **Base**: `python:3.13-slim`
- **Node.js**: 24.x LTS (MCP support)
- **Browser**: Chromium headless (MCP browser automation)
- **Working dir**: `/data/qwenpaw`
- **User**: `qwenpaw` (non-root)
- **Port**: 8088

---

## Important Files

| File | Purpose |
|------|---------|
| [docs/qwenpaw-info.md](docs/qwenpaw-info.md) | QwenPaw documentation reference |
| [.env.example](.env.example) | Environment variable template |
| [Dockerfile](Dockerfile) | Multi-stage image definition |
| [docker-compose.yml](docker-compose.yml) | Docker Compose configuration |
| [scripts/entrypoint.sh](scripts/entrypoint.sh) | Container startup script |
| [scripts/healthcheck.sh](scripts/healthcheck.sh) | Health check script |
