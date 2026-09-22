# SLOWBOT_LEAGUE — NORTHSTAR (scoping only, no code yet)

## Founder ask (verbatim, 2026-09-22, real-time chat)

> "can we create separate repository separat training skrip for the slow bot league? i want it
> to run in the server on a separate server from queue queue should remain this is a new elo
> based autocuriculum humans will be able to participate slurp the shit we just built for
> DEADWEIGHT slurp it all over in terms of like how accounts work but we need totally separate
> tenants - DEADWEIGHT and SHANKPIT accounts are totally different totally different product
> keys - have it be match entries into the slow bot league same claim account affordances totally
> separate tables copy it all over to shankpit have the tickets be match entries for the league
> have the stats all tracked via wotan - IMPORTANT IMPORTANT IMPORTANT we are using the currently
> queued BOT from our shankpit training THAT IS THE STARTING POINT FOR SLOW BOT LEAGUE SLOW BOT
> LEAGUE PFSP the auto curiculum is the humans - same setup as SHANKPIT has now for queue but
> instead of the games resetting resetting resetting give the top player 3 lives player 2 2
> lives player 3 1 life and if theres 4 in game the last guy none if theres 5 in game the last 2
> guys none 25 lives per day same reset schedule TOTALLY SEPARATE PRODUCTS shankpit has a
> different license but it will all live in IDUNA it neets to be separate tenatnt for everything
> including the iduna tab (SHANKPIT CODES GEN TAB whatever deadweight has) need league stats on
> wotan like DEADWEIGHT separate section leaderboard"

Nine requirements bundled together. This doc audits what already exists (a lot, it turns out),
names the real new work, and lays out a phased plan. **No code changes ship from this doc alone.**

## Real capability audit (checked, not assumed)

**Much more of this already exists than the ask implies.** Four real, load-bearing pieces of
infrastructure are already built, generic, and directly reusable:

1. **IDUNA's per-game "tenant" system already IS the separation mechanism asked for.**
   `IDUNA/internal/games/games.go`: `games.Registry` is a map keyed by slug (today: just
   `"deadweight"`), each entry carrying its own `PlayPerm`/`BotPerm`/`MatchWritePerm`/
   `CheckpointsWritePerm`/`TicketsWritePerm`/`CheckpointBlobDir`. The package's own doc comment:
   *"adding a game with guest accounts, match results and a checkpoint registry is one row here
   (plus a migration granting its permissions/agents), not a new handler."* Every table this
   touches (`game_player_tickets`, `game_signup_log`, `player_credentials`, `game_matches`, the
   checkpoint registry) is already keyed by a `game` column/param — DEADWEIGHT and a new
   `shankpit_slowbot` (or similar) slug would be **structurally separate rows in the same tables**
   from day one, with separate permissions (the real analog of "separate product key" — an agent
   or player token scoped to one game's permissions literally cannot touch the other's data).
   **This means "totally separate tenant" does not require inventing new IDUNA infrastructure —
   it requires one new `Registry` entry + one migration granting its permissions.**
2. **Guest auth / Claim Account / daily ticket cap is already 100% generic over `game`.**
   `internal/http/handlers/game_online.go`'s `accountState`/`guestUpgrade`/`effectiveDailyCap`
   were audited line-by-line this session (against the DEADWEIGHT Claim Account spec) and take a
   `game` parameter throughout — nothing DEADWEIGHT-specific in the logic itself. "Slurp the
   Claim Account affordance into SHANKPIT" is real, but it's a **client-side integration** (the
   SHANKPIT client needs the same guest-register / claim-account UI DEADWEIGHT's GUI just got),
   not new backend work.
3. **The admin "codes gen" page is already game-generic** — `GameClaimCodesHandler`
   (`internal/http/handlers/game_claim_codes_page.go`) reads its game list from `games.Registry`
   and was never hardcoded to DEADWEIGHT; only the page *route* (`/admin/deadweight`) and its
   title text are DEADWEIGHT-specific from this session's own naming choice. A second admin tab
   for the new game slug is a route/page-wrapper change, not a new backend handler.
4. **PFSP + Elo training math already exists, game-agnostic, twice-proven.**
   `SHANKPIT/scripts/rl_league.py` (ported verbatim from `BRAWLPIT/scripts/rl_league.py`, per its
   own doc comment) is a real `LeagueManager`: 3-role self-play (Main/Main Exploiter/League
   Exploiter), PFSP-weighted opponent sampling (`pfsp_weight`, AlphaStar's `f_hard`), and a real,
   standard Elo implementation (`elo_expected`/`elo_update`, K=32, DEFAULT_ELO=1500) — "never
   references any specific game" per its own header. This is the real library the new repo's
   training script should import/vendor, not reinvent.
5. **The exact "currently queued bot" anchor the founder called out as IMPORTANT is a real, live,
   already-queryable fact**, not something to go find: `GET /api/v1/shankpit-checkpoints/active`
   returns, right now:
   ```json
   {"id":578,"name":"league_exploiter_20260917_202530","role":"league_exploiter",
    "generation":9,"elo":1564,"filename":"league_exploiter_gen9.zip",
    "is_active_opponent":true,"eval_note":"vs gen 10: score_a=1.0"}
   ```
   **This is the real day-1 seed**: gen 0 of the Slow Bot League PFSP pool = checkpoint 578
   (Elo 1564), fetched once at league-launch time via this same endpoint
   `IDUNA/internal/shankpit/checkpoint_store.go`'s `GetActiveOpponent` already serves.

## Real, genuinely new work (nothing above covers these)

1. **A lives-based SHANKPIT game mode does not exist.** Checked `apps/server/src/main.c`'s mode
   enum directly: `MODE_QUEUE` (the live queue humans/bots play today) is continuous-respawn FFA
   with a frag limit + 4-minute round timer (`SERVER_QUEUE_FRAG_LIMIT`/`SERVER_QUEUE_ROUND_MS`) —
   death never removes a player, it just respawns them. What the founder describes ("instead of
   the games resetting resetting resetting") is a real elimination mode: N starting lives per
   player, a death consumes one life, 0 lives = spectate/eliminated for the rest of that match.
   This is new native C game-logic in the SHANKPIT server, not a config flag.
2. **A separate server process/port, per the founder's explicit "on a separate server from
   queue — queue should remain."** SHANKPIT's live queue server (`shankpit-server.service`,
   UDP :6969) is not to be touched or shared. The Slow Bot League needs its own server instance
   (same `shank_server` binary, new game mode, a new port — `shankpit-zombie.service` on :6971
   is the existing precedent for "second standing server instance, same binary, different mode").
3. **The lives-assignment rule as stated has a real, unresolved ambiguity — named here, not
   guessed at:** "give the top player 3 lives, player 2 2 lives, player 3 1 life... last guy/2
   guys none." "Top"/"player 2"/"player 3" could mean (a) rank by each player's own current
   league Elo at match-start (a skill-based asymmetric handicap: the *strongest* player in the
   lobby gets the *most* lives, which is the opposite direction a fairness handicap usually runs
   — worth double-checking that's the intended direction, not "weakest gets most"), or (b) a
   fixed assignment by literal join/slot order with no relation to skill at all. This changes the
   server's own life-assignment code path and needs a real answer before Phase 2 below.
4. **A WOTAN leaderboard-section pattern does not exist yet, for anyone.** Checked `WOTAN/`
   directly: `index.html`/`decks.html`/`store.html` are static marketing/reference pages with no
   per-game leaderboard section, no live-data wiring, nothing DEADWEIGHT already uses as a
   precedent. "Same as DEADWEIGHT's own WOTAN section" describes something that has to be built
   from scratch — likely as a real, small WOTAN-side JS fetch against a new IDUNA leaderboard
   endpoint (`game_matches`/Elo, already tracked server-side per (3) above) — and then the exact
   same pattern reused for the Slow Bot League's own section. This is real, additional,
   undiscounted scope, not "copy an existing thing."
5. **The training script itself** — this repo's actual reason to exist: a `train.py` that (a)
   pulls checkpoint 578 as gen-0 via the real `/active` endpoint above, (b) runs SHANKPIT's own
   `frozen_policy_bot.py`-style self-play loop against the new lives-mode server, (c) folds real
   human match results from the league server into the same Elo/PFSP bookkeeping
   `rl_league.py` already provides (humans are opponents in the pool the same way a frozen
   checkpoint is — a new, real `LeagueManager` member kind, not built yet in `rl_league.py`).

## Phased plan (none of this is built yet)

- **Phase 0 — IDUNA tenant + server skeleton.** New `games.Registry["shankpit_slowbot"]` entry +
  migration (mirrors DEADWEIGHT's own, ~1 file). New `shank_server` systemd unit on a fresh port
  running the *existing* `MODE_QUEUE` unmodified (no lives yet) so the plumbing (guest auth,
  ticket=match-entry consumption, admin codes-gen tab) can be verified end to end before any new
  native game-mode code is written.
- **Phase 1 — lives-based game mode.** New `MODE_SLOWBOT` (name TBD) in `apps/server/src/main.c`:
  per-player lives counter, death decrements instead of respawning at 0, match ends when ≤1
  player has lives left. Resolve the open lives-assignment-direction question (item 3 above)
  before writing this.
- **Phase 2 — PFSP training script + `rl_league.py` "human opponent" support.** This repo's own
  `train.py`, seeded from checkpoint 578. Extend `rl_league.py` (or a forked copy here, matching
  its own established "ported verbatim per repo" convention) with a league-member kind for real
  human match results, not just frozen-policy self-play.
- **Phase 3 — WOTAN leaderboard pattern**, built once, used twice: a real section on WOTAN driven
  by IDUNA's own per-game match/Elo data, for DEADWEIGHT first (closing the real gap named above)
  then the identical pattern for the Slow Bot League.
- **Phase 4 — SHANKPIT client integration.** Claim Account UI ported into the SHANKPIT native
  client (mirrors the DEADWEIGHT GUI work), 25 match-entries/day cap wired via the already-generic
  `effectiveDailyCap`.

## Adversarial (GAIL) discriminator + the "Super Slow League" (2026-09-22, same-session addendum)

Founder real-time, direct follow-up to this doc: "how can we make our slow league more
intelligent through adversarial learning? the critic learns and the bot learns" → "that needs to
be super slow league" → "where bots are always only vs humans."

**What this is:** GAIL (Generative Adversarial Imitation Learning, Ho & Ermon 2016) — a real,
established technique, not a novel idea being invented here. A small discriminator network scores
(state, action) pairs as human-recorded vs. bot-generated; that "how human did that look" signal
feeds into PPO's reward alongside win/loss, so the policy is pushed toward human-legible play, not
just optimal play. This is directly, load-bearingly connected to `SHANKPIT/docs2/specs/
CAPTCHA_FPS_PHYSICS_DOGFOOD_NORTHSTAR.md`'s own named-but-unsolved humanness-signal gap — the
same discriminator class solves both problems.

**Why "Super Slow League" is a real, separate matchmaker constraint, not just a rename.** The
existing 3-role PFSP self-play (Main/Main Exploiter/League Exploiter, `rl_league.py`) trains bots
against EACH OTHER — bot-vs-bot trajectories would contaminate the discriminator's own "bot" class
with no clean human counterexample in the same match context, and "fast league" (this doc's own
existing bot-only continuous queue, Phase 2 above) is explicitly NOT where this belongs. The
founder's own constraint — "bots are always only vs humans" — is the real fix: a THIRD matchmaker
mode, layered on top of (not replacing) the existing slow (human queue) / fast (bot-only)
split already scoped in `ECOWAR/docs/NORTHSTAR_MAP_LEAGUE.md`'s own Phase 3 and this repo's own
Phase 2:

- **Fast league** (existing scope, unaffected) — bot-only, continuous, PFSP self-play. Produces
  skill, not humanness data. Never touches the discriminator.
- **Slow league** (existing scope, this doc's own Phase 1-2) — real humans queue, lives-based,
  today's real ask. May or may not include bot fill when the human queue is thin — not yet
  decided either way in this doc.
- **Super Slow League (new, this addendum)** — a real matchmaker CONSTRAINT: every match seats
  exactly one bot against one (or more) real humans, NEVER bot-vs-bot fill, enforced the same way
  `apps/matchmaker`'s own `try_match` already enforces its other real pairing rules (ECOWAR's own
  `FindMatchMsg` precedent for a matchmaker-level constraint, not a client-side one). Purpose:
  produce clean, paired (bot action, human action) trajectory data from the SAME match context —
  the actual data the discriminator needs, and the reason a thin human queue can't just be padded
  with bots the way ordinary queue fill already does.

**Real, checked-first gap, same as the parent doc's own §"Real, genuinely new work":** no human
trajectory logging exists anywhere in SHANKPIT today (checked directly — `rl_env_packet.py`/
`var/rl_checkpoints/` only ever record frozen-policy self-play, never a real human's own actions).
Super Slow League's own match server is the natural place to add this: log (state, action) per
tick for BOTH the seated human and the seated bot, tagged by which is which — the discriminator's
own real training set.

**Real, honest, open design risk, not glossed over:** adversarial co-training is notoriously
unstable (discriminator overpowering the policy early collapses the reward signal to noise; a
policy can learn superficial "human-like" tics — hesitation, jitter — without matching real human
decision-making, a form of reward hacking specific to this setup). Standard practice is blending
GAIL reward with win/loss reward (not replacing it) and a slow discriminator learning rate
relative to the policy — real tuning work, not a solved parameter choice, deferred to
implementation.

**Phased plan for this addendum (layered onto the existing Phased plan above, not replacing it):**
- **Phase A** — Super Slow League matchmaker constraint (always exactly 1 bot : N humans per
  match, never bot-vs-bot) — a real, scoped addition to whatever Phase 0/1 server this doc's own
  existing plan stands up, not a fourth server.
- **Phase B** — human+bot (state, action) trajectory logging from Super Slow League matches only.
- **Phase C** — discriminator network + GAIL reward blending into `rl_league.py`'s own PPO
  training loop, real, careful reward-weighting tuning (see risk above).
- **Phase D** — feed the trained discriminator back into `CAPTCHA_FPS_PHYSICS_DOGFOOD_NORTHSTAR.md`
  Phase 4's own named-but-unsolved humanness-signal gap — the real cross-repo payoff, not built
  until both sides are ready.

No code shipped from this addendum — same "scope first" standing this whole doc already follows.

## Open questions for the founder

1. **Lives-assignment direction** (item 3 above) — skill-based handicap (top-Elo gets MOST
   lives) or fixed slot order, no skill relation?
2. **Repo name** — `SLOWBOT_LEAGUE` used here is provisional, easy to rename before the first
   real push.
3. **License** — "shankpit has a different license" was named but not specified; SHANKPIT's own
   current license needs checking against whatever this repo should carry.
4. **Super Slow League scope** (adversarial addendum above) — is this a real, separate queue/
   product surface from the base Slow League, or a mode/flag on the same one? "Always exactly 1
   bot per match, never bot-vs-bot" is a real constraint on top of ordinary queue fill either way,
   but whether it's its OWN ticket type / WOTAN leaderboard section, or folds into the existing
   Slow League's own, isn't decided here.
