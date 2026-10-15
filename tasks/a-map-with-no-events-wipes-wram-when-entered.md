---
name: "A map with no events wipes WRAM when entered"
description: "Teleporting into a map that has no events at all leaves the whole WRAM at $FF some fifteen frames after map_current changes, on snes9x and on bsnes; with one still event on the map it loads fine"
type: bug
status: testing
assignee: taro
agents: [Cardón, Calandria]
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

## Calandria, 2026-10-15

**Bisect.** The test game of the-advocate `6a9ef4b9`, with the garden's
`events` emptied, built with the tools and runtime of each commit
(`cartridge convert mapdata wally` installed from it) and run frame by
frame printing `map_current` and the first eight bytes of WRAM:

* `94f79d72`, the parent of the still-animations merge: `map_current`
  becomes 1 —the garden's index— on frame 26, and on frame 39–41 the whole
  bank reads `$FF`, on snes9x and bsnes;
* `7aad6a57`, the merge: the same frames, the same `$FF`.

So it predates the still-animations work.

**Which routine.** A copy of the runtime that wrote a step number to SRAM
after each call of `enter_map_no_events` stopped at 19: `clear_parallel`
returned, `page_routes` never did. In it, `pick_with_filter` fills
`pick_by_ev` with `$FFFF` before picking pages, and its `drain` loop
stored first and compared after: with `ev_total` at zero the limit is
zero, X steps past it on the first round and stops only when it wraps, so
65,536 bytes of `$FFFF` go through the data bank, all of bank 0, stack
included.

`git blame`: the loop is from b87949dd2 (2026-09-17), which removed
`ev_tope` —`ev_total` plus one, for the old test page, never zero— and
gave its four loops to `ev_total`. The intent was "clear the map's
entries"; zero was never considered. The other three, `wait_autostart` and
the two of `start_waiting`, are do-while over `ev_total` too, but run only
when an event is marked or has an autostart, which a map with no events
cannot have: they stay. The rest of the loops over events test first.

**The fix**, in the-advocate `calandria-empty-map`: `drain` jumps to its
test before the first store (`fba39f2d`), with the why on the line.

**The test**: the test game's fourth map, the clearing, has no events;
case `empty-map` teleports into it and `tests/test_empty_map.py` asks that
the hero arrives at (10, 7) and the map draws (`e09377c7`, golden in
`1113385c`). Red before the fix on snes9x and bsnes —`map_current` reads
`$FFFF`—, green after.

**The garden's and the showcase's villagers** are no longer needed to
dodge this; they stay, because they put a character on those maps.

**The ports.** Maps with no events in each dump, and which of them the
cartridge carries by `[maps]`:

* ABL: 11, all in `excluded` —folders and maps nothing reaches—: none in
  the cartridge;
* Book of Three: 2 (34, 66), carried, no `Teleport` to them;
* Desert Nightmare: 1 (29), carried, no `Teleport` to it;
* Frozen World: 1 (148), carried, no `Teleport` to it;
* Vampires Dawn: 7 (34, 64–68, 71), carried, **and reached**: 34, the
  castle's picture, by seventeen `Teleport`s, 64–68 from 63 and 71 from
  69. Measured with the ports harness's `go_to_map` to each of the seven,
  on snes9x and bsnes: with the global tools of the-advocate `6a9ef4b9`
  all fourteen jumps end with `map_current` at `$FFFF`; with the fix all
  fourteen arrive. The port was never played into them, so its book page
  had no line about it; no ports test covers them —the test game's does
  the path—.
* Dooms2, El Dorado, Sunset over Imdahl: none.

**Verified** on `calandria-empty-map` (the-advocate) with
`just install-local .local-tools cartridge`: `just test`, 29 passed; the
test game, 17 passed and 1 skipped —bsnes's SRAM, as before—; ABL's
`just tests` with those tools, 1555 passed and 2 skipped, no golden moved;
`just boot` at the ports' root, 44 passed. `just rust-test` was not run:
no Rust changed.

**When merging**: nothing to install. Only `runtime/` and the test game
changed, and `rm2k-snes-cartridges` assembles the runtime of the checkout
it was installed from, `~/the-advocate`.
