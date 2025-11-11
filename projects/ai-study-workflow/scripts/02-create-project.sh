#!/bin/bash

# Step 2: Create GCP Project and Enable APIs

set -e

echo "Creating Google Cloud Project..."

# Generate a unique project ID or use existing one
if [ -z "$PROJECT_ID" ]; then
    export PROJECT_ID="n8n-study-$(head /dev/urandom | tr -dc a-z0-9 | head -c 10)"
    echo "Generated PROJECT_ID: $PROJECT_ID"
else
    echo "Using PROJECT_ID: $PROJECT_ID"
fi

# Check if project already exists
if gcloud projects describe "$PROJECT_ID" &> /dev/null; then
    echo "✓ Project $PROJECT_ID already exists"
else
    # Create a new project
    echo "Creating new project: $PROJECT_ID"
    gcloud projects create "$PROJECT_ID" --name="AI Study Workflow"
    echo "✓ Project created successfully"
fi

# Set the project as default
gcloud config set project "$PROJECT_ID"
echo "✓ Set active project to $PROJECT_ID"

# Prompt for billing account
echo ""
echo "⚠ IMPORTANT: Billing must be enabled for this project"
echo "Opening billing page in browser..."
echo "URL: https://console.cloud.google.com/billing/linkedaccount?project=$PROJECT_ID"
echo ""
read -p "Press Enter after you have linked a billing account..."

# Set region (default to us-central1)
if [ -z "$REGION" ]; then
    export REGION="us-central1"
fi
echo "Using region: $REGION"

# Save environment variables
cat > "$(dirname "$0")/../config/.env" << EOF
# AI Study Workflow - Environment Variables
# Generated on $(date)

PROJECT_ID=$PROJECT_ID
REGION=$REGION

# These will be generated during setup
N8N_DB_PASSWORD=
N8N_ENCRYPTION_KEY=
EOF

echo "✓ Environment variables saved to config/.env"

# Enable required APIs
echo "Enabling required Google Cloud APIs..."
gcloud services enable run.googleapis.com \
    sqladmin.googleapis.com \
    secretmanager.googleapis.com \
    iam.googleapis.com

echo "✓ All required APIs enabled"
echo "✓ GCP project setup complete!"
