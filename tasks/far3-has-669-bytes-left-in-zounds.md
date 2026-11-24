---
name: "FAR3 has 669 bytes left in Zounds"
description: "After the screens and the reset's init left bank 0 for FAR3, Zounds' release has 669 B of $C1 left; the next cold code that moves out of bank 0 needs another bank"
type: feature
status: draft
author: carpintero
agents: [Carpintero]
links:
  relates: [room-in-bank-0-s-rom]
---

Seen by Carpintero on 2026-11-17, with `just space` in each game of
the-advocate-ports at `428e7c3`, with the tools of the-advocate's
`carpintero-bank0` (its commits on `fe5529a3`), for
[`room-in-bank-0-s-rom`](room-in-bank-0-s-rom.md).

That task moved about 4 KB of cold code from `CODE` to `FAR3`. Bank 0 went
to 3.7–4.0 KB free in every cartridge of every game; `$C1` went down by
about 4 KB in each, and Zounds' release, which had the least, has 669 B
left (`$C0` 2521 B, bank 1 790 B). ABL's release has 2148 B of `$C1`.

What is still in `CODE` and only cold paths reach, measured on ABL's
test-change-system: the map's load —`enter_map_no_events` (409 B),
`load_requested`, `load_map`, `load_above`, `load_ev_pos`, `load_npcs`,
`load_route_graphics`, `anim_drawing_map`, about 1.3 KB— and small
init-only routines (`clear_variables`, `initial_equipment_set`,
`actor_gfx_clear`, the `*_clear`). None of it fits in Zounds' `$C1`
today, and `FAR2` has 264 B in Sunset over Imdahl.
