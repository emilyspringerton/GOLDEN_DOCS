# EmilyOS — GAME Domain Kiosk Boot (boots into SHANKPIT)

**Status:** implemented and live-verified end to end against a real (headless Xvfb) X server and
a real openbox binary — window decoration/maximize rules, Alt+F4, the escape-hatch keybind, and
the lobby crash-relaunch loop were all exercised and confirmed working, and two real bugs were
found and fixed in the process (see "Bugs found and fixed by live-testing" below). The one piece
still genuinely untested is SHANKPIT's own real lobby binary and a non-headless display/real
hardware boot — see "Honest gaps".

**Founder real-time, 2026-09-25:** "set up EMILY OS so that it boots into shankpit and then the
new windows that pop up for apps — handle that with like x or whatever." This document is that
setup: EmilyOS's own GAME posture (`docs/POSTURE.md`, `docs/legacy-archive/10.md`) had named a
"game domain" since Milestone 3 but nothing had ever actually implemented or launched one — this
wires SHANKPIT's lobby in as the concrete game domain, and answers "handle the popup windows with
X" literally: a minimal X11 window manager (openbox) is what turns SHANKPIT lobby's own
`lobby_launch_app` child processes (DEADWEIGHT, PITVIPER, IDUNA.GAME, EDITOR.GAME, REDGARDEN —
each its own separate SDL2 window, confirmed by reading `apps/lobby/src/main.c` in the SHANKPIT
repo) from undecorated, unmanageable raw X11 windows into normal, closable, focusable ones.

## Why a window manager is required at all

With no window manager running, a plain Xorg server gives every new top-level window zero
decoration: no titlebar, no border, no close button, no Alt+Tab, and no way to move or resize it.
SHANKPIT's lobby launches its own popup apps via `fork()` + `execl()` — genuinely separate
processes, each opening its own top-level window, not something the lobby itself can decorate or
manage. A window manager is the only layer that can give those windows any of that. openbox was
picked for being small, dependency-light, and a plain floating (not tiling) WM — the right shape
for "one SDL2 window at a time popping up," not a tiling layout.

## What's implemented

### 1. The GAME domain, for real, in the policy kernel

`internal/domain/game.go` (new): `Run(command, pidFile)` starts a command as the leader of its
own process group and blocks until it exits; `Stop(pidFile)` signals that whole process group.
This is `docs/legacy-archive/10.md`'s "Option A — GAME is a separate native domain," implemented
for the first time — previously, `DOMAIN_START`/`DOMAIN_STOP` on `domain:game` were audited but
ran a no-op placeholder handler (`cmd/emilyos/main.go`'s generic `verb dispatch` command).

`emilyos game start` / `emilyos game stop` (new CLI subcommands, `cmd/emilyos/main.go`):

- `game start` dispatches `GAME` (transitions posture NORMAL→GAME), then dispatches
  `DOMAIN_START` on `domain:game` — this is the first time this codebase has actually exercised
  the `GameDomainOnly` posture verdict (`internal/verb/dispatch.go`'s check that `objectRef ==
  "domain:game"`), not just tested it in isolation. `DOMAIN_START`'s handler blocks for the whole
  game session; when it returns (the game domain exited, one way or another), posture always
  reverts to NORMAL — even on error or denial, so a failed launch can't leave `cap.net` stuck
  `FORCE_OFF` (G0, `docs/legacy-archive/10.md`) indefinitely. A SIGTERM/SIGINT handler relays the
  signal into the game domain's own process group rather than letting Go's default disposition
  kill the `emilyos` process outright — this matters because `systemctl stop` on the packaged
  systemd unit below sends SIGTERM to exactly this process, and without the relay the posture
  revert would never run.
- `game stop` reads the pidfile `game start` wrote and signals the tracked process group from a
  separate invocation (e.g., the systemd unit's `ExecStopPost=`).

Live-verified in this sandbox (no X, no SHANKPIT binary needed for this part — `EMILY_GAME_
DOMAIN_CMD` was set to a plain `sleep` for the test): `game start` correctly transitions
NORMAL→GAME, blocks, and reverts GAME→NORMAL on both a normal exit and a SIGTERM (both the
`game stop`-initiated path and a direct SIGTERM to the `emilyos` process itself, simulating
`systemctl stop`); the audit log correctly chains `GAME` → `DOMAIN_START` → `posture.set`
events with `decision=allow` throughout. `go test ./...` passes, including new tests in
`internal/domain/game_test.go`.

### 2. The kiosk launcher (`packaging/domains/game/`)

- `start.sh` — `EMILY_GAME_DOMAIN_CMD`'s packaged default (`/etc/emilyos/domains/game/start.sh`
  once installed). Runs `startx` on a configurable VT (`EMILY_GAME_VT`, default `vt1`).
- `xinitrc` — the actual X session: disables DPMS/screen blanking, starts `openbox` in the
  background, then loops launching `$SHANKPIT_LOBBY_BIN` (default `/opt/shankpit/bin/shank_lobby`
  — SHANKPIT's own `make lobby` build target, see SHANKPIT's `Makefile`). If the lobby exits
  (crash, or the player backing out to nothing), it's relaunched — that loop, not openbox exiting,
  is what "boots into SHANKPIT" actually means day to day. The real way out is openbox's own
  escape-hatch keybind.
- `openbox/rc.xml` — window manager config. SHANKPIT's lobby window (`class="shank_lobby"`,
  assuming SDL2's default WM_CLASS derived from the binary name) is borderless and maximized, so
  it reads as the desktop; every other window (the apps the lobby forks off) gets normal
  decorations, focus-on-map, Alt+Tab, and Alt+F4-to-close. `Ctrl+Alt+BackSpace` is bound to exit
  the whole session (the old X11 "zap" combo) as an admin recovery path, mirrored in
  `openbox/menu.xml`'s single right-click menu item for a mouse-only equivalent.

### 2a. Bugs found and fixed by live-testing (2026-09-25, second pass)

Installed `Xvfb`, `openbox`, `xdotool`, `x11-utils`, and `xterm` in this sandbox and ran the
actual packaged config against a real (headless) X server. Two real bugs surfaced immediately —
neither would have been caught by XML well-formedness checking or reading the config back:

1. **`openbox --menu <file>` is not a real command-line flag.** `openbox --help` against the
   real binary confirms the only options are `--config-file`, `--replace`, `--sm-disable`, etc. —
   there is no `--menu`. `xinitrc` originally passed one; openbox rejected it and exited
   immediately (`Openbox-Message: Invalid command line argument "--menu"`). Fixed by moving the
   menu path into `rc.xml`'s own `<menu><file>...</file></menu>` element instead, which is the
   real, documented mechanism (confirmed against `/etc/xdg/openbox/rc.xml`, the package's own
   shipped default config).
2. **`<application>` rule ordering bug: the wildcard silently clobbered the specific rule.**
   openbox applies every matching `<application>` block in file order, with later blocks
   overriding earlier ones for the same window. The original `rc.xml` listed the
   `class="shank_lobby"` rule first and the `class="*"` wildcard second — but `*` also matches
   `shank_lobby`, so the wildcard's `decor=yes`/`maximized=no` ran *after* and silently undid the
   lobby's own `decor=no`/`maximized=yes`. Live-confirmed with a stand-in `xterm -class
   shank_lobby`: before the fix, `_NET_WM_STATE` was empty and `_NET_FRAME_EXTENTS` showed a
   normal titlebar; after reordering the wildcard to come first, the same window correctly showed
   `_NET_WM_STATE_MAXIMIZED_VERT`/`_MAXIMIZED_HORZ`/`_OB_WM_STATE_UNDECORATED` and `_NET_FRAME_
   EXTENTS = 0,0,0,0`, filling the full 1024x768 test screen. A second `xterm -class dw_gui`
   (standing in for a popup app window) correctly kept its normal decorations
   (`_NET_FRAME_EXTENTS = 1,1,22,5`, an 848x316 floating window) throughout.

Also live-confirmed, unchanged from the original design:

- `xdotool key alt+F4` on the focused `dw_gui`-class window closed exactly that window, leaving
  the `shank_lobby`-class window untouched.
- `xdotool key ctrl+alt+BackSpace` (the escape-hatch keybind) terminated the whole openbox
  process within ~1s, confirmed by watching `pgrep openbox` go from a live PID to nothing.
- Running the real, packaged `xinitrc` script directly (not a hand-typed reproduction of it):
  with no `SHANKPIT_LOBBY_BIN`, it printed the correct "not found or not executable" warning and
  looped every 5s; pointed at a stand-in "lobby" script that exits after 1s, it relaunched that
  script 5 times over 5 seconds (confirming the crash-relaunch loop) and the script's own `while
  kill -0 "$OPENBOX_PID"` loop correctly exited within ~1s of `openbox` being killed.
- `shellcheck -s sh` on both `start.sh` and `xinitrc`: zero findings.

Not exercised even now: `start.sh`'s own `startx ... -- vt1 -nocursor` invocation (Xvfb stood in
for what `startx` would normally set up — a real VT switch/console takeover needs real console
access this sandbox doesn't have), and the systemd unit's own `PAMName=login`/`TTYPath=/dev/tty1`
console-ownership mechanics.

### 3. Packaging

- `packaging/systemd/emilyos-game.service` — takes over `tty1` from `getty@tty1.service`
  (`Conflicts=`) and runs `emilyos game start` as a dedicated `emilyos-game` user.
  `Type=simple` is correct (not `forking`) because `game start` blocks for the session's whole
  duration. `Restart=on-failure` restarts the session if it dies unexpectedly; `ExecStopPost=`
  runs `emilyos game stop` as a belt-and-suspenders cleanup. Includes a first-cut resource budget
  (`CPUQuota=300%`, `MemoryMax=3G`) — a real, if unmeasured, step toward G2 ("deterministic
  resource budget") from `docs/legacy-archive/10.md`, tunable once this actually runs on real
  hardware. **Passes `systemd-analyze verify` clean** (checked live in this sandbox with the
  `emilyos` binary present at the path the unit expects).
  **Shipped disabled — not enabled by `postinst`.** Taking over tty1 is a real behavior change
  a package install should never do silently.
- `packaging/debian/control` — adds `Suggests: xserver-xorg, xinit, openbox` (soft: only needed
  if the kiosk path is actually used).
- `packaging/scripts/build-deb.sh` — stages the new files under `/etc/emilyos/domains/game/` and
  `/lib/systemd/system/emilyos-game.service` in the `.deb`.

## Manual setup (not automated — deliberately)

1. Build/install SHANKPIT on the box (see the SHANKPIT repo's own `CLAUDE.md`/`README.md`;
   `make lobby` produces `bin/shank_lobby`). Copy or symlink it to `/opt/shankpit/bin/shank_lobby`,
   or set `SHANKPIT_LOBBY_BIN` in the systemd unit's `Environment=` to wherever it actually lives.
2. Install `xserver-xorg`, `xinit`, `openbox` (`apt install xserver-xorg xinit openbox`).
3. Create the kiosk user: `useradd -m -G video,input,tty emilyos-game` (needs a real login shell
   and `/dev/tty1`/DRM access, which is why it's a real user, not a system/nologin account).
4. `systemctl enable --now emilyos-game.service`.

To leave the GAME domain from outside the machine (e.g., over SSH): `emilyos game stop`, or
`systemctl stop emilyos-game.service`.

## Honest gaps

- **Real SHANKPIT binary, real (non-headless) display, and real hardware boot are still
  untested.** The openbox/xinitrc layer is now live-verified against a real openbox binary on a
  real (headless, Xvfb) X server — see "Bugs found and fixed by live-testing" above — but that's
  a stand-in for the real thing on two axes: a plain `xterm -class shank_lobby` is not SHANKPIT's
  actual `shank_lobby` binary (its real WM_CLASS has not been checked with `xprop`/`obxprop`
  against the genuine compiled binary), and Xvfb is not a real GPU-backed X server on real
  console hardware (no VT switch, no DRM/KMS, no real keyboard/mouse device). `start.sh`'s own
  `startx ... -- vt1` invocation and the systemd unit's console-ownership mechanics
  (`PAMName=login`, `TTYPath=/dev/tty1`) are unexercised for the same reason.
- **Not wired into RBAC's per-identity nuance.** Any operator (not just admin) can `emilyos game
  start` today, matching `capForVerb("GAME") == CapSessionOpen` (every role has it) — this
  matches the doc's own framing of GAME as operator relief, not a privileged action, but hasn't
  been discussed with the founder as a deliberate choice versus admin-gating it.
- **Resource caps (G2) are a first-cut guess**, not measured against real hardware running a real
  X session + SHANKPIT + whatever it forks.
- **Requires SHANKPIT already built on the box.** EmilyOS doesn't vendor, fetch, or build
  SHANKPIT itself — `SHANKPIT_LOBBY_BIN` must point at an install a human or a separate deploy
  step already produced.
- **Found, not fixed, pre-existing gap nearby:** `packaging/scripts/build-deb.sh` creates
  `${BUILD_DIR}/lib/systemd/system` but has never actually copied EmilyOS's own main
  `emilyos.service` unit into it, despite `docs/PACKAGING.md` and `packaging/debian/postinst`
  both referencing it — the `.deb` this script produces has apparently never shipped that unit
  file. Unrelated to this feature; named here rather than silently worked around, not fixed as
  part of this change to avoid scope creep on an unrelated pre-existing issue.
- **No GAME→SIEGE/MERCY interaction has been re-tested** with a real domain command running;
  `internal/posture`'s own existing tests cover the pure state-machine transitions, not this new
  process-launching path combined with a posture change mid-session (e.g., what happens if
  something else forces a posture transition away from GAME while the domain process is still
  running — today nothing does that, since only `game start`/`game stop` touch GAME posture, but
  it's worth naming as untested territory if that ever changes).

## Related

- `docs/legacy-archive/10.md` — the original GAME-verb design doc this implements.
- `docs/POSTURE.md` — the posture state machine and capability-override table.
- `docs/NORTHSTAR.md` Milestone 3 — where the GAME posture was first specified.
- SHANKPIT `apps/lobby/src/main.c` (`lobby_launch_app`) — the actual fork+exec mechanism this
  document's window-manager layer exists to handle.
- `SHANKPIT/docs/SHANKPIT_OS_NORTHSTAR.md` (golden doc `SHANKPIT-OS-NORTH`) — a related but
  **distinct** effort: SHANKPIT becoming the shell/SSO for the whole IDUNA games ecosystem, using
  EmilyOS's own UI/affordance language as its visual guide. This document is the other direction —
  EmilyOS's policy kernel booting a machine straight into SHANKPIT — not the same project. Worth
  reading both before assuming "EmilyOS" and "SHANKPIT_OS" mean the same thing; they don't.
