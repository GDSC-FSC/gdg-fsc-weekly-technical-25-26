#!/bin/bash

# Step 4: Deploy n8n to Cloud Run

set -e

echo "Deploying n8n to Google Cloud Run..."

# Load environment variables
if [ -f "$(dirname "$0")/../config/.env" ]; then
    source "$(dirname "$0")/../config/.env"
fi

# Create service account for n8n
echo "Creating service account..."
export SERVICE_ACCOUNT_EMAIL="n8n-service-account@$PROJECT_ID.iam.gserviceaccount.com"

if gcloud iam service-accounts describe $SERVICE_ACCOUNT_EMAIL &> /dev/null; then
    echo "✓ Service account already exists"
else
    gcloud iam service-accounts create n8n-service-account \
        --display-name="n8n Service Account"
    echo "✓ Service account created"
fi

# Grant necessary permissions
echo "Granting permissions to service account..."

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

echo "✓ Permissions granted"

# Deploy to Cloud Run
echo "Deploying n8n container to Cloud Run..."
echo "⏳ This may take a few minutes..."

DB_CONNECTION_NAME="$PROJECT_ID:$REGION:n8n-db"

gcloud run deploy n8n \
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
    --service-account=$SERVICE_ACCOUNT_EMAIL

echo "✓ n8n deployed successfully!"

# Get the service URL
SERVICE_URL=$(gcloud run services describe n8n --region=$REGION --format='value(status.url)')

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 Deployment Successful!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Your n8n instance is available at:"
echo "  $SERVICE_URL"
echo ""
echo "Save this URL - you'll need it to access your workflows!"
echo ""

# Save URL to .env file
echo "N8N_URL=$SERVICE_URL" >> "$(dirname "$0")/../config/.env"
