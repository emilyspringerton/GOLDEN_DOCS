## TIPJAR Rewrites / Upgrades — Full Acceptance Criteria (v0 → v1 Multiplayer)

This is written so you can treat it like a contract: if every bullet is true, the build “counts.”

---

# 0) Product goals

### G0.1 — Feel

* Game feels like **arcade speed**: input-to-action latency is not perceptibly worse than current BRAWLPIT local.
* A new player can understand the objective (“serve + keep order”) within **30 seconds** without reading a manual.

### G0.2 — Killer feature

* The game supports **couch-style visibility**: you can always watch opponents struggle/succeed in real time via **4-up split view** (Mario Party callback).

### G0.3 — Scale plan

* v0 can be **single-player only** but must be architected so “fast-follow” multiplayer is not a rewrite.

---

# 1) Build targets and modes

## 1.1 v0 (Single-player) must ship with

* **Mode SP-SHIFT:** single player “work the bar” against AI chaos.
* **Mode SP-PARTY (Local simulation):** still single-player controlled, but *runs the same objective/scoring framework* intended for multiplayer.

**Pass/Fail**

* If you can’t reuse the same objective/scoring system in multiplayer without redesign, v0 fails.

## 1.2 v1 (Fast-follow) must add these multiplayer modes

### A) Competitive Party (2–4 players)

* 2P, 3P, 4P competitive supported.
* Each player has independent score + independent bar performance.
* Players can **see all bars** at all times in split view.

### B) 2v2 Team Co-op (up to 4 players)

* Two teams of two.
* Same mechanics as competitive, but scoring is team-based and objectives are team-shared.

### C) Regular Co-op (2 players)

* Two players cooperate on one bar (shared shift) OR two bars with shared score (your choice, but must be one of these explicitly).
* “Revive/help” interaction exists (see co-op criteria).

---

# 2) Core gameplay acceptance criteria (applies to all modes)

## 2.1 Bar loop

* Customers appear, request service, and have a patience/mood timer.
* Player can fulfill and deliver orders.
* Success yields score (tips) and/or buffs; failure increases chaos.

**Pass/Fail**

* In any mode, there is always a **clear next task** visible to the player (order queue + timers).

## 2.2 Bouncer loop

* Conflict escalates from impatience/chaos → arguments → fights.
* Player can de-escalate or neutralize troublemakers.
* There is a non-lethal control mechanic (bubble-trap / restraint / escort).

**Pass/Fail**

* You can win a shift while doing **both** service and conflict management, not just one.

## 2.3 Scoring + outcomes

* Each run ends with an explicit result:

  * Win (quota / survival / objective completion)
  * Lose (vibe collapses / damage threshold / team wiped / timer)
* Results screen shows:

  * tips earned
  * orders completed/missed
  * brawls handled
  * damage caused
  * MVP stats per player/team

---

# 3) Competitive Party Mode acceptance criteria (2–4 players)

## 3.1 “All bars visible” (Mario Party call-back)

* Game supports **4-up split view** layout at 1280×720 minimum.
* Each quadrant shows:

  * that player’s bar world view
  * that player’s HUD (order queue, mood/vibe, score)
* When fewer than 4 players:

  * still show unused panels as “spectator cams” or enlarged views, but you must keep the “watch opponents” philosophy intact.

**Pass/Fail**

* In a 4-player match, a player can point at the TV and say “they’re choking / they’re popping off” without switching cameras.

## 3.2 Competitive balance

* Players do not share resources by default.
* There are at least **two direct interaction vectors**:

  1. **send trouble** to others (e.g., heckler, brawler, prank)
  2. **steal or sabotage** (e.g., ingredient denial, noise burst, spill)
* Sabotage must be readable:

  * attacker gets clear feedback
  * victim gets clear warning + counterplay window

**Pass/Fail**

* A match has meaningful interaction; if everyone plays “single-player beside each other,” it fails.

## 3.3 Win condition

* Competitive winner is determined by one of:

  * highest score at timer end, or
  * first to reach quota, or
  * best-of rounds
* Ties are resolved by a deterministic tiebreaker (e.g., fewer broken items → more perfect orders → fewer ejections).

---

# 4) Co-op acceptance criteria

## 4.1 2-player co-op

* Two players can coordinate actions that are faster/better together:

  * one pours while other delivers
  * one bubbles while other escorts/ejects
  * team combo scoring exists (see 4.3)

**Pass/Fail**

* Co-op must feel strictly different from solo: there must be at least 1 mechanic that is clearly stronger with 2 people.

## 4.2 2v2 team co-op (up to 4 players)

* Two teams share a team score and team success/fail state.
* Friendly collision rules are defined:

  * either “soft collision” or “no collision,” but consistent.
* Team communication readability:

  * teammates have a distinctive outline or color tag
  * teammate critical states are visible (downed / holding key item / in trouble)

## 4.3 Co-op rescues / assists

* At least one “assist” mechanic exists:

  * revive a stunned teammate faster
  * throw/hand off an item
  * team bubble combo (two players bubble = bigger trap)

**Pass/Fail**

* If one player gets overwhelmed, the other can meaningfully help within 2 seconds.

---

# 5) Rendering & UI acceptance criteria (Split-screen is the big one)

## 5.1 Split-screen layouts

Must support:

* 1P full screen
* 2P vertical or horizontal split (choose one, must be stable)
* 3P: one large + two small or three equal (choose one)
* 4P: 2×2 grid

## 5.2 HUD requirements per player panel

Every panel displays:

* current score
* current “vibe/chaos” meter
* customer/order queue with timers
* warnings for imminent failure (e.g., riot threshold)

## 5.3 Readability

* All critical UI is readable at 4-up on 720p:

  * no essential text smaller than your current HUD text scale equivalent
  * use icons + numbers over paragraphs

**Pass/Fail**

* If a player can’t reliably read their next order in 4-up, it fails.

---

# 6) Input & controller acceptance criteria

## 6.1 Local multiplayer inputs

* Supports 1–4 inputs simultaneously:

  * keyboard + controllers OR multiple controllers
* No input conflicts:

  * each player’s actions are isolated and deterministic

## 6.2 Remapping (minimum viable)

* At minimum allow selecting presets:

  * “Arcade (4 buttons)”
  * “Smash-like”
* Must be possible to play 4P with 4 controllers without editing code.

---

# 7) Simulation & architecture acceptance criteria (so multiplayer isn’t a rewrite)

## 7.1 Deterministic tick

* Game simulation advances in fixed steps (you already do ~16ms).
* Rendering can be decoupled, but simulation must be authoritative and stable.

## 7.2 Player-indexed state (N players)

* No logic assumes “player 0 is the only real human.”
* All gameplay systems accept `player_id` and work for any 0..3.

**Pass/Fail**

* You can spawn 4 humans and each can complete orders, bubble enemies, score points.

## 7.3 Entity ownership

* Every interactive entity (drink, bubble, thrown object, etc.) has:

  * `owner_id`
  * clear rules for who gets credit for score

## 7.4 Spectating opponents

* In competitive, each player’s panel camera tracks that player’s area.
* Camera never “steals” view from a player’s own space.

---

# 8) Networking fast-follow acceptance criteria (even if v0 is local-only)

You said v0 can be SP only, but you *need* co-op quickly. So the acceptance criteria is: **don’t paint yourselves into a corner.**

## 8.1 Net-ready data model

* Player commands are representable as a compact `UserCmd` (already true).
* Game snapshots are representable as compact entity arrays.
* No system relies on local-only timing hacks that cannot be reconciled online.

## 8.2 Authoritative server plan

* There is a written “net plan” file (even short) that declares:

  * authoritative sim location (server)
  * client-side prediction strategy for movement
  * reconciliation tolerance for service actions (orders, item spawns)

**Pass/Fail**

* If someone joins late and state cannot be reconstructed from snapshots, it fails.

---

# 9) Content minimums (so it’s a real game, not a tech demo)

## 9.1 At least one full “shift” scenario

* 3+ customer archetypes (patient, impatient, VIP)
* 2+ trouble archetypes (heckler, brawler)
* 3+ drink types with different effects (fast, calming, high tip)

## 9.2 At least one “party board ruleset”

Competitive must include:

* at least 2 sabotage actions
* at least 1 comeback mechanic (e.g., behind players get a “last call” bonus)

---

# 10) Test checklist (must pass before you call it “done”)

### Single-player

* Can complete a shift without crashes for 10 minutes.
* Can lose a shift and understand why.

### 2-player

* Both players can independently score and complete objectives.
* No camera/HUD overlap issues.

### 4-player split view

* All 4 panels render correctly.
* All 4 can read their order queue.
* All 4 can act simultaneously without dropped input.

### Competitive interaction

* Sabotage can be triggered and countered.
* Winner is calculated correctly and displayed.

### 2v2

* Team score updates correctly.
* Friendly assist mechanic works.

---

# 11) Definition of Done (DoD)

You can declare “TIPJAR v0 shipped” only if:

* Sections **0–2**, **5**, **6**, **7**, **9**, **10** (SP + split view readiness + architecture) are satisfied.

You can declare “TIPJAR v1 killer feature shipped” only if:

* Sections **3–4** + 4-up split view + co-op assist + stable results screen all pass.

---

If you want, I can also translate this into a **milestone plan** with exact “Build X” increments that map cleanly onto your current code layout (protocol additions, sim loops, rendering passes, camera per-viewport), but the above is the acceptance contract.
