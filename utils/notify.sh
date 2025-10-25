#!/bin/bash
#############################################################################
# Notification Utility Module
# Handles email and Slack notifications
#############################################################################

# Send email notification
send_email() {
    local subject="$1"
    local body="$2"
    
    if [[ "${ENABLE_EMAIL:-false}" != "true" ]]; then
        return 0
    fi
    
    if [[ -z "${EMAIL_TO:-}" ]]; then
        log_warning "Email recipient not configured"
        return 1
    fi
    
    log_info "Sending email to: $EMAIL_TO"
    
    # Try different mail commands
    if command -v mail &> /dev/null; then
        echo "$body" | mail -s "$subject" "$EMAIL_TO"
    elif command -v mailx &> /dev/null; then
        echo "$body" | mailx -s "$subject" "$EMAIL_TO"
    elif command -v sendmail &> /dev/null; then
        {
            echo "To: $EMAIL_TO"
            echo "Subject: $subject"
            echo ""
            echo "$body"
        } | sendmail -t
    else
        log_error "No mail command available"
        return 1
    fi
    
    return 0
}

# Send Slack notification
send_slack() {
    local status="$1"
    local message="$2"
    
    if [[ "${ENABLE_SLACK:-false}" != "true" ]]; then
        return 0
    fi
    
    if [[ -z "${SLACK_WEBHOOK_URL:-}" ]]; then
        log_warning "Slack webhook URL not configured"
        return 1
    fi
    
    log_info "Sending Slack notification..."
    
    # Determine color
    local color="good"
    if [[ "$status" == "FAILURE" ]] || [[ "$status" == "ERROR" ]]; then
        color="danger"
    elif [[ "$status" == "WARNING" ]]; then
        color="warning"
    fi
    
    local hostname=$(hostname)
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    local payload=$(cat <<PAYLOAD
{
    "attachments": [
        {
            "title": "Backup System Notification",
            "color": "$color",
            "fields": [
                {
                    "title": "Status",
                    "value": "$status",
                    "short": true
                },
                {
                    "title": "Host",
                    "value": "$hostname",
                    "short": true
                },
                {
                    "title": "Message",
                    "value": "$message",
                    "short": false
                },
                {
                    "title": "Timestamp",
                    "value": "$timestamp",
                    "short": true
                }
            ]
        }
    ]
}
PAYLOAD
    )
    
    # Send to Slack
    if curl -X POST -H 'Content-type: application/json' \
        --data "$payload" \
        "$SLACK_WEBHOOK_URL" \
        --silent --show-error --fail > /dev/null; then
        log_info "Slack notification sent successfully"
        return 0
    else
        log_error "Failed to send Slack notification"
        return 1
    fi
}

# Main notification function
send_notification() {
    local status="$1"
    local message="$2"
    
    local subject="[Backup System] $status - $(hostname)"
    
    local body=$(cat <<BODY
Backup System Notification
==========================

Status: $status
Host: $(hostname)
Timestamp: $(date)

Message:
$message

Log File: $LOG_FILE
BODY
    )
    
    # Send notifications
    send_email "$subject" "$body"
    send_slack "$status" "$message"
}
