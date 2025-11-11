#!/bin/bash

# Cleanup Script - Remove all Google Cloud Resources

set -e

# Color codes
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${RED}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║          ⚠️  RESOURCE CLEANUP WARNING ⚠️                   ║${NC}"
echo -e "${RED}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}This script will DELETE the following resources:${NC}"
echo "  - Cloud Run service (n8n)"
echo "  - Cloud SQL database (n8n-db)"
echo "  - Secret Manager secrets"
echo "  - Service accounts"
echo "  - Optionally: The entire GCP project"
echo ""
echo -e "${RED}THIS ACTION CANNOT BE UNDONE!${NC}"
echo ""

# Load environment variables
if [ -f "$(dirname "$0")/../config/.env" ]; then
    source "$(dirname "$0")/../config/.env"
else
    echo -e "${YELLOW}No .env file found. Using current gcloud project.${NC}"
    PROJECT_ID=$(gcloud config get-value project)
    REGION="us-central1"
fi

echo "Project ID: $PROJECT_ID"
echo "Region: $REGION"
echo ""

read -p "Are you sure you want to continue? (yes/no): " -r
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Cleanup cancelled."
    exit 0
fi

echo ""
echo -e "${YELLOW}Starting cleanup...${NC}"

# Set project
gcloud config set project "$PROJECT_ID"

# Delete Cloud Run service
echo "Deleting Cloud Run service..."
if gcloud run services describe n8n --region=$REGION &> /dev/null; then
    gcloud run services delete n8n --region=$REGION --quiet
    echo "✓ Cloud Run service deleted"
else
    echo "Cloud Run service not found (already deleted)"
fi

# Delete Cloud SQL instance
echo "Deleting Cloud SQL database..."
if gcloud sql instances describe n8n-db &> /dev/null; then
    gcloud sql instances delete n8n-db --quiet
    echo "✓ Cloud SQL instance deleted"
else
    echo "Cloud SQL instance not found (already deleted)"
fi

# Delete secrets
echo "Deleting secrets..."
if gcloud secrets describe n8n-db-password &> /dev/null; then
    gcloud secrets delete n8n-db-password --quiet
    echo "✓ Database password secret deleted"
fi

if gcloud secrets describe n8n-encryption-key &> /dev/null; then
    gcloud secrets delete n8n-encryption-key --quiet
    echo "✓ Encryption key secret deleted"
fi

# Delete service account
echo "Deleting service account..."
SERVICE_ACCOUNT_EMAIL="n8n-service-account@$PROJECT_ID.iam.gserviceaccount.com"
if gcloud iam service-accounts describe $SERVICE_ACCOUNT_EMAIL &> /dev/null; then
    gcloud iam service-accounts delete $SERVICE_ACCOUNT_EMAIL --quiet
    echo "✓ Service account deleted"
else
    echo "Service account not found (already deleted)"
fi

echo ""
echo -e "${GREEN}✓ Resource cleanup complete!${NC}"
echo ""

# Ask about deleting the project
read -p "Do you want to delete the entire project? (yes/no): " -r
if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Deleting project $PROJECT_ID..."
    gcloud projects delete "$PROJECT_ID" --quiet
    echo -e "${GREEN}✓ Project deleted${NC}"
else
    echo "Project kept. You can delete it later from the GCP Console."
fi

echo ""
echo -e "${GREEN}Cleanup finished!${NC}"
echo ""
echo "Note: It may take a few minutes for all resources to be fully removed."
