#!/bin/bash

# Step 3: Setup Database and Secrets

# Source common utilities
source "$(dirname "$0")/common.sh"

log_header "Cloud SQL Database and Secrets Setup"

# Load environment variables
load_env || {
    log_error "Failed to load environment variables"
    exit 1
}

# Generate secure credentials
log_info "Generating secure credentials..."
export N8N_DB_PASSWORD=$(generate_secure_password 16)
export N8N_ENCRYPTION_KEY=$(generate_secure_password 42)
log_success "Credentials generated"

# Create Cloud SQL instance
log_step "Creating Cloud SQL PostgreSQL instance"
log_warning "This may take 10-15 minutes..."

if check_sql_instance "n8n-db"; then
    log_info "Using existing Cloud SQL instance"
else
    gcloud sql instances create n8n-db \
        --database-version=POSTGRES_13 \
        --tier=db-f1-micro \
        --region=$REGION \
        --root-password=$N8N_DB_PASSWORD \
        --storage-size=10GB \
        --no-backup \
        --storage-type=HDD
    
    log_success "Cloud SQL instance created"
fi

# Create database
log_info "Creating database..."
if gcloud sql databases describe n8n --instance=n8n-db &> /dev/null; then
    log_info "Database 'n8n' already exists"
else
    gcloud sql databases create n8n --instance=n8n-db
    log_success "Database created"
fi

# Create database user
log_info "Creating database user..."
if gcloud sql users list --instance=n8n-db | grep -q "n8n-user"; then
    log_info "User 'n8n-user' already exists, updating password..."
    gcloud sql users set-password n8n-user \
        --instance=n8n-db \
        --password=$N8N_DB_PASSWORD
else
    gcloud sql users create n8n-user \
        --instance=n8n-db \
        --password=$N8N_DB_PASSWORD
    log_success "Database user created"
fi

# Store secrets in Secret Manager
log_step "Storing secrets in Secret Manager"

# Store database password
if check_secret "n8n-db-password"; then
    log_info "Updating secret 'n8n-db-password'..."
    echo $N8N_DB_PASSWORD | gcloud secrets versions add n8n-db-password --data-file=-
else
    echo $N8N_DB_PASSWORD | gcloud secrets create n8n-db-password \
        --data-file=- \
        --replication-policy="automatic"
    log_success "Database password stored in Secret Manager"
fi

# Store encryption key
if check_secret "n8n-encryption-key"; then
    log_info "Updating secret 'n8n-encryption-key'..."
    echo $N8N_ENCRYPTION_KEY | gcloud secrets versions add n8n-encryption-key --data-file=-
else
    echo $N8N_ENCRYPTION_KEY | gcloud secrets create n8n-encryption-key \
        --data-file=- \
        --replication-policy="automatic"
    log_success "Encryption key stored in Secret Manager"
fi

# Update .env file with generated credentials
save_env_var "N8N_DB_PASSWORD" "$N8N_DB_PASSWORD"
save_env_var "N8N_ENCRYPTION_KEY" "$N8N_ENCRYPTION_KEY"

log_success "Database and secrets setup complete!"
echo ""
echo "Database connection details:"
echo "  Instance: n8n-db"
echo "  Database: n8n"
echo "  User: n8n-user"
echo "  Region: $REGION"
