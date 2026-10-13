---
name: "Delcentric Factory: the right pump misses a tile"
description: "Of the two decorative pumps on the left of map 17, the right one misses a tile in one of its two frames; the left one is right"
type: bug
status: testing
assignee: taro
agents: [Hurón]
---

taro, on 2026-10-12 (seen for a long time, with Talan and with Dalia): in
Delcentric Factory there are machines that go up and down, decoration. Of
the two on the left of the map, the left one works perfectly, but the right
one misses a tile in one of its two animation frames.

What the map does (map 17, read from `data/maps/Map0017.json` by Hornero):

* The left pump is four tile events, `Mech4`..`Mech1` (ids 1–4) at x 27,
  y 64–67; the right one three, `Mech3b`, `Mech2b`, `Mech1b` (ids 8, 6, 5)
  at x 31, y 65–67.
* `AnimatePump` (id 7, parallel) loops: `TradeEventLocations` 4↔5, 6↔3,
  2↔8, then `SetEventLocation` of event 1 (`Mech4`) to (31, 64), wait 0.3
  s; and the same swaps, and `Mech4` back to (27, 64).
* So the pump that is up takes `Mech4` as its fourth tile: the missing tile
  is most likely `Mech4` not shown at (31, 64) —`SetEventLocation` of a
  tile event, and how wally decides what is baked (`rm2k-snes/wally/src/
  map.rs`, `baking.rs`)—. To be measured, not assumed.

## Log

**2026-10-12, Hurón.** The converter log of `release` says `map 17: 1
opaque event(s) baked into the map: 3`: `Mech2` (tile 132, at 27,66) is
baked into the upper layer. It should not be: `AnimatePump` swaps it with
`Mech2b` (`TradeEventLocations 6, 3`). `bakeable` in
`rm2k-snes/wally/src/baking.rs` collects the events "a page moves" from
the first parameter of each moving command only, so of a
`SwapEventLocations` it misses the second event —3, 5 and 8 here; 5 and 8
are not baked for other reasons—. Since `f1cecbdb` (`baking.py`), carried
over to Rust in `756fe507`. So when the pump is up on the right, its
third tile stays painted on the left, under `Mech2b`, and the right one
has a hole at (31,66). The same function also ignores "this event"
(10005): an event that moves itself with `SetEventLocation` could be
baked too.

Measured before fixing: in the ROM, `Mech4` changes column every 18
ticks, and with it on the right the cell (31,66) is empty —256 pixels, one
tile—; the original under Wine (start moved to 17 (29,61) in a copy of the
game) draws both pumps whole in both frames. Map 83, "Dalia at the
Factory", is a copy of 17 with the same events, and had the same `Mech2`
baked: that is why taro saw it with Dalia too.

Fix, in `bakeable`: both events of a `SwapEventLocations` count as moved,
and "this event" counts as the event whose page it is (branch
`huron-pump` in the-advocate). Common events are still not looked at, as
before. After it no event of 17 or 83 is baked, and no other map's baking
changes (the `baked` lines of every cartridge's converter log, compared).

Test: `pruebas/abl/test_delcentric_pump_golden.py` in ABL, both maps,
both frames, the frame chosen by where `Mech4` stands; red with main's
tools (the `right-up` of each map, 256 pixels), green with the fix. And
`an_event_a_page_moves_is_not_baked` in wally's `tests/whole_map.rs`.

Ran, with the wally of the fix: `just crate-test wally` (the new test red
without the change); ABL's `just pruebas`, 1285 passed (main's 1283 plus
these two), no other golden moved; `just arrancan` at the root of the
ports, 9 passed; and the `baked` lines of the converter logs of the eight
games, compared with main's: only ABL's maps 17 and 83 change. Captures,
original and ROM side by side, in
`/shared/capturas/2026-10-12-delcentric-pump/`.

Not covered: `bakeable` still does not look at common events. In ABL only
one moves a map event by id, `AG7CutsceneInTheRain` (32), with a
`MoveEvent` of event 2, and none places "this event"; no map is known to
lose a tile by it, so it is not a draft.

To install when merging: `just install wally`.

Branches: `huron-pump` in the-advocate (`792e40d2`) and in the ports
(`5332b23` the test, `c9832f7` its goldens).
