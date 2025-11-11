# Deployment Guide

Complete step-by-step guide for deploying n8n on Google Cloud Run.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Initial Setup](#initial-setup)
3. [Deployment Steps](#deployment-steps)
4. [Post-Deployment Configuration](#post-deployment-configuration)
5. [Verification](#verification)
6. [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Accounts

- **Google Cloud Platform Account**
  - Active billing account
  - Permissions to create projects
  - Recommended: $300 free trial credits for new users

- **Google Gemini API Access**
  - Visit [Google AI Studio](https://aistudio.google.com/app/api-keys)
  - Create an API key
  - Keep it secure for later use

### Local Requirements

- **Operating System**: Linux, macOS, or Windows (with WSL)
- **Tools**:
  - `bash` shell
  - `curl` (for downloading gcloud CLI)
  - `git` (optional, for version control)
  - `openssl` (for generating secure keys)

## Initial Setup

### 1. Clone or Download the Project

```bash
cd projects/ai-study-workflow
```

### 2. Make Scripts Executable

```bash
chmod +x scripts/*.sh
```

### 3. Review Configuration

Check `config/.env.example` to understand what variables will be set:

```bash
cat config/.env.example
```

## Deployment Steps

### Option A: Automated Deployment (Recommended)

Run the complete deployment script:

```bash
./scripts/deploy.sh
```

This script will:
1. ✅ Check and install gcloud CLI
2. ✅ Authenticate with Google Cloud
3. ✅ Create a new GCP project
4. ✅ Enable required APIs
5. ✅ Setup PostgreSQL database
6. ✅ Configure Secret Manager
7. ✅ Deploy n8n to Cloud Run

**Estimated time**: 15-20 minutes

### Option B: Manual Step-by-Step Deployment

If you prefer more control:

#### Step 1: Setup gcloud CLI

```bash
./scripts/01-setup-gcloud.sh
```

- Installs gcloud CLI if not present
- Authenticates your account
- Verifies installation

#### Step 2: Create GCP Project

```bash
./scripts/02-create-project.sh
```

- Creates a unique project ID
- Enables required APIs:
  - Cloud Run API
  - Cloud SQL Admin API
  - Secret Manager API
  - IAM API
- **Important**: You'll be prompted to link a billing account

#### Step 3: Setup Database

```bash
./scripts/03-setup-database.sh
```

- Creates PostgreSQL 13 instance
- Configures database and user
- Generates secure credentials
- Stores secrets in Secret Manager
- ⏳ **Takes 10-15 minutes**

#### Step 4: Deploy n8n

```bash
./scripts/04-deploy-n8n.sh
```

- Creates service account
- Configures IAM permissions
- Deploys n8n container
- Connects to Cloud SQL
- Returns service URL

## Post-Deployment Configuration

### 1. Access Your n8n Instance

After deployment, you'll receive a URL like:
```
https://n8n-xxxxx.us-central1.run.app
```

Open this URL in your browser.

### 2. Create Owner Account

On first access:
1. Set up owner account credentials
2. Choose a strong password
3. Optionally add enterprise license

### 3. Configure Gemini API

1. Click **"Credentials"** in the left sidebar
2. Click **"Add Credential"**
3. Search for **"Google Gemini (PaLM) API"**
4. Click **"Create New Credential"**
5. Enter your API key from [AI Studio](https://aistudio.google.com/app/api-keys)
6. Click **"Save"**

### 4. Import Workflow Templates

1. Go to **"Workflows"**
2. Click **"Import from file"**
3. Navigate to `workflows/` directory
4. Import each template:
   - `study-assistant.json`
   - `research-helper.json`
   - `schedule-manager.json`
   - `note-taking.json`

### 5. Configure Additional Integrations (Optional)

Depending on which workflows you use:

- **Google Drive**: For note-taking automation
  - Credentials → Add → Google Drive
  - Follow OAuth flow

- **Google Calendar**: For schedule management
  - Credentials → Add → Google Calendar
  - Follow OAuth flow

- **Google Sheets**: For research tracking
  - Credentials → Add → Google Sheets
  - Follow OAuth flow

## Verification

### Test Basic Functionality

1. **Health Check**
   ```bash
   curl https://your-n8n-url.run.app/healthz
   ```
   Should return `200 OK`

2. **Test Study Assistant**
   - Import `study-assistant.json`
   - Click "Execute Workflow"
   - Try the chat: "Explain quantum physics"

3. **Monitor Logs**
   ```bash
   ./scripts/monitor.sh
   ```

### Check Database Connection

```bash
gcloud sql instances describe n8n-db --format="value(state)"
```

Should return `RUNNABLE`

### Verify Secret Access

```bash
gcloud secrets versions access latest --secret=n8n-encryption-key
```

Should display the encryption key.

## Cost Optimization

### Estimated Monthly Costs

| Resource | Configuration | Est. Cost |
|----------|--------------|-----------|
| Cloud Run | 2GB RAM, 1 CPU | $5-15 |
| Cloud SQL | db-f1-micro | $7-10 |
| Secret Manager | 2 secrets | $0.06 |
| **Total** | | **~$12-25** |

### Tips to Reduce Costs

1. **Use Cloud Run Minimum Instances**
   ```bash
   gcloud run services update n8n --min-instances=0 --region=$REGION
   ```

2. **Enable Database Auto-pause** (not available on f1-micro)

3. **Set Budget Alerts**
   - Go to GCP Console → Billing → Budgets
   - Set alert at $20/month

4. **Clean Up Unused Resources**
   ```bash
   ./scripts/cleanup.sh
   ```

## Security Best Practices

### 1. Enable Authentication

Add to your n8n environment:
```bash
gcloud run services update n8n \
  --update-env-vars="N8N_BASIC_AUTH_ACTIVE=true" \
  --region=$REGION
```

### 2. Restrict Network Access

```bash
gcloud run services update n8n \
  --ingress=internal-and-cloud-load-balancing \
  --region=$REGION
```

### 3. Regular Backups

Schedule weekly backups:
```bash
crontab -e
# Add: 0 2 * * 0 /path/to/backup.sh
```

### 4. Monitor Access Logs

```bash
gcloud logging read "resource.type=cloud_run_revision" --limit=50
```

## Updating n8n

### Update to Latest Version

```bash
gcloud run deploy n8n \
  --image=n8nio/n8n:latest \
  --region=$REGION
```

### Pin to Specific Version

```bash
gcloud run deploy n8n \
  --image=n8nio/n8n:1.x.x \
  --region=$REGION
```

## Troubleshooting

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues and solutions.

## Next Steps

1. ✅ Explore [pre-built workflows](../workflows/)
2. ✅ Join [n8n Community Forum](https://community.n8n.io/)
3. ✅ Check [n8n Documentation](https://docs.n8n.io/)
4. ✅ Build custom workflows for your study needs

---

**Need Help?** Check the troubleshooting guide or ask in the n8n community!
