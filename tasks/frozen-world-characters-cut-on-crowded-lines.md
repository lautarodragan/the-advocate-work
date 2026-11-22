---
name: "The Frozen World: characters cut on crowded lines"
description: "1 map put more characters on a line than the console draws —nine characters are 36 slivers, past the PPU's 34—, and the ones further back lose columns or vanish"
type: bug
status: todo
author: mulita
game: frozen-world
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

* map 128: 11 characters and 44 slivers on cell row 12 (events 14, 15, 16, 17, 18, 19, 20, 21 Shopkeeper Stalls, 22 Shopkeeper Stalls, 23, 24); at the entrance too

How to reproduce: `just objects-per-line frozen-world` at the root of the ports,
which prints each map's worst lines and the camera X that shows them; the
full report of that day, with captures of a few maps in both cores, is in
`/shared/captures/2026-11-17-objects-per-line/`. Playing, the debug
screen's last page counts the map's frames in `Time over`.

What the report cannot say: whether a line is one the player sees with
everyone on it —a page another switch turns off, people a first scene
sends away—, and what a scene adds later.

## Log

### 2026-11-22, Chajá: still so, and `baked_events` on map 128 fixes it

Measured with `just objects-per-line frozen-world` in a worktree of the
ports at `89f77b4`, with the global tools (the-advocate `0ae40e0a`): map
128 is still the only one over, 11 characters and 44 slivers on cell row
12 at camera x 0 (events 14-20, 21 and 22 Shopkeeper Stalls, 23, 24), and
at the entrance too. Maps 1, 2, 3, 4 and 7 are not counted: the jump
does not arrive.

**What they are**, from the dump: of the 20 drawn, sixteen —8 to 20, 23,
24, 27— are a ChipSet tile (tile 108) on the hero's layer, still, with an
action page of three commands: the stalls' goods. The other four are the
shopkeepers, 7, 21, 22 and 25, CharSets with long action pages.

**No patch of the game's data is needed**: the generic `[graphics]
baked_events` takes them. With `baked_events = [128]` in the game's
`advocate.toml` (only in my worktree, not committed), the converter says
"16 still event(s) drawn into the background, a block per pose: 8, 9, 10,
11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 23, 24, 27", keeps 7, 21 and 25 as
objects because they turn toward the hero and 22 because someone can
stand behind what it draws past its cell, and `just objects-per-line
frozen-world` finds no map over. `painted_events` would not do: it
refuses ChipSet tiles, and the map has no panorama of its own.

**Done** is that line in Frozen World's `advocate.toml` —or `true`, which
asks for every map and needs the game's suite and a look at every map
it changes—, the game's `just boot` green, map 128 looked at against the
original (a baked stall is under every character, an object was over
the ones behind it), and the Known issues line of the book's Frozen World
page removed. Not done here: no ROM was looked at and no test was run
with the change. To `todo`.
