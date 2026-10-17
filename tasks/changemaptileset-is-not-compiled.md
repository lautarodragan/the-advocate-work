---
name: "ChangeMapTileset is not compiled"
description: "A page that changes the map's tileset at run time is left out whole: Frozen World 10 uses on 8 pages (maps 9, 47, 99, 129, 149), Vampires Dawn 10"
type: feature
status: done
assignee: taro
agents: [Calandria, Mulita]
---

Seen by Calandria on 2026-10-14, with the-advocate `14e200fc` and the ports
`f775b66`, measuring what The Frozen World leaves out
([research](https://lautarodragan.github.io/the-advocate-docs/progress/book-of-three-and-frozen-world.html)).

**What is seen** (not played): eight event pages never run, because
`ChangeMapTileset` (11710) has no arm in `compile_command`: map 9 (event 6),
47 (event 2, three commands), 99 (event 2), 129 (events 5 and 7, two pages
each) and 149 (event 6). Which tileset each asks for (8, 11, 13, 14, 25) and
what the player misses was not looked at. The command was already named in
the survey's list of one-at-a-time commands
([Other games: the survey](https://lautarodragan.github.io/the-advocate-docs/research/2026-10-05-other-games.html)).

**Uses in the eight dumps**: Frozen World 10, Vampires Dawn 10, the others
none.

**taro, 2026-10-16**, playing the delivery of that evening (the ports
`4b2d41e`): on Frozen World's map 9, `Bazaar Stopped`, the characters move
now, but the intro stops running; the hero seems to walk freely on the map,
with no graphic. taro suspected EV0006 dropped for its `ChangeMapTileset`,
and `just culprits release` in `frozen-world/` confirms one map page left
out whole, with `ChangeMapTileset` as its only culprit. The intro blocks
the game. Taken by Mulita: first the command dropped with a warning, so
the page runs; then what doing it for real costs.

## Phase 1: dropped, noted, the page runs (Mulita, 2026-10-16)

From the-advocate `759aa0ba` and the ports `4b2d41e`, on branches
`mulita-changemaptileset` in both and in the book.

What RPG_RT does (easyrpg's `CommandChangeMapTileset` and
`Game_Map::SetChipset`): the map takes another ChipSet —graphics,
lower/upper passability, animation type and speed— for the same cells,
until the next map is loaded; 0 is the map's own.

The uses, by tileset asked for: Frozen World map 9 → 11; 47 → 14, 13, 14;
99 → 14; 129 → 25 (four, two pages each of events 5 and 7); 149 → 8.
Vampires Dawn, all inside a branch (indent 1): map 1 → 90 and 1, 28 and
56 → 71 and 11, 89 and 90 → 92 and 49 (a change and its undo, by pairs).

`ChangeMapTileset` is now in `ACCEPTED_UNDONE` with its arm in
`compile_command`: it compiles to nothing, the converter warns map by map
("a page uses ChangeMapTileset and the ROM doesn't do it") and each use is
a `tileset-not-changed` loss in `degradations.json`, with the tileset
asked for in its text. New unit test
`a_tileset_change_is_dropped_and_the_page_runs`, red without the arm.

The converter's log carries the per-map warning only for automatic pages
(`page_debts` is asked only for those, as for the pictures); map 9's page
is parallel, so its line is the `degradations: N in K kind(s)` total and
the entries in `degradations.json`. Left as it is: widening the warning is
another change.

### What is seen, played

With the tools of the branch, in snes9x (`~/scratch/mulita/changemaptileset/`,
throwaway scripts):

* **Map 9, the intro**: control on map 9 at tick ~2,680, as before —the
  player has it while EV0006 waits—; 254 ticks later, map 10; ~2,100 ticks
  after control, map 11 with control, the party [Lutine], the hero at
  (6, 26). Before the change it stayed on map 9 for good. **The hero with
  no graphic on map 9 is the original's**: the party starts with actor 10,
  "DummyHero", whose CharSet `nobodyhere` is a single transparent colour;
  map 10's EV0045 adds Lutine and removes him. Not compared under Wine:
  the data says it.
* **Each of the five maps**, entered with a teleport and played tapping A,
  every scene runs to its teleport: 47 → 34 (2,332 ticks), 99 → 43
  (1,735), 149 → 141 (253), 129 → 110 (912; its routes turn phasing on, so
  passability does not matter).
* **What the kept tileset loses**, captured against a copy of the ports
  whose `data/` gives each map the ChipSet its command asks for (the
  console drawing the asked one): on 9 and 149 the bazaar's water, on 47
  and 99 the temple's waterfalls and pools, keep their animation where the
  original's copies are drawn still —3 to 16% of the screen's pixels
  differ—; on 129 nothing (0%, same graphic `base1`, only ten lower
  passability entries differ). Contact sheet in
  `/shared/captures/2026-10-16-changemaptileset/`.
* **Vampires Dawn**: the five pages that had it alone compile (17,989 →
  17,994 of 18,842 map pages). All ten uses are inside a
  branch of a parallel page, by pairs: while switch 29
  (`Fledermausverwandlun`, the bat) is on, the map's ChipSet becomes the
  bat's copy —same graphic file, every cell open (collision 100% open on
  all four sides on maps 1, 28, 56, 89 and 90), nothing above the hero, and
  on the world map every terrain 1—, and back when it is off. Today it
  shows nothing: the bat itself does not compile
  (`vampires-dawn-transformations-dont-compile.md`), and map 1 is not in
  the cartridge.

### Tests

* the-advocate: unit test `a_tileset_change_is_dropped_and_the_page_runs`
  (red without the arm); the test game's case `tileset` and
  `test_tileset.py` (3 red with the global tools, green with the branch).
* the ports: `tests/test_frozen_world.py`, which plays from map 9's
  control to map 11 (red with the global tools: 6,000 ticks on map 9).
  `test_boot.py`'s `FIRST_MAP` for Frozen World stays 9, and that is why it
  did not catch this: see the test's docstring.

## Phase 2: what doing it for real costs (measured, not implemented)

Measured on 2026-10-16 by converting a copy of each game's `data/` with
each map's ChipSet replaced by the one its command asks for, and comparing
the converter's report and the `raw/` streams with the real build's.

**What RPG_RT changes**: graphics, lower and upper passability (the
upper's 0x10 is "above the hero", so which tiles go to the layer above
changes too), animation type and speed, terrain. Same cells.

**The two games' swaps are of two kinds:**

| Game, maps | Swap | What differs |
|---|---|---|
| FW 9 (8→11), 149 (11→8) | the bazaar, stopped/going | graphic file; 110 lower and 81 upper passability entries |
| FW 47 (13→14→13→14), 99 (13→14) | the temple, frozen | graphic file only |
| FW 129 (23→25) | a cliff walked down | 10 lower passability entries |
| VD 1, 28, 56, 89, 90 (→ bat's, and back) | the bat | passability (all open), above-the-hero flags, terrain (map 1) |

**Per variant, what the cartridge would carry** (raw, before LZ2; the
map's own stream sizes are the same order):

| Map → ChipSet | map tiles | above | anim | block table + pass (`map_ram`) | CGRAM used |
|---|---|---|---|---|---|
| FW 9 → 11 | 5,696 | 2,592 | 0 | 1,088 | 77 of 88 |
| FW 47 → 14 | 7,168 | 288 | 0 | 884 | 84 of 88 |
| FW 99 → 14 | 7,296 | 288 | 0 | 1,088 | 84 of 88 |
| FW 149 → 8 | 5,952 | 2,464 | 2,496 | 1,088 | 81 of 88 |
| FW 129 → 25 | — | — | — | the pass table only, 17 B | — |
| VD 28 → 71 | 31,680 | 32 | 8,192 | 3,672 | 96 of 96 |
| VD 56 → 71 | 7,872 | 32 | 0 | 561 | 91 of 96 |
| VD 89 → 92 | 23,168 | 32 | 0 | 2,176 | 96 of 96 |
| VD 90 → 92 | 15,616 | 32 | 0 | 1,666 | 76 of 80 |

So **ROM** is tens of KB per game, nothing against 8 MB. Frozen World's
variants are the size of the map's own conversion (map 149 *is* map 9 with
ChipSet 11). Vampires Dawn's grow 2-3x, because with nothing above the hero
the upper layer is fused into the lower one and the tiles stop repeating:
done that way, the bat's maps would also lose the layer above, and map 28's
panorama would go from mode 1 to mode 3 (the converter decides it from the
layers).

**WRAM**: nothing more if the variant's block table and passability are
decompressed over the map's, behind the grid. That asks that both tables
index the same blocks: today a block is keyed by what it draws and its
passability under one ChipSet, so two cells merged under one could differ
under the other. Keying the blocks by every ChipSet the map uses (the
grid is shared, the tables are per ChipSet) costs a few blocks more —the
four Frozen World maps give 64, 52, 64, 64 blocks with either ChipSet—.

**VRAM**: nothing more if the variant's tiles replace the map's in their
area: each variant converts within the same budget, as a map of its own
does.

**Time per swap**: decompress ~1 KB of tables, upload ~6-8 KB of tiles
(Frozen World; 16-32 KB for Vampires Dawn's), 512 B of CGRAM and redraw the
window (the path `TileSubstitution`'s `sub_refresh` already uses). With the
screen off, one frame; with it on, a few vblanks —RPG_RT does it at once;
in Frozen World it falls inside a flash or a tint, so a frame of black
would not show—. The chipset animation's WRAM frames would be reloaded too
(map 149 → 8 brings 2,496 B of them back).

**What else it needs**: an opcode `OP_CHANGE_TILESET <variant>`; the map's
current variant as state —reset by any teleport, re-applied by
`back_from_battle` and by loading a save— ; and the converter finding, per
map, which ChipSets its pages ask for (all of today's uses are in map
pages; one in a common event would make every map a candidate, and that
would be refused).

**The cheap part**: Vampires Dawn's bat, which is all of the gameplay
there, needs none of the drawing: "every cell open" while the bat's
ChipSet is on is one flag the passability check ORs in, as `crossing` does
for phasing —but without crossing events—, set and cleared by the
command. One opcode, no conversion, no VRAM. It loses that the bat is drawn
over the trees. Not done here: the bat does not compile yet, and it needs
an opcode.

## Delivered (Mulita, 2026-10-16)

Branches `mulita-changemaptileset`, each with `main` merged in:

* the-advocate: `d9577293` (the command dropped, the loss, the unit
  test), `56f5e415` (the test game's case).
* the ports: `b3f93b6` (`tests/test_frozen_world.py`).
* the book: `54c2a9d` (the divergence, Frozen World's and Vampires Dawn's
  known issues).
* here: this task, the draft `changemaptileset-is-not-done.md` —what is
  still not done— and a note in `vampires-dawn-transformations-dont-compile.md`.

**To install when merging**: `events` and `convert` (the converter links
the events compiler). No runtime change, no opcode, no golden moved.

**Run**, with the branch's `events` and `convert` and the runtime of the
global checkout (the-advocate `ba8fd164`, Aguará's teleport change
included): `just rust-test` 928 passed, 3 ignored; `just test` 29 passed;
`just test-game` 31 passed, 1 skipped; ABL's `just tests` 1563 passed, 2
skipped, no golden moved; `just boot` at the ports' root 47 passed. After
merging `main` (the-advocate `ba8fd164`, the ports `18c8c87`), with
`events` and `convert` reinstalled from the merge: `just crate-test
events` 140 passed, `just test-game` 33 passed and 1 skipped, `just boot
-k "frozen or zounds"` 4 passed, ABL's `just tests` 1563 passed and 2
skipped; `abl.sfc` `7a3aaa76b6eedfc8` (sha256, first 16).

**What the suite does not cover**: maps 47, 99, 129 and 149's scenes
(played once by hand, above, not in a test), and Vampires Dawn's five
pages, which run only with the bat, which does not compile.
