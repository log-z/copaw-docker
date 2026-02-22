# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Docker deployment project for CoPaw, a personal assistant product based on AgentScope. CoPaw supports multi-channel conversations (DingTalk, Feishu, QQ, Discord, iMessage) and runs locally with user-configured LLM providers.

**Key Technologies**: Python 3.12, Docker, Docker Compose, AgentScope framework

**Official Documentation**: http://copaw.agentscope.io/docs/

---

## Common Commands

### Build and Run

```bash
# Build the Docker image
docker compose build

# Start the service
docker compose up -d

# View logs
docker compose logs -f copaw

# Stop the service
docker compose stop

# Restart the service
docker compose restart

# Stop and remove containers
docker compose down
```

### Container Interaction

```bash
# Enter the container shell
docker compose exec copaw bash

# Run CoPaw commands inside container
docker compose exec copaw copaw init --defaults
docker compose exec copaw copaw skills config
docker compose exec copaw copaw cron
```

### Data Management

```bash
# Inspect the data volume
docker volume inspect copaw-data

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

```
[builder stage] → [runtime stage]
     ↓                   ↓
  Install copaw      Copy packages
  (gcc, g++)      Create 'copaw' user
                     Copy scripts
```

- **Builder stage**: Uses `python:3.12-slim`, installs build tools (gcc, g++), and runs `pip install copaw`
- **Runtime stage**: Final image with only runtime dependencies (curl, ca-certificates), runs as non-root user `copaw`

### Container Startup Flow

```
docker compose up
        ↓
entrypoint.sh runs
        ↓
Check if config.json exists
        ↓
If missing: run `copaw init --defaults`
        ↓
Execute CMD: copaw app
        ↓
Service listens on 0.0.0.0:8088
```

### Data Persistence

All CoPaw data is stored in the Docker volume `copaw-data` at `/data/copaw`:

| File/Directory | Purpose |
|----------------|---------|
| `config.json` | Main configuration (channels, heartbeat, language) |
| `SOUL.md` | Agent core identity and behavior rules (required) |
| `AGENTS.md` | Detailed workflow and guidelines (required) |
| `MEMORY.md` | Long-term memory storage |
| `HEARTBEAT.md` | Heartbeat task questions |
| `active_skills/` | Currently active skills |
| `customized_skills/` | User-defined skills |
| `memory/` | Agent memory files |

### Environment Variables

Key variables are defined in two places:

1. **Dockerfile**: Default values (COPAW_WORKING_DIR, COPAW_LOG_LEVEL, etc.)
2. **docker-compose.yml**: Configuration file for environment variables

Critical variables:
- `EMBEDDING_API_KEY` - Required for vector memory search
- `MODELSCOPE_API_KEY` / `DASHSCOPE_API_KEY` / `OPENAI_API_KEY` - LLM provider keys
- `COPAW_AUTO_INIT` - Controls automatic initialization (default: true)

### Script Responsibilities

- **scripts/entrypoint.sh**: Checks for config.json, runs auto-init if needed, validates required files
- **scripts/healthcheck.sh**: Health check for Docker (curl test or process check)

---

## Important Files

| File | Purpose |
|------|---------|
| [docs/copaw-info.md](docs/copaw-info.md) | Comprehensive CoPaw documentation reference from official docs |
| [.env.example](.env.example) | Environment variable template for API keys and configuration |
