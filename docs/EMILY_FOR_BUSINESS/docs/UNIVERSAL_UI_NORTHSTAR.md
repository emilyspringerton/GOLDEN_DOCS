# NORTHSTAR — A Universal Affordance Language (the frontend half of "vibe code your own APIs")

*Spec-only, 2026-09-11. No code, no name locked in, no repo of its own yet — this document names
the real shape of a genuinely novel idea and the real, hard problems in it, matching this
monorepo's own established discipline (`LO/NORTHSTAR.md`'s own critical review of its source
design doc is the direct precedent for this document's own tone) rather than a design pitched as
already solved.*

## Where this came from

Founder, real-time, same thread that produced `IDUNA/docs/EMILY_FOR_BUSINESS_NORTHSTAR.md`'s own
"the Rails for 2026 agents" section, preserved close to verbatim: "what does the frontend look
like? we need a super abstract language for affordances like a BA would write a user can do this
— not at all about the interface because think about it we can have an android interface or we
can have a ratatui terminal interface for the same apis. so like what if we build a language like
react native but its even more abstract — like we target ratatui and android native and react
native and flutter and everything you just need to write an adaptor you know?"

## The real idea, stated precisely

**Separate WHAT a user can do from HOW it's rendered, one full abstraction layer further than
React Native/Flutter already go.** React Native and Flutter both already separate "app logic"
from "platform-specific rendering," but both still commit to one rendering PARADIGM — a retained-
mode widget tree, painted by a GPU-backed engine, assuming a pointer/touch input model and a
2D visual canvas. Every real target they support (iOS, Android, web-via-canvas) is a variation on
that same paradigm. **A terminal UI (ratatui) is not a variation on that paradigm — it's a
categorically different one**: cell-addressed monospace text, no images/video without real,
lossy tricks (sixel/kitty-graphics, not universally supported), keyboard-and-maybe-mouse input
with no touch/gesture/haptic concept at all, no true 2D freeform layout (everything is rows/
columns of character cells). Naming a real, useful "affordance" that spans BOTH honestly — not by
picking the lowest common denominator and calling it done, but by having a real degradation story
for what each target genuinely can't do — is the actual hard, novel problem here. React Native/
Flutter never had to solve this because they never tried to also target something as
fundamentally different as a terminal.

## Real prior art, named honestly — this is not being invented from nothing

- **React Native / Flutter** — the direct naming inspiration, and the real ceiling this idea
  explicitly wants to go past (see above): both already prove "write once, adapt per target," but
  only within the single GUI-widget-tree paradigm.
- **JSON Schema + UI Schema (`react-jsonschema-form` and its many cousins)** — real, existing
  precedent for "describe DATA and the ALLOWED OPERATIONS on it declaratively, let a renderer
  decide the concrete widget" — much closer in spirit to "a BA would write 'a user can do this'"
  than React Native is, but scoped narrowly to FORMS, not whole-app navigation/flow.
  Low-code/no-code platforms (Retool, Appsmith, Salesforce Lightning) generalize this to whole
  apps, but every one of them still targets a single rendering paradigm (a web canvas), same real
  ceiling as React Native/Flutter.
- **Gherkin/Cucumber's `Given`/`When`/`Then`** — real, existing, genuinely BA-authored prior art
  for describing BEHAVIOR abstractly ("Given a user is logged in, When they tap Checkout, Then
  they see an order confirmation") — much closer to the actual REGISTER the founder's own "a BA
  would write 'a user can do this'" is describing than any UI framework is, but it describes
  TEST SCENARIOS over an already-built UI, not a source specification a renderer generates a UI
  FROM. A real, interesting open question (see "Real, open design questions" below): could this
  language's own affordance description double as its own real, executable acceptance-test
  suite, the same content serving both jobs?
- **Android's own `Intent` system** — real, existing OS-level precedent for "a user wants to
  perform ACTION X on DATA of TYPE Y," resolved to a concrete Activity at runtime, not authored
  at build time — closer in SPIRIT (action-and-data over exact-widget) than any of the above, but
  scoped to inter-app handoff, not whole-app UI description.
- **This monorepo's own real, already-proven "one source, many backends" pattern** — PARENA
  itself already does exactly this shape one layer down: one `.prn` source file, real, distinct
  C/Java/TypeScript emitters (Wasm planned), each producing genuinely idiomatic output for its
  own target, not a lowest-common-denominator translation. `KARAMBIT`/`SPIDERBEETLE`'s own real,
  shipped "PARENA emits pure decision logic, a thin native host does real I/O" split is the
  closest existing precedent in this ENTIRE monorepo to what an "adapter" for this new language
  would concretely be: PARENA already proves that a narrow, purpose-built DSL compiling to
  multiple genuinely different targets is tractable here, not theoretical. This is real,
  load-bearing grounding for why this idea is worth scoping seriously rather than dismissing as
  too ambitious.

## A real, concrete conceptual model — proposed, not final

Three layers, matching the founder's own "language for affordances... you just need to write an
adaptor" framing directly:

### 1. The Affordance IR (intermediate representation)

A structured, declarative description of an application in terms a BA would actually write, not
in terms of pixels or widgets:

- **Entities** — the real, named things a user deals with (a Repo, an Issue, a Resume, a Skill —
  matching this exact monorepo's own real domain models already sitting in IDUNA_PRO/PARENA
  stdlib). Just data shape + a human-readable label, no visual information at all.
- **Actions** — a real, named thing a user CAN DO to an entity or the app as a whole ("create a
  Repo," "add a Skill," "categorize Skills with AI," "sign in") — each with a real, declared
  input shape (what data the action needs), a real, declared effect (what API call/state change
  it causes — this is the literal seam where this language calls into the backend half of the
  platform, `IDUNA_PRO`'s own APIs), and real, declared preconditions (must be signed in, must
  have `community-tools.access`, entity must exist) — the precondition model directly reuses
  RBAC/permission concepts IDUNA_PRO already has, not a second, parallel authorization system.
- **Views** — a real, named place a user can BE, described as "shows these entities, offers these
  actions" (a list view, a detail view, a form) — no layout, no color, no widget choice at all.
  This is the layer a BA-authored user story maps onto directly: "a user can see their list of
  Skills and add a new one" is literally one View + two Actions in this IR, nothing more
  specified.
- **Flows** — real, named transitions between Views triggered by Actions (submitting the "add a
  Skill" form returns to the Skills list View) — the abstract equivalent of navigation, described
  as a graph, not a stack/tab-bar/drawer (those are rendering choices, made in layer 3 below).

### 2. The Capability Model — the real, honest, load-bearing piece nothing in the prior-art list
above has to solve, because none of them span this wide

Every target platform DECLARES which Affordance IR primitives it can render, and how — not
assumed to support everything. A real, concrete, partial example:

| IR primitive | Android native | React Native | Flutter | ratatui (terminal) |
|---|---|---|---|---|
| List View | `RecyclerView` | `FlatList` | `ListView` | a scrollable table widget |
| Detail View | an `Activity`/Fragment | a screen component | a `Widget` | a bordered text block |
| Form Action | native input widgets | `TextInput` components | `TextField` widgets | line-edit widgets, Tab to move focus |
| Image display | `ImageView` | `Image` | `Image` | **degraded**: filename/alt-text only, or a real (lossy, terminal-dependent) sixel/kitty-graphics attempt named as opt-in, never assumed |
| Touch gesture (swipe-to-delete) | native gesture detector | `PanResponder`/gesture lib | `GestureDetector` | **no equivalent** — degrades to an explicit keyboard action ("press d to delete"), never silently dropped |
| Push notification | real OS notification | real OS notification | real OS notification | **no equivalent** — degrades to nothing, or a log line if the terminal app has a status bar |

**The real, honest design commitment this table implies**: a target that cannot render a given
affordance must DEGRADE EXPLICITLY (a named, visible fallback — "not available in this
interface," or a text-only substitute) and never SILENTLY DROP a real, described capability. This
is the same "an unsupported shape gets a real, clean error, never a silent wrong answer or a
crash" discipline this whole monorepo's PARENA self-hosting effort already holds itself to
(`selfhost/emit.prn`'s own real "#error, never a segfault" convention) — applied here to UI
capability instead of compiler shape-matching, but the same real principle.

### 3. Adapters — one per target, the piece the founder named directly as "the thing you write"

An Adapter consumes the Affordance IR (filtered through that target's own real Capability Model)
and produces genuinely idiomatic output for its own platform — not a generic, lowest-common-
denominator UI, the same real standard PARENA's own emitters already hold themselves to (real,
idiomatic C/Java/TS output, not one dialect wearing three different file extensions). Real,
concrete candidate implementation shape, directly reusing this monorepo's own established,
working pattern: an Adapter is itself substantially a PARENA program (or a `burrow`-compiled Go
program, for a Go-hosted target) that walks the Affordance IR and emits real target-native source
(Kotlin/Java for Android, TSX for React Native, Dart for Flutter, Rust for ratatui) — the exact
same "PARENA/BURROW emits real target code, a thin per-target runtime consumes it" shape this
whole monorepo already trusts, one abstraction layer higher than any single existing PARENA
emitter currently reaches.

## Real, open design questions — named, not resolved

1. **Where does the Affordance IR itself get authored?** As real PARENA `.prn` source (a new
   `stdlib/ui/affordance.prn`-shaped domain), as a declarative YAML/JSON config (matching the
   backend-side "Terraform-like" option named in `EMILY_FOR_BUSINESS_NORTHSTAR.md`), or as its
   own small, purpose-built DSL (the same "Rails-like framework built as a stdlib first, a real
   LO-level construct only if genuinely needed" discipline `LO/FRAMEWORK_NORTHSTAR.md` already
   established for the backend side)? Recommendation, not a decision, for exactly that same
   reason: start as a PARENA stdlib module (fastest to get a real, working end-to-end proof), let
   a dedicated surface syntax earn its own existence later if the stdlib-only version proves
   genuinely awkward to author by hand.
2. **Does the Affordance IR double as a real, executable acceptance-test suite** (the Gherkin
   parallel named above)? A real, attractive property if it works: the SAME description that
   generates the Android/ratatui/React Native/Flutter UI could also be the source of a real,
   automated "does this app actually let a user do what it claims" test — but this needs a real,
   working per-adapter driver (an Android UI test harness, a ratatui input-injection harness,
   etc.) that doesn't exist and isn't scoped here.
3. **How does real-time/live data (websockets, push) get described abstractly** when the targets'
   own real capability for it varies this widely (a terminal app can poll or hold a persistent
   connection and redraw; a mobile OS has real, separate push-notification infrastructure a
   foreground redraw model doesn't need)? Not resolved — likely needs its own real IR primitive
   ("this View subscribes to live updates on Entity X") with per-adapter-specific
   implementation, not a one-size mechanism.
4. **State management across four genuinely different runtime models** (a terminal app's own
   event loop, React Native's own component state/hooks, Flutter's own widget rebuild model,
   Android's own Activity/ViewModel lifecycle) — the Affordance IR describing WHAT state exists
   (per the Entities/Views layers above) is the easy 80%; each Adapter still has to solve HOW that
   state is held and invalidated in its own idiomatic way, a real, substantial per-adapter
   engineering job each time, not eliminated by this design, only made consistent in what each
   adapter is implementing against.
5. **Accessibility** — genuinely different per-platform primitives (Android's own
   `TalkBack`/content-descriptions, a terminal's own screen-reader story is a real, much narrower,
   different problem entirely) — named here as a real gap this document does not attempt to
   solve, not glossed over.

## Real, phased plan

**Phase 0 — this document.** Named, no code.

**Phase 1 — prove the hardest real pair first, on the narrowest possible slice.** Not "build all
four adapters" — pick the two targets with the LEAST in common (ratatui and Android native, or
ratatui and React Native — a terminal versus a real touch GUI is the actual hard case; React
Native versus Flutter are close enough to each other that proving that pair first would hide the
real problem) and implement exactly ONE trivial affordance end to end: a List View + a Create
Action + a Detail View over one simple Entity (a real, minimal CRUD loop — matching this
document's own "Skills" example, or reusing `KARAMBIT`'s own already-real `ScanResult` entity as
a genuinely available, already-built test subject). Real Definition of Done: the SAME Affordance
IR source produces a genuinely usable ratatui terminal app and a genuinely usable native/React
Native screen, with zero per-target hand-editing of the generated output.

**Phase 2 — the Capability Model + explicit degradation**, proven on a second affordance that
Phase 1's pair genuinely disagrees on capability for (e.g. add an image-display affordance, watch
the terminal adapter degrade explicitly rather than crash or silently omit it).

**Phase 3 — the remaining two adapters** (Flutter, and whichever of React Native/Android wasn't
in the Phase 1 pair), proving the model generalizes past the two targets it was designed against.

**Phase 4 (stretch)** — the acceptance-test-suite question (open design question 2 above), the
real-time/live-data primitive (question 3), and a real authoring surface beyond raw PARENA stdlib
calls if Phase 1-3 show hand-authoring the IR is genuinely too awkward.

## Naming — real, deliberately left open

No name is locked in. Following this exact monorepo's own established convention for a genuinely
new idea (`SAND` went `IRONCLAD → JEWEL → SAND` before landing; `LO`/`qi` were named and re-named
in real time) — this document uses "the Affordance IR"/"this language" throughout rather than
inventing a name unilaterally. Candidate directions, offered not decided: something naming the
"adapter" concept directly (the founder's own chosen word), or something continuing the
React-Native-but-further lineage the founder's own framing invoked.

## Related

- `IDUNA/docs/EMILY_FOR_BUSINESS_NORTHSTAR.md` — the backend half of this same platform pitch
  ("an API that lets you create APIs"); this document is its frontend counterpart.
- `IDUNA_PRO/docs/MULTI_TENANCY_NORTHSTAR.md` — Phase 0 for the backend half; this document's own
  adapters would ultimately consume tenant-scoped `IDUNA_PRO` APIs once that work lands.
- `LO/FRAMEWORK_NORTHSTAR.md` — the real, closest-existing precedent in this monorepo for "a
  narrow DSL generating real backend code," the direct inspiration for this document's own
  Adapter model.
- `KARAMBIT`/`SPIDERBEETLE` — real, shipped, minimal examples of "PARENA owns decision logic, a
  thin native host does real I/O," the concrete precedent an Adapter's own implementation shape
  would extend.
- `PITVIPER`/`DUNG`/`SAND` — this monorepo's own existing terminal-UI and editor work; real,
  worth a direct look before Phase 1 starts, for whether any existing ratatui-adjacent Rust/Go
  terminal-rendering code here is reusable as (or informs) the ratatui Adapter specifically.
