# 🧠 MyBrain

Personal to-do list + notes. Dump rough text (English / Hinglish / Gujarati), AI splits it into to-dos and notes.

**Stack (all free):** GitHub Pages (hosting) · Supabase (database + login) · Groq free tier · Qwen 3 (AI, default) or Gemini free tier · offline parser fallback.

## Files
| File | What it does |
|---|---|
| `index.html` | The whole app |
| `schema.sql` | Database table + privacy rules (run once in Supabase) |
| `migrations/002-lists.sql` | Lists + shopping store type (run once, after `schema.sql`) |
| `migrations/003-ideas.sql` | Ideas tab: status (New / Exploring / Doing / Parked), impact, effort (run once, after 002) |
| `manifest.json`, `sw.js`, `icons/` | Make it installable as a phone/desktop app (PWA) |
| `.github/workflows/keepalive.yml` | Pings Supabase every 3 days so the free project never pauses |

## Security notes
- The Supabase **anon key** in `index.html` is public by design. Row Level Security in `schema.sql` keeps your rows private.
- The **AI keys** (Groq / Gemini) are NOT in the repo. You paste it in ⚙️ Settings; it stays in your browser only.
- Never commit backups (`mybrain-backup-*.json`) — this repo is public.

## Known limits (free tier)
- Supabase Free has no automatic backups → use ⚙️ **Export backup** sometimes.
- Gemini free tier: Google may use free-tier inputs to improve its products (Groq says it does not train on API data). Don't put passwords or very private things in "Organize". Use **Save as note** for those (no AI).
