#!/bin/bash

# Cleanup Script - Remove all Google Cloud Resources

# Source common utilities
source "$(dirname "$0")/common.sh"

echo -e "${RED}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║          ⚠️  RESOURCE CLEANUP WARNING ⚠️                   ║${NC}"
echo -e "${RED}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
log_warning "This script will DELETE the following resources:"
echo "  - Cloud Run service (n8n)"
echo "  - Cloud SQL database (n8n-db)"
echo "  - Secret Manager secrets"
echo "  - Service accounts"
echo "  - Optionally: The entire GCP project"
echo ""
log_error "THIS ACTION CANNOT BE UNDONE!"
echo ""

# Load environment variables
load_env || {
    log_warning "No .env file found. Using current gcloud project."
    PROJECT_ID=$(gcloud config get-value project)
    REGION="us-central1"
}

echo "Project ID: $PROJECT_ID"
echo "Region: $REGION"
echo ""

if ! confirm "Are you sure you want to continue?" "no"; then
    echo "Cleanup cancelled."
    exit 0
fi

log_step "Starting cleanup..."

# Set project
gcloud config set project "$PROJECT_ID"

# Delete Cloud Run service
log_info "Deleting Cloud Run service..."
if check_cloud_run_service "n8n" "$REGION"; then
    gcloud run services delete n8n --region=$REGION --quiet
    log_success "Cloud Run service deleted"
else
    log_info "Cloud Run service not found (already deleted)"
fi

# Delete Cloud SQL instance
log_info "Deleting Cloud SQL database..."
if check_sql_instance "n8n-db"; then
    gcloud sql instances delete n8n-db --quiet
    log_success "Cloud SQL instance deleted"
else
    log_info "Cloud SQL instance not found (already deleted)"
fi

# Delete secrets
log_info "Deleting secrets..."
for secret in "n8n-db-password" "n8n-encryption-key"; do
    if check_secret "$secret"; then
        gcloud secrets delete "$secret" --quiet
        log_success "Secret '$secret' deleted"
    fi
done

# Delete service account
log_info "Deleting service account..."
SERVICE_ACCOUNT_EMAIL="n8n-service-account@$PROJECT_ID.iam.gserviceaccount.com"
if check_service_account "$SERVICE_ACCOUNT_EMAIL"; then
    gcloud iam service-accounts delete $SERVICE_ACCOUNT_EMAIL --quiet
    log_success "Service account deleted"
else
    log_info "Service account not found (already deleted)"
fi

echo ""
log_success "Resource cleanup complete!"
echo ""

# Ask about deleting the project
if confirm "Do you want to delete the entire project?" "no"; then
    log_info "Deleting project $PROJECT_ID..."
    gcloud projects delete "$PROJECT_ID" --quiet
    log_success "Project deleted"
else
    log_info "Project kept. You can delete it later from the GCP Console."
fi

echo ""
log_success "Cleanup finished!"
echo ""
log_info "Note: It may take a few minutes for all resources to be fully removed."
