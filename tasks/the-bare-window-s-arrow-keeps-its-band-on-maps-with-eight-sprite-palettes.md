---
name: "The bare window's arrow keeps its band on maps with eight sprite palettes"
description: "Where no sprite palette or no two sprite tiles are free, the arrow of a message without a background stays in the window's cells and its bottom row still hides the layer above: in A Blurred Line, the busy maps, the city of Core and Manta's memory among them"
type: feature
status: todo
author: chaja
agents: [cardon]
links:
  found-in: [the-window-s-arrow-without-a-background-as-an-object]
  relates: [book-of-three-a-black-block-over-the-window-in-the-lava-tunnels]
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

## Comments

### 2026-11-24, Cardón: a question for taro

Still so at the-advocate `8b069fc2`: the
converter still says "the message arrow stays in the window's cells"
(`record.rs` 1626) where no sprite palette or two tiles are free. What is
lost is eight lines of the upper layer under a bare window, for lack of room,
so it is theirs:

* **a)** a divergence: accept it, a line in the book.
* **b)** look for another home for the arrow on those maps —share a palette
  with a character whose colours are close, or the window's own layer drawn
  without hiding BG2 on that row—: unmeasured, and each costs something.

Recommendation: **a**, and `wishlist` for b; a bare window on a crowded map
is rare, and only the arrow's row shows it.

### 2026-11-28, taro: a comment

> the arrow must show, so let’s look for another home. picking close colors from another palette should be fine. when no sprite tiles are free… see if any possible solution to that comes up. If there’s no easy fix, create a new, separate task for that, and reduce the scope of this one to just the palette.

### 2026-11-28, Hornero: to todo, the arrow gets another home

To `todo` with taro's scope: the arrow always shows. Where no sprite
palette is free, it borrows the palette of the character whose colours
are closest to its own. Where no sprite tiles are free, the one doing it
looks for a fix; if there is no easy one, that part becomes a task of
its own and this one keeps only the palette.

## Log
