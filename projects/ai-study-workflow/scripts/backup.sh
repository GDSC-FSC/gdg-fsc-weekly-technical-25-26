#!/bin/bash

# Backup Script - Backup n8n database and workflows

set -e

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              n8n Database Backup Tool                      ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Load environment variables
if [ -f "$(dirname "$0")/../config/.env" ]; then
    source "$(dirname "$0")/../config/.env"
else
    echo "Error: .env file not found!"
    exit 1
fi

# Create backups directory
BACKUP_DIR="$(dirname "$0")/../backups"
mkdir -p "$BACKUP_DIR"

# Generate backup filename with timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/n8n_backup_$TIMESTAMP.sql"

echo "Creating database backup..."
echo "Project: $PROJECT_ID"
echo "Instance: n8n-db"
echo "Database: n8n"
echo ""

# Export database to Cloud Storage bucket (optional, requires bucket)
# For now, we'll create a local export via Cloud SQL proxy

# Option 1: Using gcloud sql export (requires Cloud Storage bucket)
read -p "Do you have a Cloud Storage bucket for backups? (yes/no): " -r
echo

if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    read -p "Enter bucket name (e.g., gs://my-backup-bucket): " BUCKET_NAME
    
    EXPORT_FILE="$BUCKET_NAME/n8n_backup_$TIMESTAMP.sql"
    
    echo "Exporting database to Cloud Storage..."
    gcloud sql export sql n8n-db "$EXPORT_FILE" \
        --database=n8n \
        --project=$PROJECT_ID
    
    echo -e "${GREEN}✓ Database exported to: $EXPORT_FILE${NC}"
    
    # Download to local
    read -p "Download backup to local machine? (yes/no): " -r
    if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        gsutil cp "$EXPORT_FILE" "$BACKUP_FILE"
        gzip "$BACKUP_FILE"
        echo -e "${GREEN}✓ Backup downloaded to: ${BACKUP_FILE}.gz${NC}"
    fi
else
    # Option 2: Manual backup instructions
    echo -e "${YELLOW}Manual Backup Instructions:${NC}"
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
    read -p "Do you want to backup workflows via n8n API? (requires API key) (yes/no): " -r
    
    if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        read -p "Enter your n8n API key: " N8N_API_KEY
        
        WORKFLOWS_BACKUP="$BACKUP_DIR/workflows_$TIMESTAMP.json"
        
        echo "Fetching workflows from n8n..."
        curl -X GET "$N8N_URL/api/v1/workflows" \
            -H "X-N8N-API-KEY: $N8N_API_KEY" \
            -H "Accept: application/json" \
            -o "$WORKFLOWS_BACKUP"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Workflows backed up to: $WORKFLOWS_BACKUP${NC}"
        else
            echo "Failed to backup workflows"
        fi
    fi
fi

echo ""
echo -e "${GREEN}Backup process complete!${NC}"
echo ""
echo "Backup location: $BACKUP_DIR"
echo ""
echo -e "${YELLOW}Remember to:${NC}"
echo "  - Store backups in a secure location"
echo "  - Keep multiple versions"
echo "  - Test restoration periodically"
echo "  - Consider automated backup schedules"
