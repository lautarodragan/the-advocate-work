---
name: "The test game: its skeleton"
description: "A game of our own, made from scratch with free assets, where the engine's ROM tests can live instead of in A Blurred Line: first a map, the hero and an NPC, built from text and booting"
type: feature
status: testing
assignee: taro
agents: [Calandria]
---

Phase 2 of `research/2026-10-02-the-test-game.md` in the book. taro, on
2026-10-15: start with the assets —EasyRPG's RTP, checking its license
allows it in the public repo— and build on it; a ChipSet and a CharSet are
enough to begin.

**The license, checked by Hornero**: EasyRPG's RTP (`~/ref/easyrpg-rtp`,
commit `993d88c`, 2025-04-05) is Creative Commons Attribution 4.0, some of
it CC0; redistribution in a public repo is allowed with attribution
—author, license, link, and saying if it was changed—. Its `AUTHORS.md`
gives each file's.

**The assets chosen** (taro agreed): ChipSet `Exterior.png` (Jason Perry,
CC0) and CharSet `People1.png` (VictorSena, CC BY).

**Where it lives**: in the-advocate, in a folder of its own (the research
proposed `test-game/`), public, in English, with its assets inside.

## Log

**2026-10-15, Calandria.** Started from the-advocate `d5648f1e`, docs
`25e7f95`; branch `calandria-test-game` in both.

**The research's experiment, again, and what of its seven assumptions is
left.** A hand-written exact dump —one map, one actor, state 1, the
Exterior ChipSet— packed with `ditto pack`, dumped back with `ditto
unpack` and converted with the installed tools, booted in snes9x, the hero
walked up and the NPC talked to: the message came out in the window. Of the
seven assumptions: **gone** the debug map in `patches/manual/new` (the
project has no `patches/` at all), a single-map game not building, the
`fallback_backdrop` having to exist (`"none"` passes, without battles) and
the System not fitting (the converter merges what does not fit and says
so: four warnings, the message window's gradient fused into bands).
**Still there**: the cartridge has to be called `release`. **Not
measured**: whether a missing section of the database stops the converter
—the converter reads what `ditto unpack` writes, and the resolved view
writes all fifteen— and whether the System is looked up in the RTP —the
game carries its own—. And the research's open question, "100% open cells
with walls": the ChipSet's passability default is 15 for every tile, open,
so a map is all open until `db/chipsets.json` says otherwise. With the
bushes and the tree trunks at 0 it gives 77%.

**The title**: the game has none, and `--no-title` in the cartridge's flags
starts it on its map. An empty `title_name` without the flag stops the
converter looking for `Title/.png`.

**The System**: the RTP's `System.png` (andwhyisit, CC BY 4.0 / OGA-BY),
unchanged. The tools cannot do without one —every window is drawn from it—
and the one in `rm2k-snes/screens/tests/game/` is flat colours by formula,
which tests nothing of a real window's conversion.

**How it is written**: `test-game/src/` is a Ditto **exact dump written by
hand** —the liblcf names, enums by name, defaults left out: the NPC is 15
lines— plus one **sketch** per map, `maps/MapNNNN.toml`: a character grid
and a legend `char = { lower, upper }`. A new crate in `rm2k/`,
**`rm2k-sketch`**, makes the sketch into the `.tiles`, with Ditto's own
writer —`ditto::dump::grid`, made public for it, byte for byte the same
output—. Inventing a TOML of our own for the whole database was the
alternative; it would be a second schema to keep in step with liblcf's,
and the cases already are exact-dump command lists.

**The pipeline** (`test-game/justfile`): `just game` copies `src/` to
`build/text/`, writes each sketch's `.tiles`, `ditto pack`s it into
`build/game/` with the ini and the pictures —a folder RM2k or EasyRPG
open— and `ditto unpack`s that into `build/data/`, the dump the converter
reads, like a port's. `just cartridges` builds with an empty `--rtp-dir`
and `SOUNDFONT` from the environment (no default; FluidR3_GM, MIT, here).
`just test` runs pytest after building. The root's `just test-game` calls
it; `just test` does not.

**The harness, and what moving it would take.** For the skeleton,
`test-game/tests/game.py` (~200 lines, the ports' `tests/games.py`
trimmed: the tick clock, control, walking until blocked, goldens at 15
bits, the builder's staleness) and a copy of ABL's
`tests/harness/emulator/retro.py` with a paragraph saying it is one.
Moving the generic part of ABL's harness here —phase 2, step 1— is today
about 10,400 lines in `abl/tests/harness/` (the research counted 9,411 on
2026-10-02). What stands in the way is **`places.py`**: it pins ABL's
project on import (`project.use(ABL)`) and reads `GAME_DIR` & co., and
`console.py`, `cartridges.py`, `converter.py`, `music.py`, `resources.py`,
`sheet.py`, `suite.py`, `playthrough.py` and `video.py` import it at the
top. So the move is: (1) make the project a parameter —a `Harness(root)`
or `places.use(root)` the game's `conftest.py` calls— instead of an
import side effect; (2) move `emulator/`, `console`, `cartridges`,
`drawing`, `menu`, `screens`, `battle`, the models (`model`, `experience`,
`scene`, `animation`, `rm2k`, `lcf`, `render_map`), the stage clients and
`lz2` to a package in the-advocate (say `harness/`), with the ABL bits the
research named —the `ABLS` signature, the title options, the droid and the
intro party— turned into project settings; (3) ABL imports it from the
installation, the way `rm2k-snes-project` is consumed today (a
`pythonpath` the tools print, or an installed package); (4) the test
game's `game.py` and the ports' `games.py` go. ABL's own —`playthrough`,
the `stretch_*`, `stones`, `video`, `msu`, `places`— stays there. It is a
mechanical move with one judgement change (1), and should be split that
way: the move verified by ABL's suite giving the same count, the
parameterisation after.

**Where it was left (2026-10-15, 03:30).** Committed in the-advocate
`calandria-test-game` (Ditto `0bd8167f`, sketch `755b0e4d`, test game
`b11370e9`, main merged in `35dfa507`) and the book `c2c442e`. `just test`
29 green, `just rust-test` green, Ditto's directory round trip 91 of 91.
**Missing: the two goldens.** The experiment booted, walked and showed the
message (captures in `~/scratch/calandria/exp/a-map.png`, `b-msg.png`),
but `just test` in `test-game/` could not run: the global tools were
installed before `978c0d25` and `~/the-advocate` was already there, so
assembling stops at `runtime/enter_map.s: map_access undefined`. Once the
global install matches `main`: `SOUNDFONT=<free .sf2> just test-game`, look
at the two captures in `test-game/tests/snapshots/golden/`, copy them to
`tests/golden/` in their own commit, run again for green in snes9x and
bsnes. Then this goes to `testing`. To install when merging: `ditto` and
`sketch` (new).

**Finished, the same day.** Hornero reinstalled the globals; to be safe I
built with this branch's tools (`install-local` of what the build uses)
over main `f6e17ccc` (merged, `cf8b9d5d`). The first run showed a harness
bug: it waited for `msg_state` 2, which `vblank.s` clears as soon as the
window shows, so it timed out with the message whole on screen; it now
waits for `msg_open` with `msg_state` at 0 (`42b9783d`). The two goldens,
looked at, in their own commit (`dc5a26af`); `just test-game` green twice
in snes9x and bsnes, `just test` 29. Run with
`SOUNDFONT=.../Microsoft GS Wavetable Synth.sf2` as Hornero asked: the game
has no music, so no sample goes in; with music, a free one is needed.
`AUTHORS.md` names the font (`6c345345`). Captures in
`~/scratch/calandria/captures/2026-10-15-test-game/`.

**When merging**: install `ditto` and `sketch` (new). The goldens depend on
the runtime, so a runtime change can move them: `just test-game` is now
the second ROM check after ABL's suite.
