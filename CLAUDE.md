# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a **Home Assistant development workflow system** that provides AI-assisted development, automated branch testing, and safe production deployment. The system uses a dual-repository structure:

- **Main repository** (`homeassistant-dev/`) - Development workflow scripts and tools
- **Config repository** (`homeassistant-dev/config/`) - Home Assistant configuration using packages pattern

## Development Commands

### Core Workflow Scripts
```bash
# Get fresh AI context from production HA instance
./scripts/get-ai-context.sh

# Deploy current branch to production for testing
./scripts/deploy-branch.sh  

# Rollback to main branch (emergency recovery)
./scripts/rollback.sh
```

### Configuration Management
The Home Assistant configuration uses standard HA commands via SSH:
```bash
# Configuration validation
ssh $HAOS_USER@$HAOS_IP "ha core check"

# Service reloads (via API)
curl -X POST -H "Authorization: Bearer $HA_TOKEN" "http://$HAOS_IP:8123/api/services/homeassistant/reload_all"
curl -X POST -H "Authorization: Bearer $HA_TOKEN" "http://$HAOS_IP:8123/api/services/automation/reload"
curl -X POST -H "Authorization: Bearer $HA_TOKEN" "http://$HAOS_IP:8123/api/services/script/reload"

# Full restart (if needed)
ssh $HAOS_USER@$HAOS_IP "ha core restart"
```

### GitHub Integration
```bash
# Issue management (configured in .claude/settings.local.json)
gh issue list
gh issue create --title "Feature Name" --body "Description..." --label "enhancement"

# Branch and PR workflow
git checkout -b feature/descriptive-name
git push origin feature-name
gh pr create --title "Feature: Description" --body "Closes #ISSUE_NUMBER" --base main
```

## Architecture

### Development Workflow Structure
- **`scripts/`** - Automation scripts for deployment, context generation, and rollback
- **`config/`** - Git submodule containing Home Assistant configuration
- **`context/`** - AI context files generated from production HA instance (gitignored)
- **`.env`** - Environment configuration (HA connection details, tokens)

### Home Assistant Configuration Architecture
The `config/` directory uses Home Assistant's packages pattern:

- **`packages/`** - Modular feature packages (cameras, presence, notifications, security, etc.)
- **`configuration.yaml`** - Main config with package imports and core settings
- **`automation/`** - Additional automation files via `!include_dir_merge_list`
- **`input_boolean/`** - Boolean controls via `!include_dir_merge_named`
- **`.github/workflows/validate.yaml`** - CI validation using Home Assistant container

### Key Configuration Patterns
```yaml
# Package structure (packages/*.yaml)
automation:
  - alias: "Descriptive Name" 
    description: "Clear purpose description"
    trigger: [triggers]
    condition: [conditions]
    action: [actions]

script:
  script_name:
    alias: "Script Name" 
    sequence: [steps]
```

### Notification System
Multi-device notifications configured in `configuration.yaml`:
- `notify.all_mobile_devices` - Group service for Brian and Hester's phones
- Individual services: `mobile_app_brian_phone`, `mobile_app_hester_phone`

## Environment Setup

### Required Environment Variables (.env)
```bash
# Home Assistant connection
HAOS_IP=192.168.1.XXX
HAOS_USER=root
HA_TOKEN=your_long_lived_access_token_here

# Project paths
PROJECT_DIR=/home/USERNAME/Projects/homeassistant-dev
```

### Prerequisites
- Home Assistant OS instance with SSH access
- GitHub repository for HA configuration 
- Home Assistant long-lived access token
- Modified export script on HAOS: `/config/scripts/export-ha-data-fixed.sh`

## Development Process

### Standard Workflow (90-second cycle)
1. **Get AI Context**: `./scripts/get-ai-context.sh` → Upload `context/ai-context.txt` to AI
2. **Develop**: Create/edit YAML configurations with AI assistance
3. **Commit**: `git add . && git commit -m "feat: description"`
4. **CI Validation**: `git push` triggers GitHub Actions validation
5. **Test on Production**: `./scripts/deploy-branch.sh` after CI passes
6. **Finalize**: Merge PR or `./scripts/rollback.sh` if issues

### Branch Strategy
- Feature branches: `feature/descriptive-name`
- Bug fixes: `fix/descriptive-name`
- CI validation required before production testing
- Squash merge to main after testing

### Claude Code Permissions
The `.claude/settings.local.json` configures allowed GitHub CLI operations:
- `gh issue view:*`, `gh issue create:*`, `gh issue comment:*`
- Default mode: `acceptEdits`

## Special Features

### AI Context Generation
- Exports comprehensive HA state, entities, and configurations
- Generated via remote script execution on production instance
- Provides full context for AI-assisted development

### Safe Production Testing  
- Git-based deployment to production HA instance
- Configuration validation before reload
- API-based reloads (no full restarts needed)
- Instant rollback capability

### CI Integration
- GitHub Actions validate configuration using HA container
- Creates dummy service account file for Google Assistant integration
- Continues on expected errors to allow deployment testing