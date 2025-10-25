#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../config/backup.conf"
source "${SCRIPT_DIR}/../utils/logger.sh"
source "${SCRIPT_DIR}/../utils/notify.sh"

S3_BUCKET="${S3_BUCKET:-s3://my-backup-bucket}"
S3_PREFIX="${S3_PREFIX:-backups/}"

log_info "========================================"
log_info "S3 Sync Started"
log_info "========================================"

if ! command -v aws &> /dev/null; then
    log_error "AWS CLI not installed. Install with: sudo apt-get install awscli"
    exit 1
fi

log_info "Syncing to S3 bucket: $S3_BUCKET"

aws s3 sync "$BACKUP_DIR" "${S3_BUCKET}/${S3_PREFIX}" \
    --storage-class STANDARD_IA \
    --exclude "*.tmp" \
    --exclude "temp_*" \
    2>&1 | tee -a "$LOG_FILE"

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    log_info "S3 sync completed successfully"
    send_notification "SUCCESS" "Backups synced to S3: ${S3_BUCKET}"
else
    log_error "S3 sync failed"
    send_notification "FAILURE" "S3 sync failed!"
    exit 1
fi

log_info "========================================"
log_info "S3 Sync Completed"
log_info "========================================"
