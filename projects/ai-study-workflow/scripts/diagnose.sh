#!/bin/bash

# AI Study Workflow - Diagnostic and Troubleshooting Script
# Detects and fixes common workshop issues

# Source common utilities
source "$(dirname "$0")/common.sh"

log_header "AI Study Workflow - Diagnostics"

echo ""
echo "This tool will check for common issues and suggest fixes."
echo ""

# Load environment if it exists
if [ -f "$ENV_FILE" ]; then
    load_env
    HAS_CONFIG=true
else
    HAS_CONFIG=false
fi

# Issue counter
ISSUES_FOUND=0
ISSUES_FIXED=0

# Function to report issue
report_issue() {
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
    log_error "$1"
}

# Function to report fix
report_fix() {
    ISSUES_FIXED=$((ISSUES_FIXED + 1))
    log_success "$1"
}

# ============================================================================
# Check 1: System Prerequisites
# ============================================================================
log_step "Checking system prerequisites"

if ! check_command curl; then
    report_issue "curl is not installed"
    log_info "Install: sudo apt-get install curl (Debian/Ubuntu) or brew install curl (macOS)"
else
    log_success "curl is installed"
fi

if ! check_command openssl; then
    report_issue "openssl is not installed"
    log_info "Install: sudo apt-get install openssl (Debian/Ubuntu) or brew install openssl (macOS)"
else
    log_success "openssl is installed"
fi

if ! check_command git; then
    log_warning "git is not installed (optional)"
else
    log_success "git is installed"
fi

# ============================================================================
# Check 2: Docker Setup (for local development)
# ============================================================================
log_step "Checking Docker setup"

if ! check_command docker; then
    log_warning "Docker is not installed (needed for local development)"
    log_info "Install from: https://docs.docker.com/get-docker/"
else
    log_success "Docker is installed"
    
    # Check if Docker daemon is running
    if docker ps &>/dev/null; then
        log_success "Docker daemon is running"
        
        # Check for port conflicts
        if docker ps --format '{{.Ports}}' | grep -q '5678'; then
            report_issue "Another container is using port 5678"
            echo ""
            docker ps --filter "publish=5678" --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
            echo ""
            read -p "Stop conflicting containers? (yes/no): " -r
            if [[ $REPLY =~ ^[Yy] ]]; then
                CONFLICTING=$(docker ps --filter "publish=5678" --format "{{.Names}}")
                for container in $CONFLICTING; do
                    docker stop "$container"
                    log_success "Stopped container: $container"
                    report_fix "Stopped conflicting container"
                done
            fi
        else
            log_success "Port 5678 is available"
        fi
    else
        report_issue "Docker daemon is not running"
        log_info "Start Docker Desktop or run: sudo systemctl start docker"
    fi
fi

if ! check_command docker-compose; then
    log_warning "Docker Compose is not installed (needed for local development)"
    log_info "Install from: https://docs.docker.com/compose/install/"
else
    log_success "Docker Compose is installed"
fi

# ============================================================================
# Check 3: Configuration Files
# ============================================================================
log_step "Checking configuration files"

if [ "$HAS_CONFIG" = true ]; then
    log_success "Configuration file found: $ENV_FILE"
    
    # Check for required variables
    MISSING_VARS=()
    
    if [ -z "$PROJECT_ID" ]; then
        MISSING_VARS+=("PROJECT_ID")
    fi
    
    if [ -z "$REGION" ]; then
        MISSING_VARS+=("REGION")
    fi
    
    if [ ${#MISSING_VARS[@]} -gt 0 ]; then
        report_issue "Missing environment variables: ${MISSING_VARS[*]}"
        log_info "Run ./setup.sh to configure"
    else
        log_success "All required variables are set"
    fi
else
    report_issue "Configuration file not found"
    log_info "Run ./setup.sh to create configuration"
fi

# ============================================================================
# Check 4: Google Cloud Setup
# ============================================================================
log_step "Checking Google Cloud setup"

if ! check_command gcloud; then
    log_warning "gcloud CLI is not installed"
    log_info "Install from: https://cloud.google.com/sdk/docs/install"
    log_info "Or run: ./scripts/01-setup-gcloud.sh"
else
    log_success "gcloud CLI is installed"
    
    # Check authentication
    if check_gcloud_auth; then
        CURRENT_ACCOUNT=$(gcloud config get-value account 2>/dev/null)
        log_success "Authenticated as: $CURRENT_ACCOUNT"
        
        # Check active project
        if [ "$HAS_CONFIG" = true ] && [ -n "$PROJECT_ID" ]; then
            CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null)
            
            if [ "$CURRENT_PROJECT" != "$PROJECT_ID" ]; then
                report_issue "Active project mismatch"
                log_info "Expected: $PROJECT_ID"
                log_info "Current: $CURRENT_PROJECT"
                
                read -p "Switch to $PROJECT_ID? (yes/no): " -r
                if [[ $REPLY =~ ^[Yy] ]]; then
                    gcloud config set project "$PROJECT_ID"
                    log_success "Switched to project: $PROJECT_ID"
                    report_fix "Fixed project mismatch"
                fi
            else
                log_success "Active project: $PROJECT_ID"
            fi
            
            # Check if project exists
            if validate_project_id "$PROJECT_ID"; then
                log_success "Project exists: $PROJECT_ID"
                
                # Check billing
                if gcloud beta billing projects describe "$PROJECT_ID" --format='value(billingEnabled)' 2>/dev/null | grep -q "True"; then
                    log_success "Billing is enabled"
                else
                    report_issue "Billing is not enabled"
                    log_info "Enable billing: https://console.cloud.google.com/billing/linkedaccount?project=$PROJECT_ID"
                fi
            else
                report_issue "Project does not exist: $PROJECT_ID"
                log_info "Run ./scripts/02-create-project.sh to create it"
            fi
        fi
    else
        report_issue "Not authenticated with gcloud"
        log_info "Run: gcloud auth login"
    fi
fi

# ============================================================================
# Check 5: Cloud Resources (if deployed)
# ============================================================================
if [ "$HAS_CONFIG" = true ] && [ -n "$PROJECT_ID" ] && check_gcloud_auth; then
    log_step "Checking Cloud Run deployment"
    
    if check_cloud_run_service "n8n" "$REGION"; then
        log_success "Cloud Run service 'n8n' exists"
        
        # Get service status
        SERVICE_URL=$(gcloud run services describe n8n --region="$REGION" --format='value(status.url)' 2>/dev/null)
        SERVICE_STATUS=$(gcloud run services describe n8n --region="$REGION" --format='value(status.conditions[0].status)' 2>/dev/null)
        
        if [ "$SERVICE_STATUS" = "True" ]; then
            log_success "Service is healthy"
            log_info "URL: $SERVICE_URL"
        else
            report_issue "Service is not healthy"
            log_info "Check logs: gcloud run logs read n8n --region=$REGION"
        fi
    else
        log_warning "Cloud Run service not deployed"
        log_info "Deploy with: ./scripts/deploy.sh"
    fi
    
    log_step "Checking Cloud SQL instance"
    
    if check_sql_instance "n8n-db"; then
        log_success "Cloud SQL instance 'n8n-db' exists"
        
        # Get instance status
        INSTANCE_STATUS=$(gcloud sql instances describe n8n-db --format='value(state)' 2>/dev/null)
        
        if [ "$INSTANCE_STATUS" = "RUNNABLE" ]; then
            log_success "Database is running"
        else
            report_issue "Database is not running (status: $INSTANCE_STATUS)"
        fi
    else
        log_warning "Cloud SQL instance not created"
        log_info "Deploy with: ./scripts/deploy.sh"
    fi
fi

# ============================================================================
# Check 6: Local Docker Environment
# ============================================================================
if [ "$HAS_CONFIG" = true ] && check_command docker && docker ps &>/dev/null; then
    log_step "Checking local Docker environment"
    
    if [ -f "$(dirname "$ENV_FILE")/docker-compose.yml" ]; then
        log_success "docker-compose.yml found"
        
        # Check if containers are running
        cd "$(dirname "$ENV_FILE")"
        
        if docker-compose ps | grep -q "n8n"; then
            log_success "Local n8n container is running"
            
            if docker-compose ps | grep -q "Up"; then
                log_success "Containers are healthy"
                log_info "Access n8n at: http://localhost:5678"
            else
                report_issue "Containers are not running properly"
                log_info "Check status: cd config && docker-compose ps"
                log_info "View logs: cd config && docker-compose logs"
                
                read -p "Restart containers? (yes/no): " -r
                if [[ $REPLY =~ ^[Yy] ]]; then
                    docker-compose down
                    docker-compose up -d
                    log_success "Containers restarted"
                    report_fix "Restarted local environment"
                fi
            fi
        else
            log_warning "Local n8n not running"
            log_info "Start with: cd config && docker-compose up -d"
        fi
        
        cd - > /dev/null
    else
        log_warning "docker-compose.yml not found"
    fi
fi

# ============================================================================
# Summary
# ============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_header "Diagnostic Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ $ISSUES_FOUND -eq 0 ]; then
    log_success "No issues found! Everything looks good. ✨"
else
    log_warning "Found $ISSUES_FOUND issue(s)"
    
    if [ $ISSUES_FIXED -gt 0 ]; then
        log_success "Fixed $ISSUES_FIXED issue(s) automatically"
    fi
    
    echo ""
    echo "If you're still experiencing problems:"
    echo "  1. Check docs/TROUBLESHOOTING.md"
    echo "  2. Review deployment logs"
    echo "  3. Ensure billing is enabled in GCP"
    echo ""
fi

echo ""
echo "For more help, see:"
echo "  📖 docs/TROUBLESHOOTING.md - Common issues and solutions"
echo "  📖 docs/DEPLOYMENT.md - Deployment guide"
echo "  📖 QUICKSTART.md - Quick start guide"
echo ""

exit 0
