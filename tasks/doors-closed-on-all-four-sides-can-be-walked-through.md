---
name: "Doors closed on all four sides can be walked through"
description: "A tile event under the hero whose tile closes everything imposes $00, and `pass_has` stored that value as a flag: it stayed off and `pass_with_event` didn't look at the rows"
type: bug
status: testing
assignee: taro
agents: [Hornero]
---

From taro, on 2026-10-10: in Tasgarde Military Base (ABL's map 74) the
door —Door1Bottom and Door1Top, events 2 and 1— can be walked through without
DoorGuard opening it. In RM2k an event under the hero, not passable and
with a tile graphic imposes its tile's passability
(easyrpg's `Game_Map::IsPassableTile`), and tiles 109 and 115 of
chipset 19 close all four sides.

Measured with the harness on ABL's `release`: from (19,40), up
held, Talan ends up at (19,32). The rows of the two events arrive
with +15 = $00, correct; but `pass_has` is 0.

`pass_look` (`far_npcs.s`) and the page refresh (`event_pages.s`)
stored in `pass_has` the row's value, not a one: with $00 the
flag says "nobody imposes". It was born in `da466bbe`, the run at 60
frames, which added the flag.

## Done

Both writes store a one (`7dcdcfce`). The test is ABL's,
`tests/rpgmaker/test_tile_door.py`: the door closed on load,
with page 279 —the other path, the refresh— and open with 279
and 280. The first two went red without the fix, with Talan at
(19,32). With 280 alone the door stays closed, and it isn't an error: `Door1Top`
stays on its page 1, with 109; `DoorGuard` turns both on.

**Verified:** A Blurred Line's whole suite with the fix's runtime, on
ABL's `main` with Hurón's world doors: no golden changed, and
everything green except the new test —which had the "open" state wrong— and
the index that didn't name it, both fixed and run again.
`just -f tools/justfile test` green.

**What it doesn't cover:** any other door in the game that was open
because of this. No walk crossed a closed door —otherwise, some
would have changed—, but now all those on a tile closed on all four
sides stop you, as in RM2k: to be played.

**When merging:** nothing to install. `project` finds the runtime in the
checkout it was installed from, so the global one already sees it, and the
cartridges' fingerprint rebuilds it.
