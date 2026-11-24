---
name: "Desert Nightmare: the warehouse is darker than the original's"
description: "Map 21's light is drawn into the map as the picture the opening scene leaves, not the one the map shows each time it is entered: the room comes out a third darker"
type: bug
status: draft
author: cardon
game: desert-nightmare
agents: [Cardón]
links:
  relates: [desert-nightmare-the-map-draws-over-the-hero-and-white-boxes]
---

Seen by Cardón on 2026-11-20, doing
[`desert-nightmare-the-map-draws-over-the-hero-and-white-boxes`](desert-nightmare-the-map-draws-over-the-hero-and-white-boxes.md),
with the-advocate `cardon-dn-walls` (from `7951af2a`) and the ports
`cardon-dn-walls` (from `42f70e8`), in snes9x against EasyRPG.

**What is seen**: in the warehouse, map 21, with its opening scene played
(S234), the room's mean luminance is about 33 of 255 in the ROM and 50 in
EasyRPG over the same floor, walls and boxes. Captures in
`/shared/captures/2026-11-20-dn-walls/`: `rom-after-m21.png` against
`easyrpg-m21-after.png`.

**Why, as far as it was looked**: the map lights itself with picture 1.
Event 5, a parallel page, shows `Lichteffekt_Lager1_1` at transparency 55
and erases itself each time the map is entered, or `Lichteffekt_Lager1_2`
at 45 once S233 is on; the opening scene (event 8) ends showing
`Lichteffekt_Lager1_2` at 55. The map pictures' rule
(`map_pictures.rs` in the-advocate's converter) draws one picture per number,
the one shown most —`Lichteffekt_Lager1_2`, twice— and with the
transparency of the last show it read. What RM2k shows once the scene is
over is `Lichteffekt_Lager1_1`. The two pictures were not compared.

**To reproduce**: the ports' `tests/test_desert_nightmare_scenes_and_items.py`
sets S234 and jumps to map 21 at (10, 7); EasyRPG needs map 21's event 8
page 1 replaced by turning S234 on, in a copy of the game.
