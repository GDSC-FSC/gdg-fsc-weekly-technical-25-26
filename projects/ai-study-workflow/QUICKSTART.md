# Quick Start Guide

Get your AI study workflow up and running in minutes!

## ⚡ Fastest Path to Success

### Option 1: Automated Setup (Recommended)

```bash
cd projects/ai-study-workflow
./setup.sh
```

Follow the wizard prompts. It will guide you through everything!

### Option 2: Direct Deployment

If you already have gcloud configured:

```bash
cd projects/ai-study-workflow
chmod +x scripts/*.sh
./scripts/deploy.sh
```

Wait 15-20 minutes, and you're done! ☕

### Option 3: Local Testing First

```bash
cd projects/ai-study-workflow/config
docker-compose up -d
```

Access n8n at: `http://localhost:5678`

## 📋 Prerequisites Checklist

- [ ] Google Cloud account
- [ ] Billing enabled ($300 free credit available)
- [ ] Gemini API key ([Get it here](https://aistudio.google.com/app/api-keys))
- [ ] Terminal/Command line access

## 🚀 5-Minute Deployment

```bash
# 1. Navigate to project
cd projects/ai-study-workflow

# 2. Run setup wizard
./setup.sh

# 3. Follow prompts:
#    - Confirm GCP account
#    - Enter Gemini API key (optional)
#    - Select region (default: us-central1)
#    - Choose deployment option

# 4. Wait for deployment (15-20 min)

# 5. Access your n8n instance
# URL will be displayed at the end
```

## 📚 First Steps After Deployment

1. **Access n8n**
   - Open the URL provided after deployment
   - Create owner account

2. **Add Gemini API Key**
   - Credentials → Add → "Google Gemini (PaLM) API"
   - Paste your API key
   - Save

3. **Import a Workflow**
   - Workflows → Import from File
   - Choose `workflows/study-assistant.json`
   - Test it!

4. **Try the Study Assistant**
   - Execute the workflow
   - Ask: "Explain machine learning in simple terms"
   - See the magic happen! ✨

## 🎯 Common Use Cases

### For Students

```bash
# Import study assistant
# Use for: homework help, concept explanation, exam prep
```

### For Researchers

```bash
# Import research helper
# Configure: research topics, Google Sheets
# Schedule: daily literature reviews
```

### For Lifelong Learners

```bash
# Import all workflows
# Create custom learning pipeline
```

## 💡 Quick Tips

1. **Start Simple**: Import one workflow first
2. **Test Locally**: Use Docker Compose before cloud deployment
3. **Read Docs**: Check `docs/` for detailed guides
4. **Monitor Costs**: Set budget alerts in GCP Console
5. **Backup Regularly**: Run `./scripts/backup.sh` weekly

## 🆘 Quick Troubleshooting

**Deployment fails?**
```bash
# Check logs
gcloud run logs read n8n --region=us-central1

# Retry specific step
./scripts/04-deploy-n8n.sh
```

**Can't access n8n?**
```bash
# Get service URL
gcloud run services describe n8n --region=us-central1 --format='value(status.url)'

# Check health
curl https://your-url.run.app/healthz
```

**Workflow not working?**
- Ensure workflow is "Active"
- Check all credentials are connected
- View execution logs in n8n

## 📖 Documentation

| Document | Purpose |
|----------|---------|
| [README.md](README.md) | Project overview |
| [DEPLOYMENT.md](docs/DEPLOYMENT.md) | Detailed deployment guide |
| [WORKFLOWS.md](docs/WORKFLOWS.md) | Workflow documentation |
| [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) | Common issues |

## 🎓 Learning Resources

- [n8n Documentation](https://docs.n8n.io/)
- [Gemini API Docs](https://ai.google.dev/)
- [n8n Community](https://community.n8n.io/)
- [Original Guide](https://www.philschmid.de/n8n-cloud-run-gemini)

## 🧹 Cleanup

When you're done experimenting:

```bash
./scripts/cleanup.sh
```

**Warning**: This deletes everything! Backup first if needed.

## 💰 Cost Management

**Estimated Monthly Cost**: $12-25

**Reduce Costs**:
```bash
# Set minimum instances to 0
gcloud run services update n8n --min-instances=0 --region=us-central1
```

**Monitor Costs**:
- GCP Console → Billing → Budgets
- Set alert at $20/month

## 🚦 Status Checks

```bash
# Check service status
./scripts/monitor.sh

# View logs
gcloud run logs read n8n --region=us-central1 --limit=50

# Database status
gcloud sql instances describe n8n-db
```

## 🎉 You're Ready!

Everything you need is set up. Now go automate your studying!

**Next**: Import a workflow and try it out!

---

**Questions?** Check [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) or the [n8n Community Forum](https://community.n8n.io/)
