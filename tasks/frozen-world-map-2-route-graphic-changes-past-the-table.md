---
name: "Frozen World's map 2: route graphic changes past the ROM's table of 8"
description: "Map 2 (\"Plate Placement\") builds since its code stays in the cartridge, with 20 warnings: a route changes an event's graphic to one the ROM's table of 8 has no room for, and the change is ignored"
type: bug
status: todo
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
