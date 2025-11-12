#!/bin/bash

# Step 1: Install and Configure gcloud CLI

# Source common utilities
source "$(dirname "$0")/common.sh"

log_header "gcloud CLI Setup"

# Check if gcloud is already installed
if check_command gcloud "gcloud CLI"; then
    gcloud version
else
    log_info "Installing gcloud CLI..."
    
    # Install gcloud CLI
    curl https://sdk.cloud.google.com | bash
    exec -l $SHELL
    
    log_success "gcloud CLI installed successfully"
fi

# Check if user is already authenticated
if check_gcloud_auth; then
    ACTIVE_ACCOUNT=$(gcloud auth list --filter=status:ACTIVE --format="value(account)")
    if confirm "Do you want to use this account ($ACTIVE_ACCOUNT)?" "yes"; then
        log_success "Using existing authentication"
    else
        log_info "Logging in to Google Cloud..."
        gcloud auth login
    fi
else
    # Authenticate with Google Cloud
    log_info "Logging in to Google Cloud..."
    gcloud auth login
fi

log_success "gcloud CLI setup complete!"
