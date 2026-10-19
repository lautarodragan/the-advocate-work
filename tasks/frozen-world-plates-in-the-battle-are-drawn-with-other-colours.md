---
name: "Frozen World: plates in the battle are drawn with other colours"
description: "On the battle screen, map 1, thirteen of the plates —Fire's among them— are drawn with another graphic's palette: on the cursor after picking them in the grid, and on the battle's events that show them; Fire's flame comes out grey instead of orange"
type: bug
status: draft
agents: [Carpintero]
---

Seen by Carpintero on 2026-10-19 in an emulator, with the-advocate
`carpintero-cursor-graphic` (on `52d564ca`) and the ports on `1869b99`,
while fixing
[`frozen-world-the-cursor-keeps-the-wrong-graphic`](frozen-world-the-cursor-keeps-the-wrong-graphic.md).
Not seen by taro yet: until that fix the cursor showed another graphic
altogether.

**What is seen**: in the battle's command grid (map 3), pick the Fire
plate (`Plates2 4`, the grid's slot with switch 92); the battle screen
(map 1) shows the cursor as the plate, but its flame is grey and tan where
the grid draws it orange and yellow. A side-by-side capture is in
`/shared/captures/2026-10-19-frozen-world-cursor/`.

**Why, from the build**: `converter.log` of The Frozen World's release
says map 1 has 37 graphics "without a palette of their own, drawn with
someone else's" —29 before the fix—, thirteen of them plates: `Plates1 5`
and `7`, `Plates2 3` to `7` and `Plates3 1` to `6`. Five of them were in
that list before, for map 1's own event pages (`Wyrm's Flame Breath`,
`Wizard1's FireSpell`…); the other eight came in with the plates the
grid's pages give the hero there. Not measured further: why they do not go
in the leaders' palette with colours of their own, like the graphics only
the hero shows.

**How to reproduce**: as `test_the_battle_shows_the_plate_picked` in the
ports' `tests/test_frozen_world_cursor.py` gets to the battle, with switch
92 instead of 6: switches 92 and 171 on, variable 30 at 99, jump to map 3
at (9,4) and press A.
