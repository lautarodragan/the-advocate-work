---
name: "rm2k-sketch becomes a library"
description: "rm2k-sketch's binary goes and its format stays: the test game's maps keep being sketched as a grid of characters and a legend, and whatever packs the test game's text into RM2k's files reads each MapNNNN.toml itself, instead of the recipe calling rm2k-sketch per map"
type: refactor
game: advocate
status: todo
author: taro
links:
  relates: [ditto-becomes-advocate-import]
---

**Why**: the format earns its place, the binary does not. A map sketched
as a grid —the meadow, 20x15, about 150 tokens and a diff that shows
what moved— against its two layers as 600 tile numbers, some 2,000–2,500
tokens and a diff nobody reads; and an RPG Maker project as the source
of truth would be binary files that git cannot diff and an AI cannot
edit without tools, while the events have to be written as text anyway.
The binary is only the test game's recipe calling it once per map
before `ditto pack`.

> Regarding rm2k-sketch: I have mixed feelings. When I mentioned making
> our own test game, I did not specify _how_. I think rm2k-sketch comes
> from there. What I had in mind is that you directly create a project in
> RPG Maker 2000 format, we keep it as the source of truth, and use ditto
> to derive it. I now think that did not make much sense. I think sketch
> helps for generating maps with AI, right? It is much simpler and less
> token-hungry to build it that way than in another format? I feel maybe
> we could remove it and save ourselves another binary.

> Two separate tasks for tracking, but they can be implemented together.

(taro, 2026-11-27, the second on this task and
[`ditto-becomes-advocate-import`](ditto-becomes-advocate-import.md))

**What is asked**:

* `rm2k/sketch/` stays as a library; its `main.rs` goes, and `cargo
  uninstall rm2k-sketch` where it was installed.
* The step that packs the test game's text —`ditto pack` today, whatever
  `ditto-becomes-advocate-import` decides tomorrow— reads a map's
  `MapNNNN.toml` sketch in place of its `.tiles`, so `test-game/justfile`
  stops calling a binary per map.
* The test game's `.lmu` files, its dump and its ROMs byte for byte the
  same; the README of the test game and of the crate, and the book's
  "The tools", follow.

Implemented together with
[`ditto-becomes-advocate-import`](ditto-becomes-advocate-import.md),
which has to decide where the packing lives; kept apart only to track
it.

## Log

### 2026-11-27, Hornero: written

Nothing done yet.

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
