---
name: "The farm's goldens move with the bank packing"
description: "paradise-127-celebration and paradise-127-farmers-jump catch four farmers in the other frame of their idle animation when map 127's data lands in other banks, with nothing changed in the map or the runtime"
type: bug
status: draft
---

Seen by Tijereta on 2026-11-01, with the-advocate `422f904d` (main's
tools) and the ports `cd41913` plus the debug map's two full-party NPCs
(`b879c8c` on `tijereta-sp-in-the-menu`), while doing
[`sp-in-the-menu-and-the-item-target-picker`](sp-in-the-menu-and-the-item-target-picker.md).

**What it is**: two NPCs added to ABL's debug map, map 1000, which nobody
visits in `tests/abl/test_farm.py`, made its two goldens red:
`paradise-127-celebration` by 338 pixels and `paradise-127-farmers-jump`
by 560. The debug map's events grew the data by one piece, the bank
packing shifted, and map 127's `map_tiles_127` and `pose_1270` to
`pose_1275` moved banks —the `.sym` before and after—. Map 127 does not
fit in VRAM and every pose goes up through the slot cache as the vblank
has room, so four farmers are caught in the other frame of their idle
animation. Without the NPCs the goldens pass; with them, with main's
tools or the branch's, they come out the same. The new captures were
committed (`a67dddf`), and look right.

So any change that moves the packing can turn these two red without a
change to what the farm draws; `test_the_celebration_with_the_slot_cache`'s
frame-by-frame check of the slots stays green throughout.

How to see it: on the ports at `cd41913`, add any event to
`abl/patches/manual/maps/Map1000.json`, `just cartridges` and
`just tests tests/abl/test_farm.py` in `abl/`.
