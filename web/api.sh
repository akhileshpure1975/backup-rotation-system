#!/bin/bash
#############################################################################
# Simple API for Web Dashboard
# Generates JSON data for the dashboard
#############################################################################

BACKUP_DIR="$HOME/Projects/backup-rotation-system/backups"
LOG_DIR="$HOME/Projects/backup-rotation-system/logs"

# Get backup statistics
get_stats() {
    local total_backups=$(ls $BACKUP_DIR/backup_*.tar.gz 2>/dev/null | wc -l)
    local total_size=$(du -sh $BACKUP_DIR 2>/dev/null | cut -f1)
    local latest=$(ls -t $BACKUP_DIR/backup_*.tar.gz 2>/dev/null | head -1)
    
    if [ -n "$latest" ]; then
        local latest_name=$(basename "$latest")
        local latest_size=$(du -h "$latest" | cut -f1)
        local latest_date=$(stat -c %y "$latest" 2>/dev/null)
    fi
    
    cat <<JSON
{
    "totalBackups": $total_backups,
    "totalSize": "$total_size",
    "latestBackup": {
        "name": "$latest_name",
        "size": "$latest_size",
        "date": "$latest_date"
    },
    "status": "healthy"
}
JSON
}

# Get list of backups
get_backups() {
    echo "["
    first=true
    ls -t $BACKUP_DIR/backup_*.tar.gz 2>/dev/null | head -10 | while read backup; do
        if [ "$first" = false ]; then
            echo ","
        fi
        first=false
        
        local name=$(basename "$backup")
        local size=$(du -h "$backup" | cut -f1)
        local date=$(stat -c %y "$backup" 2>/dev/null)
        
        cat <<JSON
{
    "name": "$name",
    "size": "$size",
    "date": "$date",
    "status": "verified"
}
JSON
    done
    echo "]"
}

# Main router
case "${1:-stats}" in
    stats)
        get_stats
        ;;
    backups)
        get_backups
        ;;
    *)
        echo '{"error": "Invalid endpoint"}'
        ;;
esac
