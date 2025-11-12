#!/bin/bash

# Step 4: Deploy n8n to Cloud Run

# Source common utilities
source "$(dirname "$0")/common.sh"

log_header "n8n Cloud Run Deployment"

# Load environment variables
load_env || {
    log_error "Failed to load environment variables"
    exit 1
}

# Create service account for n8n
log_step "Creating service account"
export SERVICE_ACCOUNT_EMAIL="n8n-service-account@$PROJECT_ID.iam.gserviceaccount.com"

if check_service_account "$SERVICE_ACCOUNT_EMAIL"; then
    log_info "Using existing service account"
else
    gcloud iam service-accounts create n8n-service-account \
        --display-name="n8n Service Account"
    log_success "Service account created"
fi

# Grant necessary permissions
log_step "Granting permissions to service account"

# Access to secrets
gcloud secrets add-iam-policy-binding n8n-db-password \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/secretmanager.secretAccessor"

gcloud secrets add-iam-policy-binding n8n-encryption-key \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/secretmanager.secretAccessor"

# Cloud SQL client role
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/cloudsql.client"

log_success "Permissions granted"

# Deploy to Cloud Run
log_step "Deploying n8n container to Cloud Run"

DB_CONNECTION_NAME="$PROJECT_ID:$REGION:n8n-db"

# Function to deploy with retries
deploy_cloud_run() {
    local max_attempts=3
    local attempt=1
    local wait_time=30
    
    while [ $attempt -le $max_attempts ]; do
        log_info "Deployment attempt $attempt of $max_attempts..."
        
        if [ $attempt -gt 1 ]; then
            log_warning "Waiting ${wait_time}s for Cloud Run region to fully initialize..."
            sleep $wait_time
        fi
        
        if gcloud run deploy n8n \
            --image=n8nio/n8n:latest \
            --region=$REGION \
            --allow-unauthenticated \
            --port=5678 \
            --memory=2Gi \
            --cpu=1 \
            --no-cpu-throttling \
            --set-env-vars="N8N_PORT=5678,N8N_PROTOCOL=https,DB_TYPE=postgresdb,DB_POSTGRESDB_DATABASE=n8n,DB_POSTGRESDB_USER=n8n-user,DB_POSTGRESDB_HOST=/cloudsql/$DB_CONNECTION_NAME,DB_POSTGRESDB_PORT=5432,DB_POSTGRESDB_SCHEMA=public,GENERIC_TIMEZONE=UTC,QUEUE_HEALTH_CHECK_ACTIVE=true" \
            --set-secrets="DB_POSTGRESDB_PASSWORD=n8n-db-password:latest,N8N_ENCRYPTION_KEY=n8n-encryption-key:latest" \
            --add-cloudsql-instances=$DB_CONNECTION_NAME \
            --service-account=$SERVICE_ACCOUNT_EMAIL 2>&1; then
            return 0
        fi
        
        local exit_code=$?
        
        if [ $attempt -lt $max_attempts ]; then
            log_warning "Deployment failed. This is common on first deployment to a new region."
            wait_time=$((wait_time + 30))  # Increase wait time for next attempt
        else
            log_error "Deployment failed after $max_attempts attempts"
            log_info "This can happen if:"
            log_info "  1. Cloud Run is still initializing the region (wait 5 min and retry)"
            log_info "  2. Billing is not properly enabled"
            log_info "  3. Cloud SQL instance is not ready"
            log_info ""
            log_info "To retry manually, run: ./scripts/04-deploy-n8n.sh"
            return $exit_code
        fi
        
        attempt=$((attempt + 1))
    done
}

deploy_cloud_run || exit 1

log_success "n8n deployed successfully!"

# Get the service URL
SERVICE_URL=$(gcloud run services describe n8n --region=$REGION --format='value(status.url)')

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_success "Deployment Successful!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Your n8n instance is available at:"
echo "  $SERVICE_URL"
echo ""
echo "Save this URL - you'll need it to access your workflows!"
echo ""

# Save URL to .env file
save_env_var "N8N_URL" "$SERVICE_URL"
