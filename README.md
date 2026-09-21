# GOLDEN_DOCS

A full, real snapshot of every EINHORN_INDUSTRIAL golden doc (the docs Emily Prime's own
context-loading treats as authoritative, per `EMILY/context/golden-docs-index.md`), plus the
core EMILY context files. Generated, not hand-written -- see `context/golden-docs-index.md`
for the real source of truth this was built from, and `MANIFEST.md` below for exactly what
was copied and when.

## Layout

- `context/` -- EMILY's own context files: `golden-docs-index.md` (the real index every doc
  below is listed in), `full-system-context.md`, the sprawl memo, `golden-repos.json`, plus
  the monorepo's own root `CLAUDE.md` (`MONOREPO_CLAUDE.md` here) and
  `ECOSYSTEM_CONTINUITY_REPORT.md`.
- `docs/<repo>/<path>` -- every golden doc, at its real path inside its own repo (e.g.
  `docs/IDUNA/docs/NORTHSTAR.md` mirrors `IDUNA/docs/NORTHSTAR.md` in the monorepo).

## Why this repo exists

Founder real-time, 2026-09-21: a standalone, browsable/cloneable snapshot of every golden
doc across the whole monorepo, kept up to date whenever a golden doc changes. See
`MONOREPO_CLAUDE.md`'s own repo table entry for this repo (once added) and
`EMILY/BACKLOG.md` for the sync automation this repo depends on.

## Staying in sync

This repo is **not auto-updated by CI yet** -- resynced by Claude Code, following a standing
instruction in the monorepo's own `CLAUDE.md` ("whenever a golden doc is added, removed, or
meaningfully changed, also update GOLDEN_DOCS") each time a golden doc actually changes.
Real CI-based automation (a workflow triggered off the monorepo's own pushes) is tracked as a
follow-up in `EMILY/BACKLOG.md`, not built yet.
