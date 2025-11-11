#!/bin/bash

# Step 3: Setup Database and Secrets

set -e

echo "Setting up Cloud SQL database and secrets..."

# Load environment variables
if [ -f "$(dirname "$0")/../config/.env" ]; then
    source "$(dirname "$0")/../config/.env"
fi

# Generate secure passwords and encryption keys
echo "Generating secure credentials..."
export N8N_DB_PASSWORD=$(openssl rand -base64 16)
export N8N_ENCRYPTION_KEY=$(openssl rand -base64 42)

echo "✓ Credentials generated"

# Create Cloud SQL instance
echo "Creating Cloud SQL PostgreSQL instance..."
echo "⏳ This may take 10-15 minutes..."

# Check if instance already exists
if gcloud sql instances describe n8n-db --project=$PROJECT_ID &> /dev/null; then
    echo "✓ Cloud SQL instance 'n8n-db' already exists"
else
    gcloud sql instances create n8n-db \
        --database-version=POSTGRES_13 \
        --tier=db-f1-micro \
        --region=$REGION \
        --root-password=$N8N_DB_PASSWORD \
        --storage-size=10GB \
        --no-backup \
        --storage-type=HDD
    
    echo "✓ Cloud SQL instance created"
fi

# Create database
echo "Creating database..."
if gcloud sql databases describe n8n --instance=n8n-db &> /dev/null; then
    echo "✓ Database 'n8n' already exists"
else
    gcloud sql databases create n8n --instance=n8n-db
    echo "✓ Database created"
fi

# Create database user
echo "Creating database user..."
if gcloud sql users list --instance=n8n-db | grep -q "n8n-user"; then
    echo "✓ User 'n8n-user' already exists"
    # Update password for existing user
    gcloud sql users set-password n8n-user \
        --instance=n8n-db \
        --password=$N8N_DB_PASSWORD
else
    gcloud sql users create n8n-user \
        --instance=n8n-db \
        --password=$N8N_DB_PASSWORD
    echo "✓ Database user created"
fi

# Store secrets in Secret Manager
echo "Storing secrets in Secret Manager..."

# Store database password
if gcloud secrets describe n8n-db-password &> /dev/null; then
    echo "✓ Secret 'n8n-db-password' already exists, updating..."
    echo $N8N_DB_PASSWORD | gcloud secrets versions add n8n-db-password --data-file=-
else
    echo $N8N_DB_PASSWORD | gcloud secrets create n8n-db-password \
        --data-file=- \
        --replication-policy="automatic"
    echo "✓ Database password stored in Secret Manager"
fi

# Store encryption key
if gcloud secrets describe n8n-encryption-key &> /dev/null; then
    echo "✓ Secret 'n8n-encryption-key' already exists, updating..."
    echo $N8N_ENCRYPTION_KEY | gcloud secrets versions add n8n-encryption-key --data-file=-
else
    echo $N8N_ENCRYPTION_KEY | gcloud secrets create n8n-encryption-key \
        --data-file=- \
        --replication-policy="automatic"
    echo "✓ Encryption key stored in Secret Manager"
fi

# Update .env file with generated credentials
sed -i "s|N8N_DB_PASSWORD=.*|N8N_DB_PASSWORD=$N8N_DB_PASSWORD|" "$(dirname "$0")/../config/.env"
sed -i "s|N8N_ENCRYPTION_KEY=.*|N8N_ENCRYPTION_KEY=$N8N_ENCRYPTION_KEY|" "$(dirname "$0")/../config/.env"

echo "✓ Database and secrets setup complete!"
echo ""
echo "Database connection details:"
echo "  Instance: n8n-db"
echo "  Database: n8n"
echo "  User: n8n-user"
echo "  Region: $REGION"
