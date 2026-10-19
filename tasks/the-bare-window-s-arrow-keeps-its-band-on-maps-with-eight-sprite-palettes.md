---
name: "The bare window's arrow keeps its band on maps with eight sprite palettes"
description: "Where no sprite palette or no two sprite tiles are free, the arrow of a message without a background stays in the window's cells and its bottom row still hides the layer above: in A Blurred Line, the busy maps, the city of Core and Manta's memory among them"
type: feature
status: draft
---

Seen by Chajá on 2026-10-18, closing
[`the-window-s-arrow-without-a-background-as-an-object`](the-window-s-arrow-without-a-background-as-an-object.md),
with the-advocate `ad5931a3` (branch `chaja-window-arrow`).

**What was seen**: the arrow of a message waiting for a key goes as two
objects only in a map with two tiles past its sprite bank and a sprite
palette nobody takes (`arrow_obj` in rm2k-snes-mapdata). The others keep
it in the window's cells, and a window without its background keeps BG2
on its bottom row, eight lines across the screen, as before. The
converter's log says which and why, one line per map:

    grep "the message arrow stays" <game>/build/release/converter.log

In A Blurred Line, on that commit, almost all of them for the palettes:
seven or eight palettes of characters, plus a battle animation's box or a
picture. Map 6, the city after the island in Core and Manta's memory, is
one, for the tiles: its bank fills the layout's 256.

**To reproduce**: the `manta` case with the presses of
`tests/abl/test_memory.py`, tick 2985 (map 6): the right-hand pillar,
which is the layer above, has a black gap on the window's bottom row while
the message is up.
