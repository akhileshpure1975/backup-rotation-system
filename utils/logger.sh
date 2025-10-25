#!/bin/bash
# Logger Utility Module

COLOR_RESET="\033[0m"
COLOR_INFO="\033[0;32m"
COLOR_WARNING="\033[0;33m"
COLOR_ERROR="\033[0;31m"

get_timestamp() {
    date +"%Y-%m-%d %H:%M:%S"
}

log_message() {
    local level="$1"
    local message="$2"
    local color="$3"
    local timestamp=$(get_timestamp)
    local log_entry="[$timestamp] [$level] $message"
    echo "$log_entry" >> "$LOG_FILE"
    echo -e "${color}${log_entry}${COLOR_RESET}"
}

log_info() {
    log_message "INFO" "$1" "$COLOR_INFO"
}

log_warning() {
    log_message "WARNING" "$1" "$COLOR_WARNING"
}

log_error() {
    log_message "ERROR" "$1" "$COLOR_ERROR" >&2
}
