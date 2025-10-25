#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../config/backup.conf"
source "${SCRIPT_DIR}/../utils/logger.sh"
source "${SCRIPT_DIR}/../utils/notify.sh"
source "${SCRIPT_DIR}/../utils/database.sh"

DB_BACKUP_DIR="${BACKUP_DIR}/databases"
mkdir -p "$DB_BACKUP_DIR"

log_info "========================================"
log_info "Database Backup Started"
log_info "========================================"

# MySQL Backups
if [ "${ENABLE_MYSQL_BACKUP:-false}" == "true" ]; then
    log_info "Starting MySQL backups..."
    
    if [ ${#MYSQL_DATABASES[@]} -gt 0 ]; then
        for db in "${MYSQL_DATABASES[@]}"; do
            output_file="$DB_BACKUP_DIR/mysql_${db}_$(date +%Y%m%d_%H%M%S).sql.gz"
            backup_mysql "$db" "${MYSQL_USER:-root}" "${MYSQL_PASSWORD:-}" "$output_file"
        done
    else
        backup_all_mysql "${MYSQL_USER:-root}" "${MYSQL_PASSWORD:-}" "$DB_BACKUP_DIR"
    fi
fi

# PostgreSQL Backups
if [ "${ENABLE_POSTGRESQL_BACKUP:-false}" == "true" ]; then
    log_info "Starting PostgreSQL backups..."
    
    if [ ${#POSTGRESQL_DATABASES[@]} -gt 0 ]; then
        for db in "${POSTGRESQL_DATABASES[@]}"; do
            output_file="$DB_BACKUP_DIR/postgresql_${db}_$(date +%Y%m%d_%H%M%S).dump"
            backup_postgresql "$db" "${POSTGRESQL_USER:-postgres}" "$output_file"
        done
    fi
fi

# Cleanup old database backups
log_info "Cleaning up old database backups..."
find "$DB_BACKUP_DIR" -name "*.sql.gz" -mtime "+${DB_RETENTION_DAYS:-30}" -delete
find "$DB_BACKUP_DIR" -name "*.dump" -mtime "+${DB_RETENTION_DAYS:-30}" -delete

log_info "========================================"
log_info "Database Backup Completed"
log_info "========================================"

send_notification "SUCCESS" "Database backups completed"
