---
name: "The golden game and two repos"
description: "A test game for the engine, and ABL in its own repo"
type: refactor
status: wishlist
---

# What

**An RM2k game made on purpose —the "golden game"— that tests the engine**,
and **ABL in its own repo**, separate from what doesn't depend on it.

Two layers of tests instead of one:

* **Engine conformance**, against the golden game: one map per feature,
  small and deterministic, and the whole game is the golden. It is **the
  single-cartridge rule solved at the root** —one game, one ROM— and it is the
  specification of what the port supports. Porting another game reuses it whole.
* **ABL acceptance**: that it plays and looks like this.
  It is still needed, because the most expensive errors came from real content
  that nobody would write on purpose. **The golden game grows with those**: each
  error that turns up in a real game is abstracted and added as a case.

And **two repos**: what doesn't depend on ABL —the engine, the tools, the golden
game— can be published, because the golden game uses public domain material
or material with a licence that allows it. ABL stays in its own, and if it ever
has to be taken down, it is taken down without dragging along what is valuable.

# Status

taro's idea, on 2026-09-17. Noted, not started: **today the only thing done is the
embryo**, `pruebas/casos/`, which are RM2k events in Ditto's JSON and not
a special table of the ROM.

# Blockers

* **What the golden game can't inherit without review**: Don Miguel's RTP
  belongs to Enterbrain; the samples come from the SoundFonts in
  `/extras/soundfonts`, whose licence has to be checked one by one; and RM2k's
  system font has an owner. ABL's MIDIs are music from other games:
  they stay on ABL's side.
* **The game has to be built**, map by feature, with our own assets.

# Decisions to make

* **Which tests go with the engine and which with ABL.** Today's split left
  cases on the doubtful side, and they are these:

  What ended up on the doubtful side, and is worth reviewing when building the golden game:

  * **`rpgmaker/` is more "engine" than "RM2k"**: `test_cores`, `test_compositor`,
    `test_paralelos` and `test_musica_paquete` look after properties of the port —the
    uninitialised WRAM, the text buffer, the frame budget, the
    samples in ARAM— and not RM2k behaviour. They go with the engine anyway.
  * **`abl/test_escenas_golden.py` has cases that exercise generic
    commands** —`elegir`, `tienda`, `savepoint-guarda`, the doors— with
    the game's pages, and `factoria`, which is the third VRAM layout. Splitting it
    by case required duplicating the family's function; it was split only by
    family: `hablar` went to `rpgmaker/test_hablar_golden.py`.
  * **`herramientas/` was decided by form** —it doesn't run a ROM— and several look at
    the converter over ABL's maps: `test_lideres`, `test_destello_paleta`,
    `test_timer_paleta`, `test_encuentros`. `test_bancos` reads the symbol table
    of the built cartridge, without running it. If they go "with their tool",
    the natural place is next to `tools/`, and that is decided when `tools/`
    is split between the two repos.
* **Where `tools/` ends up**, which is of both kinds: the converter belongs to the engine,
  but `port/` still knows things about ABL.
* **What happens with `golden/` and `casos/`**, which today serve both layers.

On 2026-09-28 it was measured what in the repo is ABL's and what isn't, with a
plan in parts to reach two repos that doesn't require waiting for this game: see
`docs/research/el-mapa-de-las-herramientas-de-python.md`. Its questions in
§5 touch the three decisions here.
