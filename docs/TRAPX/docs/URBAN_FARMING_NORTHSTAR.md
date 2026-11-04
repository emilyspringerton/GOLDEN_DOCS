# TRAPX — urban FARMING northstar (not urban planning)

**Status:** planned, no code. Corrected on the founder's own words, 2026-11-04: *"urban planning is
supposed to actually be urban farming"* — the cozy layer of TRAPX is not zoning diagrams, it is **plots,
soil and food**.

Why it belongs in TRAPX at all: TRAPX is a city that watches. Farming is the one thing a player can do in
it that is slow, public and *good* — which makes it the honest counterweight to Field Offices, Watchers
and K9 units. It is also the cheapest way to make a district feel lived in: a garden is proof somebody
expects to still be there next season.

## 1. The loop, in one paragraph

You take a plot (an empty lot, a roof, a back yard), you fix the soil, you plant, you water, you wait, and
you sell what comes out of it — at a stall, to a neighbour, or on the auction house. Everything you do is
visible on the street, so a garden is also a statement about who owns that block. A corrupt block grows
poison. A block with no scrutiny grows thieves. A block with a Field Office grows *protected* thieves, and
that is the joke TRAPX is making.

## 2. Systems (all of them decision logic, all planned as one PARENA mod)

Planned file: `PARENA/stdlib/trapx/farming_rules.prn` (does not exist yet). Same discipline as
`city_engine_rules.prn`: I32 permille, total functions, no RNG (a caller passes the roll), no host state.

| System | What the rule decides | Reads |
|---|---|---|
| plot | whether a cell can host a plot at all (empty lot, roof, yard), and its size | neighborhood stage, building state |
| soil | soil health 0..1000: depleted by harvests, restored by compost and fallow seasons | plot age, compost |
| contamination | crops carry the block's corruption: a garden in a bought district poisons people | `ce-casino-corruption`'s output, `ce-scrutiny` |
| water | each crop's water need per phase; drought is a slow failure, not an event | weather (`sky_rules`), season |
| seed → crop | seed kind, grow phases, yield per plot quality | era tech (a 1700s plot has no greenhouse) |
| harvest | yield and quality, and the contamination cut | soil, contamination, care |
| market | what it is worth: a stall price, a neighbour price (contact affinity), and the auction floor | `ce-money-flow`, contacts |
| compost | district waste → soil health; the one loop that rewards staying put | day clock, citizens' hunger |
| theft / vandalism | whether a plot is robbed: inverse scrutiny, thief path (DUEL/IDLE), time of day | `ce-scrutiny`, citizen day |
| community garden | a plot that is a *safe zone*: raises local mood, lowers crime drift, attracts CRAFT citizens | neighborhood personality |

## 3. Why it is cozy without being soft

The "harder Animal Crossing" framing (founder, 2026-11-04) lands here more than anywhere else: the loop is
gentle, the consequences are not. A garden teaches you the district's actual numbers — who patrols, who
steals, who buys — because you watch it for three in-game days instead of reading a HUD. That is the cozy
game vibes ask, answered with systems rather than with a colour palette.

- **Cozy**: no fail state, no timer that punishes you for sleeping, plots persist, neighbours remember you
  watered their row.
- **Hard**: contamination is invisible until you eat it or sell it; a protected block's garden is safe and
  rotten; the auction house does not care who grew it.

## 4. Affordances (SHANKPIT's, reused rather than invented)

Following `SHANKPIT/docs/MASTER_AFFORDANCE_LIBRARY.md` and `docs/WIDGET_AFFORDANCES.md`, the physical
layer is deliberately boring:

- a plot is `LevelBox` geometry; a fence is boxes; a gate is `MACHINE(2)` with `box_index` or a lever;
- a water butt is a `LevelBox` plus a widget register, not a fluid sim (there is **no** fluid system in this
  engine — checked, `fluid_state.h` does not exist);
- seeds/crops are cargo (`BP_APP_CARGO`) and a stall is a `LevelBox` plus a `PLATE`/`LEVER` if it must
  react to a body;
- the farm ledger is a phone surface, not a new window: TECHTREE's shape (`phone_set_tech`) is the
  precedent for a host-fed list of plots.

## 5. Coupling to what is already built

- **City engine** (`stdlib/trapx/city_engine_rules.prn`): corruption poisons plots, scrutiny decides theft,
  neighborhood stage decides whether a lot is empty, `ce-money-flow` is the market's size. Farming is the
  first *player-facing* consumer of that engine, and the reason to build its host struct.
- **Citizen day** (`stdlib/shankpit/citizen_day_rules.prn`): CRAFT citizens tend plots in MORNING (activity
  WORK at `zone kind` WORKPLACE); their hunger is the local demand. A community garden is where IDLE
  citizens' SOCIAL activity lands.
- **Contacts** (`stdlib/trapx/citizen_contact_rules.prn`): the neighbour price is the friend price; a
  market garden is how a CRAFT contact becomes worth calling.
- **Era tech** (`stdlib/shankpit/era_tech_rules.prn`): freight is what moves produce to the auction house
  in bulk; the 1900s signal network is what makes a market garden a supply chain.
- **Mining** (`stdlib/shankpit/mining_rules.prn`): the same tool-tier and stamina shape, deliberately, so a
  hoe and a pickaxe feel like the same game.

## 6. Named, not built

- No `farming_rules.prn`, no plot entity, no crop item, no market or auction house (the auction house does
  not exist anywhere in this monorepo — it is planned in
  `SHANKPIT/docs/ONGOING_DEVELOPMENT_REPORT_2026-11-04.md`, shared with mining and actor goals).
- No fluid system, so watering is a register, not water.
- No seasons: `sky_rules.prn` has weather, `day_night_clock.c` has a clock, nothing has a calendar yet.
- No neighborhood personality implementation (`TRAPX_NEIGHBORHOOD_PERSONALITIES.md` is still prose), so
  the "personality raises mood" line above is a rule waiting for its input.

## 7. Phases

1. `farming_rules.prn` + hand-derived C test beside the city engine's, nothing else.
2. One plot in one authored level: geometry + one crop + harvest into cargo.
3. Market stall: one neighbour, one price, contact affinity applied.
4. Auction house (shared with mining), then the community-garden safe-zone effects.
