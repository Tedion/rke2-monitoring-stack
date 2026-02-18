#!/bin/bash
# Backup Metrics Exporter for Prometheus Pushgateway
# Add this to your existing backup scripts

set -e

BACKUP_TYPE="${1:-database}"  # database or nfs
PROMETHEUS_PUSHGATEWAY="${PROMETHEUS_PUSHGATEWAY:-http://prometheus-pushgateway.monitoring.svc.cluster.local:9091}"
INSTANCE=$(hostname -f)
BACKUP_LOG_DIR="${BACKUP_LOG_DIR:-/var/log/backups}"

# Create log directory if it doesn't exist
mkdir -p "${BACKUP_LOG_DIR}"

# Function to push metrics to Prometheus Pushgateway
push_metric() {
    local metric_name=$1
    local metric_value=$2
    local labels=$3
    
    echo "${metric_name}{${labels}} ${metric_value}" | \
        curl --silent --show-error --data-binary @- \
        "${PROMETHEUS_PUSHGATEWAY}/metrics/job/backup/instance/${INSTANCE}/backup_type/${BACKUP_TYPE}" || true
}

# Function to log backup events
log_backup_event() {
    local level=$1
    local message=$2
    echo "[$(date +%Y-%m-%d\ %H:%M:%S)] [${level}] ${message}" >> "${BACKUP_LOG_DIR}/${BACKUP_TYPE}-backup.log"
}

# Start backup
BACKUP_START_TIME=$(date +%s)
log_backup_event "INFO" "Starting ${BACKUP_TYPE} backup"
push_metric "backup_start_timestamp" "${BACKUP_START_TIME}" "backup_type=\"${BACKUP_TYPE}\""

# Your existing backup logic here
# Example:
# if [ "${BACKUP_TYPE}" == "database" ]; then
#     pg_dump ... > /backup/db_backup.sql
# elif [ "${BACKUP_TYPE}" == "nfs" ]; then
#     tar -czf /backup/nfs_backup.tar.gz /nfs/data
# fi

# Simulate backup (replace with your actual backup commands)
BACKUP_EXIT_CODE=0
# YOUR_BACKUP_COMMAND_HERE || BACKUP_EXIT_CODE=$?

BACKUP_END_TIME=$(date +%s)
BACKUP_DURATION=$((BACKUP_END_TIME - BACKUP_START_TIME))

if [ $BACKUP_EXIT_CODE -eq 0 ]; then
    # Calculate backup size if backup file exists
    BACKUP_FILE="/backup/${BACKUP_TYPE}_backup_$(date +%Y%m%d_%H%M%S)"
    if [ -f "${BACKUP_FILE}" ]; then
        BACKUP_SIZE=$(stat -f%z "${BACKUP_FILE}" 2>/dev/null || stat -c%s "${BACKUP_FILE}" 2>/dev/null || echo "0")
    else
        BACKUP_SIZE=0
    fi
    
    log_backup_event "SUCCESS" "Backup completed successfully in ${BACKUP_DURATION} seconds"
    push_metric "backup_status" "1" "backup_type=\"${BACKUP_TYPE}\",status=\"success\""
    push_metric "backup_last_success_timestamp" "${BACKUP_END_TIME}" "backup_type=\"${BACKUP_TYPE}\""
    push_metric "backup_duration_seconds" "${BACKUP_DURATION}" "backup_type=\"${BACKUP_TYPE}\""
    push_metric "backup_size_bytes" "${BACKUP_SIZE}" "backup_type=\"${BACKUP_TYPE}\""
    
    # Reset failure count on success
    push_metric "backup_failure_count" "0" "backup_type=\"${BACKUP_TYPE}\""
else
    log_backup_event "ERROR" "Backup failed with exit code ${BACKUP_EXIT_CODE}"
    push_metric "backup_status" "0" "backup_type=\"${BACKUP_TYPE}\",status=\"failed\""
    push_metric "backup_failure_count" "1" "backup_type=\"${BACKUP_TYPE}\""
fi

exit $BACKUP_EXIT_CODE
