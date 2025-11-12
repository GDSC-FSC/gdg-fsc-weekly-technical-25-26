#!/bin/bash

# Monitor Script - Check n8n service status and logs

# Source common utilities
source "$(dirname "$0")/common.sh"

# Load environment variables
load_env || {
    log_error ".env file not found!"
    exit 1
}

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              n8n Monitoring Dashboard                      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Service Status
log_header "Cloud Run Service Status"
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
log_info "Service URL: ${GREEN}$SERVICE_URL${NC}"
echo ""

# Check if service is accessible
log_header "Health Check"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$SERVICE_URL/healthz")
if [ "$HTTP_CODE" = "200" ]; then
    log_success "Service is healthy (HTTP $HTTP_CODE)"
else
    log_error "Service health check failed (HTTP $HTTP_CODE)"
fi
echo ""

# Database Status
log_header "Cloud SQL Status"
gcloud sql instances describe n8n-db \
    --format="table(
        state,
        databaseVersion,
        settings.tier,
        region
    )"
echo ""

# Recent logs
log_header "Recent Logs (last 20 lines)"
gcloud run logs read n8n --region=$REGION --limit=20
echo ""

# Resource Usage
log_header "Resource Metrics"
log_info "Fetching metrics..."
gcloud run services describe n8n \
    --region=$REGION \
    --format="table(
        spec.template.spec.containers[0].resources.limits.memory,
        spec.template.spec.containers[0].resources.limits.cpu
    )"
echo ""

# Menu for additional actions
log_header "Additional Actions"
echo "1. View detailed logs"
echo "2. Check database connections"
echo "3. View service revisions"
echo "4. Monitor in real-time"
echo "5. Exit"
echo ""

read -p "Select an option (1-5): " option

case $option in
    1)
        log_info "Fetching detailed logs (last 100 lines)..."
        gcloud run logs read n8n --region=$REGION --limit=100
        ;;
    2)
        log_info "Checking database connections..."
        gcloud sql operations list --instance=n8n-db --limit=10
        ;;
    3)
        log_info "Service revisions:"
        gcloud run revisions list --service=n8n --region=$REGION
        ;;
    4)
        log_info "Monitoring logs in real-time (Ctrl+C to stop)..."
        gcloud run logs tail n8n --region=$REGION
        ;;
    5)
        log_info "Exiting..."
        exit 0
        ;;
    *)
        log_error "Invalid option"
        ;;
esac
