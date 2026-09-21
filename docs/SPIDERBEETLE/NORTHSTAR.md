# NORTHSTAR — SPIDERBEETLE

Moved here from `PARENA/docs/ANDROID_JAVA_TARGET_NORTHSTAR.md` now that this repo is the real
home for the work it scoped (same real precedent `BURROW`'s own `DUNG.md` set when `DUNG` got its
own repo) — PARENA's own doc there now just points here.

## What's real and shipped

`app/src/main/java/industrial/einhorn/spiderbeetle/generated/BatteryUi.java` — two real, small,
pure decision functions (`shouldShowLowBatteryWarning`, `clampBrightness`) plausible for a real
Android app to actually need (`MJOLNIR` is the real, established precedent for what a real
Android app in this monorepo does). Compiled via PARENA's own real Java emitter
(`parena build stdlib/android/battery_ui.prn -o app/src/main/java/industrial/einhorn/
spiderbeetle/generated/BatteryUi.java` — the real Maven/Gradle-convention output path so
`parena`'s own `java_package_name_from_path` derives the package automatically) and verified
with a REAL JDK (`javac`/`java 25.0.4`, the same version `PARENA/STDLIB.md`'s own
`BezierInterp`/`Humanness` Java proof already used) against `smoke_test/Main.java` — 7 real
assertions, all pass, including the boundary case (`batteryPct == 15` warns; `16` doesn't) and
both brightness-clamp directions.

## What's real and honestly NOT attempted

**A real, buildable, runnable Android APK.** Checked directly, not assumed: this sandbox has no
Android SDK (`ANDROID_HOME`/`ANDROID_SDK_ROOT` both unset, no `sdkmanager`/`adb` on `PATH`), and
`MJOLNIR` — this monorepo's own real, existing Android app — doesn't even have a real `gradlew`
wrapper script checked out locally (only the `gradle/wrapper` metadata), confirming MJOLNIR
itself is never actually built or run in this sandbox either, only via real CI or the founder's
own machine. Building a genuinely new Android project here and claiming it's real without ever
compiling it would be exactly the kind of "written but not verified" gap this monorepo's own
standing discipline refuses to ship — so it isn't attempted. Real, honest deliverable instead:
prove the PARENA→Java compiler pipeline itself works end to end (done, above), and name the real,
concrete remaining steps plainly.

## Real, concrete next steps (none started)

1. A minimal Android project skeleton (`app/build.gradle.kts`, root `settings.gradle.kts`,
   `AndroidManifest.xml`, one Activity) — mechanical, low-risk, but genuinely unverifiable
   without the Android SDK present, so real, later work rather than guessed-at scaffolding now.
   `MJOLNIR/build.gradle.kts` and `MJOLNIR/app/build.gradle.kts` are the real, direct templates
   to start from, not invented fresh.
2. Wiring `BatteryUi.shouldShowLowBatteryWarning`/`clampBrightness` (or their real, eventual
   equivalents) into an Activity's own real battery-state callback (`BatteryManager`) and
   brightness-setting call (`WindowManager.LayoutParams.screenBrightness`) — real Android APIs
   this v0's own scalar-only PARENA functions were deliberately designed to plug into without
   needing any Android-specific type crossing the PARENA/Java boundary.
3. A real CI step (a new `.github/workflows/` here, or extending an existing one) that actually
   has the Android SDK available, to build and instrument-test the result — the real, missing
   piece that would let this go from "proven in isolation" to "proven as a real app."
4. Deciding whether more PARENA decision logic (beyond battery/brightness) belongs in this repo's
   own `generated/` tree as the app grows, or whether `PARENA/stdlib/android/*.prn` should host a
   broader real library first — an open, real, undecided question, not resolved here.

## Related

- `PARENA/STDLIB.md`'s own "android/battery-ui" section and "Real proof, verified with an actual
  `javac`" section (the `BezierInterp`/`Humanness` precedent this repo's own verification
  approach follows).
- `MJOLNIR/CLAUDE.md` — this monorepo's own real, existing Android app; the real reference for
  what Android build tooling this monorepo already assumes exists (and doesn't, locally, in this
  sandbox).
- `PARENA/docs/V16_NORTHSTAR.md` — the same "size the ask honestly, ship what's real, name what
  isn't" discipline applied to a different, larger ask in the same monorepo.
