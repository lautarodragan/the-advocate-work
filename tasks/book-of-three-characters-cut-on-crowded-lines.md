---
name: "The Book of Three: characters cut on crowded lines"
description: "1 map put more characters on a line than the console draws —nine characters are 36 slivers, past the PPU's 34—, and the ones further back lose columns or vanish"
type: bug
status: todo
author: mulita
game: book-of-three
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

* map 79: 26 characters and 104 slivers on cell row 11 (events 8, 9, 10, 11 Taran, 12 Isabella, 13, 14, 15, 16, 17, 18 Arden, 19, 20, 21 Saldra, 22, 23, 24, 25 Wick's Girl1, 26 Wick's Girl2, 27 "Wickie", 28, 29 Kersh, 30, 31, 32, 33 AG7-17); at the entrance too

How to reproduce: `just objects-per-line book-of-three` at the root of the ports,
which prints each map's worst lines and the camera X that shows them; the
full report of that day, with captures of a few maps in both cores, is in
`/shared/captures/2026-11-17-objects-per-line/`. Playing, the debug
screen's last page counts the map's frames in `Time over`.

What the report cannot say: whether a line is one the player sees with
everyone on it —a page another switch turns off, people a first scene
sends away—, and what a scene adds later.

## Log

### 2026-11-22, Chajá: still so, and none of the generic paths takes it

Measured with `just objects-per-line book-of-three` in a worktree of the
ports at `89f77b4`, with the global tools (the-advocate `0ae40e0a`): map
79 is still the only one over, the same 26 characters and 104 slivers on
cell rows 11 and 12 at camera x 17, and 25 and 100 at the entrance.

**What the map is**, from the dump: "The Festival Ceremony", 20x15, a
scene the player never walks. Event 6 is an autostart page with no
condition that plays it —42 messages, five `MoveEvent`s, all on event 7,
Gwydion— and ends teleporting to map 67. The crowd is 39 people in three
rows of 13, events 8 to 46, each one page, still, on the hero's layer,
facing up; 38 have no commands, and 43, The Director, has an action page
of three, so it turns toward the hero. Nobody names any of them.

**Tried, each alone, in my worktree and not committed**:

* `painted_events = [79]`: nothing painted, "it shows no panorama of
  its own": `pieces` in Wally takes only a map drawn as its panorama.
* `baked_events = [79]`: 43 events stay objects, "someone can stand
  behind what it draws past its cell" —a person is drawn past its 16x16
  cell, onto the row above, where the hero can stand as far as the
  converter knows—; 7 because a route moves it, 43 because it turns.
  Still 26 objects on the line.
* `baked_events = [79]` with the 38 empty ones put below the hero in the
  dump (what a patch of the game's data could do): the converter takes
  them by position but refuses them all the same, "drawn into the
  background they move its colours or its tiles past the layouts". 38
  people with 36 graphics drawn with someone else's palette do not fit
  BG1's colours or tiles. Still 25 objects at the entrance.
* `decorative_events` does not apply: it takes only a drawing inside its
  cell.

So **a patch that bakes the crowd into this map does not work** with
today's tools —the limit measured is the background's colours and tiles,
not the patch—, and none of the existing generic switches does either.
What is left, none of it measured:

* **Generic, in the converter**: let `painted_events` paint a map that
  has no panorama of its own, making one from its ChipSet layers and the
  pieces —a painted map carries a tile per cell and uploads them as they
  come into view, so the question is its colours—; together with the
  reach knowing that an unconditioned autostart that ends in a teleport
  leaves the hero no cell to stand on.
* **Generic, in the runtime**: rotate which objects go first in OAM
  every frame, so that past the 34 slivers a different character is cut
  each frame —flicker, as commercial games do— instead of the same ones
  always.
* **Game-specific**: a patch that thins the crowd. taro's call.

To `todo`: it applies, and whoever takes it chooses among those.
