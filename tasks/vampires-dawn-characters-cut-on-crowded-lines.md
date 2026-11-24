---
name: "Vampires Dawn: characters cut on crowded lines"
description: "58 maps put more characters on a line than the console draws —nine characters are 36 slivers, past the PPU's 34—, and the ones further back lose columns or vanish"
type: bug
status: todo
author: mulita
agents: [cardon]
links:
  found-in: [maps-with-more-objects-on-a-line-than-the-ppu-draws]
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

Maps 347, 429, 341 also go over by **objects** —more than 32 on a line—, not
only by slivers.

* map 347: 34 characters and 122 slivers on cell row 48 (events 9, 10, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48); at the entrance too
* map 429: 43 characters and 122 slivers on cell row 11 (events 6, 7, 10, 11, 12, 13, 14, 15, 18, 19, 20, 21, 27, 28, 29, 30, 32, 34, 35, 36, 40, 41, 42, 43, 44, 47, 49, 50, 61, 62, 65, 66, 67, 68, 81, 82, 83, 84, 85, 86, 87, 92, 93)
* map 341: 38 characters and 120 slivers on cell row 0 (events 4, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 103)
* map 350: 27 characters and 102 slivers on cell row 14 (events 13, 14, 15, 22, 23, 24, 25, 26, 27, 28, 29, 31, 32, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50); at the entrance too
* map 228: 28 characters and 100 slivers on cell row 42 (events 34, 35, 36, 37, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 58, 59, 60, 61, 62, 63, 64, 65, 81, 82, 83, 84)
* map 372: 20 characters and 74 slivers on cell row 38 (events 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 51)
* map 216: 19 characters and 72 slivers on cell row 1 (events 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44)
* map 332: 19 characters and 72 slivers on cell row 0 (events 4, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70)
* map 334: 19 characters and 72 slivers on cell row 0 (events 31, 32, 33, 34, 35, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63); at the entrance too
* map 396: 19 characters and 72 slivers on cell row 0 (events 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60)
* map 56: 18 characters and 68 slivers on cell row 0 (events 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41); at the entrance too
* map 59: 18 characters and 68 slivers on cell row 0 (events 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 25, 26, 27, 28, 29, 30, 31)
* and 46 more, in the report

How to reproduce: `tests/objects_per_line.py vampires-dawn` at the root of the ports,
which prints each map's worst lines and the camera X that shows them; the
full report of that day, with captures of a few maps in both cores, is in
`/shared/captures/2026-11-17-objects-per-line/`. Playing, the debug
screen's last page counts the map's frames in `Time over`.

What the report cannot say: whether a line is one the player sees with
everyone on it —a page another switch turns off, people a first scene
sends away—, and what a scene adds later.

## Log

### 2026-11-24, Cardón: to todo

Measured by the sweep (`just objects-per-line`); its siblings went to
`todo` the same way —[ABL's](abl-characters-cut-on-crowded-lines.md),
[Book of Three's](book-of-three-characters-cut-on-crowded-lines.md),
[Desert Nightmare's](desert-nightmare-characters-cut-on-crowded-lines.md)—
and taro set the way on 2026-11-22: no flicker, the converter's ways first
(`baked_events`, `painted_events`, the reach), a game's patch only when
those do not reach, and that patch is their call. The first step is
re-running the sweep at today's main.
