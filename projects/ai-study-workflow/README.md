# AI Study Workflow with n8n and Google Cloud Run

An automated AI-powered study workflow system built with n8n, Google Gemini, and deployed on Google Cloud Run. This project helps you create intelligent study assistants that can help with research, note-taking, scheduling, and learning automation.

## 🎯 Overview

This project provides a complete setup for deploying n8n (a powerful workflow automation tool) on Google Cloud Run with:
- **PostgreSQL database** for persistent storage
- **Google Gemini AI** integration for intelligent workflows
- **Automated deployment scripts** for easy setup
- **Pre-built workflow templates** for study automation

## 📋 Prerequisites

Before starting, ensure you have:
- A Google Cloud Platform (GCP) account
- Billing enabled on your GCP account
- `gcloud` CLI installed on your machine
- Basic familiarity with command line and Docker

## 🏗️ Architecture

```
┌─────────────────┐
│   Cloud Run     │
│   (n8n)         │◄──── HTTPS Requests
└────────┬────────┘
         │
         │ Cloud SQL Connector
         ▼
┌─────────────────┐
│  Cloud SQL      │
│  (PostgreSQL)   │
└─────────────────┘

┌─────────────────┐
│ Secret Manager  │
│  - DB Password  │
│  - Encryption   │
└─────────────────┘
```

## 🚀 Quick Start

### Option 1: Interactive Setup Wizard (Recommended for Workshops)

The easiest way to get started:

```bash
./setup.sh
```

This interactive wizard will:
- ✅ Check prerequisites automatically
- ✅ Guide you through configuration
- ✅ Verify billing and authentication
- ✅ Offer both local and cloud deployment options
- ✅ Provide clear error messages and fixes

### Option 2: Manual Setup

1. **Check Your System**

```bash
# Run diagnostics to catch issues early
./scripts/diagnose.sh
```

2. **Deploy to Cloud**

```bash
# Complete automated deployment
./scripts/deploy.sh
```

**OR** deploy step-by-step:

```bash
./scripts/01-setup-gcloud.sh      # Install gcloud CLI
./scripts/02-create-project.sh    # Create GCP project
./scripts/03-setup-database.sh    # Setup Cloud SQL
./scripts/04-deploy-n8n.sh        # Deploy to Cloud Run
```

### 3. Access Your Instance

After deployment, open the provided URL and create your owner account.

## 🛠️ New Workshop Features

### Automatic Error Recovery

The deployment scripts now include:

- **🔄 Automatic Retries**: Cloud Run deployment retries up to 3 times if region initialization fails
- **✅ Billing Verification**: Interactive billing check before API enablement  
- **🔍 Pre-flight Checks**: Validates prerequisites before starting deployment
- **🩺 Diagnostic Tool**: Run `./scripts/diagnose.sh` to detect and fix common issues automatically

### Common Issues - Now Auto-Fixed!

| Issue | Old Behavior | New Behavior |
|-------|--------------|--------------|
| Port 5678 conflict | Manual fix required | `diagnose.sh` auto-detects and fixes |
| Region initialization timeout | Deployment fails | Automatic retry with backoff |
| Billing not enabled | Cryptic error | Interactive verification with guide |
| Wrong GCP account | Deployment fails | Clear error with account info |

## 📚 Study Workflow Templates

This project includes pre-built workflow templates:

### 1. **Smart Study Assistant**
- Automatically summarizes study materials
- Creates flashcards from documents
- Generates quiz questions

### 2. **Research Helper**
- Searches academic resources
- Extracts key insights from papers
- Organizes citations and references

### 3. **Study Schedule Manager**
- Creates personalized study schedules
- Sends reminders and notifications
- Tracks study progress

### 4. **Note-Taking Automation**
- Converts lecture recordings to notes
- Organizes notes by topic
- Links related concepts

## 🛠️ Project Structure

```
ai-study-workflow/
├── README.md                      # This file
├── scripts/
│   ├── deploy.sh                  # Main deployment script
│   ├── 01-setup-gcloud.sh        # GCloud CLI setup
│   ├── 02-create-project.sh      # GCP project creation
│   ├── 03-setup-database.sh      # Database setup
│   ├── 04-deploy-n8n.sh          # n8n deployment
│   ├── cleanup.sh                # Resource cleanup
│   └── backup.sh                 # Backup script
├── workflows/
│   ├── study-assistant.json      # Study assistant workflow
│   ├── research-helper.json      # Research automation
│   ├── schedule-manager.json     # Schedule management
│   └── note-taking.json          # Note automation
├── config/
│   ├── .env.example              # Environment variables template
│   └── docker-compose.yml        # Local development setup
├── docs/
│   ├── DEPLOYMENT.md             # Detailed deployment guide
│   ├── WORKFLOWS.md              # Workflow documentation
│   └── TROUBLESHOOTING.md        # Common issues and solutions
└── .gitignore
```

## 💰 Cost Estimation

Approximate monthly costs (may vary):
- **Cloud Run**: ~$5-15/month (with minimal usage)
- **Cloud SQL (db-f1-micro)**: ~$7-10/month
- **Secret Manager**: ~$0.06/month
- **Total**: ~$12-25/month

💡 **Tip**: Set up budget alerts in GCP Console to monitor costs.

## 🔧 Configuration

### Environment Variables

Copy the example configuration:
```bash
cp config/.env.example config/.env
```

Edit the variables:
```env
PROJECT_ID=your-project-id
REGION=us-central1
N8N_ENCRYPTION_KEY=your-encryption-key
GEMINI_API_KEY=your-gemini-api-key
```

### Local Development

For local testing before deploying:
```bash
cd config
docker-compose up -d
```

Access n8n locally at: `http://localhost:5678`

## � Troubleshooting

### Quick Diagnostics

Run the diagnostic tool to automatically detect and fix issues:

```bash
./scripts/diagnose.sh
```

This will check and fix:
- System prerequisites
- Docker port conflicts
- GCP authentication
- Project and billing status
- Cloud resource health
- Local environment issues

### Common Workshop Issues

| Problem | Quick Fix |
|---------|-----------|
| Port 5678 in use | `./scripts/diagnose.sh` (auto-stops conflicts) |
| "Resource readiness exceeded" | Wait 30s, script auto-retries |
| Can't find project | Check account: `gcloud config get-value account` |
| Billing errors | Script now verifies interactively |
| Docker not starting | `docker system prune -a` |

For detailed solutions, see:
- 📖 **[Workshop Guide](docs/WORKSHOP_GUIDE.md)** - Comprehensive workshop troubleshooting
- 📖 **[Troubleshooting Guide](docs/TROUBLESHOOTING.md)** - Detailed error solutions
- 📖 **[Deployment Guide](docs/DEPLOYMENT.md)** - Step-by-step instructions

## �📖 Usage Examples

### Example 1: Study Material Summarizer

1. Import `workflows/study-assistant.json`
2. Configure your document source (Google Drive, Dropbox, etc.)
3. Activate the workflow
4. Upload study materials
5. Receive AI-generated summaries

### Example 2: Research Paper Assistant

1. Import `workflows/research-helper.json`
2. Connect to academic databases
3. Enter research topics
4. Get automated literature reviews

## 🔐 Security Best Practices

1. **Never commit secrets** - Use Secret Manager
2. **Enable authentication** - Configure n8n authentication
3. **Use IAM roles** - Follow principle of least privilege
4. **Regular backups** - Run backup script weekly
5. **Monitor logs** - Check Cloud Run logs regularly

## 🧹 Cleanup

To delete all resources and avoid charges:

```bash
./scripts/cleanup.sh
```

⚠️ **Warning**: This will permanently delete:
- Cloud Run service
- Cloud SQL database
- All secrets
- Service accounts
- The GCP project (optional)

## 📊 Monitoring

Monitor your n8n instance:

```bash
# View logs
gcloud run logs read n8n --region=us-central1

# Check service status
gcloud run services describe n8n --region=us-central1
```

## 🤝 Contributing

Feel free to contribute by:
- Adding new workflow templates
- Improving documentation
- Reporting issues
- Suggesting features

## 📚 Additional Resources

- [n8n Documentation](https://docs.n8n.io/)
- [Google Gemini API](https://ai.google.dev/)
- [Cloud Run Documentation](https://cloud.google.com/run/docs)
- [n8n Community Workflows](https://n8n.io/workflows/)
- [n8n Community Forum](https://community.n8n.io/)

## 🆘 Troubleshooting

See [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for common issues.

## 📄 License

This project is provided as-is for educational purposes.

## 🙏 Acknowledgments

Based on the excellent guide by [Philipp Schmid](https://www.philschmid.de/n8n-cloud-run-gemini)

---

**Happy Studying! 📖🤖**
