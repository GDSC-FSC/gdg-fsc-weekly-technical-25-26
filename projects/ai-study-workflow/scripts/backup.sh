#!/bin/bash

# Backup Script - Backup n8n database and workflows

# Source common utilities
source "$(dirname "$0")/common.sh"

echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              n8n Database Backup Tool                      ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Load environment variables
load_env || {
    log_error ".env file not found!"
    exit 1
}

# Ensure backup directory exists
ensure_backup_dir

# Generate backup filename with timestamp
TIMESTAMP=$(get_timestamp)
BACKUP_FILE="$BACKUP_DIR/n8n_backup_$TIMESTAMP.sql"

log_info "Creating database backup..."
echo "Project: $PROJECT_ID"
echo "Instance: n8n-db"
echo "Database: n8n"
echo ""

# Check if Cloud SQL instance exists
if ! check_sql_instance "n8n-db"; then
    log_error "Cloud SQL instance 'n8n-db' not found"
    exit 1
fi

# Option 1: Using gcloud sql export (requires Cloud Storage bucket)
if confirm "Do you have a Cloud Storage bucket for backups?"; then
    BUCKET_NAME=$(prompt_input "Enter bucket name (e.g., gs://my-backup-bucket)")
    
    EXPORT_FILE="$BUCKET_NAME/n8n_backup_$TIMESTAMP.sql"
    
    log_info "Exporting database to Cloud Storage..."
    gcloud sql export sql n8n-db "$EXPORT_FILE" \
        --database=n8n \
        --project=$PROJECT_ID
    
    log_success "Database exported to: $EXPORT_FILE"
    
    # Download to local
    if confirm "Download backup to local machine?"; then
        gsutil cp "$EXPORT_FILE" "$BACKUP_FILE"
        gzip "$BACKUP_FILE"
        log_success "Backup downloaded to: ${BACKUP_FILE}.gz"
    fi
else
    # Option 2: Manual backup instructions
    log_warning "Manual Backup Instructions:"
    echo ""
    echo "1. Install Cloud SQL Proxy:"
    echo "   https://cloud.google.com/sql/docs/postgres/connect-admin-proxy"
    echo ""
    echo "2. Start the proxy:"
    echo "   cloud-sql-proxy $PROJECT_ID:$REGION:n8n-db"
    echo ""
    echo "3. In another terminal, run:"
    echo "   PGPASSWORD='<password>' pg_dump -h 127.0.0.1 -U n8n-user n8n > $BACKUP_FILE"
    echo ""
    echo "4. Compress the backup:"
    echo "   gzip $BACKUP_FILE"
    echo ""
fi

# Backup workflows via API (if n8n is accessible)
if [ ! -z "$N8N_URL" ]; then
    echo ""
    if confirm "Do you want to backup workflows via n8n API? (requires API key)"; then
        N8N_API_KEY=$(prompt_input "Enter your n8n API key")
        
        WORKFLOWS_BACKUP="$BACKUP_DIR/workflows_$TIMESTAMP.json"
        
        log_info "Fetching workflows from n8n..."
        if curl -X GET "$N8N_URL/api/v1/workflows" \
            -H "X-N8N-API-KEY: $N8N_API_KEY" \
            -H "Accept: application/json" \
            -o "$WORKFLOWS_BACKUP"; then
            log_success "Workflows backed up to: $WORKFLOWS_BACKUP"
        else
            log_error "Failed to backup workflows"
        fi
    fi
fi

echo ""
log_success "Backup process complete!"
echo ""
echo "Backup location: $BACKUP_DIR"
echo ""
log_warning "Remember to:"
echo "  - Store backups in a secure location"
echo "  - Keep multiple versions"
echo "  - Test restoration periodically"
echo "  - Consider automated backup schedules"
