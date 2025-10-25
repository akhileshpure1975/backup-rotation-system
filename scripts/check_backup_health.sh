#!/bin/bash

BACKUP_DIR="$HOME/Projects/backup-rotation-system/backups"
LOG_FILE="$HOME/Projects/backup-rotation-system/logs/backup_$(date +%Y-%m-%d).log"

# Check if backup ran today
if [ ! -f "$LOG_FILE" ]; then
    echo "ERROR: No backup log for today!" | mail -s "Backup Failed" akhileshpure000@gmail.com
    exit 1
fi

# Check for errors in log
if grep -q "ERROR" "$LOG_FILE"; then
    echo "ERROR: Backup encountered errors!" | mail -s "Backup Errors Detected" akhileshpure000@gmail.com.com
    exit 1
fi

echo "All backups healthy!"
