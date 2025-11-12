# Workshop Guide: AI Study Workflow with n8n

This guide is specifically designed for workshop facilitators and participants to ensure a smooth, successful workshop experience.

## 📋 Table of Contents

- [Pre-Workshop Preparation](#pre-workshop-preparation)
- [Common Workshop Issues](#common-workshop-issues)
- [Troubleshooting Tools](#troubleshooting-tools)
- [Time Estimates](#time-estimates)
- [Workshop Flow](#workshop-flow)

## 🎯 Pre-Workshop Preparation

### For Facilitators

**1 Week Before:**
- [ ] Test the complete deployment process
- [ ] Verify all scripts work in a clean environment
- [ ] Prepare a demo GCP project
- [ ] Create a backup Gemini API key for demos

**1 Day Before:**
- [ ] Send pre-workshop email with setup instructions
- [ ] Share prerequisites checklist
- [ ] Test local Docker setup
- [ ] Prepare troubleshooting cheat sheet

### For Participants

**Before the Workshop:**
1. **Create Google Cloud Account** (Required)
   - Visit: https://cloud.google.com/
   - Sign up for free trial ($300 credit)
   - Enable billing (credit card required, won't be charged during free trial)

2. **Get Gemini API Key** (Optional but recommended)
   - Visit: https://aistudio.google.com/app/api-keys
   - Create a new API key
   - Save it for the workshop

3. **Install Prerequisites**
   ```bash
   # macOS
   brew install curl openssl git
   
   # Ubuntu/Debian
   sudo apt-get install curl openssl git
   
   # Windows (WSL recommended)
   # Install WSL first, then use Ubuntu commands
   ```

4. **Optional: Install Docker** (for local testing)
   - Download from: https://docs.docker.com/get-docker/
   - Install Docker Desktop
   - Verify: `docker --version` and `docker-compose --version`

## 🚨 Common Workshop Issues

### Issue 1: Port 5678 Already in Use

**Symptoms:**
```
Error: Bind for 0.0.0.0:5678 failed: port is already allocated
```

**Solution:**
```bash
# Find what's using the port
docker ps -a | grep 5678

# Stop conflicting container
docker stop <container-name>

# Or use diagnostic tool
./scripts/diagnose.sh
```

**Prevention:** Run diagnostic before starting local environment.

---

### Issue 2: "Resource Readiness Deadline Exceeded"

**Symptoms:**
```
ERROR: (gcloud.run.deploy) Initializing project for the current region. 
Resource readiness deadline exceeded.
```

**What's Happening:**
Cloud Run is initializing the region for the first time. This is **normal** and expected.

**Solution:**
The deployment script now **automatically retries** (up to 3 times with increasing wait times).

**Manual Fix:**
```bash
# Wait 1-2 minutes, then retry
./scripts/04-deploy-n8n.sh
```

**Expected Timeline:**
- First attempt: May fail (region initializing)
- Second attempt: Usually succeeds (30-60s wait)
- Third attempt: Should definitely work

---

### Issue 3: Billing Not Enabled

**Symptoms:**
```
ERROR: Billing account for project is not found
```

**Solution:**
1. Visit: `https://console.cloud.google.com/billing/linkedaccount?project=<PROJECT_ID>`
2. Select a billing account
3. Click "SET ACCOUNT"
4. Wait for confirmation
5. Retry deployment

**New Feature:** The script now **verifies billing** before proceeding.

---

### Issue 4: Can't Find Project in Console

**Symptoms:**
- Project created by script not visible in Cloud Console
- "Project does not exist" errors

**Solution:**
1. **Verify you're logged in with the correct account:**
   ```bash
   gcloud config get-value account
   ```

2. **Check which account you used:**
   The script shows: "You are now logged in as [email@example.com]"

3. **Switch accounts in Cloud Console:**
   - Click profile icon (top right)
   - Select the correct account
   - Or use direct link: `https://console.cloud.google.com/home/dashboard?project=<PROJECT_ID>`

---

### Issue 5: gcloud CLI Not Installed

**Symptoms:**
```
gcloud: command not found
```

**Solution:**
```bash
# Option 1: Run the setup script
./scripts/01-setup-gcloud.sh

# Option 2: Manual installation
# macOS
brew install --cask google-cloud-sdk

# Linux
curl https://sdk.cloud.google.com | bash
exec -l $SHELL

# Windows
# Download from: https://cloud.google.com/sdk/docs/install
```

---

## 🛠️ Troubleshooting Tools

### 1. Diagnostic Script (NEW!)

Automatically detects and fixes common issues:

```bash
./scripts/diagnose.sh
```

**What it checks:**
- ✅ System prerequisites (curl, openssl, git)
- ✅ Docker installation and status
- ✅ Port conflicts
- ✅ Configuration files
- ✅ Google Cloud authentication
- ✅ Project existence and billing
- ✅ Cloud Run deployment status
- ✅ Cloud SQL status
- ✅ Local Docker environment

**Auto-fixes:**
- Stops conflicting Docker containers
- Switches to correct GCP project
- Restarts unhealthy containers

### 2. Setup Wizard

Interactive setup for first-time users:

```bash
./setup.sh
```

**Features:**
- Prerequisites checking
- Step-by-step guidance
- Configuration validation
- Multiple deployment options
- Clear error messages

### 3. Manual Debugging Commands

```bash
# Check what's using port 5678
lsof -i :5678
docker ps -a | grep 5678

# View Cloud Run logs
gcloud run logs read n8n --region=$REGION

# Check service status
gcloud run services describe n8n --region=$REGION

# Check billing status
gcloud beta billing projects describe $PROJECT_ID

# List all projects
gcloud projects list

# Check current authentication
gcloud auth list
gcloud config get-value account
gcloud config get-value project
```

## ⏱️ Time Estimates

### Quick Start (Local Only)
- **Prerequisites:** 10-15 minutes
- **Setup:** 5 minutes
- **Docker startup:** 2-3 minutes
- **Total:** ~20 minutes

### Full Cloud Deployment
- **Prerequisites:** 10-15 minutes
- **gcloud setup:** 5-10 minutes
- **Project creation:** 2-3 minutes
- **Billing setup:** 5 minutes
- **Database setup:** 10-15 minutes
- **n8n deployment:** 5-10 minutes (with retries)
- **Total:** ~40-60 minutes

### Workshop Timeline (90 minutes)
- **Intro & Prerequisites (10 min)**
- **Setup & Configuration (15 min)**
- **Local Development Demo (10 min)**
- **Cloud Deployment (25 min)** - run in background
- **Break while deploying (10 min)**
- **Workflow Creation (15 min)**
- **Q&A & Troubleshooting (5 min)**

## 📚 Workshop Flow

### Phase 1: Introduction (10 minutes)

1. **Welcome & Overview**
   - What is n8n?
   - Use cases for AI study workflows
   - Architecture overview

2. **Prerequisites Check**
   ```bash
   ./scripts/diagnose.sh
   ```
   - Everyone runs diagnostic
   - Fix any immediate issues

### Phase 2: Local Setup (15 minutes)

1. **Run Setup Wizard**
   ```bash
   ./setup.sh
   ```
   - Choose option 2 (local development)

2. **Verify Local Installation**
   - Access http://localhost:5678
   - Create owner account
   - Quick tour of interface

### Phase 3: Cloud Deployment (25 minutes)

1. **Start Deployment** (5 min)
   ```bash
   ./scripts/deploy.sh
   ```
   - Explain each step as it runs
   - Highlight billing requirement

2. **Monitor Progress** (20 min)
   - Watch Cloud Run initialization
   - Explain automatic retries
   - Troubleshoot any issues

3. **Coffee Break** (10 min)
   - While Cloud SQL creates (~15 min total)

### Phase 4: Workflow Creation (15 minutes)

1. **Import Templates**
   - Show `workflows/` directory
   - Import study-assistant.json
   - Explain node connections

2. **Add Gemini Integration**
   - Credentials setup
   - Test the workflow
   - Demonstrate AI responses

3. **Customize & Test**
   - Modify prompts
   - Add custom nodes
   - Run test workflows

### Phase 5: Wrap Up (5 minutes)

1. **Resource Cleanup** (optional)
   ```bash
   ./scripts/cleanup.sh
   ```

2. **Next Steps**
   - Share documentation links
   - Additional resources
   - Q&A

## 🎓 Teaching Tips

### For First-Time Facilitators

1. **Always have a backup plan:**
   - Demo project ready to show
   - Pre-deployed instance for reference
   - Screenshots of successful deployments

2. **Set expectations:**
   - "First deployment can take 15-20 minutes"
   - "Errors are normal, we have automatic retries"
   - "Local development is faster for testing"

3. **Use the diagnostic tool early:**
   ```bash
   # Run this at the start
   ./scripts/diagnose.sh
   ```

4. **Keep participants engaged during waits:**
   - Explain architecture while deploying
   - Show workflow examples
   - Discuss use cases

### Common Questions

**Q: Will this cost money?**
A: Free tier covers this ($300 credit), but ~$12-25/month after. Can delete immediately after workshop.

**Q: Can I use an existing project?**
A: Yes! Edit `config/.env` and set `PROJECT_ID`.

**Q: Why is deployment slow?**
A: Cloud SQL creation takes 10-15 min. This is normal for managed databases.

**Q: Do I need Docker?**
A: Only for local development. Cloud deployment doesn't need it.

**Q: Can I stop and resume?**
A: Yes! Each script can be run independently. Use `./scripts/diagnose.sh` to check state.

## 📊 Success Metrics

By the end of the workshop, participants should:

- ✅ Have n8n running (locally or cloud)
- ✅ Successfully imported a workflow
- ✅ Connected Gemini API
- ✅ Run at least one AI workflow
- ✅ Understand how to troubleshoot issues

## 🆘 Emergency Contacts

If stuck, check:
1. `./scripts/diagnose.sh` - Automatic diagnostics
2. `docs/TROUBLESHOOTING.md` - Detailed solutions
3. `docs/DEPLOYMENT.md` - Step-by-step guide
4. GitHub Issues - Report bugs

## 📝 Feedback Collection

After workshop:
- What worked well?
- What was confusing?
- Which errors did you encounter?
- Suggestions for improvement?

Use feedback to update this guide!

---

**Last Updated:** November 2025  
**Tested With:** n8n latest, gcloud SDK 547.0.0, Docker 24.x
