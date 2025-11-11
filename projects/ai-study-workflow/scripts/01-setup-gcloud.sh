#!/bin/bash

# Step 1: Install and Configure gcloud CLI

set -e

echo "Setting up gcloud CLI..."

# Check if gcloud is already installed
if command -v gcloud &> /dev/null; then
    echo "✓ gcloud CLI is already installed"
    gcloud version
else
    echo "Installing gcloud CLI..."
    
    # Install gcloud CLI
    curl https://sdk.cloud.google.com | bash
    exec -l $SHELL
    
    echo "✓ gcloud CLI installed successfully"
fi

# Check if user is already authenticated
if gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
    ACTIVE_ACCOUNT=$(gcloud auth list --filter=status:ACTIVE --format="value(account)")
    if [ -n "$ACTIVE_ACCOUNT" ]; then
        echo "✓ Already authenticated as: $ACTIVE_ACCOUNT"
        read -p "Do you want to use this account? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            gcloud auth login
        fi
    else
        gcloud auth login
    fi
else
    # Authenticate with Google Cloud
    echo "Logging in to Google Cloud..."
    gcloud auth login
fi

echo "✓ gcloud CLI setup complete!"
