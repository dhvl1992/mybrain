# 🧠 MyBrain

Personal to-do list + notes. Dump rough text (English / Hinglish / Gujarati), AI splits it into to-dos and notes.

**Stack (all free):** GitHub Pages (hosting) · Supabase (database + login) · Gemini API free tier (AI) · offline parser fallback.

## Files
| File | What it does |
|---|---|
| `index.html` | The whole app |
| `schema.sql` | Database table + privacy rules (run once in Supabase) |
| `.github/workflows/keepalive.yml` | Pings Supabase every 3 days so the free project never pauses |

## Security notes
- The Supabase **anon key** in `index.html` is public by design. Row Level Security in `schema.sql` keeps your rows private.
- The **Gemini key** is NOT in the repo. You paste it in ⚙️ Settings; it stays in your browser only.
- Never commit backups (`mybrain-backup-*.json`) — this repo is public.

## Known limits (free tier)
- Supabase Free has no automatic backups → use ⚙️ **Export backup** sometimes.
- Gemini free tier: Google may use free-tier inputs to improve its products. Don't put passwords or very private things in "Organize". Use **Save as note** for those (no AI).
