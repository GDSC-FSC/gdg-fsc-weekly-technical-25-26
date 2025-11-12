# PostgreSQL Credentials Setup for n8n

## 📋 Your Database Connection Details

### Cloud SQL Instance Information

**Connection Name:** `n8n-study-incfj9ke0d:us-east1:n8n-db`  
**Host (Public IP):** `34.23.241.6`  
**Database Name:** `n8n`  
**Port:** `5432`  
**User:** `n8n-user`  
**Password:** `QNpewBs0Oo7DC+zXC5RIOw==`

**SSL Mode:** `require` (recommended)

---

## 🔧 Method 1: Add PostgreSQL Credentials in n8n UI

### Step-by-Step Instructions

1. **Open your n8n instance:**
   - Go to: https://n8n-665354400041.us-east1.run.app

2. **Navigate to Credentials:**
   - Click **"Credentials"** in the left sidebar (🔑 icon)

3. **Add New Credential:**
   - Click **"Add Credential"** button (top right)
   - Search for: **"Postgres"** or **"PostgreSQL"**
   - Click on **"Postgres"** when it appears

4. **Fill in the Connection Details:**

   ```
   Name: Cloud SQL PostgreSQL
   
   Host: 34.23.241.6
   
   Database: n8n
   
   User: n8n-user
   
   Password: QNpewBs0Oo7DC+zXC5RIOw==
   
   Port: 5432
   
   SSL: Enabled (or "require")
   ```

5. **Test the Connection:**
   - Click **"Test"** or **"Save"** button
   - Should show "Connection successful" ✅

6. **Save:**
   - Click **"Create"** or **"Save"**
   - Your credential is now available!

---

## 🌐 Method 2: Using the Public IP (External Access)

### Configuration

**Use this if connecting from outside Cloud Run:**

```
Host: 34.23.241.6
Port: 5432
Database: n8n
User: n8n-user
Password: QNpewBs0Oo7DC+zXC5RIOw==
SSL Mode: require
```

### Important Notes

⚠️ **The public IP must be whitelisted in Cloud SQL**

To allow connections:

```bash
# Allow your IP address
gcloud sql instances patch n8n-db \
  --authorized-networks=YOUR_IP_ADDRESS \
  --project=n8n-study-incfj9ke0d

# Or allow all IPs (NOT RECOMMENDED for production)
gcloud sql instances patch n8n-db \
  --authorized-networks=0.0.0.0/0 \
  --project=n8n-study-incfj9ke0d
```

---

## 🔒 Method 3: Using Unix Socket (Recommended for Cloud Run)

### Configuration

**This is what n8n uses internally on Cloud Run:**

```
Host: /cloudsql/n8n-study-incfj9ke0d:us-east1:n8n-db
Port: 5432
Database: n8n
User: n8n-user
Password: QNpewBs0Oo7DC+zXC5RIOw==
```

### When to Use

- ✅ **From Cloud Run** (where n8n is running)
- ✅ **Most secure** (no public internet)
- ✅ **Better performance** (local socket)

### When NOT to Use

- ❌ From your local machine
- ❌ From other cloud services
- ❌ External workflows

---

## 🧪 Testing the Connection

### Using psql (Command Line)

```bash
# Install psql if needed
sudo apt-get install postgresql-client

# Connect to database
psql "host=34.23.241.6 \
      port=5432 \
      dbname=n8n \
      user=n8n-user \
      password=QNpewBs0Oo7DC+zXC5RIOw== \
      sslmode=require"
```

### Using n8n Workflow

Create a simple test workflow:

1. **Add "Postgres" node**
2. **Select your credential**
3. **Operation:** "Execute Query"
4. **Query:** 
   ```sql
   SELECT current_database(), current_user, version();
   ```
5. **Execute workflow**
6. **Check output** - should show database info

---

## 📊 Common Use Cases

### 1. Save Chat History (from Study Assistant)

The workflow already includes this! Check the "Save Chat History" node:

```json
{
  "table": "chat_history",
  "columns": {
    "session_id": "={{ $json.sessionId }}",
    "user_message": "={{ $json.message }}",
    "ai_response": "={{ $json.response }}",
    "created_at": "={{ $json.timestamp }}"
  }
}
```

### 2. Store Research Papers

```sql
CREATE TABLE research_papers (
    id SERIAL PRIMARY KEY,
    arxiv_id VARCHAR(50) UNIQUE,
    title TEXT,
    authors TEXT[],
    summary TEXT,
    published DATE,
    categories TEXT[],
    pdf_link TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 3. Track Study Progress

```sql
CREATE TABLE study_progress (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(100),
    topic VARCHAR(200),
    status VARCHAR(50),
    quiz_score INTEGER,
    completed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 🔐 Security Best Practices

### 1. Use Environment Variables

Instead of hardcoding password:
- Store in n8n credentials (encrypted)
- Use Secret Manager (already done!)
- Never commit to git

### 2. Limit Database Permissions

```sql
-- Create read-only user for analytics
CREATE USER readonly_user WITH PASSWORD 'secure_password';
GRANT CONNECT ON DATABASE n8n TO readonly_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly_user;
```

### 3. Enable SSL

Always use SSL for connections:
```
SSL Mode: require
```

### 4. Whitelist IPs

Only allow specific IPs to connect:
```bash
gcloud sql instances patch n8n-db \
  --authorized-networks=YOUR_IP \
  --project=n8n-study-incfj9ke0d
```

---

## 🛠️ Troubleshooting

### Error: "Connection refused"

**Cause:** IP not whitelisted or wrong host

**Fix:**
```bash
# Check current authorized networks
gcloud sql instances describe n8n-db \
  --project=n8n-study-incfj9ke0d \
  --format="value(settings.ipConfiguration.authorizedNetworks)"

# Add your IP
gcloud sql instances patch n8n-db \
  --authorized-networks=YOUR_IP \
  --project=n8n-study-incfj9ke0d
```

### Error: "Authentication failed"

**Cause:** Wrong username or password

**Fix:**
```bash
# Get the correct password
gcloud secrets versions access latest \
  --secret=n8n-db-password \
  --project=n8n-study-incfj9ke0d

# Verify username (should be n8n-user)
gcloud sql users list \
  --instance=n8n-db \
  --project=n8n-study-incfj9ke0d
```

### Error: "SSL connection required"

**Cause:** Trying to connect without SSL

**Fix:**
- Set SSL Mode to "require" in n8n
- Or use `sslmode=require` in connection string

### Error: "Database does not exist"

**Cause:** Wrong database name

**Fix:**
```bash
# List databases
gcloud sql databases list \
  --instance=n8n-db \
  --project=n8n-study-incfj9ke0d

# Should show "n8n" database
```

---

## 📚 Advanced Configuration

### Connection Pooling

For high-traffic workflows:

```
Pool Size: 10
Pool Timeout: 30000ms
Idle Timeout: 10000ms
```

### SSL Certificate

For maximum security:

1. Download server certificate:
```bash
gcloud sql ssl-certs create mycert mycert.pem \
  --instance=n8n-db \
  --project=n8n-study-incfj9ke0d
```

2. Use in connection:
```
SSL Mode: verify-ca
SSL Certificate: [upload mycert.pem]
```

---

## 💡 Quick Reference Card

### For n8n Workflows (Internal Cloud Run)

```
Credential Type: Postgres
Host: /cloudsql/n8n-study-incfj9ke0d:us-east1:n8n-db
Port: 5432
Database: n8n
User: n8n-user
Password: QNpewBs0Oo7DC+zXC5RIOw==
SSL: Not needed (Unix socket)
```

### For External Connections

```
Credential Type: Postgres
Host: 34.23.241.6
Port: 5432
Database: n8n
User: n8n-user
Password: QNpewBs0Oo7DC+zXC5RIOw==
SSL: require
```

---

## 📖 Resources

- **Cloud SQL Docs:** https://cloud.google.com/sql/docs/postgres
- **n8n Postgres Node:** https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.postgres/
- **Connection Best Practices:** https://cloud.google.com/sql/docs/postgres/connect-overview

---

## ✅ Checklist

After setting up PostgreSQL credentials:

- [ ] Credential created in n8n
- [ ] Connection tested successfully
- [ ] SSL enabled (if using public IP)
- [ ] IP whitelisted (if needed)
- [ ] Password stored securely
- [ ] Test query executed successfully
- [ ] Workflow using credential works

---

**Database Status:** ✅ Running  
**Connection Method:** Unix Socket (Cloud Run) or Public IP (External)  
**Security:** SSL Required, Secret Manager encrypted password

---

**Need help?** Check the troubleshooting section or run:
```bash
./scripts/diagnose.sh
```
