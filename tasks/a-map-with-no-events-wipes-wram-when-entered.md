---
name: "A map with no events wipes WRAM when entered"
description: "Teleporting into a map that has no events at all leaves the whole WRAM at $FF some fifteen frames after map_current changes, on snes9x and on bsnes; with one still event on the map it loads fine"
type: bug
status: draft
---

Seen by Cardón on 2026-10-15, in
[`book-the-tools-page-explained`](book-the-tools-page-explained.md), with
the-advocate `299c51fd` —the tools installed from it and its runtime— and
the test game.

**What happens**: a test page that is only a `Teleport` to a map whose
`events` list is empty —the test game's garden, map 2, before it had a
villager— leaves on the first tick and fades; about fifteen frames after
`map_current` takes the new map's index, every byte of WRAM reads `$FF`
—`ticks`, `fade`, `map_current`, the first bytes of the bank— and the
screen is black, on snes9x and on bsnes alike. The same `Teleport` inside
the meadow, which has ten events, arrives; and the same map with a single
still event —a page with a CharSet and no commands— loads and draws, which
is what the garden and the showcase ship with.

**How to reproduce**: in `test-game/`, give `src/maps/Map0002.json` no
`events`, make it with `just game`, build with `just cartridges` and run a
`Session(core, case="garden")` printing `word("map_current")` and
`console.ram(0, 8)` each frame: the trace that found it is in the task
above. The converter's report says `0 NPCs with a CharSet out of 0
events` and `sprites: 2 characters, 1 slots` for that map.

**Not looked at**: which routine does it. A loop over the map's events
that decrements before it tests, run with none, would fill memory like
this; the runtime between `94f79d72` and `299c51fd` changed how still
events share slots, and whether the wipe predates that was not bisected.
No port's map is known to have no events, so it may not show in a game.
