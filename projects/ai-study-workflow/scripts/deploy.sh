#!/bin/bash

# AI Study Workflow - Complete Deployment Script
# This script orchestrates the complete deployment of n8n on Google Cloud Run

# Source common utilities
source "$(dirname "$0")/common.sh"

echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   AI Study Workflow - n8n Cloud Run Deployment            ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Pre-flight checks
log_header "Pre-Deployment Checks"

# Check if gcloud is installed
if ! check_command gcloud; then
    log_error "gcloud CLI not found. Please run Step 1 first or install manually."
    log_info "Installation: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Check if user is authenticated
if ! check_gcloud_auth; then
    log_error "Not authenticated with gcloud. Please run Step 1 first."
    log_info "Or run: gcloud auth login"
    exit 1
fi

# Check if Docker is needed for local development
if [ "$1" == "--local" ]; then
    if ! check_command docker; then
        log_error "Docker is required for local development"
        log_info "Installation: https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    if ! check_command docker-compose; then
        log_error "Docker Compose is required for local development"
        log_info "Installation: https://docs.docker.com/compose/install/"
        exit 1
    fi
fi

log_success "Pre-deployment checks passed"
echo ""

# Function to run step with error handling
run_step() {
    local step_num="$1"
    local step_name="$2"
    local script="$3"
    
    log_step "Step $step_num/4: $step_name"
    
    if bash "$SCRIPT_DIR/$script"; then
        log_success "$step_name completed"
        return 0
    else
        log_error "$step_name failed"
        return 1
    fi
}

# Step 1: Setup gcloud CLI
run_step 1 "Setting up gcloud CLI" "01-setup-gcloud.sh" || exit 1

# Step 2: Create GCP project
run_step 2 "Creating GCP project and enabling APIs" "02-create-project.sh" || exit 1

# Load environment variables
load_env

# Step 3: Setup database and secrets
run_step 3 "Setting up Cloud SQL database and secrets" "03-setup-database.sh" || exit 1

# Step 4: Deploy n8n to Cloud Run
run_step 4 "Deploying n8n to Cloud Run" "04-deploy-n8n.sh" || exit 1

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              🎉 Deployment Complete! 🎉                    ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Your n8n instance is now running on Google Cloud Run!"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Access your n8n instance using the URL provided above"
echo "2. Create an owner account when prompted"
echo "3. Add your Gemini API key in Credentials"
echo "4. Import workflow templates from the workflows/ directory"
echo ""
echo -e "${YELLOW}Important Commands:${NC}"
echo "  View logs:    gcloud run logs read n8n --region=\$REGION"
echo "  Get URL:      gcloud run services describe n8n --region=\$REGION --format='value(status.url)'"
echo "  Cleanup:      ./scripts/cleanup.sh"
echo ""
echo -e "${GREEN}Happy automating! 🚀${NC}"
