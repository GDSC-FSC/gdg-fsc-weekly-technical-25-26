#!/bin/bash

# Monitor Script - Check n8n service status and logs

set -e

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Load environment variables
if [ -f "$(dirname "$0")/../config/.env" ]; then
    source "$(dirname "$0")/../config/.env"
else
    echo "Error: .env file not found!"
    exit 1
fi

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              n8n Monitoring Dashboard                      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Service Status
echo -e "${YELLOW}=== Cloud Run Service Status ===${NC}"
gcloud run services describe n8n \
    --region=$REGION \
    --format="table(
        status.url,
        status.conditions[0].type,
        status.conditions[0].status,
        spec.template.spec.containers[0].image
    )"
echo ""

# Get service URL
SERVICE_URL=$(gcloud run services describe n8n --region=$REGION --format='value(status.url)')
echo -e "Service URL: ${GREEN}$SERVICE_URL${NC}"
echo ""

# Check if service is accessible
echo -e "${YELLOW}=== Health Check ===${NC}"
if curl -s -o /dev/null -w "%{http_code}" "$SERVICE_URL/healthz" | grep -q "200"; then
    echo -e "${GREEN}✓ Service is healthy${NC}"
else
    echo -e "${RED}✗ Service health check failed${NC}"
fi
echo ""

# Database Status
echo -e "${YELLOW}=== Cloud SQL Status ===${NC}"
gcloud sql instances describe n8n-db \
    --format="table(
        state,
        databaseVersion,
        settings.tier,
        region
    )"
echo ""

# Recent logs
echo -e "${YELLOW}=== Recent Logs (last 20 lines) ===${NC}"
gcloud run logs read n8n --region=$REGION --limit=20
echo ""

# Resource Usage
echo -e "${YELLOW}=== Resource Metrics ===${NC}"
echo "Fetching metrics..."
gcloud run services describe n8n \
    --region=$REGION \
    --format="table(
        spec.template.spec.containers[0].resources.limits.memory,
        spec.template.spec.containers[0].resources.limits.cpu
    )"
echo ""

# Menu for additional actions
echo -e "${YELLOW}=== Additional Actions ===${NC}"
echo "1. View detailed logs"
echo "2. Check database connections"
echo "3. View service revisions"
echo "4. Monitor in real-time"
echo "5. Exit"
echo ""

read -p "Select an option (1-5): " option

case $option in
    1)
        echo "Fetching detailed logs (last 100 lines)..."
        gcloud run logs read n8n --region=$REGION --limit=100
        ;;
    2)
        echo "Checking database connections..."
        gcloud sql operations list --instance=n8n-db --limit=10
        ;;
    3)
        echo "Service revisions:"
        gcloud run revisions list --service=n8n --region=$REGION
        ;;
    4)
        echo "Monitoring logs in real-time (Ctrl+C to stop)..."
        gcloud run logs tail n8n --region=$REGION
        ;;
    5)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid option"
        ;;
esac
