# Workflow Documentation

Comprehensive guide to using the AI study workflow templates.

## Overview

This project includes four pre-built workflow templates designed to automate various aspects of studying and research:

1. **Smart Study Assistant** - AI-powered study helper
2. **Research Paper Helper** - Automated literature review
3. **Study Schedule Manager** - Intelligent scheduling
4. **Note-Taking Automation** - Automatic note organization

---

## 1. Smart Study Assistant

**File**: `workflows/study-assistant.json`

### Purpose
An interactive AI assistant that helps with studying, answering questions, creating summaries, and generating study materials.

### Features
- ✅ Conversational AI powered by Gemini
- ✅ Context-aware responses with memory
- ✅ Can explain complex concepts
- ✅ Generates study materials on demand

### Setup

1. **Import the workflow**
   ```
   Workflows → Import from File → study-assistant.json
   ```

2. **Configure Gemini credentials**
   - The workflow uses Google Gemini Chat Model
   - Ensure your Gemini API credential is connected

3. **Test the workflow**
   - Click "Execute Workflow"
   - Use the chat interface

### Usage Examples

**Example 1: Explain a Concept**
```
User: Explain photosynthesis in simple terms
AI: Photosynthesis is the process by which plants...
```

**Example 2: Create Study Materials**
```
User: Create 5 flashcards about the water cycle
AI: [Generates flashcards with questions and answers]
```

**Example 3: Problem Solving**
```
User: Help me solve this math problem: 2x + 5 = 15
AI: Let's solve this step by step...
```

### Customization

Edit the AI Agent node to customize:
```javascript
{
  "systemMessage": "You are a helpful study assistant specializing in [YOUR SUBJECT]",
  "temperature": 0.7,  // Creativity (0-1)
  "maxTokens": 2048    // Response length
}
```

### Best Practices
- Start sessions with context: "I'm studying biology for my exam"
- Ask follow-up questions for deeper understanding
- Request specific formats: "Summarize in bullet points"

---

## 2. Research Paper Helper

**File**: `workflows/research-helper.json`

### Purpose
Automatically searches for research papers, analyzes them, and organizes findings in Google Sheets.

### Features
- ✅ Daily automated searches on arXiv
- ✅ AI-powered paper analysis
- ✅ Extracts key findings and methodologies
- ✅ Saves results to Google Sheets
- ✅ Suggests related work

### Setup

1. **Import the workflow**

2. **Configure credentials**
   - Google Sheets API (for saving results)
   - Gemini API (for analysis)

3. **Create a Google Sheet**
   - Create a sheet with columns:
     - Title
     - Authors
     - Summary
     - Key Findings
     - Methodology
     - Related Work
     - Date Added

4. **Configure the workflow**
   - Edit "Schedule Trigger" for your preferred time
   - Update "Save to Google Sheets" with your sheet ID
   - Set research topics in the webhook/trigger

### Usage

**Automated Mode** (Recommended):
- Workflow runs daily at 9 AM
- Searches for papers on configured topics
- Results automatically saved to Google Sheets

**Manual Mode**:
- Click "Execute Workflow"
- Enter research topic when prompted
- View results in Google Sheets

### Research Topics Configuration

Edit the HTTP Request node:
```javascript
{
  "topics": [
    "machine learning",
    "quantum computing",
    "renewable energy"
  ],
  "maxResults": 10
}
```

### Output Format

The workflow generates:
1. **Summary**: 200-word overview
2. **Key Findings**: Main contributions
3. **Methodology**: Research approach
4. **Related Work**: Suggested papers
5. **Applications**: Potential uses

### Advanced Features

**Filter by Date**:
```javascript
{
  "dateFrom": "2024-01-01",
  "dateTo": "2024-12-31"
}
```

**Specific Authors**:
```javascript
{
  "author": "Hinton, Geoffrey"
}
```

---

## 3. Study Schedule Manager

**File**: `workflows/schedule-manager.json`

### Purpose
Creates personalized study schedules based on your subjects, exam dates, and available time.

### Features
- ✅ AI-optimized scheduling
- ✅ Considers exam priorities
- ✅ Includes breaks and review sessions
- ✅ Syncs with Google Calendar
- ✅ Webhook API for integrations

### Setup

1. **Import the workflow**

2. **Configure credentials**
   - Google Calendar API

3. **Activate the workflow**
   - Click "Active" toggle

4. **Get webhook URL**
   - Click on Webhook node
   - Copy the Production URL

### Usage

**Via Webhook API**:

```bash
curl -X POST https://your-n8n-url.run.app/webhook/study-schedule \
  -H "Content-Type: application/json" \
  -d '{
    "subjects": [
      {"name": "Mathematics", "difficulty": "hard"},
      {"name": "History", "difficulty": "medium"},
      {"name": "Chemistry", "difficulty": "hard"}
    ],
    "hoursPerDay": 6,
    "examDates": {
      "Mathematics": "2024-12-15",
      "History": "2024-12-18",
      "Chemistry": "2024-12-20"
    },
    "goals": "Focus on problem-solving for Math, memorization for History"
  }'
```

**Response**:
```json
{
  "success": true,
  "message": "Study schedule created",
  "schedule": {
    "Monday": [...],
    "Tuesday": [...],
    ...
  }
}
```

### Schedule Customization

Edit the AI prompt to customize scheduling logic:
```
System instructions:
- Prioritize subjects with earlier exam dates
- Allocate more time to difficult subjects
- Include 10-minute breaks every hour
- Review sessions every 3 days
- No study sessions longer than 2 hours
```

### Integration Examples

**With Mobile App**:
Create a simple mobile app that sends POST requests to the webhook.

**With Google Forms**:
Use Google Apps Script to trigger the webhook when form is submitted.

**With Notion**:
Use Notion automation to create schedules from database.

---

## 4. Note-Taking Automation

**File**: `workflows/note-taking.json`

### Purpose
Automatically processes uploaded notes, extracts key information, and organizes them intelligently.

### Features
- ✅ Monitors Google Drive for new files
- ✅ Processes multiple file formats
- ✅ Extracts key concepts and definitions
- ✅ Creates summaries
- ✅ Generates review questions
- ✅ Organizes by topics
- ✅ Saves to database

### Setup

1. **Import the workflow**

2. **Configure credentials**
   - Google Drive API
   - PostgreSQL (already configured)

3. **Create trigger folder**
   - Create a folder in Google Drive (e.g., "Study Notes")
   - Note the folder ID

4. **Update workflow**
   - Edit "Google Drive Trigger"
   - Set folder ID

5. **Create database table**
   ```sql
   CREATE TABLE notes (
     id SERIAL PRIMARY KEY,
     title VARCHAR(255),
     content TEXT,
     summary TEXT,
     topics TEXT[],
     created_at TIMESTAMP DEFAULT NOW()
   );
   ```

### Usage

1. **Upload notes to monitored folder**
   - Supported formats: PDF, DOCX, TXT, MD
   - Naming convention: `SUBJECT_TOPIC_DATE.ext`

2. **Automatic processing**
   - Workflow detects new file
   - Downloads and extracts text
   - AI processes content
   - Creates organized markdown file
   - Saves to database

3. **Review processed notes**
   - Check Google Drive for `*_processed.md` files
   - Query database for searchable notes

### Processing Features

The AI automatically:
1. **Organizes by Topics**
   - Main topics and subtopics
   - Hierarchical structure

2. **Extracts Key Information**
   - Definitions
   - Formulas
   - Important facts
   - Examples

3. **Creates Summary**
   - 200-word overview
   - Main takeaways

4. **Generates Questions**
   - 5 review questions
   - Varying difficulty

### Example Output

```markdown
# Physics - Thermodynamics
*Processed on 2024-11-11*

## Summary
This lecture covers the fundamental laws of thermodynamics...

## Key Concepts

### First Law of Thermodynamics
Definition: Energy cannot be created or destroyed...

### Important Formulas
- ΔU = Q - W
- PV = nRT

## Review Questions
1. What is entropy?
2. Explain the Carnot cycle...

## Related Topics
- Statistical mechanics
- Heat engines
```

### Database Queries

**Search notes by topic**:
```sql
SELECT * FROM notes 
WHERE 'thermodynamics' = ANY(topics);
```

**Recent notes**:
```sql
SELECT * FROM notes 
ORDER BY created_at DESC 
LIMIT 10;
```

**Full-text search**:
```sql
SELECT * FROM notes 
WHERE content LIKE '%entropy%';
```

---

## Workflow Combinations

### Study Session Flow
1. **Schedule Manager** → Creates weekly schedule
2. **Study Assistant** → Interactive learning during sessions
3. **Note-Taking** → Automatically processes session notes

### Research Flow
1. **Research Helper** → Finds relevant papers
2. **Note-Taking** → Processes paper summaries
3. **Study Assistant** → Answers questions about research

---

## Tips for Success

### 1. Start Simple
Begin with one workflow, understand it, then add more.

### 2. Customize Prompts
Edit AI prompts to match your learning style and subjects.

### 3. Regular Backups
```bash
./scripts/backup.sh
```

### 4. Monitor Performance
```bash
./scripts/monitor.sh
```

### 5. Iterate
Track what works, adjust workflows based on results.

---

## Advanced: Creating Custom Workflows

### Example: Flashcard Generator

1. **Create new workflow**
2. **Add trigger** (manual or scheduled)
3. **Add AI Agent** with custom prompt:
   ```
   Create flashcards from this content: {{ $input }}
   Format: Question | Answer (one per line)
   ```
4. **Add output** (Google Sheets, Anki, etc.)

### Example: Study Group Coordinator

1. **Webhook trigger** for group requests
2. **AI Agent** to suggest meeting times
3. **Google Calendar** integration
4. **Email notifications** to group members

---

## Troubleshooting

### Workflow Not Executing
- Check if workflow is active
- Verify all credentials are connected
- Check execution logs in n8n

### AI Responses Incorrect
- Adjust temperature (lower = more focused)
- Improve prompt specificity
- Add examples to prompts

### Integration Issues
- Reauthorize OAuth connections
- Check API quotas
- Verify permissions

---

## Resources

- [n8n Documentation](https://docs.n8n.io/)
- [Gemini API Docs](https://ai.google.dev/)
- [Community Workflows](https://n8n.io/workflows/)
- [n8n Forum](https://community.n8n.io/)

---

**Happy Automating! 🚀**
