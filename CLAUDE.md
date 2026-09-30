# Recurse: personal DSA learning tool (single user: akdevv)

Archived web app. The Mac app replaced it and lives on `main`.

- `web/`: React + Hono web app (PWA). See `web/CLAUDE.md`; run npm commands from `web/`
- `courses/dsa/`: curriculum, the source of truth. Content format is documented in `web/CLAUDE.md`
- `scripts/`: python content tooling + `pyjudge.py` (judge core, spawned by the server)
- `data/`: gitignored runtime data (web app's `learn.db`, logs, VAPID keys). Never test on it

Never run prettier on `courses/`.
