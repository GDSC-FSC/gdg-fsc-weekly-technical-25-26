#!/bin/bash

# AI Study Workflow - Initialization Script
# Quick setup wizard for first-time users

set -e

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear

echo -e "${BLUE}"
cat << "EOF"
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║        AI Study Workflow Setup Wizard                        ║
║        Powered by n8n + Google Gemini + Cloud Run            ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo ""
echo -e "${CYAN}Welcome! This wizard will help you set up your AI study workflow.${NC}"
echo ""

# Check if already initialized
if [ -f "config/.env" ]; then
    echo -e "${YELLOW}⚠ Found existing configuration${NC}"
    read -p "Do you want to reconfigure? (yes/no): " -r
    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        echo "Keeping existing configuration."
        exit 0
    fi
fi

# Step 1: Prerequisites Check
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 1: Checking Prerequisites${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Check for required commands
MISSING_DEPS=0

echo -n "Checking for curl... "
if command -v curl &> /dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${YELLOW}✗ Missing${NC}"
    MISSING_DEPS=1
fi

echo -n "Checking for openssl... "
if command -v openssl &> /dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${YELLOW}✗ Missing${NC}"
    MISSING_DEPS=1
fi

echo -n "Checking for git... "
if command -v git &> /dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${YELLOW}⚠ Optional${NC}"
fi

if [ $MISSING_DEPS -eq 1 ]; then
    echo ""
    echo -e "${YELLOW}Please install missing dependencies before continuing.${NC}"
    exit 1
fi

# Step 2: GCP Account
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 2: Google Cloud Platform Setup${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Do you have a Google Cloud Platform account with billing enabled?"
echo ""
read -p "Continue? (yes/no): " -r
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo ""
    echo "Please create a GCP account first:"
    echo "  1. Go to: https://cloud.google.com/"
    echo "  2. Click 'Get started for free'"
    echo "  3. Enable billing (you get $300 free credit)"
    echo ""
    exit 0
fi

# Step 3: Gemini API
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 3: Google Gemini API Key${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "You'll need a Gemini API key for the AI features."
echo ""
read -p "Do you have a Gemini API key? (yes/no): " -r
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo ""
    echo "Get your API key here:"
    echo "  → https://aistudio.google.com/app/api-keys"
    echo ""
    echo "We'll continue setup now. You can add the API key later."
    GEMINI_API_KEY=""
else
    echo ""
    read -p "Enter your Gemini API key: " GEMINI_API_KEY
fi

# Step 4: Configuration
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 4: Configuration${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Region selection
echo "Select your preferred region:"
echo "  1) us-central1 (Iowa)"
echo "  2) us-east1 (South Carolina)"
echo "  3) us-west1 (Oregon)"
echo "  4) europe-west1 (Belgium)"
echo "  5) asia-northeast1 (Tokyo)"
echo ""
read -p "Enter choice (1-5, default 1): " region_choice

case $region_choice in
    2) REGION="us-east1" ;;
    3) REGION="us-west1" ;;
    4) REGION="europe-west1" ;;
    5) REGION="asia-northeast1" ;;
    *) REGION="us-central1" ;;
esac

echo -e "${GREEN}✓${NC} Selected region: $REGION"

# Create config directory
mkdir -p config
mkdir -p backups

# Create .env file
cat > config/.env << EOF
# AI Study Workflow - Environment Variables
# Generated on $(date)

# Google Cloud Configuration
PROJECT_ID=
REGION=$REGION

# Database Credentials (Auto-generated during setup)
N8N_DB_PASSWORD=
N8N_ENCRYPTION_KEY=

# n8n Service URL (Set after deployment)
N8N_URL=

# Gemini API Configuration
GEMINI_API_KEY=$GEMINI_API_KEY

# Optional: n8n Authentication
N8N_BASIC_AUTH_ACTIVE=false
N8N_BASIC_AUTH_USER=
N8N_BASIC_AUTH_PASSWORD=

# Timezone
GENERIC_TIMEZONE=UTC
EOF

echo -e "${GREEN}✓${NC} Configuration file created"

# Step 5: Deployment Choice
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 5: Deployment Options${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Choose your deployment method:"
echo ""
echo "  1) Deploy to Google Cloud Run now (Recommended)"
echo "  2) Setup local development environment first"
echo "  3) Skip deployment (configure manually later)"
echo ""
read -p "Enter choice (1-3): " deploy_choice

echo ""

case $deploy_choice in
    1)
        echo -e "${CYAN}Starting Cloud Run deployment...${NC}"
        echo ""
        echo "This will:"
        echo "  ✓ Install gcloud CLI"
        echo "  ✓ Create GCP project"
        echo "  ✓ Setup PostgreSQL database (~15 min)"
        echo "  ✓ Deploy n8n to Cloud Run"
        echo ""
        echo -e "${YELLOW}Estimated cost: $12-25/month${NC}"
        echo ""
        read -p "Continue with deployment? (yes/no): " -r
        if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
            ./scripts/deploy.sh
        else
            echo "Deployment cancelled. Run './scripts/deploy.sh' when ready."
        fi
        ;;
    2)
        echo -e "${CYAN}Setting up local environment...${NC}"
        echo ""
        if command -v docker &> /dev/null && command -v docker-compose &> /dev/null; then
            echo "Starting local n8n with Docker Compose..."
            cd config
            docker-compose up -d
            echo ""
            echo -e "${GREEN}✓ Local n8n is running!${NC}"
            echo ""
            echo "Access it at: http://localhost:5678"
            echo ""
            echo "To stop: cd config && docker-compose down"
        else
            echo -e "${YELLOW}Docker not found.${NC}"
            echo ""
            echo "Install Docker first:"
            echo "  → https://docs.docker.com/get-docker/"
            echo ""
            echo "Then run: cd config && docker-compose up -d"
        fi
        ;;
    3)
        echo "Setup completed. Configuration saved to config/.env"
        echo ""
        echo "To deploy later, run: ./scripts/deploy.sh"
        ;;
esac

# Final summary
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "📁 Project structure:"
echo "  ├── scripts/     - Deployment and management scripts"
echo "  ├── workflows/   - Pre-built workflow templates"
echo "  ├── config/      - Configuration files"
echo "  └── docs/        - Documentation"
echo ""
echo "📚 Next steps:"
echo "  1. Deploy to Cloud Run: ./scripts/deploy.sh"
echo "  2. Or run locally: cd config && docker-compose up -d"
echo "  3. Import workflows from workflows/ directory"
echo "  4. Read docs/DEPLOYMENT.md for detailed guide"
echo ""
echo "🔧 Useful commands:"
echo "  ./scripts/monitor.sh  - Check service status"
echo "  ./scripts/backup.sh   - Backup database"
echo "  ./scripts/cleanup.sh  - Remove all resources"
echo ""
echo "📖 Documentation:"
echo "  docs/DEPLOYMENT.md      - Deployment guide"
echo "  docs/WORKFLOWS.md       - Workflow documentation"
echo "  docs/TROUBLESHOOTING.md - Common issues"
echo ""
echo -e "${CYAN}Happy studying! 📖🤖${NC}"
echo ""
