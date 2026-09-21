# EINHORN_SURVIVAL

## What this is

A real, live EINHORN_INDUSTRIAL community Minecraft survival server — Paper (the modern,
actively-maintained Spigot-API-compatible standard; ships ready-to-run jars, no BuildTools
compile step). Founder: "we need to set up a real EINHORN_INDUSTRIAL community survival minecraft
server" → "i want spigot" → "or whatever the most modern equivalent is."

Not related to GoblinFoxDragon/DragonsNShit — that's a from-scratch custom UDP protocol in
Dragonfly's general architectural style, not real Minecraft Bedrock/Java protocol, and not
vanilla-survival-shaped at all. This is the real thing: a real Java Edition server real Minecraft
clients connect to.

## Stack

- **Server**: Paper `26.2` build 97 (STABLE — 26.2 flipped from ALPHA to STABLE on 2026-08-05 and
  the server was upgraded to it that day; see `server/.paper/version_history.json` for what's
  actually running).
- **Java**: Temurin 25 (LTS), vendored locally at `jdk25/` (not a system package — this box had no
  JDK installed and no root/sudo; downloaded the portable Adoptium tarball directly instead).
- **Persistence**: user-level systemd (`ops/systemd/einhorn-survival.service`), no root needed.
  `loginctl show-user $(whoami) -p Linger` must say `Linger=yes` for the server to survive
  logout/reboot without an active session — already enabled on this box.
- **Bedrock bridge**: Geyser + Floodgate plugins (`server/plugins/Geyser-Spigot.jar`,
  `server/plugins/floodgate-spigot.jar`) — real Bedrock clients can join a real Java server.
  Bedrock port is `19133`, **not** Bedrock's standard `19132` — a separate, unrelated real
  Dragonfly server (`/home/fatbaby/dragonfly`) already owns `19132` on this box. Also needs
  **ViaVersion** (`server/plugins/ViaVersion.jar`) — Geyser translates Bedrock clients into a
  range of Java protocol versions that didn't line up with this exact pinned Paper build on its
  own; ViaVersion closes that gap. Real error hit live and fixed: "Your server software does not
  support the Java version that Geyser requires" until ViaVersion was installed. See
  `plugins/README-geyser-floodgate.md` for the full setup + why.

## Setup from scratch (if `jdk25/` or `server/paper-*.jar` are missing)

```bash
# JDK (Temurin 25 LTS, portable tarball, no root needed)
curl -s "https://api.adoptium.net/v3/assets/latest/25/hotspot?image_type=jdk&os=linux&architecture=x64" \
  | python3 -c "import json,sys; print(json.load(sys.stdin)[0]['binary']['package']['link'])"
# download that URL, tar -xzf into jdk25/ with --strip-components=1

# Paper server jar (check https://fill.papermc.io/v3/projects/paper for the current STABLE build
# before blindly grabbing "latest" -- the newest version family is sometimes still ALPHA/BETA)
curl -s "https://fill.papermc.io/v3/projects/paper/versions/<version>/builds" | python3 -m json.tool
# find the newest entry with "channel": "STABLE", download its downloads.server:default.url
# into server/paper-<version>-<build>.jar, update server/start.sh's -jar filename to match
```

Then: `cd server && echo "eula=true" > eula.txt` (required, Mojang's EULA — implicit in "set up a
Minecraft server," not asked separately each time), `./start.sh` once by hand to confirm it boots
and generates a world before wiring up systemd (see `ops/systemd/`'s own deploy steps).

## Config choices made at setup (real decisions, not defaults to leave unexamined)

- `online-mode=true` — only real, authenticated Mojang/Microsoft accounts can join. Turning this
  off lets anyone connect under any name (impersonation risk) in exchange for supporting
  offline/cracked clients -- deliberately left on for a real community server.
- `white-list=false` + `enforce-whitelist=false` (founder, 2026-08-05: "im down for online mode
  true for now but i am not down for the whitelist blacklist only until we have reason to
  switch") — open to anyone with a real, authenticated account; moderation is ban-based instead
  (`ban <username>`/`ban-ip <ip>` in the console, or edit `server/banned-players.json`/
  `banned-ips.json` directly — both git-tracked, real audit history). Started whitelist-closed at
  first boot as the safer default before any real community existed to moderate; switched once
  there was an actual server to open up. Revisit if ban-based moderation stops being enough.
- `-Xms3G -Xmx3G` in `start.sh`, with Aikar's flags (the standard JVM tuning set for Paper/Spigot,
  reduces GC pause stutter) — sized against this box's real ~7.8GB total RAM, shared with
  IDUNA/EMILY/other game servers already running here. Revisit if the box's real player count
  outgrows this.
- `enforce-secure-profile=false` (flipped from Paper's own default `true` — 2026-08-14, real
  incident: a real player, `.GarbageMan4147`, hit `"Chat disabled due to missing profile public
  key. Please try reconnecting."` and reported it as the GTA7 chat bridge being broken. It
  wasn't — this is Mojang/Paper's own chat-signing enforcement (unrelated to
  `GTA7/plugin/.../ChatBridgePoller.java`/`ChatBridgeListener.java`), which requires a client to
  present a signed chat profile key mainly so servers can participate in Mojang's official chat
  report system. Not useful for a private community server, and it silently locks legitimate
  players out of chat for a reason that reads as an unrelated bug from the player's side.
  `online-mode=true` (real account auth) is untouched — this only drops the extra signing
  requirement on top of it.

## What's git-tracked vs. not

Tracked: `server.properties`, `start.sh`, Paper/Bukkit/Spigot config (`bukkit.yml`, `spigot.yml`,
`commands.yml`, `help.yml`, `permissions.yml`, `config/`), and player-list data
(`whitelist.json`/`ops.json`/`banned-*.json`/`usercache.json`) — the last group deliberately
tracked as a real audit trail (who's whitelisted/opped/banned and when), same spirit as `APPLES`
being the git-authoritative Apple record elsewhere in this monorepo.

Not tracked (see `.gitignore`): the JDK (141MB download, not source), the Paper jar itself
(download artifact), world save data (`world*/`, binary, huge, regenerates), `logs/`/`cache/`/
`libraries/`/`versions/` (Paper's own internal working dirs), `eula.txt` (a personal acceptance
flag, no real content).

## Founder Real-Time Direction

Whenever the founder gives real-time direction — a new ask, a correction, a "can we also..." —
route it through `emily observe -s info "Founder real-time: <summary>"` first, even if it isn't
this repo's usual domain, then sprint-plan it into `EMILY/BACKLOG.md` (`emily backlog curate`,
scoped into a real SECTION/sub-item, not just a one-line log), and only then implement. See
`EMILY/docs/THE_EMILY_WAY.md` Principle 18 ("Pave the Cow Paths").

## README Reality — SAGA reconciliation (standing instruction, monorepo-wide)

Founder real-time, 2026-09-18: if a change of yours **substantially changes the claim of this project's core README**,
then per SAGA protocols (`EMILY/docs/SAGA_SYSTEM_AUDIT_2026-07-18.md`, HQ-SPEC-DOC-102: intent ↔ claim ledger ↔ reality)
you **must update `README.md` in the same unit of work** so it reflects current reality. The README is the project's public
claim; it must not lag behind the code.

- **When it applies:** a capability is added or removed; status moves ("design only" → "working", "planned" → "shipped");
  the stack, build, run or install steps change; a claim in the README is now false or stale; or you add a **meaningful,
  genuinely interesting piece of kit** (a new tool, engine capability, protocol, pipeline, game system). For that last case
  especially: put it in the README — what it is, how to run it, and its honest status and limits.
- **When it does not:** ordinary fixes, refactors and small features that leave the README's claims true.
- **How:** re-read the README against what you just changed; fix or delete stale lines (including "not built yet" notes that
  are now built); verify any new claim by actually running it, and mark anything untested as untested; commit the README
  with (or immediately after) the change, and mention it in the CHANGELOG entry.

## Frame-Break Reframing

Founder-sourced prompting technique (REDGARDEN/NORTHSTAR.md §28, full origin in
REDGARDEN/docs2/MULTI_AGENT_RD_RESEARCH_NOTES.md §5): given a request, name the underlying
structural/systemic pattern it's one instance of — one level of abstraction up — as an added
lens during planning/triage/judgment calls. Use it to spot the general case behind a specific
ask. It augments judgment, it does not replace doing the work: direct, concrete execution of
the literal task asked for still happens every time.

## Commit Protocol (standing instruction)

Always commit and push completed work immediately — don't wait to be asked. This is the default
for every repo in this monorepo.

Every commit — human-written or produced by automated code paths (git-commit helpers in emily-agent, emily.cli, IDUNA handlers, etc.) — must carry the active `emily session` fingerprint as a `session: <tag>` trailer (blank line, then the trailer). This was silently missing from several independently-implemented automated commit helpers across the monorepo until an audit on 2026-08-10 (founder, real-time: "where in the fuck is my llm session id anywhere"). If you add a new automated git-commit code path anywhere, wire in the session tag the same way — don't assume an existing helper already does it.
