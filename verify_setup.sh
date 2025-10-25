#!/bin/bash

echo "🔍 Verifying Backup System Setup..."
echo "===================================="
echo ""

# Check 1: Scripts exist
echo "1. Checking scripts..."
for script in backup.sh restore.sh verify.sh; do
    if [ -x "$HOME/Projects/backup-rotation-system/scripts/$script" ]; then
        echo "   ✅ $script exists and is executable"
    else
        echo "   ❌ $script missing or not executable"
    fi
done
echo ""

# Check 2: Configuration
echo "2. Checking configuration..."
if [ -f "$HOME/Projects/backup-rotation-system/config/backup.conf" ]; then
    echo "   ✅ backup.conf exists"
else
    echo "   ❌ backup.conf missing"
fi
echo ""

# Check 3: Cron jobs
echo "3. Checking cron jobs..."
CRON_COUNT=$(crontab -l 2>/dev/null | grep -c backup.sh)
if [ $CRON_COUNT -gt 0 ]; then
    echo "   ✅ Cron jobs configured ($CRON_COUNT found)"
    crontab -l | grep backup
else
    echo "   ⚠️  No cron jobs found"
fi
echo ""

# Check 4: Backups exist
echo "4. Checking backups..."
BACKUP_COUNT=$(ls $HOME/Projects/backup-rotation-system/backups/backup_*.tar.gz 2>/dev/null | wc -l)
if [ $BACKUP_COUNT -gt 0 ]; then
    echo "   ✅ $BACKUP_COUNT backup(s) found"
else
    echo "   ⚠️  No backups found yet"
fi
echo ""

# Check 5: Logs
echo "5. Checking logs..."
if [ -f "$HOME/Projects/backup-rotation-system/logs/backup_$(date +%Y-%m-%d).log" ]; then
    echo "   ✅ Log file exists"
else
    echo "   ⚠️  No log file for today"
fi
echo ""

echo "===================================="
echo "✅ Setup verification complete!"
