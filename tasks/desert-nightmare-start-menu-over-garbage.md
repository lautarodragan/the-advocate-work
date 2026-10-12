---
name: "Desert Nightmare: the start menu over garbage"
description: "Map 1's menu ('With Intro / No Intro / Quit') shows its three pictures over a repeated 8x8 pattern instead of the Introauswahl panorama; not EraseScreen"
type: bug
status: draft
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

What the converter says about it, in `build/release/conversor.log`:

    map 1: its panorama goes mode3
    panorama Introauswahl: mode 3 in VENTANA_PANORAMA, a stretch of 320x240, 576 tiles of 1146 distinct, 76 colors of 256, 973 merged

So it is converted; where it goes wrong —the tiles not uploaded, uploaded
and overwritten by the pictures, or a tilemap pointing elsewhere— was not
looked at. The book's own survey (`research/2026-10-10-otros-juegos-de-nuevo.md`)
already noted "light-blue garbage" there, attributed to a panoramas bug
fixed that day; today the pattern is orange, so either that fix did not
cover this or something else broke it.

**To reproduce**: `just cartuchos` in `desert-nightmare/` of the ports, and
run `build/release/desert-nightmare.sfc`: the title does not fit, so the
menu is the first thing on screen. Captures (before and after the
EraseScreen branch, identical on this screen) in
`~/scratch/calandria/capturas/`, `antes/t00000-…png`.
