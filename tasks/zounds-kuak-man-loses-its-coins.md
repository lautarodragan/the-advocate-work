---
name: "Zounds: the Kuak-Man mini-game loses 206 of its 314 coins"
description: "Map 178 has 327 events and the console keeps 120 rows; the coins are drawn, touch and erase themselves, so no twin folding keeps them"
type: bug
status: draft
---

Seen by Carpintero on 2026-10-17, measuring
[`zounds-maps-over-120-events`](zounds-maps-over-120-events.md), with the
branch `carpintero-zounds-events` over the-advocate `30786e0b` and the ports
`1d93da4`.

Map 178 "Kuak-Man" is a mini-game: 314 "Coin" events, each drawn with
`Zounds_Animation_001`, touched by the hero, a `PlaySound`, a
`ControlVariables` and an `EraseEvent`. The console's RAM holds 120 events
per map, so the converter keeps 120 rows: the 4 exits, the mini-game's
other events and 108 coins, and leaves out the 206 coins with the highest
ids and the fox that is only seen. Besides that, the NPC table draws 104 events at most, so 10 of
the coins kept are not drawn either (the converter's WARNING).

A twin cannot stand for a coin: twins draw nothing and share the erasing of
the event whose row they share. Keeping them would need something new: a
per-cell erased bit and drawing from a table, or the coins as tiles of the
map that a touch replaces.

**How to see it**: `just cartridges` in `zounds/` of the ports, and
`map 178: WARNING` in `build/release/converter.log`; on the console, the
right half of the maze has no coins.
