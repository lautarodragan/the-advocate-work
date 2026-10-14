---
name: "ABL: the slot screen has no room for the last leaders' names"
description: "With every map of ABL, the leaders' names the slot screen composes ask for 48 tiles and the menu's bank leaves 44: rm2k-snes-screens stops the cartridge"
type: bug
status: draft
---

Seen by Cardón on 2026-10-14, with the-advocate `a7f278e6` and the ports
`6a9d53c`, in ABL, building a cartridge with every map of the game: see
[`abl-release-stops-at-the-first-night`](abl-release-stops-at-the-first-night.md).

**What is seen**: `rm2k-snes-screens` stops with "the menu's bank has no
room for the composed names, even with the slot screen's text last: the
menu shows 326 tiles and leaves 122 free up to its tilemap, and its names
can ask for 100: 70 the party's and 30 a medicine's; the slot screen shows
403 and leaves 44, and its leaders can ask for 48". The check is
`strips_fit` in `rm2k-snes/screens/src/convert.rs`, which reserves four
slots times the widest leader. The actors that join in the last chapter and
the ending —Royal Dalia (30), the Advocate (31), "ABL 2.0 Save" (34)— are
the ones the build also warns as cut in the slot screen.

It is point 4 of `degrade-instead-of-failing.md` —"the names that don't fit
in the menu's bank"—, which was left undone; the Dooms 2 draft
[`dooms-2-slots-and-menu-dont-fit-in-their-bank`](dooms-2-slots-and-menu-dont-fit-in-their-bank.md)
is the bank itself, another stop of the same screen.

**How to see it**: a cartridge with every map of ABL, and the converter's
output.
