#!/bin/bash
set -e

# Load environment variables
source "$(dirname "$0")/../.env"

CONTEXT_DIR="$PROJECT_DIR/context"

echo "🤖 Getting fresh AI context from production..."

# Run your export script remotely
ssh $HAOS_USER@$HAOS_IP "cd /config && ./scripts/export-ha-data-fixed.sh"

# Download the result
scp $HAOS_USER@$HAOS_IP:/config/exports/ai-context.txt $CONTEXT_DIR/

echo "✅ AI context ready: $CONTEXT_DIR/ai-context.txt"
echo "📤 Upload this file to Open WebUI for full context"
