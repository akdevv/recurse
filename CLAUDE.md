# Recurse: personal DSA learning tool (single user: akdevv)

One repo, two apps over the same curriculum:

- `web/`: React + Hono web app (PWA). See `web/CLAUDE.md`; run npm commands from `web/`
- `mac/`: native SwiftUI Mac app (core loop ported; see `mac/CLAUDE.md`)
- `courses/dsa/`: curriculum, the source of truth for both apps. Content format is documented in `web/CLAUDE.md`
- `scripts/`: python content tooling + `pyjudge.py` (judge core, spawned by both apps)
- `data/`: gitignored runtime data (web app's `learn.db`, logs, VAPID keys). Never test on it

Never run prettier on `courses/`.
