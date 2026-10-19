---
name: "Frozen World's map 2: route graphic changes past the ROM's table of 8"
description: "Map 2 (\"Plate Placement\") builds since its code stays in the cartridge, with 20 warnings: a route changes an event's graphic to one the ROM's table of 8 has no room for, and the change is ignored"
type: bug
status: testing
assignee: taro
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

## Defined (2026-10-16, Carpintero)

Still open: `ROUTE_GFX_MAX` is still the ROM's table of graphics a route
or `ChangeSpriteAssociation` can name per map
(`rm2k-snes/convert/src/convert.rs`, at the-advocate `f4709d0b`). Map 2
is where The Frozen World is played —its combat is on maps 1 and 2—, so
the plates are the game. **Done**: map 2 builds with no "table of 8 is
full" warning, and a test sees a plate change its graphic. Two ways, the
agent picks and measures: size the table by the map (far RAM is placed by
the linker since `fb156a3e`), or share entries between the graphics that
are never on screen together. **First step**: how many distinct route
graphics map 2 needs (twenty and the eight). The same table stops Vampires
Dawn's transformations
([`vampires-dawn-transformations-dont-compile`](vampires-dawn-transformations-dont-compile.md)).

## Done (2026-10-19, Carpintero)

**First step, measured**: map 2 gives the hero 28 distinct graphics with
command 34 —23 plates of the inventory, `MiscPlates 7` and `Plates4 6` of
the Del buttons and the three heroes—, all on the hero; map 3, the battle's
command grid, 16. No sharing between graphics that are never on screen
together: the table is sized by the map. `ROUTE_GFX_MAX` is now the
compiler's cap, 255 —the route carries the index in a byte—, and the
console's table lives in far RAM (`route_gfx_buf` and `route_gfx_colors`
in `far_ram_game.s`), as big as the cartridge's map that asks for most:
the emission writes it, 28 in The Frozen World. Bank 0's BSS gets its 24
bytes back.

Map 2 builds without a "table of 8 is full" warning, and
`test_a_plate_past_the_eighth_is_shown` in the ports'
`tests/test_frozen_world_cursor.py` sees the Focus plate —`Plates2 1`, the
ninth graphic, which was dropped— on the cursor, pixel for pixel as its
event shows it. Red without the change. The rest of that file is the
other causes of
[`frozen-world-the-cursor-keeps-the-wrong-graphic`](frozen-world-the-cursor-keeps-the-wrong-graphic.md).
