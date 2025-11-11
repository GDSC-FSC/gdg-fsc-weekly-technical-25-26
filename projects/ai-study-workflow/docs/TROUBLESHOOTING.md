# Troubleshooting Guide

Common issues and their solutions when deploying and using n8n on Google Cloud Run.

## Table of Contents

1. [Deployment Issues](#deployment-issues)
2. [Runtime Issues](#runtime-issues)
3. [Database Issues](#database-issues)
4. [Workflow Issues](#workflow-issues)
5. [Performance Issues](#performance-issues)
6. [API and Integration Issues](#api-and-integration-issues)

---

## Deployment Issues

### Issue: gcloud CLI Installation Fails

**Symptoms**: Error during `./scripts/01-setup-gcloud.sh`

**Solutions**:

1. **Manual Installation**:
   ```bash
   # For Linux
   curl https://sdk.cloud.google.com | bash
   exec -l $SHELL
   
   # For macOS
   brew install --cask google-cloud-sdk
   
   # For Windows (use PowerShell)
   # Download from: https://cloud.google.com/sdk/docs/install
   ```

2. **Verify Installation**:
   ```bash
   gcloud version
   ```

3. **Update PATH**:
   ```bash
   export PATH=$PATH:$HOME/google-cloud-sdk/bin
   ```

---

### Issue: Project Creation Fails

**Symptoms**: "Permission denied" or "Quota exceeded"

**Solutions**:

1. **Check Permissions**:
   - Ensure you have `resourcemanager.projects.create` permission
   - Contact your organization admin if needed

2. **Quota Limits**:
   - New accounts can create limited projects
   - Delete unused projects or request quota increase

3. **Billing Account**:
   ```bash
   # List billing accounts
   gcloud billing accounts list
   
   # Link to project
   gcloud billing projects link PROJECT_ID --billing-account=ACCOUNT_ID
   ```

---

### Issue: API Enablement Fails

**Symptoms**: "Service could not be enabled"

**Solutions**:

1. **Enable Manually**:
   ```bash
   gcloud services enable run.googleapis.com
   gcloud services enable sqladmin.googleapis.com
   gcloud services enable secretmanager.googleapis.com
   gcloud services enable iam.googleapis.com
   ```

2. **Check Billing**:
   - Ensure billing is enabled on the project
   - Visit: `https://console.cloud.google.com/billing`

3. **Wait and Retry**:
   - API enablement can take a few minutes
   - Wait 2-3 minutes and retry

---

### Issue: Cloud SQL Creation Timeout

**Symptoms**: "Operation timed out" during database creation

**Solutions**:

1. **Check Status**:
   ```bash
   gcloud sql operations list --instance=n8n-db
   ```

2. **Wait Longer**:
   - Cloud SQL creation takes 10-15 minutes
   - Check GCP Console for progress

3. **Check Quota**:
   ```bash
   gcloud compute regions describe $REGION
   ```

4. **Try Different Region**:
   ```bash
   export REGION=us-east1
   ./scripts/03-setup-database.sh
   ```

---

### Issue: Secret Manager Access Denied

**Symptoms**: "Permission denied" when creating secrets

**Solutions**:

1. **Enable API**:
   ```bash
   gcloud services enable secretmanager.googleapis.com
   ```

2. **Check IAM Permissions**:
   ```bash
   gcloud projects get-iam-policy PROJECT_ID
   ```

3. **Add Required Role**:
   ```bash
   gcloud projects add-iam-policy-binding PROJECT_ID \
     --member="user:YOUR_EMAIL" \
     --role="roles/secretmanager.admin"
   ```

---

### Issue: Cloud Run Deployment Fails

**Symptoms**: "Service deployment failed"

**Solutions**:

1. **Check Logs**:
   ```bash
   gcloud run deploy n8n --image=n8nio/n8n:latest --dry-run
   ```

2. **Verify Cloud SQL Connection**:
   ```bash
   gcloud sql instances describe n8n-db
   ```

3. **Check Service Account**:
   ```bash
   gcloud iam service-accounts list
   ```

4. **Manually Deploy**:
   ```bash
   ./scripts/04-deploy-n8n.sh
   ```

5. **Check Region Availability**:
   - Some regions have limited resources
   - Try `us-central1`, `us-east1`, or `europe-west1`

---

## Runtime Issues

### Issue: n8n Not Accessible

**Symptoms**: Service URL returns 404 or timeout

**Solutions**:

1. **Check Service Status**:
   ```bash
   gcloud run services describe n8n --region=$REGION
   ```

2. **Health Check**:
   ```bash
   curl -I https://your-n8n-url.run.app/healthz
   ```

3. **View Logs**:
   ```bash
   gcloud run logs read n8n --region=$REGION --limit=50
   ```

4. **Check Authentication**:
   - Ensure `--allow-unauthenticated` was set during deployment
   - Or use:
   ```bash
   gcloud run services add-iam-policy-binding n8n \
     --region=$REGION \
     --member="allUsers" \
     --role="roles/run.invoker"
   ```

---

### Issue: 500 Internal Server Error

**Symptoms**: n8n loads but shows 500 error

**Solutions**:

1. **Check Database Connection**:
   ```bash
   gcloud sql instances describe n8n-db --format="value(state)"
   ```

2. **Verify Secrets**:
   ```bash
   gcloud secrets versions access latest --secret=n8n-db-password
   gcloud secrets versions access latest --secret=n8n-encryption-key
   ```

3. **Check Environment Variables**:
   ```bash
   gcloud run services describe n8n --region=$REGION \
     --format="value(spec.template.spec.containers[0].env)"
   ```

4. **Restart Service**:
   ```bash
   gcloud run services update n8n --region=$REGION
   ```

---

### Issue: Slow Performance

**Symptoms**: n8n responds slowly or times out

**Solutions**:

1. **Increase Resources**:
   ```bash
   gcloud run services update n8n \
     --memory=4Gi \
     --cpu=2 \
     --region=$REGION
   ```

2. **Enable CPU Boost**:
   ```bash
   gcloud run services update n8n \
     --cpu-boost \
     --region=$REGION
   ```

3. **Set Minimum Instances**:
   ```bash
   gcloud run services update n8n \
     --min-instances=1 \
     --region=$REGION
   ```
   ⚠️ **Note**: Increases costs

4. **Optimize Workflows**:
   - Reduce concurrent executions
   - Use batch processing
   - Add delays between API calls

---

## Database Issues

### Issue: Database Connection Failed

**Symptoms**: "Could not connect to database"

**Solutions**:

1. **Check Database State**:
   ```bash
   gcloud sql instances describe n8n-db
   ```

2. **Verify Cloud SQL Connector**:
   ```bash
   gcloud run services describe n8n --region=$REGION \
     --format="value(spec.template.metadata.annotations)"
   ```

3. **Check Database User**:
   ```bash
   gcloud sql users list --instance=n8n-db
   ```

4. **Reset Password**:
   ```bash
   gcloud sql users set-password n8n-user \
     --instance=n8n-db \
     --password=NEW_PASSWORD
   
   # Update secret
   echo NEW_PASSWORD | gcloud secrets versions add n8n-db-password --data-file=-
   ```

---

### Issue: Database Out of Space

**Symptoms**: "Disk full" errors

**Solutions**:

1. **Check Storage**:
   ```bash
   gcloud sql instances describe n8n-db \
     --format="value(settings.dataDiskSizeGb)"
   ```

2. **Increase Storage**:
   ```bash
   gcloud sql instances patch n8n-db \
     --storage-size=20GB
   ```

3. **Enable Auto-resize**:
   ```bash
   gcloud sql instances patch n8n-db \
     --storage-auto-increase
   ```

4. **Clean Old Executions**:
   - In n8n: Settings → Executions
   - Set retention policy

---

## Workflow Issues

### Issue: Workflow Not Executing

**Symptoms**: Workflow doesn't run when triggered

**Solutions**:

1. **Check Workflow Status**:
   - Ensure workflow is "Active"
   - Check trigger configuration

2. **View Execution Log**:
   - n8n → Executions
   - Check error messages

3. **Test Manually**:
   - Click "Execute Workflow"
   - Check which node fails

4. **Verify Credentials**:
   - Credentials → Check all connections
   - Re-authenticate if needed

---

### Issue: Gemini API Errors

**Symptoms**: "API key invalid" or "Quota exceeded"

**Solutions**:

1. **Verify API Key**:
   - Check [AI Studio](https://aistudio.google.com/app/api-keys)
   - Ensure key is active
   - Regenerate if needed

2. **Check Quota**:
   - AI Studio → Quota
   - Wait if limit reached
   - Request quota increase

3. **Update Credentials**:
   - n8n → Credentials → Google Gemini
   - Re-enter API key
   - Test connection

4. **Rate Limiting**:
   - Add delays between calls
   - Use "Function" node with:
   ```javascript
   return new Promise(resolve => {
     setTimeout(() => resolve($input.all()), 1000);
   });
   ```

---

### Issue: Webhook Not Receiving Data

**Symptoms**: Webhook trigger doesn't fire

**Solutions**:

1. **Check Webhook URL**:
   - Click Webhook node
   - Copy Production URL (not Test URL)

2. **Test Webhook**:
   ```bash
   curl -X POST https://your-n8n-url.run.app/webhook/path \
     -H "Content-Type: application/json" \
     -d '{"test": "data"}'
   ```

3. **Activate Workflow**:
   - Toggle workflow to "Active"
   - Webhooks only work when active

4. **Check Logs**:
   ```bash
   gcloud run logs read n8n --region=$REGION
   ```

---

## Performance Issues

### Issue: Workflow Timeout

**Symptoms**: "Execution timed out"

**Solutions**:

1. **Increase Timeout**:
   ```bash
   gcloud run services update n8n \
     --timeout=3600 \
     --region=$REGION
   ```
   Max: 3600 seconds (1 hour)

2. **Use Queue Mode**:
   - For long-running workflows
   - See: [n8n Queue Mode](https://docs.n8n.io/hosting/scaling/queue-mode/)

3. **Split Workflow**:
   - Break into smaller workflows
   - Use webhooks to chain them

4. **Optimize Nodes**:
   - Reduce data processing
   - Use "Set" node to filter data
   - Limit API calls

---

### Issue: Memory Errors

**Symptoms**: "Out of memory" errors

**Solutions**:

1. **Increase Memory**:
   ```bash
   gcloud run services update n8n \
     --memory=4Gi \
     --region=$REGION
   ```

2. **Process in Batches**:
   - Use "Split In Batches" node
   - Process smaller chunks

3. **Clean Data**:
   - Remove unnecessary fields
   - Use "Set" node to keep only needed data

---

## API and Integration Issues

### Issue: Google OAuth Not Working

**Symptoms**: "OAuth consent required" or redirect errors

**Solutions**:

1. **Configure OAuth Consent**:
   - GCP Console → APIs & Services → OAuth consent screen
   - Add your n8n URL to authorized domains

2. **Create OAuth Client**:
   - APIs & Services → Credentials → Create OAuth Client
   - Type: Web application
   - Authorized redirect URIs: `https://your-n8n-url.run.app/rest/oauth2-credential/callback`

3. **Update n8n Credentials**:
   - Use Client ID and Client Secret from GCP

---

### Issue: Google Drive Access Denied

**Symptoms**: "Insufficient permissions"

**Solutions**:

1. **Enable API**:
   ```bash
   gcloud services enable drive.googleapis.com
   ```

2. **Check Scopes**:
   - Credentials in n8n should request proper scopes
   - Re-authorize with correct permissions

3. **Share Files**:
   - Ensure files are shared with the OAuth account

---

## Emergency Procedures

### Complete Reset

If nothing works:

1. **Backup Data**:
   ```bash
   ./scripts/backup.sh
   ```

2. **Clean Up**:
   ```bash
   ./scripts/cleanup.sh
   ```

3. **Redeploy**:
   ```bash
   ./scripts/deploy.sh
   ```

### Restore from Backup

```bash
# Restore database
gcloud sql import sql n8n-db gs://bucket/backup.sql \
  --database=n8n
```

---

## Getting Help

### Check Logs First

```bash
# n8n logs
gcloud run logs read n8n --region=$REGION --limit=100

# Database logs
gcloud sql operations list --instance=n8n-db
```

### Community Support

- [n8n Community Forum](https://community.n8n.io/)
- [n8n Discord](https://discord.gg/n8n)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/n8n)

### GCP Support

- [GCP Console](https://console.cloud.google.com/)
- [GCP Support](https://cloud.google.com/support)
- [GCP Community](https://www.googlecloudcommunity.com/)

---

## Prevention Tips

1. **Regular Backups**
   ```bash
   # Add to crontab
   0 2 * * 0 /path/to/backup.sh
   ```

2. **Monitor Resources**
   ```bash
   ./scripts/monitor.sh
   ```

3. **Set Budget Alerts**
   - GCP Console → Billing → Budgets

4. **Test Before Production**
   - Use local Docker setup first
   - Test workflows thoroughly

5. **Keep Documentation**
   - Document custom workflows
   - Note configuration changes

---

**Still Having Issues?**

Open an issue on the project repository or consult the [official n8n documentation](https://docs.n8n.io/).
