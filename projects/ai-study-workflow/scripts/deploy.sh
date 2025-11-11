#!/bin/bash

# AI Study Workflow - Complete Deployment Script
# This script orchestrates the complete deployment of n8n on Google Cloud Run

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   AI Study Workflow - n8n Cloud Run Deployment            ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if we're in the right directory
if [ ! -f "$SCRIPT_DIR/01-setup-gcloud.sh" ]; then
    echo -e "${RED}Error: Deployment scripts not found!${NC}"
    echo "Please run this script from the ai-study-workflow directory"
    exit 1
fi

# Function to display step
step() {
    echo ""
    echo -e "${YELLOW}▶ $1${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Function to display success
success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Function to display error
error() {
    echo -e "${RED}✗ $1${NC}"
}

# Step 1: Setup gcloud CLI
step "Step 1/4: Setting up gcloud CLI"
bash "$SCRIPT_DIR/01-setup-gcloud.sh"
if [ $? -eq 0 ]; then
    success "gcloud CLI setup completed"
else
    error "gcloud CLI setup failed"
    exit 1
fi

# Step 2: Create GCP project
step "Step 2/4: Creating GCP project and enabling APIs"
bash "$SCRIPT_DIR/02-create-project.sh"
if [ $? -eq 0 ]; then
    success "GCP project created successfully"
else
    error "GCP project creation failed"
    exit 1
fi

# Load environment variables
if [ -f "$SCRIPT_DIR/../config/.env" ]; then
    source "$SCRIPT_DIR/../config/.env"
else
    echo -e "${YELLOW}Note: .env file not found. Using defaults.${NC}"
fi

# Step 3: Setup database and secrets
step "Step 3/4: Setting up Cloud SQL database and secrets"
bash "$SCRIPT_DIR/03-setup-database.sh"
if [ $? -eq 0 ]; then
    success "Database and secrets configured"
else
    error "Database setup failed"
    exit 1
fi

# Step 4: Deploy n8n to Cloud Run
step "Step 4/4: Deploying n8n to Cloud Run"
bash "$SCRIPT_DIR/04-deploy-n8n.sh"
if [ $? -eq 0 ]; then
    success "n8n deployed successfully!"
else
    error "n8n deployment failed"
    exit 1
fi

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
