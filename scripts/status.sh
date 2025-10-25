#!/bin/bash

echo "╔════════════════════════════════════════════════╗"
echo "║    Backup System Status Dashboard              ║"
echo "╚════════════════════════════════════════════════╝"
echo ""

BACKUP_DIR="$HOME/Projects/backup-rotation-system/backups"
LOG_DIR="$HOME/Projects/backup-rotation-system/logs"

# Check if backups exist
if [ -z "$(ls $BACKUP_DIR/backup_*.tar.gz 2>/dev/null)" ]; then
    echo "⚠️  No backups found!"
    exit 1
fi

# Latest backup
LATEST=$(ls -t $BACKUP_DIR/backup_*.tar.gz | head -1)
LATEST_NAME=$(basename "$LATEST")
LATEST_SIZE=$(du -h "$LATEST" | cut -f1)
LATEST_DATE=$(stat -c %y "$LATEST" 2>/dev/null | cut -d'.' -f1)

echo "📦 Latest Backup:"
echo "   Name: $LATEST_NAME"
echo "   Size: $LATEST_SIZE"
echo "   Date: $LATEST_DATE"
echo ""

# Total stats
TOTAL_BACKUPS=$(ls $BACKUP_DIR/backup_*.tar.gz 2>/dev/null | wc -l)
TOTAL_SIZE=$(du -sh $BACKUP_DIR | cut -f1)

echo "📊 Statistics:"
echo "   Total Backups: $TOTAL_BACKUPS"
echo "   Total Size: $TOTAL_SIZE"
echo ""

# Check backup age
NOW=$(date +%s)
LATEST_TIME=$(stat -c %Y "$LATEST" 2>/dev/null)
AGE_HOURS=$(( (NOW - LATEST_TIME) / 3600 ))

echo "⏰ Backup Age:"
if [ $AGE_HOURS -lt 24 ]; then
    echo "   ✅ $AGE_HOURS hours old (Fresh!)"
elif [ $AGE_HOURS -lt 48 ]; then
    echo "   ⚠️  $AGE_HOURS hours old (Acceptable)"
else
    echo "   ❌ $AGE_HOURS hours old (Too old!)"
fi
echo ""

# Recent log entries
echo "📋 Recent Log (Last 5 entries):"
tail -5 $LOG_DIR/backup_*.log | sed 's/^/   /'
echo ""

# Cron status
echo "⏲️  Cron Jobs:"
crontab -l | grep backup.sh | sed 's/^/   /'
echo ""

echo "╚════════════════════════════════════════════════╝"
