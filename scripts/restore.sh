#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/../config/backup.conf"
[[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"

usage() {
    echo "Usage: $0 [OPTIONS] <backup_file> <destination>"
    echo "Options:"
    echo "  -h, --help    Show help"
    echo "  -l, --list    List backups"
    exit 0
}

list_backups() {
    echo "Available backups:"
    echo "=================="
    find "$BACKUP_DIR" -name "backup_*.tar.gz*" | sort -r | while read -r backup; do
        echo "$(basename "$backup") - $(du -h "$backup" | cut -f1)"
    done
}

restore_backup() {
    local file="$1"
    local dest="$2"
    
    [[ ! -f "$file" ]] && echo "Error: File not found" && exit 1
    
    echo "Restoring to: $dest"
    mkdir -p "$dest"
    tar -xzf "$file" -C "$dest" --verbose
    echo "Restore completed"
}

main() {
    case "${1:-}" in
        -h|--help) usage ;;
        -l|--list) list_backups; exit 0 ;;
        *) [[ $# -lt 2 ]] && usage || restore_backup "$1" "$2" ;;
    esac
}

main "$@"
