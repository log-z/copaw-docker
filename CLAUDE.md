# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Docker deployment project for CoPaw, a personal assistant product based on AgentScope. CoPaw supports multi-channel conversations (DingTalk, Feishu, QQ, Discord, iMessage, Telegram, Twilio Voice, MQTT, Mattermost, Matrix) and runs locally with user-configured LLM providers.

**Key Technologies**: Python 3.12, Docker, Docker Compose, AgentScope framework

**Official Documentation**: http://copaw.agentscope.io/docs/

**Official Repository**: https://github.com/agentscope-ai/CoPaw

---

## Critical Warnings

### Security Warning

> **CoPaw v0.1.0+ supports optional Web authentication. For versions prior to v0.1.0 or when authentication is disabled, NEVER expose the service port to the public internet!**

- **v0.1.0+**: Set `COPAW_AUTH_ENABLED=true` to enable Web authentication (disabled by default)
  - First access shows registration page
  - Local requests (127.0.0.1) automatically bypass authentication
  - Password reset: `docker compose exec copaw copaw auth reset-password`
- **v0.0.x or when authentication disabled**:
  - The WebUI management interface has **no login authentication**
  - Default port `8088` should only be accessed in **trusted internal networks**
  - v0.0.5+ changed default Docker port binding to `127.0.0.1` for improved security
  - If remote access is required, use:
    - SSH tunnel: `ssh -L 8088:localhost:8088 your-server`
    - Reverse proxy (Nginx/Caddy) with Basic Auth or OAuth
    - Firewall rules to restrict access by IP

### Data Volume Compatibility

> The `copaw-data` storage volume is **NOT compatible** with the official CoPaw image due to different file permission settings.

---

## Common Commands

### Build and Run

```bash
# Build the Docker image (with optional version)
docker compose build
docker compose build --build-arg COPAW_VERSION=0.0.5

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

### CoPaw CLI Commands

```bash
# Initialization
docker compose exec copaw copaw init --defaults   # Non-interactive default config
docker compose exec copaw copaw init              # Interactive initialization

# Model Management (Cloud Providers)
docker compose exec copaw copaw models list                    # List all providers
docker compose exec copaw copaw models config                  # Interactive configuration
docker compose exec copaw copaw models config-key modelscope   # Configure API Key
docker compose exec copaw copaw models config-key dashscope    # Configure DashScope API Key
docker compose exec copaw copaw models config-key custom       # Configure custom provider
docker compose exec copaw copaw models config-key anthropic    # Configure Anthropic API Key (v0.0.5+)
docker compose exec copaw copaw models config-key gemini       # Configure Gemini API Key (v0.0.6+)
docker compose exec copaw copaw models config-key lmstudio    # Configure LM Studio API Key (v0.0.7+)
docker compose exec copaw copaw models set-llm                 # Switch active model

# Model Management (Local Models - llama.cpp / MLX)
docker compose exec copaw copaw models download <repo_id>      # Download local model
docker compose exec copaw copaw models download Qwen/Qwen3-4B-GGUF
docker compose exec copaw copaw models download Qwen/Qwen3-4B --backend mlx
docker compose exec copaw copaw models download <repo_id> --source modelscope  # From ModelScope
docker compose exec copaw copaw models local                   # List downloaded models
docker compose exec copaw copaw models remove-local <model_id>  # Delete downloaded model

# Model Management (Ollama)
docker compose exec copaw copaw models ollama-pull <model>     # Pull Ollama model
docker compose exec copaw copaw models ollama-list             # List Ollama models
docker compose exec copaw copaw models ollama-remove <model>   # Delete Ollama model

# Channel Management
docker compose exec copaw copaw channels list       # List all channels
docker compose exec copaw copaw channels config     # Interactive configuration
docker compose exec copaw copaw channels install <key>    # Install custom channel
docker compose exec copaw copaw channels add <key>        # Add channel to config
docker compose exec copaw copaw channels remove <key>     # Remove custom channel

# Skills Management
docker compose exec copaw copaw skills list         # List all skills
docker compose exec copaw copaw skills config       # Interactive enable/disable

# Daemon Mode (v0.0.5+)
docker compose exec copaw copaw daemon status       # Service status
docker compose exec copaw copaw daemon restart      # Print restart instructions
docker compose exec copaw copaw daemon reload-config # Reload configuration
docker compose exec copaw copaw daemon version      # Version info
docker compose exec copaw copaw daemon logs -n 50   # Recent logs

# Cron Jobs
docker compose exec copaw copaw cron list           # List all jobs
docker compose exec copaw copaw cron get <job_id>   # Get job configuration details
docker compose exec copaw copaw cron state <job_id> # Check job state
docker compose exec copaw copaw cron create ...     # Create a job
docker compose exec copaw copaw cron pause <job_id> # Pause a job
docker compose exec copaw copaw cron resume <job_id># Resume a paused job
docker compose exec copaw copaw cron run <job_id>   # Run once immediately

# Environment Variables
docker compose exec copaw copaw env list            # List all variables
docker compose exec copaw copaw env set KEY VALUE   # Set a variable
docker compose exec copaw copaw env delete KEY      # Delete a variable

# Chat Sessions
docker compose exec copaw copaw chats list          # List all sessions
docker compose exec copaw copaw chats get <id>      # Get session details
docker compose exec copaw copaw chats create ...    # Create new session
docker compose exec copaw copaw chats update <id> --name "New Name"  # Rename session
docker compose exec copaw copaw chats delete <id>   # Delete session

# Maintenance
docker compose exec copaw copaw clean               # Clean working directory (with confirmation)
docker compose exec copaw copaw clean --yes         # Clean without confirmation
docker compose exec copaw copaw clean --dry-run     # Show what would be deleted

# Desktop Mode (v0.0.6+)
docker compose exec copaw copaw desktop             # Open CoPaw in native webview window

# Web Authentication (v0.1.0+)
docker compose exec copaw copaw auth reset-password # Reset Web UI password
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
  - Supports `COPAW_VERSION` build argument to specify version (default: `latest`)
- **Runtime stage**: Final image with only runtime dependencies (curl, ca-certificates), runs as non-root user `copaw`

### Container Startup Flow

```
docker compose up
        ↓
entrypoint.sh runs
        ↓
Check if config.json exists
        ↓
If missing: run `copaw init --defaults` (if COPAW_AUTO_INIT=true)
        ↓
Validate required files (SOUL.md, AGENTS.md)
        ↓
Execute CMD: copaw app --host 0.0.0.0
        ↓
Service listens on 0.0.0.0:8088
```

### Data Persistence

All CoPaw data is stored in the Docker volume `copaw-data` at `/data/copaw`:

| File/Directory | Purpose |
|----------------|---------|
| `config.json` | Root configuration with agent references (v0.1.0+) |
| `workspaces/default/` | Default agent workspace (v0.1.0+) |
| `workspaces/default/agent.json` | Agent configuration (v0.1.0+) |
| `workspaces/default/SOUL.md` | Agent core identity (moved to workspace) |
| `workspaces/default/AGENTS.md` | Detailed workflow (moved to workspace) |
| `.runtime/` | SECRET_DIR: providers.json, envs.json, auth.json |
| `.runtime/auth.json` | Web authentication data (v0.1.0+) |
| `MEMORY.md` | Long-term memory storage |
| `PROFILE.md` | Identity and user profile |
| `HEARTBEAT.md` | Heartbeat task questions |
| `jobs.json` | Cron job list |
| `chats.json` | Chat session list |
| `active_skills/` | Currently active skills |
| `customized_skills/` | User-defined skills |
| `custom_channels/` | User-defined channel modules |
| `memory/` | Agent memory files (with daily logs) |

**v0.1.0 Migration**: Existing configurations are automatically migrated to the new multi-workspace architecture on first startup.

**v0.0.5 Important Change**: `providers.json` and `envs.json` are now stored in a persistent `SECRET_DIR` to survive container restarts. Automatic migration happens on first startup.

### Environment Variables

Key variables are defined in two places:

1. **Dockerfile**: Default values (COPAW_WORKING_DIR, COPAW_LOG_LEVEL, etc.)
2. **docker-compose.yml**: Configuration file for environment variables

Critical variables:
- `COPAW_AUTH_ENABLED` - Enable Web authentication (default: `false`, v0.1.0+)
- `EMBEDDING_API_KEY` - Required for vector memory search
- `MODELSCOPE_API_KEY` / `DASHSCOPE_API_KEY` / `OPENAI_API_KEY` / `ANTHROPIC_API_KEY` / `GEMINI_API_KEY` - LLM provider keys
- `COPAW_AUTO_INIT` - Controls automatic initialization (default: true)
- `COPAW_LLM_MAX_RETRIES` - Maximum retry attempts for LLM API calls (v0.0.7+)
- `COPAW_LLM_BACKOFF_BASE` - Base backoff time for retries (v0.0.7+)
- `COPAW_LLM_BACKOFF_CAP` - Maximum backoff time cap (v0.0.7+)

See [.env.example](.env.example) for all available variables.

### Script Responsibilities

- **scripts/entrypoint.sh**: Checks for config.json, runs auto-init if needed, validates required files
- **scripts/healthcheck.sh**: Health check for Docker (curl test or process check)
- **scripts/validate-config.sh**: Validates environment before startup (for CI/CD)
- **scripts/test-startup.sh**: Tests the startup flow end-to-end

---

## CI/CD Workflows

The project uses GitHub Actions for automated testing and image releases:

| Workflow | Purpose | Trigger |
|----------|---------|---------|
| [dev-test.yml](.github/workflows/dev-test.yml) | Test development builds | Push to `dev` branch |
| [prod-test.yml](.github/workflows/prod-test.yml) | Test production image | Push to `main` branch |
| [release-image.yml](.github/workflows/release-image.yml) | Build and publish Docker image | Release creation |

---

## WebUI Console Features

Access http://localhost:8088/ after startup:

| Group | Feature | Description |
|-------|---------|-------------|
| Chat | Chat | Chat with CoPaw, manage sessions, switch models (v0.0.7+) |
| Control | Channels | Enable/disable channels, configure credentials |
| Control | Sessions | Filter, rename, delete sessions |
| Control | Cron Jobs | Create/edit/delete tasks, run immediately |
| Agent | Workspace | Edit persona files, view memory, upload/download |
| Agent | Skills | Enable/disable/create/**import**/delete skills |
| Agent | MCP | Enable/disable/create/delete MCP clients |
| Agent | Runtime Config | Modify max iterations and max input length |
| Agent | Tools | Enable/disable built-in tools (v0.0.6+), batch toggle (v0.0.7+) |
| Agent | System Prompts | Custom system prompts from workspace files (v0.0.6+), drag-and-drop reordering (v0.0.7+) |
| Settings | Models | Configure providers (custom providers), manage local/Ollama models, select model |
| Settings | Environment Variables | Add/edit/delete environment variables (with security masking v0.0.6+) |
| Settings | Security | Tool Guard security rules management (v0.0.7+) |
| Settings | Token Usage | Track token usage across providers (v0.0.7+) |

**Skills Hub Import**: Now supports importing skills from community platforms:
- `https://skills.sh/...`
- `https://clawhub.ai/...`
- `https://skillsmp.com/...`
- `https://github.com/...`

---

## New Features (CoPaw v0.1.0-beta.1)

### v0.1.0-beta.1 New Features (Latest)

#### Multi-Workspace Architecture
- **Agent Workspaces** - Each agent has its own workspace directory with isolated configuration
- **Default Workspace** - `{WORKING_DIR}/workspaces/default/` for single-agent deployments
- **Automatic Migration** - Legacy configurations are automatically migrated to new format
- **Backward Compatibility** - Falls back to root config if `agent.json` not found

#### Web Authentication
- **Optional Authentication** - Set `COPAW_AUTH_ENABLED=true` to enable (disabled by default)
- **Single User Mode** - First access shows registration page
- **Local Bypass** - Requests from 127.0.0.1 automatically bypass authentication
- **Password Reset** - Use `copaw auth reset-password` CLI command

#### Built-in WeCom Channel
- **Official Support** - WeCom channel is now built into CoPaw
- **No Custom Setup** - Remove the need for third-party WeCom plugins

#### New Model Providers
- **MiniMax Provider** - New built-in model provider
- **DeepSeek Provider** - New built-in model provider
- **Gemini Provider** - New built-in model provider

#### Voice Transcription
- **Audio Transcription** - Voice messages can be transcribed using local Whisper
- **Provider Support** - Supports whisper_api and local_whisper backends

#### Other Improvements
- **XiaoYi Channel** - New channel for Huawei A2A protocol
- **CLI Update Command** - `copaw update` to automatically update CoPaw
- **view_image Tool** - LLM visual analysis tool
- **User Timezone Configuration** - Per-user timezone settings
- **Console Dark Mode** - Dark theme support

---

## New Features (CoPaw 0.0.7)

### v0.0.7 New Features (Latest)

#### Security
- **Tool Guard** - Pre-execution security layer that scans tool parameters for risky patterns (e.g., `rm`, `mv` in shell commands). Risky calls are blocked until the user approves via `/approve`; denied tools are always blocked. New Security settings page for managing rules and approvals.

#### Channel & Communication
- **Mattermost Channel** - Full Mattermost integration supporting DMs and threaded conversations with text, images, files, video, and audio, plus typing indicator and configurable access policies.
- **Matrix Channel** - New Matrix protocol channel integration using matrix-nio, supporting text, images, video, audio, and file messages.
- **Require Mention Filtering** - Group messages are ignored unless the bot is @mentioned (or a slash command is used on Telegram), configurable per-channel via `require_mention` for Discord, DingTalk, Feishu, and Telegram.
- **Telegram Markdown Rendering** - Markdown-to-Telegram HTML conversion for LLM output including bold, italic, code blocks, links, blockquotes, spoilers, and more, with automatic plain text fallback on send failure.
- **Feishu Emoji Reaction** - Automatically adds a "DONE" emoji reaction to the last Feishu reply when processing completes successfully.
- **Feishu Rich Text Media** - Parsing of media files (videos, audio, and other files) in Feishu post-type rich text messages, with automatic download and attachment.
- **QQ Image Messages** - Support for sending image messages via `[Image: url]` tags in agent output for both DM and group chats.

#### Model & AI Features
- **Model Retry** - Automatic retries for LLM API calls on transient errors (rate limit, timeout, connection) with exponential backoff, configurable via `COPAW_LLM_MAX_RETRIES`, `COPAW_LLM_BACKOFF_BASE`, `COPAW_LLM_BACKOFF_CAP`.
- **LM Studio Provider** - LM Studio added as a built-in model provider with configuration UI and documentation.
- **Token Usage Tracking** - End-to-end token usage tracking across providers with a Token Usage settings page, API, and `get_token_usage` tool.
- **Provider Advanced Configuration** - Added `generate_kwargs` editor for custom generation parameters (e.g., temperature, top_p, enable_thinking); providers without API keys (Ollama, LM Studio) are now correctly shown as configured.

#### Console & UI
- **Workspace Drag-and-Drop** - Drag-and-drop reordering for enabled system prompt files in Agent Workspace, controlling prompt file precedence.
- **Chat Model Selection** - Model selector dropdown on the Chat page for switching models during conversation.
- **Agent Language Selector** - Change the agent's language directly from the console Agent Config page.
- **Tool Batch Toggle** - "Enable All" and "Disable All" buttons on the Tools page for batch tool management.
- **Chat URL Routing** - Direct URL access to specific chat sessions via `/chat/:chatId` with automatic URL synchronization.
- **Context Management UI** - New Context Management section in Agent Config with adjustable compact ratio, reserve ratio, and tool result compaction settings, displaying derived token thresholds.
- **Preserve Chat on Navigate** - Chat stays mounted when switching to other pages, preserving in-progress messages, cursor position, and running state.

#### Skills
- **AI Skill Optimization** - "AI Optimize" button in the skill editor uses the active model to rewrite skill content with streaming output; supports English, Chinese, and Russian prompts.
- **Skill Card Description** - Skill cards now display the `description` from SKILL.md frontmatter so you can see what each skill does without opening it.

#### Installation & Platform
- **Auto PyPI Mirror** - Automatic PyPI mirror selection in the install script, detecting connectivity and falling back to Alibaba Cloud mirror for users in China.
- **Docker Secret Directory** - SECRET_DIR (`/data/copaw.secret` -> `/data/copaw/.runtime`) for persistent provider settings and API keys.

---

## New Features (CoPaw 0.0.6)

### v0.0.6 Features (Retained)

#### Desktop Applications
- **Native Desktop Installers** - One-click installer for Windows and standalone `.app` bundle for macOS
- **Desktop Launch Command** - New `copaw desktop` command opens CoPaw in native webview window with automatic server startup

#### Internationalization
- **Russian Language** - Complete translation across console UI, agent configuration files, and initialization command
- **Japanese Language** - Full console UI translation with language switcher integration

#### Channel & Communication
- **MQTT Channel** - IoT and message queue integration support
- **Telegram Access Control** - DM/group access policies with user allowlists and custom denial messages
- **QQ Markdown Support** - Rich markdown messages with validation-aware fallback
- **QQ Rich Media** - Attachment download and parsing for images, videos, audio, and files
- **Unified Allowlist Control** - Centralized DM/group access policies for Discord and Feishu
- **DingTalk Media Expansion** - Extended audio/video format support
- **Feishu Table Rendering** - Markdown tables converted to native interactive message cards
- **Feishu Post Messages** - Support for receiving Feishu post-type rich text messages
- **Discord Media Support** - Media sending with local/remote file handling
- **Docker Channel Enablement** - Telegram and Discord channels now enabled by default in Docker images

#### Model & AI Features
- **Gemini Thinking Model** - Preserved reasoning content via `extra_content` field for Gemini thinking models
- **MLX Backend** - Message normalization handling for MLX tokenizer compatibility
- **Local/Cloud LLM Routing** - Intelligent model selection with policy hooks

#### Console & UI
- **Environment Variable Security** - Password-style masking for sensitive values with show/hide toggle
- **Environment Variable Deletion** - Single and bulk deletion support
- **Built-in Tool Management** - Dedicated Tools page with toggle switches for enabling/disabling built-in tools
- **Custom System Prompts** - Select and reorder workspace Markdown files to compose custom system prompts

#### Memory & Configuration
- **ReMeLight Migration** - Refactored memory system from ReMeCopaw to ReMeLight
- **Configurable Memory Compaction** - New compact split strategy with tunable parameters
- **Smart Tool Output Truncation** - Automatic truncation for file reads and shell commands

### v0.0.5 Features (Retained)

- **Twilio Voice Channel** - Voice channel integration with Cloudflare tunnel support
- **Telegram CLI Configuration** - Interactive command-line tool for configuring Telegram
- **Anthropic Provider** - New built-in model provider
- **DeepSeek Reasoner Support** - Preserved `reasoning_content` for reasoner mode
- **Version Update Notification** - Automatic version detection with update badge
- **Daemon Mode** - `copaw daemon` CLI for managing background service
- **Agent Interruption API** - `interrupt()` method to cancel active reply tasks
- **MCP Client Auto-Recovery** - Automatic reconnect/rebuild for closed MCP sessions
- **Windows One-Click Install** - `install.bat` script support
- **Channel Documentation Links** - Quick "Doc" buttons on each channel card
- **iMessage Attachments** - Support for sending images, audio, and video files
- **Message Filtering** - Per-channel `filter_tool_messages` and `filter_thinking` options
- **Docker Config Persistence** - `providers.json` and `envs.json` auto-migrated to `SECRET_DIR`
- **Docker Security** - Default port binding changed to `127.0.0.1` (v0.0.5)

### v0.0.4 Features (Retained)

- **Telegram Channel Support** - New Telegram bot channel with full multimodal support
- **OpenAI & Azure OpenAI** - New built-in model providers
- **Aliyun coding-plan Provider** - New model provider option
- **CORS Configuration** - New `COPAW_CORS_ORIGINS` environment variable
- **Heartbeat Monitor Panel** - New monitoring UI in console
- **Audio File Support** - DingTalk and Feishu channels now support audio files

### v0.0.3 Features (Retained)

### MCP (Model Context Protocol) Support

CoPaw now supports connecting to external MCP servers to extend capabilities.

**Prerequisites**: None (Node.js 20.x LTS is pre-installed in the Docker image)

**Configuration Format**:
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/directory"]
    }
  }
}
```

**Management**:
- Use **Console → Agent → MCP** to add/edit/enable/disable/delete MCP clients
- Supports three JSON formats for easy import

### Browser Support (Chromium Headless Mode)

The Docker image includes Chromium browser in headless mode for MCP browser automation.

**MCP Browser Server Configuration**:

Puppeteer MCP:
```json
{
  "mcpServers": {
    "browser": {
      "command": "npx",
      "args": ["-y", "@executeautomation/puppeteer-mcp-server"],
      "env": {
        "HEADLESS": "true",
        "CHROME_PATH": "/usr/bin/chromium"
      }
    }
  }
}
```

Playwright MCP:
```json
{
  "mcpServers": {
    "browser": {
      "command": "npx",
      "args": ["-y", "@executeautomation/playwright-mcp-server"],
      "env": {
        "HEADLESS": "true",
        "PLAYWRIGHT_BROWSERS_PATH": "0"
      }
    }
  }
}
```

**Testing Chromium**:
```bash
# Check Chromium version
docker compose exec copaw chromium --version

# Test headless mode
docker compose exec copaw chromium --headless --no-sandbox --disable-dev-shm-usage --disable-gpu --dump-dom https://example.com
```

### Local Model Support

CoPaw supports running models locally without API Keys:

#### llama.cpp (Cross-platform)
```bash
# Install (not available in Docker by default, requires custom build)
pip install 'copaw[llamacpp]'

# Download model
docker compose exec copaw copaw models download Qwen/Qwen3-4B-GGUF
```

#### MLX (Apple Silicon)
```bash
# Install
pip install 'copaw[mlx]'

# Download model
docker compose exec copaw copaw models download Qwen/Qwen3-4B --backend mlx
```

#### Ollama
```bash
# Install
pip install 'copaw[ollama]'

# Pull model
docker compose exec copaw copaw models ollama-pull mistral:7b
docker compose exec copaw copaw models ollama-pull qwen3:8b
```

**Note**: Local model support requires additional dependencies. For Docker deployment, consider building a custom image with these extras.

### Enhanced CLI Commands

**Channel Management**:
- `copaw channels install <key>` - Install custom channel module
- `copaw channels add <key>` - Add channel to config
- `copaw channels remove <key>` - Remove custom channel

**Cron Job Management**:
- `copaw cron get <job_id>` - Get job configuration details (v0.0.4+)
- `copaw cron state <job_id>` - Check job runtime state
- `copaw cron pause <job_id>` - Pause a job
- `copaw cron resume <job_id>` - Resume paused job

**Chat Session Management**:
- `copaw chats get <id>` - View session details
- `copaw chats create ...` - Create new session
- `copaw chats update <id> --name "..."` - Rename session
- `copaw chats delete <id>` - Delete session

---

## Important Files

| File | Purpose |
|------|---------|
| [docs/copaw-info.md](docs/copaw-info.md) | Comprehensive CoPaw documentation reference from official docs |
| [.env.example](.env.example) | Environment variable template for API keys and configuration |
| [Dockerfile](Dockerfile) | Multi-stage Docker image definition with version support |
| [docker-compose.yml](docker-compose.yml) | Docker Compose orchestration configuration |
| [scripts/entrypoint.sh](scripts/entrypoint.sh) | Container startup script with auto-init |
| [scripts/healthcheck.sh](scripts/healthcheck.sh) | Health check script for Docker |
| [scripts/validate-config.sh](scripts/validate-config.sh) | Pre-startup configuration validation |
| [scripts/test-startup.sh](scripts/test-startup.sh) | End-to-end startup flow testing |

---

## Multimodal Message Support

| Channel | Text | Image | Video | Audio | File | Send Text | Send Image | Send Video | Send Audio | Send File |
|---------|:----:|:-----:|:-----:|:-----:|:----:|:---------:|:----------:|:----------:|:----------:|:---------:|
| DingTalk | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Feishu | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Discord | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ (v0.0.6+) | ✓ (v0.0.6+) | ✓ (v0.0.6+) | ✓ (v0.0.6+) |
| iMessage | ✓ | ✓ (v0.0.5+) | ✓ (v0.0.5+) | ✓ (v0.0.5+) | ✗ | ✓ | ✓ (v0.0.5+) | ✓ (v0.0.5+) | ✓ (v0.0.5+) | ✗ |
| QQ | ✓ | ✓ (v0.0.6+) | ✓ (v0.0.6+) | ✓ (v0.0.6+) | ✓ (v0.0.6+) | ✓ | ✓ (v0.0.7+) | 🚧 | 🚧 | 🚧 |
| Telegram | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Twilio Voice | ✓ | ✗ | ✗ | ✓ | ✗ | ✓ | ✗ | ✗ | ✓ | ✗ |
| MQTT | ✓ | ✗ | ✗ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | ✗ |
| Mattermost | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Matrix | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |

> ✓ = Supported; 🚧 = In progress; ✗ = Not supported

---

## Image Information

### Pre-built Image

- **Repository**: `ghcr.io/log-z/copaw-docker:latest`
- **Pull command**: `docker pull ghcr.io/log-z/copaw-docker:latest`
- **Update frequency**: Updated with CoPaw official releases

### Build Details

- **Base image**: `python:3.12-slim`
- **Python version**: 3.12
- **Node.js version**: 20.x LTS (included for MCP support)
- **Browser**: Chromium (headless mode, for MCP browser automation)
- **Working directory**: `/data/copaw`
- **Run user**: `copaw` (non-root)
- **Exposed port**: 8088
