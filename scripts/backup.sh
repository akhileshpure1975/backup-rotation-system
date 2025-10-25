#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/../config/backup.conf"

if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
else
    echo "[ERROR] Config not found: $CONFIG_FILE"
    exit 1
fi

source "${SCRIPT_DIR}/../utils/logger.sh"
source "${SCRIPT_DIR}/../utils/notify.sh"
source "${SCRIPT_DIR}/../utils/encryption.sh"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_NAME="backup_${TIMESTAMP}.tar.gz"

init_backup() {
    log_info "Starting backup process..."
    mkdir -p "$BACKUP_DIR" "$LOG_DIR" "$SNAPSHOT_DIR"
}

perform_backup() {
    log_info "Creating: $BACKUP_NAME"
    local backup_path="${BACKUP_DIR}/${BACKUP_NAME}"
    local exclude_opts=""
    
    for pattern in "${EXCLUDE_PATTERNS[@]:-}"; do
        exclude_opts+="--exclude=$pattern "
    done
    
    tar -czf "$backup_path" $exclude_opts "${SOURCE_DIRS[@]}" 2>&1 | tee -a "$LOG_FILE"
    
    if [[ ${PIPESTATUS[0]} -eq 0 ]] || [[ ${PIPESTATUS[0]} -eq 1 ]]; then
        log_info "Backup created: $(du -h "$backup_path" | cut -f1)"
        sha256sum "$backup_path" > "${backup_path}.sha256"
        
        if [[ "${ENABLE_ENCRYPTION:-false}" == "true" ]]; then
            encrypt_backup "$backup_path"
        fi
        return 0
    else
        log_error "Backup failed"
        return 1
    fi
}

rotate_backups() {
    log_info "Rotating backups (retention: ${RETENTION_DAYS} days)"
    local count=0
    while IFS= read -r old_backup; do
        log_info "Deleting: $(basename "$old_backup")"
        rm -f "$old_backup" "${old_backup}.sha256" "${old_backup}.gpg"
        ((count++))
    done < <(find "$BACKUP_DIR" -name "backup_*.tar.gz" -mtime "+${RETENTION_DAYS}")
    log_info "Deleted $count old backup(s)"
}

main() {
    log_info "========================================"
    log_info "Backup Started"
    log_info "========================================"
    
    init_backup
    
    if perform_backup; then
        rotate_backups
        send_notification "SUCCESS" "Backup completed at $TIMESTAMP"
        log_info "Backup completed successfully"
    else
        send_notification "FAILURE" "Backup failed at $TIMESTAMP"
        log_error "Backup failed"
        exit 1
    fi
}

main "$@"
