#!/bin/bash

# Load config
source config/backup.conf
source utils/logger.sh
source utils/notify.sh

# Set log file for testing
LOG_FILE="logs/test.log"
mkdir -p logs

# Send test notification
send_notification "TEST" "This is a test notification from your backup system"

echo "Test notification sent! Check your Slack channel."
