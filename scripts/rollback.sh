#!/bin/bash
set -e

# Load environment variables
source "$(dirname "$0")/../.env"

echo "🔄 Rolling back to main..."

ssh $HAOS_USER@$HAOS_IP "
    cd /config
    git fetch origin main
    git checkout main
    git pull origin main
"

echo "📋 Back on: $(ssh $HAOS_USER@$HAOS_IP "cd /config && git log --oneline -1")"

echo "🔍 Validating main branch..."
if ssh $HAOS_USER@$HAOS_IP "ha core check"; then
  echo "✅ Main branch valid, reloading core..."

  # Reload via API
  RELOAD_RESPONSE=$(curl -s -X POST \
    -H "Authorization: Bearer $HA_TOKEN" \
    -H "Content-Type: application/json" \
    "http://$HAOS_IP:8123/api/services/homeassistant/reload_all")

  echo "✅ Rollback complete and core reloaded!"
else
  echo "❌ Even main has issues - check your repo!"
  exit 1
fi
