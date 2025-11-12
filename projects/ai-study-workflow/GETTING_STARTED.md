# 🚀 Getting Started with Your n8n Instance

**Your n8n URL:** https://n8n-665354400041.us-east1.run.app

## ✅ What You Have

- ✅ n8n running on Cloud Run
- ✅ Cloud SQL PostgreSQL database
- ✅ Gemini API key ready
- ✅ 4 pre-built workflow templates

---

## 📝 Step-by-Step Setup

### Step 1: Add Gemini API Credentials

1. Open: https://n8n-665354400041.us-east1.run.app
2. Click **"Credentials"** in left sidebar (🔑 icon)
3. Click **"Add Credential"** button (top right)
4. Search for: **"Google Gemini"** or **"Google PaLM API"**
5. Enter your API key: `AIzaSyBSjFtyGphiBaPb9ZMQ99eI2dAzRAR6opc`
6. Name it: **"Gemini Study Assistant"**
7. Click **"Save"**

> **⚠️ Security Note:** Your API key is visible here for setup. Consider rotating it after the workshop.

---

### Step 2: Import Your First Workflow

#### Option A: Smart Study Assistant (Recommended First)

This is the simplest workflow to test your setup.

1. Click **"Workflows"** in left sidebar
2. Click **"+ Add Workflow"** button
3. Click **"⋮"** menu (three dots, top right)
4. Select **"Import from File"**
5. Upload: `workflows/study-assistant.json`
6. Click the **Gemini Chat Model** node
7. Select your credential: **"Gemini Study Assistant"**
8. Click **"Execute Workflow"** to test
9. You should see AI responses!

---

### Step 3: Import Other Workflows

Once the first one works, import the others:

#### 📚 Research Helper
- **File:** `workflows/research-helper.json`
- **Purpose:** Searches arXiv for academic papers
- **Requires:** Google Sheets credential (optional)
- **Use Case:** "Find recent AI papers about transformers"

#### 📅 Schedule Manager  
- **File:** `workflows/schedule-manager.json`
- **Purpose:** Creates optimized study schedules
- **Requires:** Google Calendar credential (optional)
- **Use Case:** "Create a study schedule for finals week"

#### 📝 Note-Taking Automation
- **File:** `workflows/note-taking.json`
- **Purpose:** Processes notes from Google Drive
- **Requires:** Google Drive credential
- **Use Case:** Auto-organize and summarize lecture notes

---

## 🔧 Workflow Setup Details

### For Each Workflow:

1. **Import the JSON file**
   - Workflows → Add Workflow → Import from File

2. **Configure credentials**
   - Click on nodes with credential icons
   - Select or add your credentials

3. **Test the workflow**
   - Click "Execute Workflow" button
   - Check the output in each node

4. **Activate for automation**
   - Toggle the "Active" switch (top right)
   - Workflow will run based on triggers

---

## 🎯 Quick Test: Study Assistant

Let's verify everything works:

1. **Import** `study-assistant.json`
2. **Open the workflow**
3. **Click the Chat node** (at the end)
4. **Enter a test question:**
   ```
   Explain quantum computing in simple terms
   ```
5. **Click "Execute Workflow"**
6. **Check the output** - You should see AI-generated explanation!

---

## 🔑 Adding Other Credentials

### Google Drive (for note-taking workflow)

1. Credentials → Add Credential
2. Search: **"Google Drive"**
3. Click **"Sign in with Google"**
4. Authorize n8n
5. Save

### Google Calendar (for schedule manager)

1. Credentials → Add Credential
2. Search: **"Google Calendar"**
3. Click **"Sign in with Google"**
4. Authorize n8n
5. Save

### Google Sheets (for research helper)

1. Credentials → Add Credential
2. Search: **"Google Sheets"**
3. Click **"Sign in with Google"**
4. Authorize n8n
5. Save

---

## 💡 Tips & Tricks

### Workflow Execution

- **Manual Trigger:** Click "Execute Workflow" to run once
- **Active Mode:** Toggle "Active" to run automatically based on trigger
- **Debug Mode:** Click individual nodes to see their output

### Editing Workflows

- **Add Nodes:** Click "+" between nodes or drag from sidebar
- **Edit Node:** Click on any node to configure
- **Connect Nodes:** Drag from one output dot to another input dot
- **Delete Node:** Click node → Press Delete key

### Best Practices

1. **Test first:** Always test with "Execute Workflow" before activating
2. **Name your workflows:** Use descriptive names
3. **Document:** Add notes to complex workflows
4. **Version control:** Export workflows regularly as backup

---

## 📊 Workflow Overview

| Workflow | Complexity | Setup Time | Credentials Needed |
|----------|-----------|------------|-------------------|
| Study Assistant | ⭐ Easy | 2 min | Gemini only |
| Research Helper | ⭐⭐ Medium | 5 min | Gemini + Sheets (opt) |
| Schedule Manager | ⭐⭐ Medium | 5 min | Gemini + Calendar (opt) |
| Note-Taking | ⭐⭐⭐ Advanced | 10 min | Gemini + Drive |

**Start with Study Assistant!**

---

## 🚨 Troubleshooting

### "Credential not found" error
- Make sure you saved the Gemini credential
- Select it in the node configuration
- Name must match exactly

### "API key invalid" error
- Check your API key: `AIzaSyBSjFtyGphiBaPb9ZMQ99eI2dAzRAR6opc`
- Verify it's active at: https://aistudio.google.com/app/api-keys
- Try creating a new credential

### Workflow doesn't execute
- Check if all red nodes (errors) are resolved
- Ensure credentials are configured
- Try "Execute Workflow" instead of activating first

### Node shows error
- Click the node to see error details
- Check credential selection
- Verify API quotas haven't been exceeded

---

## 📚 Next Steps After Setup

### 1. Customize Workflows
- Edit prompts in AI nodes
- Adjust parameters
- Add your own nodes

### 2. Create New Workflows
- Start from scratch
- Combine different services
- Experiment with AI capabilities

### 3. Integrate with Your Tools
- Connect Google Workspace
- Add Notion, Slack, etc.
- Build custom automations

### 4. Learn More
- n8n Documentation: https://docs.n8n.io
- Community Workflows: https://n8n.io/workflows
- YouTube Tutorials: Search "n8n workflows"

---

## 🎓 Example Use Cases

### For Students

1. **Auto-summarize lecture notes**
   - Upload notes to Google Drive
   - n8n processes with Gemini
   - Saves summaries + flashcards

2. **Research paper analysis**
   - Trigger: New paper in folder
   - Extract key points with AI
   - Generate citations

3. **Study schedule optimization**
   - Input: Exam dates + subjects
   - AI creates optimal schedule
   - Syncs to Google Calendar

4. **Quiz generation**
   - Input: Study material
   - AI generates questions
   - Exports to Notion/Sheets

---

## 💾 Backup Your Work

### Export Workflows

1. Click workflow menu (⋮)
2. Select "Download"
3. Save JSON file locally

### Export All Settings

```bash
# Use the backup script
./scripts/backup.sh
```

This saves:
- All workflows
- Database
- Credentials (encrypted)

---

## 🔒 Security Reminders

1. **Rotate API keys** after workshop/testing
2. **Enable authentication** in n8n settings (optional)
3. **Review permissions** on Google OAuth apps
4. **Backup regularly** - Use `./scripts/backup.sh`
5. **Monitor costs** - Check GCP billing dashboard

---

## 📞 Resources

- **Your Instance:** https://n8n-665354400041.us-east1.run.app
- **Project Docs:** `docs/` folder
- **Workflow Templates:** `workflows/` folder
- **n8n Docs:** https://docs.n8n.io
- **Gemini API:** https://ai.google.dev/docs

---

## ✅ Quick Checklist

Setup checklist:
- [ ] Logged into n8n
- [ ] Added Gemini credential
- [ ] Imported study-assistant.json
- [ ] Tested workflow execution
- [ ] Imported other workflows
- [ ] Added additional credentials (optional)
- [ ] Customized workflows
- [ ] Backed up work

---

**Happy Automating! 🚀**

If you need help, check `docs/TROUBLESHOOTING.md` or `docs/WORKSHOP_GUIDE.md`.
