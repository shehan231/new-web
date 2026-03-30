# SyberHack SL Hub v2 — Deployment Guide

## Architecture
```
Browser  →  Netlify CDN (public/index.html)
                ↓  fetch
         Netlify Function (netlify/functions/videos.js)
                ↓  Supabase JS SDK
         Supabase PostgreSQL  ←  shared database, all users see same data
```

No long-running server. All backend logic runs in serverless functions.
Videos are stored in Supabase and are **shared across all visitors**.

---

## Step 1 — Create a free Supabase database

1. Go to https://supabase.com and sign up (free)
2. Click **New project** — name it `syberhack`
3. Once created, go to **SQL Editor → New Query**
4. Paste the contents of `supabase_schema.sql` and click **Run**
5. Go to **Settings → API** and copy:
   - **Project URL** → e.g. `https://xyzabc.supabase.co`
   - **service_role** key (under "Project API keys") → long secret key

---

## Step 2 — Deploy to Netlify

### Option A — Netlify Drop (quickest)
1. Go to https://app.netlify.com/drop
2. Drag this entire project folder onto the page
3. After deploy, go to **Site settings → Environment variables** and add:
   ```
   SUPABASE_URL         =  https://your-project.supabase.co
   SUPABASE_SERVICE_KEY =  eyJ...your-service-role-key...
   ```
4. Go to **Deploys → Trigger deploy → Deploy site** to restart with the env vars

### Option B — GitHub + Netlify (recommended)
1. Push this folder to a GitHub repo
2. Go to https://app.netlify.com → **Add new site → Import from Git**
3. Build settings:
   - **Build command:** `npm install`   *(installs the Supabase SDK for functions)*
   - **Publish directory:** `public`
4. Click **Deploy site**
5. Go to **Site settings → Environment variables** and add both vars above
6. Trigger a redeploy

### Option C — Netlify CLI
```bash
npm install -g netlify-cli
netlify login
netlify env:set SUPABASE_URL "https://your-project.supabase.co"
netlify env:set SUPABASE_SERVICE_KEY "eyJ..."
netlify deploy --prod
```

---

## Step 3 — Change your admin PIN

Open `public/index.html` and find:
```js
const ADMIN_PIN = '1234';
```
Change it before deploying.

---

## File Structure
```
syberhack-v2/
├── public/
│   └── index.html          ← the entire frontend
├── netlify/
│   └── functions/
│       └── videos.js       ← serverless API (GET/POST/PATCH/DELETE)
├── netlify.toml            ← tells Netlify: publish=public, functions=netlify/functions
├── package.json            ← only dependency: @supabase/supabase-js
├── supabase_schema.sql     ← run once in Supabase SQL editor
└── README.md               ← this file
```

---

## API Endpoints (handled by the function)

| Method | URL | Action |
|--------|-----|--------|
| GET | `/.netlify/functions/videos?platform=youtube` | List videos, newest first |
| GET | `/.netlify/functions/videos` | List all videos |
| POST | `/.netlify/functions/videos` | Add a video |
| PATCH | `/.netlify/functions/videos` | Update title/url/thumb/rating |
| DELETE | `/.netlify/functions/videos?id=<uuid>` | Delete a video |

---

## Notes
- The **service_role** key is **never** sent to the browser — it stays inside
  the Netlify Function (server-side environment variable).
- Video thumbnails are stored as base64 strings in the database. If you add
  many large images, consider switching to Supabase Storage (free tier) for
  actual file hosting.
