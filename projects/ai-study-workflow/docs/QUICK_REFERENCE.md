# Workshop Quick Reference Card

**Print this for easy reference during workshops!**

---

## 🚀 Quick Commands

### Essential Workshop Commands
```bash
# 1. First thing - run diagnostics
./scripts/diagnose.sh

# 2. Interactive setup (recommended)
./setup.sh

# 3. Or manual deployment
./scripts/deploy.sh

# 4. Check status anytime
gcloud run services list --region=$REGION
```

---

## 🚨 Emergency Fixes

### Port 5678 Conflict
```bash
# Find & stop conflicting container
docker ps -a | grep 5678
docker stop <container-name>

# Or use auto-fix
./scripts/diagnose.sh
```

### "Resource Readiness Exceeded"
**Don't panic!** This is normal on first deployment.

```bash
# Script auto-retries 3 times
# If still fails, wait 2 min and run:
./scripts/04-deploy-n8n.sh
```

### Billing Not Enabled
```bash
# 1. Get project ID
echo $PROJECT_ID

# 2. Open billing page
https://console.cloud.google.com/billing/linkedaccount?project=<PROJECT_ID>

# 3. Verify billing
gcloud beta billing projects describe $PROJECT_ID
```

### Wrong Google Account
```bash
# Check current account
gcloud config get-value account

# Switch accounts
gcloud auth login
gcloud config set account your-email@gmail.com
```

### Can't Find Project
```bash
# List all projects
gcloud projects list

# Use direct URL
https://console.cloud.google.com/home/dashboard?project=<PROJECT_ID>

# Check you're on the right account!
```

---

## ⏱️ Time Estimates

| Phase | Time | Notes |
|-------|------|-------|
| Prerequisites | 10 min | Done before workshop |
| Diagnostics | 2 min | Run first! |
| Local setup | 5 min | Docker only |
| Cloud deployment | 40-60 min | Background OK |
| Cloud SQL creation | 15 min | Longest wait |
| Workflow import | 5 min | Multiple templates |

**Total Workshop:** 90 minutes

---

## 📋 Workshop Flow

```
┌─────────────────────────────────────┐
│ 0:00 - Intro (10 min)               │
│  └─ Run diagnostics                 │
├─────────────────────────────────────┤
│ 0:10 - Local Setup (15 min)         │
│  └─ ./setup.sh → Option 2           │
├─────────────────────────────────────┤
│ 0:25 - Cloud Deploy (25 min)        │
│  └─ ./scripts/deploy.sh             │
│  └─ ☕ Break during SQL creation    │
├─────────────────────────────────────┤
│ 0:50 - Workflows (15 min)           │
│  └─ Import & test templates         │
├─────────────────────────────────────┤
│ 1:05 - Advanced & Q&A (25 min)      │
└─────────────────────────────────────┘
```

---

## 🔍 Diagnostic Checklist

Run `./scripts/diagnose.sh` to check:

- ✅ curl, openssl, git installed
- ✅ Docker running & port free
- ✅ Config files valid
- ✅ gcloud authenticated
- ✅ Correct project active
- ✅ Billing enabled
- ✅ Cloud resources healthy

**Auto-fixes:**
- Port conflicts
- Wrong project
- Unhealthy containers

---

## 📊 Success Metrics

By end of workshop, participants should have:

- ✅ n8n running (local OR cloud)
- ✅ Workflow imported
- ✅ Gemini API connected
- ✅ At least one AI workflow tested

---

## 🆘 Common Questions

**Q: Will this cost money?**  
A: ~$12-25/month. Free tier covers workshop. Can delete after.

**Q: How long does deployment take?**  
A: 40-60 min total. Cloud SQL is 15 min of that.

**Q: Can I use existing project?**  
A: Yes! Edit `config/.env` and set `PROJECT_ID`.

**Q: What if I'm on wrong account?**  
A: `gcloud auth login` to switch. Project won't appear on wrong account.

**Q: Local or cloud first?**  
A: Local is faster for testing. Cloud for production.

---

## 🛠️ Troubleshooting Stack

**Level 1:** Diagnostic tool
```bash
./scripts/diagnose.sh
```

**Level 2:** Manual checks
```bash
docker ps                          # Check containers
gcloud auth list                   # Check account
gcloud config get-value project    # Check project
gcloud run services list           # Check deployment
```

**Level 3:** Logs
```bash
docker-compose logs                # Local logs
gcloud run logs read n8n           # Cloud logs
```

**Level 4:** Documentation
- `docs/WORKSHOP_GUIDE.md` - Full guide
- `docs/TROUBLESHOOTING.md` - All errors
- `docs/DEPLOYMENT.md` - Step-by-step

---

## 📞 Quick Links

- **Gemini API:** https://aistudio.google.com/app/api-keys
- **GCP Console:** https://console.cloud.google.com
- **Billing:** https://console.cloud.google.com/billing
- **gcloud Install:** https://cloud.google.com/sdk/docs/install
- **Docker Install:** https://docs.docker.com/get-docker/

---

## 💡 Pro Tips

1. **Always start with diagnostics** - Catches 80% of issues
2. **Use auto-retry** - Don't manually retry Cloud Run
3. **Check account first** - Most "missing project" issues
4. **Local for testing** - Faster iteration
5. **Coffee during SQL** - 15 min wait is perfect break
6. **Import templates** - Don't build from scratch
7. **Cleanup after** - `./scripts/cleanup.sh` to avoid charges

---

## 🎯 Facilitator Checklist

### Before Workshop
- [ ] Test full deployment yourself
- [ ] Prepare demo GCP project
- [ ] Have spare Gemini API keys
- [ ] Print this reference card
- [ ] Share prerequisites 1 day before

### During Workshop
- [ ] Everyone runs `diagnose.sh` first
- [ ] Use wizard (`setup.sh`) for beginners
- [ ] Monitor Cloud Run retries (now automatic)
- [ ] Plan breaks during long waits
- [ ] Keep WORKSHOP_GUIDE.md open

### After Workshop
- [ ] Collect feedback
- [ ] Note new issues
- [ ] Update documentation
- [ ] Remind about cleanup

---

## ⚡ One-Liners

```bash
# Complete health check
./scripts/diagnose.sh && echo "✓ Ready for workshop!"

# Quick deployment status
gcloud run services describe n8n --region=$REGION --format='value(status.url,status.conditions[0].status)'

# Force retry Cloud Run
./scripts/04-deploy-n8n.sh

# Complete cleanup
./scripts/cleanup.sh && rm -rf config/.env

# Get service URL
echo "n8n URL: $(gcloud run services describe n8n --region=$REGION --format='value(status.url)')"
```

---

**Version:** 1.0  
**Last Updated:** November 2025  
**Tested:** ✅ Ready for production workshops

---

**📌 Pin this to your desk during workshops!**
