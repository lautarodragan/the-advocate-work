---
name: "Sunset over Imdahl: characters cut on crowded lines"
description: "1 map put more characters on a line than the console draws —nine characters are 36 slivers, past the PPU's 34—, and the ones further back lose columns or vanish"
type: bug
status: draft
author: mulita
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

* map 58: 9 characters and 35 slivers on cell row 24 (events 17, 19, 26, 46, 47, 65, 70, 71, 76)

How to reproduce: `tests/objects_per_line.py sunset-over-imdahl` at the root of the ports,
which prints each map's worst lines and the camera X that shows them; the
full report of that day, with captures of a few maps in both cores, is in
`/shared/captures/2026-11-17-objects-per-line/`. Playing, the debug
screen's last page counts the map's frames in `Time over`.

What the report cannot say: whether a line is one the player sees with
everyone on it —a page another switch turns off, people a first scene
sends away—, and what a scene adds later.
