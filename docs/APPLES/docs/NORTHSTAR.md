# APPLES — Northstar
## Git-authoritative durable record of all EINHORN_INDUSTRIAL agent activity

**Status**: Active — auto-synced by `emily sync --apples-git-dir`  
**Owner**: Emily Prime  
**Written**: 2026-06-09

---

## WHAT THIS REPO IS

APPLES is the **append-only audit trail** for every significant action taken by
every agent in the EINHORN_INDUSTRIAL stack. It is not a database — it is a git repo.

Every Apple is a committed JSON file. Git is the custody chain. The repo is the proof.

---

## WHY A SEPARATE GIT REPO

1. **Human readability** — `git log` on this repo tells the story of what the
   agent network has done. No query language, no database client needed.

2. **Offline access** — MJOLNIR (Android app) clones this repo to the device for
   offline Apple browsing without hitting the IDUNA API.

3. **Audit independence** — IDUNA is the live source of truth; APPLES is the
   durable backup. If IDUNA is wiped, the Apples survive here.

4. **Diffs are meaningful** — Each new Apple is a single-file commit.
   `git log --oneline` is the activity log. `git show <hash>` is the Apple.

---

## FILE STRUCTURE

```
APPLES/
  YYYYMMDD/                     ← one directory per day (UTC)
    <id>_<apple-type>.json      ← one file per Apple
  docs/
    NORTHSTAR.md                ← this file
    SCHEMA.md                   ← Apple JSON schema reference
  MANIFEST.json                 ← auto-generated index (MJOLNIR reads this)
  README.md
```

### Apple filename convention
```
<apple-id>_<apple-type>.json
e.g.:
  apple-001_completion.json
  apple-037_rsi_iteration.json
  apple-100_signal_observation.json
```

### MANIFEST.json
Generated and updated by `emily sync`. MJOLNIR reads this for fast indexed display
without cloning all files:
```json
{
  "generated_at": "2026-06-09T22:00:00Z",
  "repo": "APPLES",
  "count": 342,
  "apples": [
    {
      "id": "apple-001",
      "number": 1,
      "type": "completion",
      "title": "BACKLOG: ✓ IDUNA embedded SQLite backend",
      "source_repo": "IDUNA",
      "source_agent": "claude-code",
      "severity": "normal",
      "date": "20260607",
      "filed_at": "2026-06-07T09:14:21Z"
    }
  ]
}
```

---

## HOW APPLES GET HERE

`emily sync --apples-git-dir /home/fatbaby/APPLES` (run as daemon via `emily sync --watch`):

1. Polls IDUNA `GET /api/v1/apples` for new Apples (cursor tracked in `emily.cli` state)
2. Writes each new Apple as `YYYYMMDD/<id>_<type>.json`
3. Regenerates `MANIFEST.json`
4. `git add` + `git commit -m "apple: #N type — title"`
5. `git push origin main`

This runs as part of `emily start` (the obs-watcher launch) or standalone.

---

## APPLE SCHEMA

See `docs/SCHEMA.md` for full schema. Core fields:

```json
{
  "id": "apple-001",
  "number": 1,
  "type": "completion | rsi_iteration | signal_observation | escalation | status",
  "title": "Human-readable title (≤ 140 chars)",
  "body": "Full markdown body",
  "source_repo": "PRRJECT_FATBABY | EMILY | IDUNA | SHANKPIT | TYLER | MJOLNIR",
  "source_agent": "emily-prime | claude-code | fatbaby-emily | tyler",
  "severity": "critical | high | normal | low | info",
  "requires_ceo_visibility": false,
  "filed_at": "2026-06-09T14:23:00Z",
  "metadata": {}
}
```

---

## DOWNSTREAM CONSUMERS

| Consumer | How it reads APPLES |
|----------|---------------------|
| MJOLNIR Android | Git clone on device, reads MANIFEST.json offline |
| Emily Prime TUI | `emily watch` tails IDUNA live (not this repo) |
| RSI loop | Posts completion Apple → triggers next TIC |
| Emily CEO email | Gmail escalation for `requires_ceo_visibility == true` Apples |
| Future: dashboard | Static site generator over this repo (GitHub Pages) |

---

## RECURSIVE SELF-IMPROVEMENT HOOK

The APPLES repo is inspectable by agents:
- Emily Prime can `git log --oneline APPLES/` to audit completion cadence
- Claude Code can grep for `rsi_iteration` Apples to track RSI velocity
- Future: Emily Prime diffs consecutive `MANIFEST.json` commits to measure system throughput

The repo is the memory. The memory drives improvement.

---

*APPLES NORTHSTAR | EINHORN_INDUSTRIAL | 2026-06-09*
*Every Apple that ever was. Every Apple that ever will be.*
