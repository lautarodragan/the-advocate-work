---
name: "Desert Nightmare: the start menu over garbage"
description: "Map 1's menu ('With Intro / No Intro / Quit') shows its three pictures over a repeated 8x8 pattern instead of the Introauswahl panorama; not EraseScreen"
type: bug
status: todo
agents: [Calandria]
---

Seen by Calandria on 2026-10-11, at the-advocate `0bf46fb1` and the ports
`0405d08`, with the global tools and with those of
`calandria-erasescreen`: the same picture on both.

**What is seen**: from the first tick of map 1 —the cartridge starts there,
`start_map = 1`— the three option pictures (`Introauswahl_1` to `_3`, by
`ShowPicture`) are drawn right, and everything behind them is a small
orange pattern repeated every 8 pixels, like font tiles. In the original
the background is the panorama `Introauswahl`, 320x240, a burning face
(`rm2k-render layers --map 1` gives a lower layer all transparent: what is
seen is the panorama alone).

**It is not `EraseScreen`**, which is what Known issues blamed it on: map
1's menu pages (0 and 1) have no `EraseScreen`; the ones that leave (2
and 3) do, and with `erasescreen-and-showscreen` they now fade to black,
but the menu itself is unchanged.

What the converter says about it, in `build/release/converter.log`:

    map 1: its panorama goes mode3
    panorama Introauswahl: mode 3 in VENTANA_PANORAMA, a stretch of 320x240, 576 tiles of 1146 distinct, 76 colors of 256, 973 merged

So it is converted; where it goes wrong —the tiles not uploaded, uploaded
and overwritten by the pictures, or a tilemap pointing elsewhere— was not
looked at. The book's own survey ([`research/2026-10-10-other-games-measured-again.md`](https://lautarodragan.github.io/the-advocate-docs/research/2026-10-10-other-games-measured-again.html))
already noted "light-blue garbage" there, attributed to a panoramas bug
fixed that day; today the pattern is orange, so either that fix did not
cover this or something else broke it.

**To reproduce**: `just cartridges` in `desert-nightmare/` of the ports, and
run `build/release/desert-nightmare.sfc`: the title does not fit, so the
menu is the first thing on screen. Captures (before and after the
EraseScreen branch, identical on this screen) in
`~/scratch/calandria/capturas/`, `antes/t00000-…png`.

## Defined (2026-10-16, Carpintero)

Still open: nothing on main since touched panoramas or map 1's
pictures. It is the first screen of the game. **Done**: the
`Introauswahl` panorama behind the three pictures on map 1, the same in
snes9x and bsnes, with a golden of that screen in Desert Nightmare's
tests. **First step**: a VRAM viewer on that frame —whether the panorama's
tiles are there, and what BG2's tilemap names—, which says which of the
three suspects above it is.

## Checked (2026-10-20, Chajá): not seen any more

The `release` built that morning (ports `68bf55b`, tools from the-advocate
`8f290c39`), run with a throwaway script over ABL's `emulator/retro.py`,
no MSU-1: the title now fits and comes first ("Begin / Load / Quit" over
the burning face), and after A on "Begin" map 1's three option pictures
are over the `Introauswahl` panorama, **the same in snes9x and in bsnes**;
the repeated orange pattern is gone. Captures in
`/shared/captures/2026-10-20-task-review/`.

Which change fixed it was not traced. The converter's log for map 1 now
says "drawn into the map: 'Introauswahl_1' at 100 %" —a picture baked
into the map instead of shown by the runtime— and the title screen comes
before the first map since `3996ed61` (2026-10-16); either may be it.

What the Done asks for and is missing is the golden of that screen in the
ports' tests (`tests/test_boot.py` already reaches map 16 from it), and the
line in the book's Known issues of Desert Nightmare, which still blames
the garbage.

## taro's decision (2026-10-20)

As Chajá recommended: a small golden of the start menu in the ports'
`tests/test_boot.py`, this task closed and its "Known issues" line removed
from Desert Nightmare's page in the book, all in the same change.
