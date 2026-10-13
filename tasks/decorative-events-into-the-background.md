---
name: "Decorative events, into the background"
description: "Events that are only aesthetic —one page, no commands, nobody moves them— are baked into the background as animated tiles, blended against their cell if they are translucent, instead of spending sprites"
type: feature
status: testing
agents: [Calandria]
assignee: taro
---

Measured by Hornero on 2026-10-06 on Vampires Dawn's map 95 (Weg):
209 `water1` events, translucent, animated, without commands and with a single
page, paint a river. Today `wally` blends each translucent one against its cell
as a graphic of its own: 206 graphics and 4096 sprite tiles, the whole
bank. Without those events, or with opaque water, they are 384; but opaque they are 247
events for a cache of 18 slots, with up to 30 on screen.

taro, on 2026-10-06: "I suspect that general optimisations for cases where
events are used purely for aesthetics, like a new map
layer, could be leveraged on many maps and many games". And: "I don't want
us to over-optimise an edge case". His captures, of RM2k running:
the game's `Map0095-runtime*.png`; EV0016 shifts some water events by one
tile at start, because in the editor they can't share a cell.

# Done (Calandria, 2026-10-06)

`[graphics] decorative_events = true` in `rm2k-snes.toml`, **off by
default**: ABL has 502 candidates on 328 maps, so turning it on
changes its ROM, and the brief was that `abl.sfc` came out identical (it comes out
`8bb36b99312730ef`, built with the change's tools). It is turned on in the
games that use it. The converter passes it to Wally as `decorative` and,
with it, `test_commands`: what the test pages name.

An event is decorative if it has a single page, without commands, without
conditions, with a CharSet, without movement type or route, isn't a turning one
(animation 5), is on the lower layer or on the hero's, and nothing
names it: neither the map's pages, nor common events, nor the test ones
(`MoveEvent`, `SetEventLocation`, `SwapEventLocations`, `FlashSprite`,
`ShowBattleAnimation`, the direction condition). On the hero's layer,
in addition, its drawing has to stay inside the cell: if it sticks out, the hero
standing on the cell below would walk over it. Code in
`tools/rm2k-snes/wally/src/decor.rs`.

* It is painted on the lower layer, in each drawing of its animation; one that
  animates in place goes with the **water family**, which goes through the same
  0, 1, 2, 1 cycle as a character's columns. Translucent, it is blended
  with what is beneath it; two in one cell are blended in order.
* **It stops being an event**: no row, no slot, no page in the table
  (`maps::pages` skips its records; the index of the others doesn't shift,
  as already happens with the events that are left out). Its pixels don't go
  through the sprite palette allocation.
* **The blocking** of one on the hero's layer goes into the passability
  grid, in its cell.
* If the background doesn't fit —the palette—, the route is: all blended; the
  translucent ones dithered (`five_of_eight`); by CharSet, the most numerous
  first; and if not, they remain objects. What fits is what costs
  the ground up to `GROUND_LOST_MAX` pixels of its colours, not just one.

Measured with `wally map` on Weg's request (map 95), sprite tiles /
background tiles / events that remain as objects: before 4096 / 327 / 247;
with the knob, 960 / 394 / 59 —the water dithered—; with `water1` in
`[graphics] opaque`, 384 / 312 / 59. Blended against its cell it doesn't fit: it
costs the ground 1557 px, and the ceiling is 1024. Uruya (165): its 8 decorative ones
don't fit (palette full) and everything stays the same; Shannar (15): none.
Candidates per game, without looking at the drawing or the upper layer:
book-of-three 87, desert-nightmare 2887, dooms2 39, el-dorado 26,
frozen-world 117, sunset-over-imdahl 209, vampires-dawn 5483, ABL 502.

Divergences in `divergences/baked-decorative-events.md`
—the animation's pace and phase—. Captures in
`/shared/captures/2026-10-06-decorativos/`.

**What wasn't tested:** any ROM with the knob set —A Blurred Line's suite
doesn't turn it on—; that in the ROM the animated water in the background moves and that the
hero doesn't cross the river is what has to be played in Vampires Dawn with
`decorative_events = true`. It is covered only by `wally/tests/decorative.rs` —the
cell's passability, the water's run, the indices— and the converter
has no test that `pages` skips the decorative ones.

**When merging, reinstall:** `wally` and `convert`.
