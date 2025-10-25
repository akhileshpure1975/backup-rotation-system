#!/bin/bash

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load configuration
source "${SCRIPT_DIR}/config/backup.conf"

# Create log file first
LOG_FILE="${SCRIPT_DIR}/logs/slack_test.log"
mkdir -p "${SCRIPT_DIR}/logs"

# Load utilities AFTER log file is set
source "${SCRIPT_DIR}/utils/logger.sh"
source "${SCRIPT_DIR}/utils/notify.sh"

echo "Testing Slack Integration..."
echo "============================"
echo ""
echo "Configuration:"
echo "  ENABLE_SLACK: ${ENABLE_SLACK}"
echo "  SLACK_WEBHOOK_URL: ${SLACK_WEBHOOK_URL:0:50}..."
echo ""

if [[ "${ENABLE_SLACK}" == "true" ]] && [[ -n "${SLACK_WEBHOOK_URL}" ]]; then
    echo "Sending test notification to Slack..."
    send_slack "TEST" "🧪 Test notification from your backup system! If you see this, Slack integration is working perfectly!"
    
    if [[ $? -eq 0 ]]; then
        echo "✅ Success! Check your Slack channel for the message."
    else
        echo "❌ Failed. Check your webhook URL and internet connection."
    fi
else
    echo "⚠️  Slack is not enabled or webhook URL is not configured."
    echo ""
    echo "To enable:"
    echo "  1. Edit config/backup.conf"
    echo "  2. Set ENABLE_SLACK=true"
    echo "  3. Set SLACK_WEBHOOK_URL to your webhook"
fi
