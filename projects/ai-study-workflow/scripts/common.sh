#!/bin/bash

# Common utilities and functions for AI Study Workflow scripts
# Source this file in other scripts: source "$(dirname "$0")/common.sh"

# Exit on error
set -e

# ============================================================================
# COLOR CODES
# ============================================================================

export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export CYAN='\033[0;36m'
export NC='\033[0m' # No Color

# ============================================================================
# DIRECTORY PATHS
# ============================================================================

# Get the script directory (works even when sourced)
export SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
export CONFIG_DIR="$PROJECT_ROOT/config"
export BACKUP_DIR="$PROJECT_ROOT/backups"
export ENV_FILE="$CONFIG_DIR/.env"

# ============================================================================
# LOGGING FUNCTIONS
# ============================================================================

log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

log_step() {
    echo ""
    echo -e "${YELLOW}▶${NC} $1"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

log_header() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# ============================================================================
# ENVIRONMENT MANAGEMENT
# ============================================================================

load_env() {
    if [ -f "$ENV_FILE" ]; then
        set -a
        source "$ENV_FILE"
        set +a
        log_success "Environment variables loaded"
        return 0
    else
        log_warning "No .env file found at $ENV_FILE"
        return 1
    fi
}

save_env_var() {
    local key="$1"
    local value="$2"
    
    if [ ! -f "$ENV_FILE" ]; then
        log_error "Environment file not found: $ENV_FILE"
        return 1
    fi
    
    # Update or append the variable
    if grep -q "^${key}=" "$ENV_FILE"; then
        # macOS and Linux compatible sed
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s|^${key}=.*|${key}=${value}|" "$ENV_FILE"
        else
            sed -i "s|^${key}=.*|${key}=${value}|" "$ENV_FILE"
        fi
    else
        echo "${key}=${value}" >> "$ENV_FILE"
    fi
    
    export "${key}=${value}"
}

ensure_config_dir() {
    if [ ! -d "$CONFIG_DIR" ]; then
        mkdir -p "$CONFIG_DIR"
        log_success "Created config directory"
    fi
}

ensure_backup_dir() {
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
        log_success "Created backup directory"
    fi
}

# ============================================================================
# VALIDATION FUNCTIONS
# ============================================================================

check_command() {
    local cmd="$1"
    local name="${2:-$cmd}"
    
    if command -v "$cmd" &> /dev/null; then
        log_success "$name is installed"
        return 0
    else
        log_error "$name is not installed"
        return 1
    fi
}

check_gcloud_auth() {
    if gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
        local account=$(gcloud auth list --filter=status:ACTIVE --format="value(account)")
        if [ -n "$account" ]; then
            log_success "Authenticated as: $account"
            return 0
        fi
    fi
    
    log_warning "Not authenticated with gcloud"
    return 1
}

validate_project_id() {
    local project_id="$1"
    
    if [ -z "$project_id" ]; then
        log_error "Project ID is empty"
        return 1
    fi
    
    # Check if project exists
    if gcloud projects describe "$project_id" &> /dev/null; then
        log_success "Project $project_id exists"
        return 0
    else
        log_warning "Project $project_id does not exist"
        return 1
    fi
}

# ============================================================================
# GCP RESOURCE CHECKS
# ============================================================================

check_cloud_run_service() {
    local service_name="$1"
    local region="${2:-$REGION}"
    
    if gcloud run services describe "$service_name" --region="$region" &> /dev/null 2>&1; then
        log_success "Cloud Run service '$service_name' exists"
        return 0
    else
        log_info "Cloud Run service '$service_name' does not exist"
        return 1
    fi
}

check_sql_instance() {
    local instance_name="$1"
    
    if gcloud sql instances describe "$instance_name" &> /dev/null 2>&1; then
        log_success "Cloud SQL instance '$instance_name' exists"
        return 0
    else
        log_info "Cloud SQL instance '$instance_name' does not exist"
        return 1
    fi
}

check_secret() {
    local secret_name="$1"
    
    if gcloud secrets describe "$secret_name" &> /dev/null 2>&1; then
        log_success "Secret '$secret_name' exists"
        return 0
    else
        log_info "Secret '$secret_name' does not exist"
        return 1
    fi
}

check_service_account() {
    local sa_email="$1"
    
    if gcloud iam service-accounts describe "$sa_email" &> /dev/null 2>&1; then
        log_success "Service account '$sa_email' exists"
        return 0
    else
        log_info "Service account '$sa_email' does not exist"
        return 1
    fi
}

# ============================================================================
# INTERACTIVE PROMPTS
# ============================================================================

confirm() {
    local message="${1:-Are you sure?}"
    local default="${2:-no}"
    
    if [ "$default" = "yes" ]; then
        read -p "$message (Y/n): " -r
        [[ -z $REPLY || $REPLY =~ ^[Yy]$ ]]
    else
        read -p "$message (y/N): " -r
        [[ $REPLY =~ ^[Yy]$ ]]
    fi
}

prompt_input() {
    local prompt="$1"
    local default="$2"
    local value
    
    if [ -n "$default" ]; then
        read -p "$prompt [$default]: " value
        echo "${value:-$default}"
    else
        read -p "$prompt: " value
        echo "$value"
    fi
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

generate_random_suffix() {
    local length="${1:-10}"
    head /dev/urandom | tr -dc a-z0-9 | head -c "$length"
}

generate_secure_password() {
    local length="${1:-16}"
    openssl rand -base64 "$length"
}

get_timestamp() {
    date +%Y%m%d_%H%M%S
}

wait_with_spinner() {
    local pid=$1
    local message="${2:-Processing}"
    local spin='-\|/'
    local i=0
    
    echo -n "$message "
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) %4 ))
        printf "\r$message ${spin:$i:1}"
        sleep 0.1
    done
    printf "\r$message Done!\n"
}

# ============================================================================
# ERROR HANDLING
# ============================================================================

handle_error() {
    local exit_code=$?
    local line_number=$1
    
    log_error "Script failed at line $line_number with exit code $exit_code"
    exit $exit_code
}

# Set up error trap
trap 'handle_error $LINENO' ERR

# ============================================================================
# INITIALIZATION
# ============================================================================

# Create necessary directories
ensure_config_dir
ensure_backup_dir

# Load environment if available (don't fail if not found)
load_env || true

# Set default region if not set
export REGION="${REGION:-us-central1}"

log_success "Common utilities loaded"
