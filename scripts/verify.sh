#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/../config/backup.conf"
[[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"

verify_single() {
    local file="$1"
    echo "Verifying: $(basename "$file")"
    
    [[ ! -f "$file" ]] && echo "  [FAIL] Not found" && return 1
    echo "  Size: $(du -h "$file" | cut -f1)"
    
    if [[ -f "${file}.sha256" ]]; then
        sha256sum -c "${file}.sha256" &>/dev/null && \
            echo "  [PASS] Checksum OK" || \
            (echo "  [FAIL] Checksum failed" && return 1)
    fi
    
    tar -tzf "$file" &>/dev/null && \
        echo "  [PASS] Archive OK" || \
        (echo "  [FAIL] Corrupted" && return 1)
}

verify_all() {
    echo "Verifying all backups"
    local total=0 passed=0 failed=0
    
    while IFS= read -r backup; do
        ((total++))
        echo ""
        verify_single "$backup" && ((passed++)) || ((failed++))
    done < <(find "$BACKUP_DIR" -name "backup_*.tar.gz" -type f)
    
    echo ""
    echo "Total: $total | Passed: $passed | Failed: $failed"
}

[[ $# -eq 0 ]] && verify_all || verify_single "$1"
