#!/bin/bash
set -e

# Load environment variables
source "$(dirname "$0")/../.env"

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

echo "🚀 Deploying branch '$CURRENT_BRANCH' to production..."

# Ensure branch is pushed
git push origin "$CURRENT_BRANCH"

# Deploy via Git on production
ssh $HAOS_USER@$HAOS_IP "
    cd /config
    git fetch origin
    git checkout '$CURRENT_BRANCH'
    git pull origin '$CURRENT_BRANCH'
"

# Show what we deployed
echo "📋 Now on: $(ssh $HAOS_USER@$HAOS_IP "cd /config && git log --oneline -1")"

# Check configuration
echo "🔍 Validating configuration..."
if ssh $HAOS_USER@$HAOS_IP "ha core check"; then
  echo "✅ Configuration valid, reloading core..."

  # Reload Home Assistant core via API
  RELOAD_RESPONSE=$(curl -s -X POST \
    -H "Authorization: Bearer $HA_TOKEN" \
    -H "Content-Type: application/json" \
    "http://$HAOS_IP:8123/api/services/homeassistant/reload_all")

  if [[ $? -eq 0 ]]; then
    echo "✅ Branch '$CURRENT_BRANCH' deployed and core reloaded!"
    echo "💡 If you need additional reloads:"
    echo "   - Automations: curl -X POST -H 'Authorization: Bearer \$HA_TOKEN' http://$HAOS_IP:8123/api/services/automation/reload"
    echo "   - Scripts: curl -X POST -H 'Authorization: Bearer \$HA_TOKEN' http://$HAOS_IP:8123/api/services/script/reload"
    echo "   - Full restart: ssh $HAOS_USER@$HAOS_IP 'ha core restart'"
  else
    echo "⚠️ Core reload may have failed, but config is valid"
    echo "💡 Try manual reload or restart if needed"
  fi
else
  echo "❌ Config validation failed!"
  echo "🔧 Check logs: ssh $HAOS_USER@$HAOS_IP 'ha core logs'"
  exit 1
fi
