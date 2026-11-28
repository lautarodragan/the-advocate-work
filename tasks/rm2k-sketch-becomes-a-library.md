---
name: "rm2k-sketch goes"
description: "rm2k-sketch goes whole, binary and library: it never chose an autotile's pattern either, so the grid buys little over Ditto's aligned .tiles; the test game's maps keep their .tiles in src/ instead of a sketch"
type: refactor
game: advocate
status: doing
assignee: calandria
agents: [calandria]
author: taro
links:
  relates: [ditto-becomes-advocate-import, advocate-reset-autotiles]
---

**Why**: the format was meant to make maps easy to write by hand or by
an AI, but what is hard in a map is not its format: it is the autotiles,
whose id depends on the eight neighbours, and a sketch's legend names one
pattern per character, so it never solved them. Ditto's `.tiles` is
already text, aligned and diffable. The forest experiment in the log
below wrote a map straight as `.tiles`.

> Me parece que sí. But they could be two separate tasks, right? If today
> sketch does not solve autotiles either, then we can remove it and that
> is it, and leave the new subcommand as a task in todo, right?

(taro, 2026-11-27; the subcommand is
[`advocate-reset-autotiles`](advocate-reset-autotiles.md).)

**What is asked**:

* The test game's sixteen `src/maps/MapNNNN.toml` become the
  `MapNNNN.tiles` the recipe makes of them today, committed beside each
  map's JSON; the recipe's sketch loop goes. The `.lmu` files, the dump
  and the cartridges byte for byte the same.
* `rm2k/sketch/` goes, binary and library; `cargo uninstall
  rm2k-sketch` where it was installed; the workspace, `just install`,
  `LAYOUT.md`, the test game's README, the AGENTS.md list of projects and
  the book's "The tools" follow.

It no longer depends on
[`ditto-becomes-advocate-import`](ditto-becomes-advocate-import.md): the
recipe keeps calling `ditto pack` over `src/` as it is.

## Comments

### 2026-11-27, taro: does sketch earn its place?

> Hmm, OK. I think my preference would be: we do not keep the sketches.
> We use it only to generate new maps with AI.
>
> But I still wonder whether its existence is justified. Part of your
> design of the .tiles aimed at it being easily readable and diffable.
> Instead of being a binary format, which would take less disk space
> (negligible), it keeps the numbers as strings, aligned, so one can see
> it at a glance.
>
> I do not know if we gain much with sketch.
>
> A test comes to mind: can you add a new map to the test game, created
> directly as .tiles and .json, without going through sketch, and build me
> a ROM so I can try it by hand?
>
> I would like the map not to be so trivial and square, too. That it looks
> like a forest, with some tree graphic that takes 2x2 tiles, with the
> upper half above the hero layer and walkable, so the hero appears behind
> the tree. We can use the Exterior.png chipset of EasyRPG's RTP. It has
> 1x2 and 2x2 trees.
>
> That it also has some water.
>
> No need to run any tests, and there should be no need to compile
> anything either.

### 2026-11-27, Hornero: the forest, written as `.tiles`

On the-advocate's branch `hornero-forest`, not on main: `Map0017`, the
Forest, 30x22, `Map0017.json` and `Map0017.tiles` beside the others
with no `.toml`, which the recipe's loop skips and `cp -r src` carries
to `ditto pack` as they are. A new chipset, 4, "Forest": the Exterior
with the 2x2 tree's trunks (upper 10 and 11), the stump and the
flowered bush blocking, and the three water blocks not walkable —the
Exterior entry leaves them at liblcf's default, walkable—. The guide
lists it last. Delivered to `/shared/builds/test-game/`; the map as the
converter drew it, and the script, in
`/shared/captures/2026-11-27-forest/`. Nothing compiled, no test run.

**What the experiment showed**: the `.tiles` itself was not written by
hand. The numbers were computed by a throwaway script (`gen.py` there)
from a plan of the cells —grass, dark grass, path, water, deep water,
and where each tree goes—: the hard part is not the format but the
autotiles. Each grass, path or water cell's id depends on its eight
neighbours —easyrpg's `RecalculateAutotile`, 47 variants, and for water
a second index for the deep edge—, which neither a person nor an AI
gets right by eye over 660 cells. `rm2k-sketch` does not do it either:
its legend names one pattern per character, which is why the test
game's maps are square fields with objects on them. So what a map
needs, written by hand or by an AI, is a plan of the cells plus that
rule, whatever the plan's format.

## Log

### 2026-11-27, Hornero: written

Nothing done yet.

### 2026-11-27, Hornero: rewritten: sketch goes, autotiles apart

ABL's maps answered whether the packing could recalculate the autotiles:
4.5 % of their terrain cells and 1.8 % of their water edges are not what
the neighbour rule gives —715 inside map 66 alone, a plain interior kept
beside another terrain on purpose—, compositions by hand in RM2k's
editor. The rule is the editor's, and RM2k's player never applies it. So
nothing recalculates by default; a command a person runs on a `.tiles`
does, [`advocate-reset-autotiles`](advocate-reset-autotiles.md), and
this task is only sketch going. Name changed from "rm2k-sketch becomes a
library"; the file name stays.

### 2026-11-27, Hornero: taken, to Calandria

> Let's merge it! And then we can move on with the sketch and ditto
> tasks, so we get rid of 2 more binaries.

(taro, 2026-11-27, of the forest, merged on the-advocate's `bf18d71e`.)
Calandria does it with [`ditto-becomes-advocate-import`](ditto-becomes-advocate-import.md):
both touch the test game's recipe.
