---
name: "advocate reset-autotiles"
description: "A subcommand that rewrites a .tiles in place with each autotile cell's variant computed from its eight neighbours, as RM2k's editor does when painting, so a map written by hand or by an AI only has to say which autotile each cell is"
type: feature
game: advocate
status: todo
author: taro
links:
  relates: [rm2k-sketch-becomes-a-library]
---

**Why**: what is hard in writing a map by hand is not its format, it is
the autotiles: a grass, path or water cell's id carries one of 47
variants —water, a second index for its deep edge—, chosen from its
eight neighbours. RM2k's editor chooses them as one paints and stores
the result; RM2k's player only draws what is stored. Nobody gets 660
cells right by eye, and `rm2k-sketch` never did it either.

> What we could have is something smaller: advocate reset-autotiles or
> something like that, that modifies a .tiles in place.
>
> If what is hard is not the format but the autotiles, this covers the
> use of autotiles in maps made by hand, without requiring another new
> format or a .toml, right?

(taro, 2026-11-27)

**What is asked**: `advocate reset-autotiles <MapNNNN.tiles>` rewrites
the file's lower layer: each cell keeps its block —the terrain's
`(id - 4000) / 50`, the water's `id / 1000`— and gets the variant the
neighbours give. The rule is easyrpg-player's `RecalculateAutotile`, in
`~/ref`: `AUTOTILE_D_VARIANTS_MAP` with its corner fix-ups, water joined
to water and the animated tiles, and the deep edge's second index;
outside the map counts as the same tile. The comments and layout of the
`.tiles` stay as Ditto writes them.

* It overwrites compositions made by hand —ABL keeps thousands—, and
  says so in its help; a rectangle to limit it is for when someone needs
  it.
* Tests: every test game map gives back its own `.tiles` unchanged (none
  composes by hand), and the forest of the 2026-11-27 experiment —the
  branch `hornero-forest` in the-advocate, `Map0017`— comes back the same
  from all its cells set to their block's first id.

## Log

### 2026-11-27, Hornero: written

Nothing done yet. The rule was already ported once, to Python, for the
forest experiment: `/shared/captures/2026-11-27-forest/gen.py`, with
`check.py` beside it in the scratchpad.
