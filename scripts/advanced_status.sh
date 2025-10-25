#!/bin/bash

clear

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

BACKUP_DIR="$HOME/Projects/backup-rotation-system/backups"
LOG_DIR="$HOME/Projects/backup-rotation-system/logs"

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        AUTOMATED BACKUP SYSTEM - DASHBOARD                ║${NC}"
echo -e "${BLUE}║              Status Report & Analytics                    ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

# System Info
echo -e "${GREEN}🖥️  SYSTEM INFORMATION${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Hostname: $(hostname)"
echo "User: $(whoami)"
echo "Current Time: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Uptime: $(uptime -p)"
echo ""

# Backup Statistics
echo -e "${GREEN}📦 BACKUP STATISTICS${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
TOTAL_BACKUPS=$(ls $BACKUP_DIR/backup_*.tar.gz 2>/dev/null | wc -l)
TOTAL_SIZE=$(du -sh $BACKUP_DIR 2>/dev/null | cut -f1)
echo "Total Backups: $TOTAL_BACKUPS"
echo "Total Size: $TOTAL_SIZE"
echo ""

# Latest Backup
if [ $TOTAL_BACKUPS -gt 0 ]; then
    LATEST=$(ls -t $BACKUP_DIR/backup_*.tar.gz | head -1)
    LATEST_NAME=$(basename "$LATEST")
    LATEST_SIZE=$(du -h "$LATEST" | cut -f1)
    LATEST_DATE=$(stat -c %y "$LATEST" 2>/dev/null | cut -d'.' -f1)
    
    echo -e "${GREEN}📋 LATEST BACKUP${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Name: $LATEST_NAME"
    echo "Size: $LATEST_SIZE"
    echo "Created: $LATEST_DATE"
    
    # Check age
    NOW=$(date +%s)
    LATEST_TIME=$(stat -c %Y "$LATEST" 2>/dev/null)
    AGE_HOURS=$(( (NOW - LATEST_TIME) / 3600 ))
    
    if [ $AGE_HOURS -lt 24 ]; then
        echo -e "Status: ${GREEN}✅ Fresh (${AGE_HOURS}h old)${NC}"
    elif [ $AGE_HOURS -lt 48 ]; then
        echo -e "Status: ${YELLOW}⚠️  Acceptable (${AGE_HOURS}h old)${NC}"
    else
        echo -e "Status: ${RED}❌ Too Old (${AGE_HOURS}h old)${NC}"
    fi
    echo ""
fi

# Backup History
echo -e "${GREEN}📜 BACKUP HISTORY (Last 5)${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ls -t $BACKUP_DIR/backup_*.tar.gz 2>/dev/null | head -5 | while read backup; do
    NAME=$(basename "$backup")
    SIZE=$(du -h "$backup" | cut -f1)
    DATE=$(stat -c %y "$backup" 2>/dev/null | cut -d' ' -f1)
    echo "  • $NAME ($SIZE) - $DATE"
done
echo ""

# Notifications Status
echo -e "${GREEN}🔔 NOTIFICATIONS STATUS${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
TODAY_LOG="$LOG_DIR/backup_$(date +%Y-%m-%d).log"
if [ -f "$TODAY_LOG" ]; then
    if grep -q "Email sent successfully" "$TODAY_LOG"; then
        echo -e "Email: ${GREEN}✅ Working${NC}"
    else
        echo -e "Email: ${YELLOW}⚠️  Not detected${NC}"
    fi
    
    if grep -q "Slack notification sent successfully" "$TODAY_LOG"; then
        echo -e "Slack: ${GREEN}✅ Working${NC}"
    else
        echo -e "Slack: ${YELLOW}⚠️  Not detected${NC}"
    fi
else
    echo -e "Status: ${YELLOW}⚠️  No log for today${NC}"
fi
echo ""

# Cron Jobs
echo -e "${GREEN}⏲️  SCHEDULED JOBS${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
CRON_COUNT=$(crontab -l 2>/dev/null | grep -c backup-rotation-system)
if [ $CRON_COUNT -gt 0 ]; then
    echo -e "Status: ${GREEN}✅ $CRON_COUNT job(s) configured${NC}"
    crontab -l 2>/dev/null | grep backup-rotation-system | grep -v '^#' | while read line; do
        echo "  • $line"
    done
else
    echo -e "Status: ${RED}❌ No cron jobs found${NC}"
fi
echo ""

# Recent Activity
echo -e "${GREEN}📋 RECENT ACTIVITY (Last 10 log entries)${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ -f "$TODAY_LOG" ]; then
    tail -10 "$TODAY_LOG" | sed 's/^/  /'
else
    echo "  No activity logged today"
fi
echo ""

# Health Check
echo -e "${GREEN}🏥 SYSTEM HEALTH${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
HEALTH_SCORE=0
MAX_SCORE=5

# Check 1: Recent backup exists
if [ $AGE_HOURS -lt 48 ]; then
    echo -e "Recent Backup: ${GREEN}✅ Pass${NC}"
    ((HEALTH_SCORE++))
else
    echo -e "Recent Backup: ${RED}❌ Fail${NC}"
fi

# Check 2: Multiple backups exist
if [ $TOTAL_BACKUPS -ge 3 ]; then
    echo -e "Backup Count: ${GREEN}✅ Pass${NC}"
    ((HEALTH_SCORE++))
else
    echo -e "Backup Count: ${YELLOW}⚠️  Warning${NC}"
fi

# Check 3: Cron configured
if [ $CRON_COUNT -gt 0 ]; then
    echo -e "Automation: ${GREEN}✅ Pass${NC}"
    ((HEALTH_SCORE++))
else
    echo -e "Automation: ${RED}❌ Fail${NC}"
fi

# Check 4: Email working
if [ -f "$TODAY_LOG" ] && grep -q "Email sent successfully" "$TODAY_LOG"; then
    echo -e "Email Alerts: ${GREEN}✅ Pass${NC}"
    ((HEALTH_SCORE++))
else
    echo -e "Email Alerts: ${YELLOW}⚠️  Warning${NC}"
fi

# Check 5: Slack working
if [ -f "$TODAY_LOG" ] && grep -q "Slack notification sent successfully" "$TODAY_LOG"; then
    echo -e "Slack Alerts: ${GREEN}✅ Pass${NC}"
    ((HEALTH_SCORE++))
else
    echo -e "Slack Alerts: ${YELLOW}⚠️  Warning${NC}"
fi

echo ""
echo -e "Overall Health: ${GREEN}$HEALTH_SCORE/$MAX_SCORE${NC}"

# Health bar
echo -n "Health Bar: ["
for i in $(seq 1 $MAX_SCORE); do
    if [ $i -le $HEALTH_SCORE ]; then
        echo -n "█"
    else
        echo -n "░"
    fi
done
echo "]"

echo ""
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Last updated: $(date)"
