---
name: "EraseScreen and ShowScreen"
description: "Without a fade opcode that an event can ask for, 698 pages of Desert Nightmare stay out; among them those of the start menu, which hangs because of it. Medium: reuse the teleport's fade"
type: feature
status: done
agents: [Aguará, Calandria]
assignee: taro
---

From Aguará's brief analysis (Sonnet), on 2026-10-05, of what taro saw playing the ROMs of the other games. See also the wishlist las-otras-transiciones-de-rm2k.

Since 2026-10-06 the pages no longer drop: `EraseScreen` and `ShowScreen` are in `ACCEPTED_UNDONE` as a debt (`degrade-instead-of-failing.md`), so the map stays visible where the original stays black, and in Desert Nightmare the start menu of map 1 ("With Intro / No Intro / Quit") comes out over a drawing of VRAM garbage (`/shared/captures/2026-10-10-grupo-vacio/desert-mapa1-sin-heroe.png`). Built on 2026-10-11 (the-advocate `fc6f7456`, ports `a85b7e3`), Desert Nightmare (20 maps) and El Dorado (11) warn about it. When doing it, take them off that list. (Calandria, 2026-10-11.)

## Done (Calandria, 2026-10-11)

Branches `calandria-erasescreen` in the-advocate, the ports and the book.

**What the ROM does now.** Two opcodes, `OP_ERASE_SCREEN` (0x4A) and
`OP_SHOW_SCREEN` (0x4B), with one operand: the transition already
resolved by the converter with the same table as `ChangeScreenTransitions`
—fade, mosaic (17), cut (19 and anything past it)— or $FF for "the
teleport's" (-1), which the ROM reads when it runs. Erasing is the
teleport fade's way down and ends in black; showing is its way up. The
game is frozen while each lasts and the page waits, as in RM2k. The
screen stays black because `brightness` stays at zero, and:

* a teleport over an erased screen goes as the cut and does not show it
  (`Scene_Map::FinishPendingTeleport2`);
* a battle over an erased screen neither flashes nor fades, and the map
  stays black after it;
* the main menu, the save screen and the shop show it again on the way
  back (`Scene_Map::TransitionOut`); the custom menu does not.

Two far RAM bytes, first in the teleport transition's reserved block:
`SCREEN_ERASED = $7E7922` and `SCREEN_FADE = $7E7923`. No new zero page or
low RAM. Both off the `ACCEPTED_UNDONE` list; Desert Nightmare and El
Dorado no longer warn about them.

**Transitions other than fade, mosaic and cut**: they degrade to the fade,
the same as for the teleport. The differences left —ramps of 24 ticks and
not 35 frames, "none" as the cut, the 40-frame wait before a battle over
the black— are in the book, in the teleport transitions divergence.

**Desert Nightmare's start menu still shows over garbage**: that is not
EraseScreen. Map 1's menu pages have none; the garbage is where the
`Introauswahl` panorama should be. Draft:
`desert-nightmare-start-menu-over-garbage`. What did change in Desert
Nightmare: after "With Intro" the screen fades to black and the intro's
first map stays black until its `ShowScreen`, where before the map was in
sight for a second and a half.

**Covered**: `tests/rpgmaker/test_erase_screen.py` in ABL, with three
cases (`screen-erase-and-show`, `screen-erased-and-jump`,
`screen-mosaic`) and three goldens; red with main's tools. And
`erasing_and_showing_the_screen_carry_what_the_rom_does` in the events
crate. **Not covered**: the menus, shop, save screen and battle over an
erased screen (in ABL's `UNTESTED.md`).

**To install when merging**: `events`, `cartridge` and `convert`.

**What taro should play**: Desert Nightmare, "With Intro": the menu fades
to black, and "Somewhere on a highway in the California wild..." fades in
from black without the gas station showing first. El Dorado: wherever a
scene cuts to black (eleven maps), it stays black and comes back with a
fade.

**Measured on the merged tree** (the-advocate `703f2eaf` over main
`b6ac8227`, ports `b9ca083` over `3fd03de`): ABL's suite 1216 passed;
`just boot` of the ports 8 passed before the merge, and Desert
Nightmare, El Dorado and Vampires Dawn again after it; `just test` 27;
the events crate 89. The two far RAM bytes went to `FARBSS` with the
merge: `SCREEN_ERASED` and `SCREEN_FADE`, declared in
`teleport_transition.s`, placed by ld65.
