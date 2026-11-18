---
name: "Desert Nightmare: characters cut on crowded lines"
description: "53 maps put more characters on a line than the console draws —nine characters are 36 slivers, past the PPU's 34—, and the ones further back lose columns or vanish"
type: bug
status: draft
---

Seen by Mulita on 2026-11-17 with the ports' `just objects-per-line`, at
the-advocate `7dab7d82` and the ports `e87e936` (branch
`mulita-objects-per-line`), from
[`maps-with-more-objects-on-a-line-than-the-ppu-draws`](maps-with-more-objects-on-a-line-than-the-ppu-draws.md).

The console fetches at most 34 slivers of 8 pixels per line; every
character is a 32x32 object, four slivers, so **nine characters on a line
go over** and the ones with the highest OAM index —the ones further back—
are cut, a column or whole. The worst line of each map, under the camera
that shows the most, on a new game with every switch off, after entering
with a teleport:

* map 3: 23 characters and 92 slivers on cell row 9 (events 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 90, 100, 101); at the entrance too
* map 5: 20 characters and 76 slivers on cell row 6 (events 1, 2, 10, 11, 12, 13, 14, 15, 16, 38, 39, 40, 41, 42, 43, 44, 45, 109, 110, 111); at the entrance too
* map 62: 20 characters and 76 slivers on cell row 6 (events 1, 2, 9, 10, 11, 12, 13, 14, 15, 37, 38, 39, 40, 41, 42, 43, 44, 108, 109, 110); at the entrance too
* map 12: 19 characters and 75 slivers on cell row 3 (events 36, 37, 38, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 77, 78, 79, 80); at the entrance too
* map 64: 19 characters and 75 slivers on cell row 3 (events 36, 37, 38, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 77, 78, 79, 80); at the entrance too
* map 2: 19 characters and 70 slivers on cell row 6 (events 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 57, 58, 59, 92, 93, 94, 95)
* map 59: 19 characters and 70 slivers on cell row 6 (events 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 57, 58, 59, 96, 97, 100, 101)
* map 14: 18 characters and 69 slivers on cell row 6 (events 14, 15, 16, 17, 18, 19, 20, 21, 22, 90, 91, 92, 93, 94, 95, 96, 114, 115); at the entrance too
* map 66: 18 characters and 69 slivers on cell row 6 (events 14, 15, 16, 17, 18, 19, 20, 21, 22, 90, 91, 92, 93, 94, 95, 96, 115, 116); at the entrance too
* map 60: 17 characters and 68 slivers on cell row 7 (events 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 77, 78, 79, 80, 89, 98, 102); at the entrance too
* map 41: 17 characters and 67 slivers on cell row 10 (events 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 Tür, 17, 18, 19, 20); at the entrance too
* map 72: 17 characters and 67 slivers on cell row 10 (events 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 Tür, 17, 18, 19, 20); at the entrance too
* and 41 more, in the report

Many of these "characters" are roofs and walls the game draws
with events —see
[`desert-nightmare-roofs-left-out-show-white`](desert-nightmare-roofs-left-out-show-white.md)—:
a ChipSet tile as an event is still a 32x32 object here, four slivers for
16 pixels.

How to reproduce: `just objects-per-line desert-nightmare` at the root of the ports,
which prints each map's worst lines and the camera X that shows them; the
full report of that day, with captures of a few maps in both cores, is in
`/shared/captures/2026-11-17-objects-per-line/`. Playing, the debug
screen's last page counts the map's frames in `Time over`.

What the report cannot say: whether a line is one the player sees with
everyone on it —a page another switch turns off, people a first scene
sends away—, and what a scene adds later.
