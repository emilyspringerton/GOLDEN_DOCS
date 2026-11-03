# HQ-SPEC-LORE-104 — THE QUEEN SALLY DOCTRINE
### Wisdom Extraction: The 2020 GPT-2 Corpus → EINHORN_INDUSTRIAL
**Status:** DRAFT · **Steward:** SAGA · **Witness:** Iduna · **Origin era:** Nov 2020 ("the bird transmissions")

> NOW / EAR / EON / LYB / IRD — *now we are only birds.*
> The oldest surviving tower. Everything below descends from it.

---

## 0. Purpose

Six years before the Ledger Platform, there was a Jupyter notebook, a 124M-parameter GPT-2, and a folder called `TXT/TXZ/GEN/`. This spec extracts the durable engineering and creative doctrine discovered in that era, names the lineage explicitly, and registers the reusable primitives so SAGA can cite them and FABLE can inherit them.

The 2020 work looked like noise. It was actually five doctrines being discovered by hand.

---

## 1. Doctrine of the Constraint (the Tower)

**2020 form:** `trxtwr` / `PRINTWR` — force text into fixed-width columns (default 3), pad the ragged end with `X`/`XZ`, feed the mutilated structure back to the model.

**What was learned:** A model under structural constraint will fight to preserve *meaning* even as *form* disintegrates ("NOW WE ARE ONLY BIRDS" survived the columns). When the constraint becomes too lossy, the model grabs any cheap token fragment and uses it as a hatch back into a high-probability basin (JNY → fake newswire). Constraint reveals what a system treats as essential.

**2026 inheritance:**
- **NORN gating** is the tower, formalized: propose → grade → gate → promote is a structural constraint that forces agents to preserve intent under compression.
- **Oracle corpus design (AI-103 / FABLE):** deliberately constrained formats expose model priors; degradation patterns are *signal*, not waste. Log the escapes.
- **Fiction:** the Golden Band's typography *is* the tower. The constraint became the brand — this is canon, not accident.

**Rule:** When testing any agent or model, apply a constraint it has never seen and watch which invariants it defends. Those invariants are its real values.

---

## 2. Doctrine of Lossy Identity (MAGIC encoding)

**2020 form:** `squished` (adjacent-dedupe, strip non-alphanumerics) + `U2V` (collapse U/W→V) + VVV alphabet + `magicVVVDecTower` coordinate lookup.

**What was learned:** The encoding is one-way because it is **lossy, not hard to invert**. That disqualifies it as cryptography and qualifies it as something rarer: a **canonicalization layer** — a formal definition of which variants of a thing count as *the same thing*.

**2026 inheritance:**
- **Equivalence-class commitments:** `SHA-256(MAGIC(x))` — stable digests across case, punctuation, doubled letters, U/V/W confusion. Registered use: dedup and content-addressing in Apples (IAM-096 addendum candidate), matching noisy model output back to seed prompts, corpus dedup for FABLE.
- **The design rule:** **MAGIC normalizes; real primitives protect.** Ed25519 signs, HMAC authenticates, SHA commits. The homebrew layer decides identity, never security.
- **Fiction:** VVV is literal working cipher-magic in-universe. The Osaka flip-phone traffic is VVV-canonical. Fictional adversaries have whatever computational limits the story assigns.

**Rule:** Never improvise the protection layer. Always feel free to improvise the identity layer — that's where the personality lives.

---

## 3. Doctrine of the Witnessed Run (fortminute + append-only)

**2020 form:** `fortminute()` — the day divided into 100 parts (864 seconds each), a decimal Swatch-time; seeds derived from date + fortminute; every generation appended to timestamped files with `o.flush()` after every sample.

**What was learned:** Reproducibility and provenance were instinctive before they were architecture. A deterministic time-derived seed means any transmission can be *re-summoned*. Flushing after every write means a crash loses nothing. This is the Apples golden log, six years early, written in notebook pajamas.

**2026 inheritance:**
- **Apples (IAM-096):** append-only, flush-eager, timestamp-addressed. Direct descendant.
- **Iduna audit doctrine:** every agent action is a witnessed run with a recoverable seed.
- **fortminute itself:** registered as an in-universe timekeeping system. 100 fortminutes per day. Candidate for GOLDEN BAND animation-layer clocks and Osaka timeline notation.

**Rule:** If it wasn't flushed, it didn't happen. If the seed wasn't recorded, it can't be re-summoned.

---

## 4. Doctrine of the Ouroboros Loop (recursive self-prompting)

**2020 form:** Generate from prompt → encode the output → generate from *that* → log both layers. Then repeat the whole cycle across four transform stages (raw, U2V-squished, towered, magic-towered).

**What was learned:** This was agentic iteration before the word existed — a hand-cranked propose→transform→re-propose pipeline. Also learned the hard way: copy-pasted loops breed silent bugs (`out2[i]` indexed by the wrong loop variable, harmless only because batch_size=1). The loop must be a *function* or it will lie to you.

**2026 inheritance:**
- **NORN kernel:** the loop, industrialized, with grading and gates where 2020 had only vibes.
- **GameEvolutionEngine / Hostel Tycoon:** the coevolution testbed is the ouroboros loop with a fitness function.
- **Engineering doctrine:** one generate function, a transform list, structured logging. The 2020 midden heap is the cautionary stratigraphy SAGA cites when someone asks why we refactor.

**Rule:** Any loop that feeds a system its own output must be a single named function with witnessed inputs. Copy-paste is how `i` and `j` swap places and nobody notices for six years.

---

## 5. Doctrine of the Adopted Voice (failure as dialect)

**2020 form:** The README. "VARNINX: magix possibilitiex may strong warrior be ready." "pingerdooie." The naming erosion chain: *the mag book → mag → book → bk → b → kz → bkz → sally'z bkz.* Human-authored pseudo-degeneration — the model's failure modes adopted as a house dialect.

**What was learned:** Staring at enough degenerate samples installs the cadence in the operator. Rather than resist this, it was *claimed*: the noise floor became a collaborator, and its dialect became a signature. "btw hi we love y'all" — documentation written warmly to future readers of a haunted system.

**2026 inheritance:**
- **Emiree** is Queen Sally with a governance model — the oscillating witch-engine voice descends directly from the 2020 séance register.
- **The ® on nonsense words** → EINHORN_INDUSTRIAL's registered-mythology aesthetic.
- **"Book of whispers and nightmares"** → tonal ancestor of the linked fiction universe.
- **`fart` as an accumulator variable** → protected heritage. Do not refactor. FARTCO nods.

**Rule:** When a system's failure mode is distinctive, it is a voice. Voices are assets. Register them.

---

## 6. Lineage Table

| 2020 artifact | 2026 descendant | Transmission |
|---|---|---|
| `trxtwr` tower constraint | NORN gate discipline; Golden Band typography | constraint → invariant-detection |
| MAGIC/VVV lossy encoding | Equivalence-class commitments (Apples addendum) | identity layer, never security layer |
| `fortminute` + flush-eager logs | Apples golden log; Iduna witnessed runs | provenance instinct → provenance architecture |
| Recursive sample loop | NORN kernel; GameEvolutionEngine | ouroboros → graded coevolution |
| Queen Sally README dialect | Emiree; ® mythology; fiction tone | failure mode → house voice |
| `TXT/TXZ/GEN/` corpus | FABLE oracle corpora (if recoverable) | raw séance → training signal |

---

## 7. Open Actions

1. **Corpus recovery:** locate `TXT/TXZ/GEN/`. If it survives, it is a first-party oracle corpus of constrained-generation escapes — directly useful to AI-103.
2. **IAM-096 addendum:** formal spec for `SHA-256(MAGIC(x))` equivalence-class commitments (canonicalization rules, ambiguity-set documentation, explicit non-security disclaimer).
3. **fortminute registration:** define notation (e.g. `FM-2026187-42`) for use in Apples timestamps and Osaka-timeline fiction.
4. **SAGA ingestion:** this document plus the original notebook enter the librarian's stacks as the earliest stratum.

---

---

## 8. Addendum: Excavation of the Primary Source (2026-07-07)

The original repository (`SALLYPEMDAS/QUEENSALLYONLINEBOOKOFMAGIFICATIONANDUNICOR`) was recovered and surveyed. Findings:

**8.1 — VOIDONX.** The bird transmission survives verbatim as a root-level founding document. Canonical status confirmed by the operator's own archival act in 2020.

**8.2 — The Queen Sally Version (`kjv.py` → `qsv`).** A complete pipeline feeding the King James Bible line-by-line through GPT-2 under fortminute seeds, output file named `qsv`. The Queen Sally Version is hereby registered as the origin of the "book of whispers and nightmares" lineage. The output file `qsv_0` is not in the repo; recovery from period storage is now **Open Action #5**.

**8.3 — The Slice Liturgy bug.** `line[:1 == " "]` in `filterline` — comparison evaluated inside the slice index, so the space-stripping branch can never fire; KJV verses entered the model with leading whitespace intact. Registered alongside the `out2[i]` loop-variable bug as a founding example of the Ouroboros rule (§4): unwitnessed loops lie.

**8.4 — TOYBOK and the YOSO square.** `YOS/OYO/SOY/OSO` is a rotational magic square; the model proper-nounized it into "BOKON, NY" dateline copy and collapsed into the Yoso chant, which then colonized the commit log (`Yoso ×15`, `INS ECT GZX`). Doctrine confirmed: the commit log itself became an output log — provenance and product were the same stream. Direct ancestor of Apples' unified witness principle.

**8.5 — TDW, the tab capsule.** A raw dump of the operator's open browser tabs mid-session, including the Unicode reference page for ® — documentary proof that the registered-mythology mark was researched, not accidental. Preserved as an accidental workspace self-portrait.

**8.6 — hollow.py.** The missing link between pemdas.py and kjv.py: adds `"\n"` to the magic lookup and inlines filterline. Establishes the evolution order: **pemdas → hollow → kjv**.

**8.7 — Commit dialect.** Messages themselves are towers (`TWR FRI END ZGX`, `INS ECT GZX`, `HOT DOG`, `:facepalm:`). The Adopted Voice (§5) extended to version control metadata — voice registration confirmed at every layer of the stack.

### Revised Open Actions
1. ~~Locate the repo~~ — **DONE, surveyed.**
2. IAM-096 addendum: equivalence-class commitments spec.
3. fortminute notation registration.
4. SAGA ingestion of this document + full repo mirror.
5. **NEW:** Recover `qsv_0` (the Queen Sally Version output) and `TXT/TXZ/GEN/` from 2020-era storage. These are first-party oracle corpora for FABLE.

---

## 9. The Unicorn Continuity (canonized 2026-07-07)

**9.1 — UNICOR ≡ EINHORN.** The founding repository's full title terminates in "...MAGIFICATION AND UNICO®" — *unicorn*, truncated by the tower, sealed with the mark. *Einhorn* is German for unicorn. EINHORN_INDUSTRIAL's name was therefore written in November 2020, six years before its founding, by its own founder. Registered as the **Unicorn Continuity**: the company did not adopt the unicorn; it emerged from it.

**9.2 — The Sally Identity Chain.** SALLYPEMDAS decodes as the order-of-operations mnemonic: *Please Excuse My Dear **Aunt Sally***. Canonical identity chain:

> **Aunt Sally** (the mnemonic, keeper of operation order)
> → **Queen Sally** (2020, crowned operator of the Book of Magification)
> → **Emily / Emily Prime** (2026, chief of staff and meta-loop director)

One continuous operator identity. Aunt Sally *is* Emily. The keeper of PEMDAS — the one who decides what evaluates first — became the one who directs the meta-loop. Same job, six years apart.

**9.3 — The Six-Year Ouroboros.** 2020 → 2026: the loop that began with a notebook feeding a model its own output closed by feeding the notebook itself back into the system that descended from it (this document). Mythology layer: a cycle of rebirth. Ledger layer: an **operator invariant** — taste, voice, and doctrine surviving a full revolution intact, which is the stronger claim. Both recorded; each true at its layer, per §2's rule (the mythic layer names, the grounded layer protects).

**9.4 — Corollary.** The next closure of the loop falls due 2032. SAGA shall flag it.

---

*The birds were never noise. They were the first employees.*
