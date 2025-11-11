# Workflow Templates

This directory contains pre-built n8n workflow templates for AI-powered study automation.

## Available Workflows

### 1. 📚 Smart Study Assistant (`study-assistant.json`)
An interactive AI tutor powered by Google Gemini that helps with studying and learning.

**Features**:
- Interactive chat interface
- Context-aware responses
- Explains complex concepts
- Generates study materials

**How to Use**:
1. Import in n8n
2. Connect Gemini API credentials
3. Execute and start chatting

---

### 2. 🔬 Research Paper Helper (`research-helper.json`)
Automated research assistant that finds and analyzes academic papers.

**Features**:
- Daily arXiv searches
- AI-powered paper analysis
- Google Sheets integration
- Automated literature reviews

**How to Use**:
1. Import in n8n
2. Connect Google Sheets
3. Configure research topics
4. Schedule or run manually

---

### 3. 📅 Study Schedule Manager (`schedule-manager.json`)
Creates optimized study schedules based on your subjects and exam dates.

**Features**:
- AI-optimized scheduling
- Google Calendar sync
- Webhook API
- Personalized recommendations

**How to Use**:
1. Import in n8n
2. Connect Google Calendar
3. Activate workflow
4. Send POST request to webhook

**Example API Call**:
```bash
curl -X POST https://your-n8n-url/webhook/study-schedule \
  -H "Content-Type: application/json" \
  -d '{
    "subjects": [
      {"name": "Math", "difficulty": "hard"},
      {"name": "History", "difficulty": "medium"}
    ],
    "hoursPerDay": 6,
    "examDates": {
      "Math": "2024-12-15",
      "History": "2024-12-18"
    },
    "goals": "Focus on problem-solving"
  }'
```

---

### 4. 📝 Note-Taking Automation (`note-taking.json`)
Automatically processes and organizes study notes from Google Drive.

**Features**:
- Monitors Google Drive folder
- Extracts key concepts
- Creates summaries
- Generates review questions
- Database storage

**How to Use**:
1. Import in n8n
2. Connect Google Drive
3. Create trigger folder
4. Upload notes
5. Get processed notes

---

## Importing Workflows

### Method 1: Via n8n UI
1. Open your n8n instance
2. Click **"Workflows"** in sidebar
3. Click **"Import from file"**
4. Select the `.json` file
5. Configure credentials
6. Save and activate

### Method 2: Via API
```bash
curl -X POST https://your-n8n-url/api/v1/workflows \
  -H "X-N8N-API-KEY: your-api-key" \
  -H "Content-Type: application/json" \
  -d @study-assistant.json
```

---

## Customization Tips

### Adjust AI Temperature
Lower = More focused, Higher = More creative
```json
{
  "temperature": 0.7
}
```

### Modify Prompts
Edit the system prompts to match your needs:
```
You are a study assistant specializing in [SUBJECT]
```

### Change Schedules
Edit trigger times in Schedule nodes:
```json
{
  "triggerAtHour": 9
}
```

---

## Required Credentials

Each workflow requires different credentials:

| Workflow | Required Credentials |
|----------|---------------------|
| Study Assistant | Google Gemini API |
| Research Helper | Google Gemini API, Google Sheets |
| Schedule Manager | Google Gemini API, Google Calendar |
| Note-Taking | Google Gemini API, Google Drive, PostgreSQL |

---

## Workflow Combinations

Create powerful automation chains:

**Daily Study Routine**:
1. Research Helper → Find new papers (9 AM)
2. Schedule Manager → Create daily plan (10 AM)
3. Note-Taking → Process lecture notes (automatically)
4. Study Assistant → Interactive learning (on-demand)

---

## Troubleshooting

**Workflow won't activate**:
- Check all credentials are connected
- Ensure APIs are enabled
- Verify webhook URLs

**AI responses are poor**:
- Adjust temperature
- Improve prompts
- Add examples

**Integrations fail**:
- Reauthorize OAuth
- Check API quotas
- Verify permissions

For more help, see [TROUBLESHOOTING.md](../docs/TROUBLESHOOTING.md)

---

## Creating Custom Workflows

Use these templates as starting points:

1. **Duplicate a template**
2. **Modify nodes** to your needs
3. **Test thoroughly**
4. **Share with the community**

---

## Contributing

Have a useful workflow? Share it!

1. Export your workflow
2. Add to this directory
3. Document in this README
4. Submit a pull request

---

## Resources

- [n8n Workflow Documentation](https://docs.n8n.io/workflows/)
- [n8n Community Workflows](https://n8n.io/workflows/)
- [Gemini API Documentation](https://ai.google.dev/)
- [Google Workspace APIs](https://developers.google.com/workspace)

---

**Happy Automating! 🚀**
