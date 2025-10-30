#!/bin/bash
#############################################################################
# Advanced Backup Script
# Combines: Backup + Encryption + Database + Cloud Sync
#############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../config/backup.conf"
source "${SCRIPT_DIR}/../utils/logger.sh"
source "${SCRIPT_DIR}/../utils/notify.sh"

log_info "========================================"
log_info "Advanced Backup Process Started"
log_info "========================================"

# Step 1: Regular file backup
log_info "Step 1/4: Running file backup..."
"${SCRIPT_DIR}/backup.sh"

# Step 2: Database backup (if enabled)
if [ "${ENABLE_MYSQL_BACKUP:-false}" == "true" ] || [ "${ENABLE_POSTGRESQL_BACKUP:-false}" == "true" ]; then
    log_info "Step 2/4: Running database backup..."
    "${SCRIPT_DIR}/backup_databases.sh"
else
    log_info "Step 2/4: Database backup skipped (not enabled)"
fi

# Step 3: Cloud sync (if enabled)
if [ "${ENABLE_S3_SYNC:-false}" == "true" ]; then
    log_info "Step 3/4: Syncing to S3..."
    "${SCRIPT_DIR}/sync_to_s3.sh"
elif [ "${ENABLE_GDRIVE_SYNC:-false}" == "true" ]; then
    log_info "Step 3/4: Syncing to Google Drive..."
    "${SCRIPT_DIR}/sync_to_gdrive.sh"
else
    log_info "Step 3/4: Cloud sync skipped (not enabled)"
fi

# Step 4: Verification
log_info "Step 4/4: Verifying backups..."
"${SCRIPT_DIR}/verify.sh"

log_info "========================================"
log_info "Advanced Backup Process Completed"
log_info "========================================"

send_notification "SUCCESS" "Advanced backup completed: Files + Databases + Cloud Sync"
