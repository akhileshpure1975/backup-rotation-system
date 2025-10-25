#!/bin/bash

backup_mysql() {
    local db_name="$1"
    local db_user="${2:-root}"
    local db_pass="${3:-}"
    local output_file="$4"
    
    log_info "Backing up MySQL database: $db_name"
    
    if [ -n "$db_pass" ]; then
        mysqldump -u"$db_user" -p"$db_pass" \
            --single-transaction \
            --routines --triggers --events \
            "$db_name" | gzip > "$output_file"
    else
        mysqldump -u"$db_user" \
            --single-transaction \
            --routines --triggers --events \
            "$db_name" | gzip > "$output_file"
    fi
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        log_info "MySQL backup completed: $output_file"
        return 0
    else
        log_error "MySQL backup failed"
        return 1
    fi
}

backup_postgresql() {
    local db_name="$1"
    local db_user="${2:-postgres}"
    local output_file="$3"
    
    log_info "Backing up PostgreSQL database: $db_name"
    
    pg_dump -U "$db_user" \
        --format=custom \
        --compress=9 \
        --file="$output_file" \
        "$db_name"
    
    if [ $? -eq 0 ]; then
        log_info "PostgreSQL backup completed: $output_file"
        return 0
    else
        log_error "PostgreSQL backup failed"
        return 1
    fi
}

backup_all_mysql() {
    local db_user="${1:-root}"
    local db_pass="${2:-}"
    local output_dir="$3"
    
    log_info "Backing up all MySQL databases..."
    
    if [ -n "$db_pass" ]; then
        databases=$(mysql -u"$db_user" -p"$db_pass" -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema|mysql|sys)")
    else
        databases=$(mysql -u"$db_user" -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema|mysql|sys)")
    fi
    
    for db in $databases; do
        output_file="$output_dir/mysql_${db}_$(date +%Y%m%d_%H%M%S).sql.gz"
        backup_mysql "$db" "$db_user" "$db_pass" "$output_file"
    done
}
