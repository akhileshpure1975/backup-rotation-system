#!/bin/bash
# Encryption Utility Module

check_gpg() {
    if ! command -v gpg &> /dev/null; then
        log_error "GPG not installed"
        return 1
    fi
    return 0
}

encrypt_backup() {
    local file="$1"
    
    if ! check_gpg; then
        return 1
    fi
    
    log_info "Encrypting: $(basename "$file")"
    
    if [[ -n "${GPG_RECIPIENT:-}" ]]; then
        gpg --batch --yes --quiet --recipient "$GPG_RECIPIENT" --encrypt "$file"
    elif [[ -n "${GPG_PASSPHRASE:-}" ]]; then
        echo "$GPG_PASSPHRASE" | gpg --batch --yes --quiet \
            --passphrase-fd 0 --symmetric --cipher-algo AES256 \
            --output "${file}.gpg" "$file"
    fi
    
    if [[ "${REMOVE_UNENCRYPTED:-true}" == "true" ]]; then
        rm -f "$file"
    fi
}
