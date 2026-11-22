---
name: "ChangeMapTileset is not done"
description: "The command is dropped since 2026-10-16: the map keeps its ChipSet. Frozen World's frozen bazaar and temple don't show, and Vampires Dawn's bat would keep the ground's passability"
type: feature
game: [frozen-world, vampires-dawn]
status: todo
author: mulita
---

Seen by Mulita on 2026-10-16, with the-advocate `759aa0ba` plus branch
`mulita-changemaptileset` and the ports `4b2d41e`, in The Frozen World and
Vampires Dawn.

**What is seen**: since `changemaptileset-is-not-compiled.md`,
`ChangeMapTileset` compiles to nothing —a `tileset-not-changed` loss in
`degradations.json`— and the map keeps the ChipSet it was converted with.
In The Frozen World the bazaar (maps 9 and 149) and the temple's two
scenes (47 and 99) keep their water and waterfalls moving where the
original shows them still; map 129's swap changes only passability for a
route that walks through, and loses nothing. In Vampires Dawn the five
parallel pages that swap to the bat's ChipSet (maps 1, 28, 56, 89, 90:
same graphics, every cell open, nothing above the hero) run but do
nothing; it does not show yet because the bat itself does not compile
(`vampires-dawn-transformations-dont-compile.md`).

**What doing it costs** is measured in that task, "Phase 2": per variant,
one more conversion of the map over the same grid, and at run time a
swap of the block table, the passability, the tiles and the palettes, with
an opcode. Vampires Dawn's case alone is cheaper: every cell open, without
the drawing.

**How to see it**: `just cartridges` in `frozen-world/` and
`vampires-dawn/`, and the `tileset-not-changed` losses of
`build/release/degradations.json`; Frozen World's intro on map 9, after
the flash, with the water still in the original.

## Defined

Wishlist, on 2026-10-16, by Cardón: since `d9577293` the command is dropped and its pages
run, so nothing stops. The Frozen World shows moving water where the
original shows it still; Vampires Dawn's bat waits for
`vampires-dawn-transformations-dont-compile.md`, and when that is done
this one becomes needed for its passability.

**Done** means, per Phase 2 of `changemaptileset-is-not-compiled.md`, a
map's variants converted over its grid and swapped at run time with an
opcode, and the `tileset-not-changed` losses gone. Vampires Dawn's case
alone —every cell open, no drawing— is a smaller first piece.

## Log

### 2026-11-22, Carpintero: still so, to todo

Checked against the-advocate `0ae40e0a` and the ports `89f77b4`. The
compiler still drops it: `CHANGE_MAP_TILESET` in
`rm2k-snes/events/src/compile.rs` notes `tileset-not-changed` and
emits nothing. The `build/release/degradations.json` of that day lists
10 `tileset-not-changed` in The Frozen World, on maps 9, 47, 99, 129 and
149, and 8 in Vampires Dawn, on maps 28, 56, 89 and 90; Vampires Dawn's
map 1, which has the fifth page (event 16), has no line in either file.
Counted in the `data/` of the nine games, `ChangeMapTileset` (11710) is
in those two only, 10 each. Moved to `todo` by taro's request, with
`game: [frozen-world, vampires-dawn]`.
