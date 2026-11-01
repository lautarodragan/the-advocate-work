---
name: "Zounds: tile substitutions that do not compile"
description: "The Switch event on map 59, Centro (START), does nothing: its pages swap lower tiles 94, 95 and 1 in a ring, and the event compiler refuses the substitution, so the whole page is left out —switch, sound and all—; ten pages on six maps the same"
type: bug
status: testing
assignee: taro
agents: [Calandria]
---

taro, on 2026-11-01, in their words, translated —it blocks them in Zounds—:

> The Switch event, on the map `Centro (START)`, does nothing. Its
> commands are a switch, a sound effect, and 3 tile substitutions.

**What Hornero saw**, with `just culprits` on Zounds' `release` (ports
cd41913, the-advocate 422f904d): map 59 is `Centro (START)`, its event 22
"Switch" at (6,12), action button, same layer as the hero. Page 1:
`ControlSwitches` 132 on, `PlaySound` Door2, then `TileSubstitution`
lower 95→1, 94→95, 1→94; page 2 (switch 132 on) the reverse. The compiler
refuses the substitution and the page is left out whole, so nothing
happens. The same culprit, on every page of Zounds that has one:

    map 17  event 26 page 2   [0, 0, 132]  and  [0, 6, 138]
    map 59  event 22 pages 1, 2   (95/94/1 ring)
    map 75  event 1  page 1       (95/94/1)
    map 96  events 6, 7, 8, 9     (95 or 94 → 1)
    map 102 event 56 page 1       (95/94/1)

The compiler side is `TILE_SUBSTITUTION` in
`rm2k-snes/events/src/compile.rs` and the converter's `Substitutions`
(wally's `substitutions.rs`); RM2k's own is easyrpg's
`Game_Map::SubstituteDown`/`SubstituteUp` —a table indexed by the
original tile, which matters for a ring like this one—.

**Done**: every one of those pages compiles and does what RPG_RT does
—a ring swap included—; map 59's switch opens what it opens, seen in a
capture; a test red before.

taro, on 2026-11-01, on what map 59's switch does, translated:

> What that event does, from the player's point of view, is lower some
> spikes that come out of the floor, and raise others. It's like opening
> one door and closing another. Lowering and then raising would have
> resulted in all of them lowered, including the ones we just lowered. I
> may have used some trick to tell apart different groups of tiles on the
> map, and so achieve the swap of which ones stay up and which ones down.

So 94 and 95 are the two spike groups and 1 is the temporary of a
three-way rotate: the expected result is a real swap.

## Calandria, 2026-11-01

**Why they do not compile.** None of these maps draws the incoming tile
anywhere: no cell of maps 59, 75, 96 or 102 has lower tile 1, and map 17
has 0 and 6 (14 cells each) but neither 132 nor 138. `Substitutions`
builds a missing block out of the 8x8 cells of a block that already draws
the new tile, so a tile the map never draws has no cells in VRAM to be
built from, and `pairs` answers `None` —the limit `substitutions.rs`
names in its header—. The ring itself is not the problem: 94→95 and
95→94 compile, and 1→94 compiles to nothing because nothing draws 1.
Map 96's events 6–9 do a single 95→1 or 94→1, so tile 1 is really shown
there: the fix has to put tile 1 in VRAM, not skip it.

**RM2k's semantics.** easyrpg's `DoSubstitute` walks the table indexed by
the original tile and rewrites **the values** equal to the old tile:
sequential replaces over what is displayed. 95→1, 94→95, 1→94 leaves
original 95 showing 94 and original 94 showing 95: the swap taro
describes. `op_tile_sub` already applies its pairs the same way, by
value, so the runtime does not need to change: what is missing is blocks.

**The fix.** A panorama map already draws the combinations its
substitutions need and does not draw in extra rows below the map
(`Drawn::extended`, Cardón, dff2f849), cut off after the blocks are made;
only flattened maps used it. A map without a panorama gets the same rows.

**A second bug behind the first.** With tile 1 drawn below the map, its
block came out as **the floor's**: on every one of these maps lower tile 1
under an empty upper draws exactly like the floor (block 4 on map 59,
130 cells), with the same passability and terrain, and blocks are made of
what is drawn. `op_tile_sub` swaps a block wherever it is, so 95→1 and
1→94 would have turned the whole floor into spikes —taro's "all of them",
the other way round—. Blocks now keep apart any cell carrying a tile the
map's substitutions name (`blocks::Map::apart`, and the same in what
`Substitutions` builds), and `pairs` refuses a block shared with a
combination that stays, as a last guard.

Tests: `whole_map.rs` in wally, `a_tile_the_map_does_not_draw_…`, red at
422f904d on `missing: [[false, 95, 1]]` and, with only the first fix, on
"the floor is block 2, the one tile 1 swaps"; and
`a_block_shared_with_a_tile_that_stays_does_not_go` in
`substitutions.rs`. In the ports, `tests/test_zounds_tile_substitutions.py`
walks map 59 before and after the switch, both pages.

**The other games.** `TileSubstitution` pages left out, per game's
`release`, before (global tools over the main checkout's requests,
ports cd41913) and after (this branch):

    El Dorado            1 page, map 7 (23→0)       →  0
    Sunset over Imdahl   2 pages, map 60 (1→0)      →  0
    Zounds              10 pages (the list above)   →  0
    ABL                  5 substitutions, all built  →  the same

The other five games have no `TileSubstitution`. Sunset's map 60 is a
mode-3 panorama map, which converted its layers without the extra rows:
a third commit gives them to mode 3 and mode 1 as well. It swaps lower
tile 1 —246 of its 300 cells— for tile 0, so what the player sees there
changes; nobody has looked at it yet.

Captures of map 59, before and after the switch and back, in
`/shared/captures/2026-11-01-zounds-tile-substitutions/`: the swap is
real, the floor is untouched. RPG_RT itself was not run: easyrpg's
`DoSubstitute` and taro's description of what the switch does agree.

**A fourth commit**, after ABL's suite went red with the third: ABL's map
6, in mode 3, converted with rows it did not need —its substitutions
already built out of halves—, the rows brought colours, Adeleine merged
differently, and its patch and about thirty goldens moved. Now a map that
is not flattened draws below it only what halves cannot build
(`beyond_halves`), and a panorama map uses its rows in mode 3 or 1 only
when some are needed. With it `abl.sfc` is byte for byte the main
checkout's.

**What was run**, with this branch's `wally` (the only Rust changed):
`cargo test -p wally`; the ports' `just boot` (113 passed, the new Zounds
test among them) and ABL's `just tests` (1593 passed, 2 skipped), both on
the fourth commit, before merging the ports' `main`; after merging it,
`just boot -k zounds`. The culprits of every game, as in the table above.

**To install when merging**: `just install wally`. The runtime does not
change.

Branches: `calandria-tile-subs` in the-advocate and in the ports.
