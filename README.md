# Home Assistant Development Workflow

Streamlined Home Assistant development with AI assistance, branch testing, and
automated deployment.

## Features

- 🤖 Automated AI context generation from your HA instance
- 🚀 Git-based branch deployment and testing
- ⚡ Fast API-based reloads (no full restarts needed)
- 🛡️ CI validation with safe production testing
- 🔄 Instant rollback capability

## Setup

### Prerequisites

- Home Assistant OS instance with SSH access
- GitHub repository for your HA configuration
- Open WebUI for AI assistance
- Ubuntu/Linux development machine

### Installation

1. **Clone this repository:**

   ```bash
   git clone https://github.com/YOUR_USERNAME/homeassistant-dev ~/Projects/homeassistant-dev
   cd ~/Projects/homeassistant-dev
   ```

2. **Clone your HA configuration:**

   ```bash
   git clone https://github.com/YOUR_USERNAME/homeassistant_config config
   ```

3. **Create environment file:**

   ```bash
   cp .env.example .env
   # Edit .env with your specific details
   ```

4. **Set up SSH access to your HAOS instance:**

   ```bash
   ssh-copy-id root@YOUR_HAOS_IP
   ```

5. **Create Home Assistant long-lived access token:**
   - Go to your HA web interface
   - Click your profile (bottom left)
   - Scroll to "Long-lived access tokens"
   - Click "Create Token"
   - Name it "Development Scripts"
   - Copy token to .env file

6. **Create the modified export script on HAOS:**

   ```bash
   ssh root@YOUR_HAOS_IP
   cd /config/scripts
   cp export-ha-data.sh export-ha-data-fixed.sh
   # Edit export-ha-data-fixed.sh and change:
   # OUTPUT_FILE="$EXPORTS_DIR/ha_export_${TIMESTAMP}.txt"
   # to:
   # OUTPUT_FILE="$EXPORTS_DIR/ai-context.txt"
   ```

7. **Make scripts executable:**

   ```bash
   chmod +x scripts/*.sh
   ```

8. **Test the setup:**

   ```bash
   source .env
   curl -X GET -H "Authorization: Bearer $HA_TOKEN" "http://$HAOS_IP:8123/api/"
   ```

## Usage

### Neovim Integration

Add these keymaps to your Neovim config:

```lua
-- ~/.config/nvim/lua/config/keymaps.lua
local map = vim.keymap.set

-- HA Development workflow
map("n", "<leader>hc", ":!cd ~/Projects/homeassistant-dev && ./scripts/get-ai-context.sh<CR>", { desc = "Get AI Context" })
map("n", "<leader>ht", ":!cd ~/Projects/homeassistant-dev && ./scripts/deploy-branch.sh<CR>", { desc = "Deploy Current Branch" })
map("n", "<leader>hr", ":!cd ~/Projects/homeassistant-dev && ./scripts/rollback.sh<CR>", { desc = "Rollback to Main" })

-- Standard git workflow
map("n", "<leader>gf", ":!git checkout -b feature/$(date +%Y%m%d-%H%M%S)<CR>", { desc = "New feature branch" })
map("n", "<leader>gc", ":Git commit<CR>", { desc = "Git commit" })
```

### Daily Workflow

1. **Get fresh AI context** (20 seconds)

   ```bash
   <leader>hc    # or ./scripts/get-ai-context.sh
   ```

2. **AI-assisted development** (45 seconds)
   - Upload `context/ai-context.txt` to Open WebUI
   - Generate YAML configuration with AI
   - Paste into Neovim and edit

3. **Commit and push** (15 seconds)

   ```bash
   <leader>gc    # Commit changes
   git push      # Triggers CI validation
   ```

4. **Test on production** (10 seconds)

   ```bash
   <leader>ht    # Deploy branch after CI passes
   ```

5. **Finalize**
   - **Success:** Merge via GitHub
   - **Issues:** `<leader>hr` to rollback instantly

## Scripts

- **`get-ai-context.sh`** - Runs your export script on HAOS and downloads the result
- **`deploy-branch.sh`** - Deploys current branch to production for testing
- **`rollback.sh`** - Quickly rollback to main branch

## Directory Structure

```code
homeassistant-dev/                    # This repository
├── .env                             # Your environment variables (gitignored)
├── .env.example                     # Template for environment setup
├── context/
│   └── ai-context.txt              # Generated AI context (gitignored)
├── scripts/
│   ├── get-ai-context.sh           # Get fresh context from HAOS
│   ├── deploy-branch.sh            # Deploy branch for testing
│   └── rollback.sh                 # Rollback to main
└── config/                         # Your HA config repo (gitignored)
    ├── configuration.yaml
    ├── scripts/
    │   └── export-ha-data-fixed.sh  # Modified export script
    └── ...
```

## Benefits

- **⚡ 90 seconds** per development cycle (down from 15+ minutes)
- **🛡️ Safe testing** - test branches before merging
- **🚀 Fast reloads** - API-based, no full restarts
- **🤖 AI context** - always up-to-date entity and config info
- **🔄 Git-based** - clean deployment and rollback

## Troubleshooting

### API Token Issues

```bash
# Test token validity
curl -X GET -H "Authorization: Bearer $HA_TOKEN" "http://$HAOS_IP:8123/api/"
```

### SSH Issues

```bash
# Test SSH access
ssh $HAOS_USER@$HAOS_IP "echo 'SSH working'"
```

### Git Issues

```bash
# Ensure HAOS /config is a git repo
ssh $HAOS_USER@$HAOS_IP "cd /config && git status"
```

## Contributing

Feel free to submit issues and pull requests to improve this workflow!
