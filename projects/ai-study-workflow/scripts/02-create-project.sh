#!/bin/bash

# Step 2: Create GCP Project and Enable APIs

# Source common utilities
source "$(dirname "$0")/common.sh"

log_header "GCP Project Creation"

# Generate or use existing project ID
if [ -z "$PROJECT_ID" ]; then
    SUFFIX=$(generate_random_suffix 10)
    export PROJECT_ID="n8n-study-${SUFFIX}"
    log_info "Generated PROJECT_ID: $PROJECT_ID"
else
    log_info "Using PROJECT_ID: $PROJECT_ID"
fi

# Check if project already exists
if validate_project_id "$PROJECT_ID"; then
    log_warning "Project $PROJECT_ID already exists"
else
    # Create a new project
    log_info "Creating new project: $PROJECT_ID"
    gcloud projects create "$PROJECT_ID" --name="AI Study Workflow"
    log_success "Project created successfully"
fi

# Set the project as default
gcloud config set project "$PROJECT_ID"
log_success "Set active project to $PROJECT_ID"

# Verify and enable billing
echo ""
log_warning "IMPORTANT: Billing must be enabled for this project"

# Function to check billing status
check_billing_enabled() {
    # Try to check billing status (requires billing API)
    if gcloud beta billing projects describe "$PROJECT_ID" --format='value(billingEnabled)' 2>/dev/null | grep -q "True"; then
        return 0
    fi
    return 1
}

# Check if billing is already enabled
if check_billing_enabled; then
    log_success "Billing is already enabled for this project"
else
    log_info "Billing needs to be enabled for this project"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  BILLING SETUP REQUIRED"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Please follow these steps:"
    echo "  1. Open this URL in your browser:"
    echo "     https://console.cloud.google.com/billing/linkedaccount?project=$PROJECT_ID"
    echo ""
    echo "  2. Select a billing account from the dropdown"
    echo "  3. Click 'SET ACCOUNT'"
    echo "  4. Wait for the confirmation message"
    echo ""
    echo "Note: Make sure you're logged in as: $(gcloud config get-value account)"
    echo ""
    
    # Wait for user confirmation
    while true; do
        read -p "Have you linked a billing account? (yes/no): " response
        case $response in
            [Yy]* | [Yy][Ee][Ss]* )
                log_info "Verifying billing status..."
                sleep 3  # Give GCP a moment to update
                
                if check_billing_enabled; then
                    log_success "Billing verification successful!"
                    break
                else
                    log_warning "Billing verification failed. Please ensure:"
                    log_info "  - You selected and saved a billing account"
                    log_info "  - You're checking the correct project: $PROJECT_ID"
                    log_info "  - You have billing account admin permissions"
                    echo ""
                    read -p "Try verification again? (yes/no): " retry
                    if [[ ! $retry =~ ^[Yy] ]]; then
                        log_warning "Continuing without billing verification..."
                        log_warning "Deployment may fail if billing is not enabled"
                        break
                    fi
                fi
                ;;
            [Nn]* | [Nn][Oo]* )
                log_info "Please enable billing and run this script again"
                exit 1
                ;;
            * )
                echo "Please answer yes or no."
                ;;
        esac
    done
fi

# Set region (default to us-central1)
if [ -z "$REGION" ]; then
    export REGION="us-central1"
fi
log_info "Using region: $REGION"

# Save environment variables
ensure_config_dir

cat > "$ENV_FILE" << EOF
# AI Study Workflow - Environment Variables
# Generated on $(date)

PROJECT_ID=$PROJECT_ID
REGION=$REGION

# These will be generated during setup
N8N_DB_PASSWORD=
N8N_ENCRYPTION_KEY=
EOF

log_success "Environment variables saved to $ENV_FILE"

# Enable required APIs
log_info "Enabling required Google Cloud APIs..."
gcloud services enable \
    run.googleapis.com \
    sqladmin.googleapis.com \
    secretmanager.googleapis.com \
    iam.googleapis.com

log_success "All required APIs enabled"
log_success "GCP project setup complete!"
