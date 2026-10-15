---
name: "Frozen World's map 2: route graphic changes past the ROM's table of 8"
description: "Map 2 (\"Plate Placement\") builds since its code stays in the cartridge, with 20 warnings: a route changes an event's graphic to one the ROM's table of 8 has no room for, and the change is ignored"
type: bug
status: draft
agents: [Carpintero]
---

Seen by Carpintero on 2026-10-15, on the branches `carpintero-rom-code`
(the-advocate on top of `huron-tp` and main `978c0d25`; ports on top of
`huron-tp` and main `08551c6`), when map 2 came back into The Frozen
World's cartridge.

**How to see it**: `just cartridges release` in `frozen-world/` of the
ports, and in `build/release/converter.log`:

    map 2: WARNING, a route changes to the graphic Plates2 1 and the ROM's table of 8 is full: the change is ignored

twenty of them, for `Plates2` 0 to 7, `Plates3` 0 to 6, `MiscPlates` 7
and `rangedmelee` 7.

**What it probably looks like when playing**, not played: map 2 is where
the plates are placed in the slots, and those graphics are the plates. A
plate that a route should show would keep the graphic it had.
