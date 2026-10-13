---
name: "Book of Three: the hero freezes in Caer Dallben East"
description: "On map 4 the hero walks with no walking animation and always facing the way it came in; it is right on map 3, inside the houses, and again after leaving map 4"
type: bug
status: done
assignee: taro
agents: [Calandria]
---

taro, on 2026-10-13: in Caer Dallben East (map 4) the hero keeps a fixed
direction and no animation. Moving works, but there is no walking
animation and it always faces the same way: down if it came in facing
down, right if it came in from the left. It is fine on the map before and
inside the houses, it fixes itself every time the hero leaves map 4 and
breaks again on coming back. It happens without talking to anyone since
the start. taro went through the map's events, the teleports to it and
every common event, and nothing in them explains it.

What Hornero saw in `build/release/converter.log` of Book of Three: map 4
is the only one at the sprite budget —"7 characters, 9 slots, 256 tiles in
VRAM, 5 palettes; **6** with their twelve poses in the cartridge"—, so one
character has no twelve poses in the cartridge. If that one is the hero,
it is drawn with the one pose loaded when the map loads, which is what is
seen. To be measured, not assumed.

## Log

## Measured (Calandria, 2026-10-13)

From the-advocate `81a0a9ce`, the ports `caf39ef`.

**The lead was not it.** The hero has his twelve poses on map 4: Wally
puts the leaders first in `animated`, `hero_poses` points at Taran's table
in the cartridge, and `hero_pose` follows direction and column as it
should while walking. What did not follow was **`hero_pose_vram`: $FF on
every frame**, which is `place_hero`'s "the queue was full: next frame".

The upload queue (`vq`, eight entries, five per vblank) was full on every
frame with the same five destinations: the chickens' slots. Why:

* Book of Three **refreshes the pages on every frame**: common event 22
  (LegendariesActivated) is parallel with no condition and turns switches
  on every time it runs, so `refresh` is set every frame. (21, Eilonwy's
  Upgrades, would do the same, but it does not compile today: see the
  draft `book-of-three-reraise-and-eilonwy-dont-compile`.)
* Each refresh runs `page_graphic` → `walker_graphic` for every row that
  walks, and `walker_graphic` set the row's VRAM shadow (`npc_buf + 12`)
  to $FF even when the page's graphic was the one already in the slot. So
  every walker queued its pose again every frame.
* `place_hero` is the last to queue in a frame, so with the queue full it
  is always the hero who is left out. Map 4 is the only one with enough
  walkers (five chickens) to fill five per vblank; elsewhere it did not
  show.

## The fix, two commits in the-advocate (`calandria-hero-poses`)

1. `walker_graphic` forgets the shadow only when the page brings another
   pose bank (the case it was written for, Boss Wick in ABL), and
   `page_graphic` no longer writes the page's pose into +12 for a walking
   row. On map 4 the queue now holds 0 to 2 entries.
2. The hero cannot lose the queue: `vram_queue` leaves the last entry
   free, and `place_hero` queues with `vram_queue_hero`, which puts his
   pose at the front (or replaces his own if it is already there). Checked
   alone, with (1) reverted: the queue full every frame again and the hero
   walking right.

## The test

`tests/test_book_of_three.py` in the ports: the two walks across map 4 are
watched tick by tick, without changing a button, and the hero's block in
VRAM has to hold one of his twelve poses —read from the cartridge— and go
through more than one direction and more than one column. Red at `caf39ef`
("poses [4]"), green with each commit. Only in snes9x: bsnes does not
expose VRAM.

## What ran (branch tools: `install-local .local-tools cartridge project`)

* the-advocate `just test`: 27 passed.
* ABL `just tests` in the ports: 1294 passed, no golden moved; `abl.sfc`
  `43940ea9…3322`. `just space`: every cartridge links, bank 0 ~1.3 KB left.
* Ports `just boot`: 9 passed, no golden moved (Book of Three's walkthrough
  included, with the new check).
* A throwaway scan of every map of the seven games (snes9x): jump to the
  hero's start, walk the four ways, and flag a map where the hero's block in
  VRAM is not `hero_pose` for more than two ticks in a row. Before and after
  give the same list in every game but Vampires Dawn, where after has one
  fewer (354). The maps it flags (Book of Three 24, many of Desert
  Nightmare and Vampires Dawn, El Dorado 13, Sunset 11) are the jump landing
  in a scene —a page running, the screen erased or a big picture, with which
  `vram_drain` does not run—, not the hero losing the queue: looked at in
  Book of Three 24 (fine when entered from a fresh boot), Desert Nightmare 7
  and Vampires Dawn 161 (a big picture over the screen). Not looked at map
  by map. Map 4 itself is not flagged by the scan: at the hero's start cell
  the chickens are off screen.

## What the suite does not cover

* The check only runs in snes9x, and only on the two walks of map 4.
* No ABL test fills the queue so that the hero has to go in front: the
  front-insertion path runs only when the queue holds NPC entries as the
  hero changes pose, which the walkthrough of Book of Three exercises
  (measured: queue at 7 with the first commit reverted) but no ABL case.

## When merging

Reinstall `cartridge` and `project` (the runtime travels with them); no
other crate changed. Branches: `calandria-hero-poses` in the-advocate, the
ports and the book.

## To play

Book of Three, Caer Dallben East: Taran walking and turning, with the
chickens on screen.
