# Shepherd Supabase Quick Start Guide (Browser GUI)

This guide shows you how to set up your Supabase database using the **browser-based dashboard** - no CLI installation required!

## Quick Setup (5 Minutes)

### Step 1: Create Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Sign in or create an account
3. Click **"New Project"**
4. Fill in project details:
   - **Name**: `shepherd-app` (or your preference)
   - **Database Password**: Choose a strong password (**save this securely!**)
   - **Region**: Select closest to you
   - **Pricing Plan**: Free tier is perfect for development
5. Click **"Create new project"**
6. Wait 2-3 minutes for setup to complete

### Step 2: Get Your API Credentials

1. In your Supabase project, go to **Project Settings** (⚙️ gear icon in sidebar)
2. Click **"API"** in the left menu
3. You'll see:
   - **Project URL**: `https://xxxxxxxxxxxxx.supabase.co`
   - **anon public** key: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

4. **Copy these values** - you'll need them for your Flutter app

### Step 3: Update Your Flutter App Credentials

1. Open `shepherd/.env` in VS Code
2. Replace the placeholder values with your actual credentials:

```env
SUPABASE_URL=https://fykjzidpdnizvwpqzdnk.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ5a2p6aWRwZG5penZ3cHF6ZG5rIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUwODEwMDQsImV4cCI6MjA4MDY1NzAwNH0.C2jgCSMtULafBZRp7GMlCn0Priih_IlUtxDfwkL3KtM
```

> ✅ **Good news**: You've already done this step!

### Step 4: Run the Migration in SQL Editor

1. In your Supabase dashboard, click **"SQL Editor"** in the left sidebar
2. Click **"New Query"** button
3. Open the migration file:
   - Navigate to `supabase/migrations/0001_initial_schema.sql`
   - Copy the entire contents (all 269 lines)
4. Paste into the SQL Editor
5. Click **"Run"** button (or press `Ctrl+Enter`)
6. You should see: ✅ **"Success. No rows returned"**

**What this creates:**
- `users` table - stores pastor profiles
- `user_settings` table - stores user preferences
- RLS policies - security rules
- Indexes - for fast queries
- Triggers - for automatic timestamps

### Step 5: Verify the Migration

1. Click **"Table Editor"** in the left sidebar
2. You should see two tables:
   - ✅ `users`
   - ✅ `user_settings`
3. Click on each table to inspect the schema

**Check the columns:**

**users table** should have:
- id (uuid)
- email (text)
- name (text)
- church_name (text)
- timezone (text)
- created_at (timestamptz)
- updated_at (timestamptz)

**user_settings table** should have:
- id (uuid)
- user_id (uuid)
- elder_contact_frequency_days (int4)
- member_contact_frequency_days (int4)
- crisis_contact_frequency_days (int4)
- weekly_sermon_prep_hours (int4)
- max_daily_hours (int4)
- ... and 10 more fields

### Step 6: Test Your Flutter App

```bash
cd shepherd
flutter run
```

Choose **Chrome (option 2)**

You should see:
- ✅ Shepherd app loads
- ✅ "Ready to connect" status (you're not logged in yet)
- ✅ No errors in console

---

## Additional Setup (Optional)

### Enable Email Authentication

1. In Supabase dashboard, go to **Authentication** → **Providers**
2. Find **Email** provider
3. Toggle **"Enable Email provider"** to ON
4. Click **"Save"**

**Email settings:**
- ✅ Confirm email: OFF (for testing) or ON (for production)
- ✅ Secure email change: ON (recommended)
- ✅ Email OTP: Optional

### Load Test Data (Optional)

1. Go to **SQL Editor**
2. Click **"New Query"**
3. Copy contents of `supabase/test_data.sql`
4. Paste and click **"Run"**
5. Go to **Table Editor** → **users** to see the test data

**Test users created:**
- pastor.john@firstchurch.org
- pastor.sarah@gracechapel.com
- pastor.mike@community.org
- pastor.emily@harvestchurch.net
- pastor.david@faithbaptist.com

### Verify Schema (Optional)

1. Go to **SQL Editor**
2. Click **"New Query"**
3. Copy contents of `supabase/verify_schema.sql`
4. Paste and click **"Run"**
5. Review the output - should show all tables, policies, and indexes

---

## Common Tasks in the GUI

### View Table Data

1. Click **"Table Editor"** in sidebar
2. Select table (e.g., `users`)
3. View, edit, or add rows directly

### Run SQL Queries

1. Click **"SQL Editor"** in sidebar
2. Click **"New Query"**
3. Write your SQL
4. Click **"Run"** or press `Ctrl+Enter`

**Example queries:**

```sql
-- View all users
SELECT * FROM users;

-- View all user settings
SELECT * FROM user_settings;

-- Check RLS policies
SELECT schemaname, tablename, policyname, cmd
FROM pg_policies
WHERE schemaname = 'public';

-- Check indexes
SELECT schemaname, tablename, indexname
FROM pg_indexes
WHERE schemaname = 'public';
```

### View Database Logs

1. Click **"Logs"** in sidebar
2. Select **"Database"** tab
3. See all queries and errors

### Check RLS Policies

1. Click **"Authentication"** → **"Policies"**
2. Select a table (e.g., `users`)
3. See all policies for that table

**Expected policies for `users` table:**
- ✅ Users can view their own profile (SELECT)
- ✅ Users can create their own profile (INSERT)
- ✅ Users can update their own profile (UPDATE)
- ✅ Users can delete their own profile (DELETE)

### Monitor Database Performance

1. Click **"Database"** → **"Query Performance"**
2. See slow queries and optimization suggestions

---

## Testing Your Setup

### Test 1: Connection from Flutter App

```bash
flutter run
```

**Expected result:**
- App loads without errors
- "Ready to connect" status shown
- No red error icons

### Test 2: Query the Database (via SQL Editor)

```sql
-- This should return 0 rows (no users yet)
SELECT * FROM users;

-- This should return 0 rows (no settings yet)
SELECT * FROM user_settings;
```

### Test 3: Check RLS is Enabled

```sql
-- This should return 'true' for both tables
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
AND tablename IN ('users', 'user_settings');
```

**Expected output:**
```
tablename      | rowsecurity
---------------|------------
users          | true
user_settings  | true
```

---

## Troubleshooting

### ❌ Migration Failed

**Error**: "syntax error near..."

**Solution:**
1. Make sure you copied the **entire** migration file
2. Check for any missing or extra characters
3. Try copying again from the original file

### ❌ "Permission denied for table users"

**Cause**: RLS is working correctly! This is expected when not authenticated.

**Solution**: This is normal. The table is protected by RLS policies. You'll need to be authenticated to access data.

### ❌ Flutter app shows "Connection Error"

**Possible causes:**
1. Wrong credentials in `.env` file
2. Network connectivity issues
3. Supabase project is paused

**Solutions:**
1. Verify `SUPABASE_URL` and `SUPABASE_ANON_KEY` in `.env`
2. Check internet connection
3. Go to Supabase dashboard and check project status

### ❌ Tables don't appear in Table Editor

**Solution:**
1. Click the **refresh** button in Table Editor
2. Check **SQL Editor** → **"Logs"** for errors
3. Re-run the migration

---

## Next Steps

### 1. Test Authentication (Coming Soon)

Once you build the login screens, you can test:
- Sign up new users
- Sign in existing users
- Check that RLS policies work correctly

### 2. Add More Tables

Follow the same process for additional tables:
1. Create migration file
2. Copy to SQL Editor
3. Run migration
4. Verify in Table Editor

**Tables to add next** (from technical spec):
- `tasks` - task management
- `calendar_events` - calendar entries
- `people` - contacts/members
- `households` - family groupings
- `contact_log` - pastoral care tracking
- `sermon_series` - sermon organization
- `sermons` - individual sermons
- `notes` - general notes

### 3. Set Up Storage (for file uploads)

1. Go to **Storage** in sidebar
2. Click **"Create a new bucket"**
3. Name it: `sermon-notes` or `user-uploads`
4. Set RLS policies for the bucket

### 4. Enable Realtime (optional)

1. Go to **Database** → **Replication**
2. Find table (e.g., `tasks`)
3. Toggle **"Enable Replication"** to ON
4. Your Flutter app will receive real-time updates

---

## Useful Dashboard Sections

| Section | What It's For |
|---------|---------------|
| **Table Editor** | View/edit table data directly |
| **SQL Editor** | Run custom SQL queries |
| **Authentication** | Manage users, providers, policies |
| **Database** | Schema, performance, backups |
| **Storage** | File uploads (images, PDFs, etc.) |
| **Logs** | Debug queries, errors, auth events |
| **API Docs** | Auto-generated API documentation |
| **Project Settings** | API keys, database password, etc. |

---

## Pro Tips

### ✅ Save Your Queries

1. In **SQL Editor**, write a query
2. Click **"Save"** button
3. Give it a name: "Verify RLS" or "Check Users"
4. Access saved queries from the **Snippets** tab

### ✅ Use the API Docs

1. Go to **API Docs** in sidebar
2. See auto-generated REST and GraphQL APIs
3. Copy/paste code snippets for your Flutter app

### ✅ Download Database Backups

1. Go to **Database** → **Backups**
2. Click **"Download"** for daily backups
3. Store securely for disaster recovery

### ✅ Monitor Usage

1. Go to **Settings** → **Usage**
2. Track database size, bandwidth, API requests
3. Stay within free tier limits

---

## Security Best Practices

### ✅ Keep RLS Enabled

**Never** disable Row Level Security in production:
```sql
-- ❌ NEVER do this in production!
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
```

### ✅ Protect Your Keys

- ✅ `.env` file is in `.gitignore` (already done)
- ✅ Never commit API keys to git
- ✅ Rotate keys if accidentally exposed (Settings → API)

### ✅ Use Strong Database Password

- ✅ At least 12 characters
- ✅ Mix of letters, numbers, symbols
- ✅ Store in password manager (1Password, LastPass, etc.)

### ✅ Enable 2FA on Supabase Account

1. Go to your Supabase account settings
2. Enable two-factor authentication
3. Use authenticator app (Google Authenticator, Authy)

---

## Migration Files Reference

| File | Purpose |
|------|---------|
| `0001_initial_schema.sql` | Creates users and user_settings tables |
| `0001_initial_schema_down.sql` | Rollback script (emergency only) |
| `test_data.sql` | Sample data for testing |
| `verify_schema.sql` | Validation script |

---

## Quick Reference: Your Credentials

**Your Supabase Project:**
- **URL**: `https://fykjzidpdnizvwpqzdnk.supabase.co`
- **Anon Key**: `eyJhbGci...` (in your `.env` file)
- **Dashboard**: [https://app.supabase.com](https://app.supabase.com)

---

## Getting Help

- **Supabase Docs**: [https://supabase.com/docs](https://supabase.com/docs)
- **Community Discord**: [https://discord.supabase.com](https://discord.supabase.com)
- **GitHub Issues**: [https://github.com/supabase/supabase/issues](https://github.com/supabase/supabase/issues)

---

**You're all set!** 🎉

Your Supabase database is configured and ready for the Shepherd app. Next up: building authentication screens!
