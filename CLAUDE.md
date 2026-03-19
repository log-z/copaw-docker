# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Docker deployment project for CoPaw, a personal assistant product based on AgentScope. CoPaw supports multi-channel conversations (DingTalk, Feishu, QQ, Discord, iMessage, Telegram, Twilio Voice, MQTT, Mattermost, Matrix) and runs locally with user-configured LLM providers.

**Key Technologies**: Python 3.12, Docker, Docker Compose, AgentScope framework

**Official Documentation**: http://copaw.agentscope.io/docs/

**Official Repository**: https://github.com/agentscope-ai/CoPaw

**Detailed Feature Reference**: [docs/copaw-info.md](docs/copaw-info.md)

---

## Critical Warnings

### Security Warning

> **CoPaw v0.1.0+ supports optional Web authentication. For versions prior to v0.1.0 or when authentication is disabled, NEVER expose the service port to the public internet!**

- **v0.1.0+**: Set `COPAW_AUTH_ENABLED=true` to enable Web authentication (disabled by default)
  - First access shows registration page
  - Local requests (127.0.0.1) automatically bypass authentication
  - Auto-register admin via environment variables: `COPAW_AUTH_USERNAME` and `COPAW_AUTH_PASSWORD`
  - Password reset: `docker compose exec copaw copaw auth reset-password`
- **v0.0.x or when authentication disabled**:
  - The WebUI management interface has **no login authentication**
  - Default port `8088` should only be accessed in **trusted internal networks**
  - v0.0.5+ changed default Docker port binding to `127.0.0.1` for improved security
  - If remote access is required, use SSH tunnel or reverse proxy with authentication

### Data Volume Compatibility

> The `copaw-data` storage volume is **NOT compatible** with the official CoPaw image due to different file permission settings.

---

## Common Commands

### Build and Run

```bash
docker compose build                              # Build the image
docker compose build --build-arg COPAW_VERSION=0.1.0  # Build with specific version
docker compose up -d                              # Start the service
docker compose logs -f copaw                      # View logs
docker compose stop / restart                     # Stop/Restart
docker compose down                               # Stop and remove containers
```

### Container Interaction

```bash
docker compose exec copaw bash                    # Enter container shell
docker compose exec copaw copaw init --defaults   # Initialize with defaults
docker compose exec copaw copaw models config     # Configure LLM provider
docker compose exec copaw copaw channels config   # Configure channels
```

### Data Management

```bash
# Backup data
docker run --rm -v copaw-data:/data -v $(pwd):/backup \
    alpine tar czf /backup/copaw-backup-$(date +%Y%m%d).tar.gz -C /data .

# Restore data
docker run --rm -v copaw-data:/data -v $(pwd):/backup \
    alpine tar xzf /backup/copaw-backup-YYYYMMDD.tar.gz -C /data
```

---

## Architecture

### Dockerfile Structure (Multi-stage Build)

- **Builder stage**: `python:3.12-slim`, installs build tools and `pip install copaw`
  - Supports `COPAW_VERSION` build argument (default: `latest`)
- **Runtime stage**: Runtime dependencies only, runs as non-root user `copaw`

### Container Startup Flow

```
docker compose up → entrypoint.sh → check config.json
    → (if missing) copaw init --defaults
    → validate SOUL.md, AGENTS.md
    → copaw app --host 0.0.0.0 → listens on 0.0.0.0:8088
```

### Data Persistence

All data stored in Docker volume `copaw-data` at `/data/copaw`:

| File/Directory | Purpose |
|----------------|---------|
| `config.json` | Root configuration (v0.1.0+) |
| `workspaces/default/` | Default agent workspace (v0.1.0+) |
| `.runtime/` | SECRET_DIR: providers.json, envs.json, auth.json |

See [docs/copaw-info.md](docs/copaw-info.md) for complete directory structure.

### Environment Variables

Key variables (see [.env.example](.env.example) for full list):

| Variable | Description |
|----------|-------------|
| `COPAW_AUTH_ENABLED` | Enable Web authentication (default: `false`, v0.1.0+) |
| `COPAW_AUTH_USERNAME` | Auto-register admin username (v0.1.0+) |
| `COPAW_AUTH_PASSWORD` | Auto-register admin password (v0.1.0+) |
| `COPAW_AUTO_INIT` | Auto initialization (default: true) |
| `COPAW_LLM_MAX_RETRIES` | LLM API retry attempts (v0.0.7+) |
| `EMBEDDING_API_KEY` | Vector memory search |
| `MODELSCOPE_API_KEY` / `DASHSCOPE_API_KEY` / `OPENAI_API_KEY` / `ANTHROPIC_API_KEY` / `GEMINI_API_KEY` | LLM provider keys |

---

## CI/CD Workflows

| Workflow | Purpose | Trigger |
|----------|---------|---------|
| [dev-test.yml](.github/workflows/dev-test.yml) | Test development builds | Push to `dev` |
| [prod-test.yml](.github/workflows/prod-test.yml) | Test production image | Push to `main` |
| [release-image.yml](.github/workflows/release-image.yml) | Build and publish | Release creation |

---

## Image Information

- **Repository**: `ghcr.io/log-z/copaw-docker:latest`
- **Base**: `python:3.12-slim`
- **Node.js**: 20.x LTS (MCP support)
- **Browser**: Chromium headless (MCP browser automation)
- **Working dir**: `/data/copaw`
- **User**: `copaw` (non-root)
- **Port**: 8088

---

## Important Files

| File | Purpose |
|------|---------|
| [docs/copaw-info.md](docs/copaw-info.md) | CoPaw documentation reference |
| [.env.example](.env.example) | Environment variable template |
| [Dockerfile](Dockerfile) | Multi-stage image definition |
| [docker-compose.yml](docker-compose.yml) | Docker Compose configuration |
| [scripts/entrypoint.sh](scripts/entrypoint.sh) | Container startup script |
| [scripts/healthcheck.sh](scripts/healthcheck.sh) | Health check script |
