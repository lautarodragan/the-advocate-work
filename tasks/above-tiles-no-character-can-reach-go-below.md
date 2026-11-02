---
name: "Above tiles no character can reach go below"
description: "A tile marked to be drawn above the hero goes to the layer above (BG2) even where no character can ever stand beside it, like a cave's ceiling; drawn below, the transparent message stops blacking it out and BG2 is freed"
type: feature
status: doing
assignee: Aguará
agents: [Aguará]
---

Follows [`a-transparent-message-blacks-out-tiles-on-its-lines`](a-transparent-message-blacks-out-tiles-on-its-lines.md):
on Zounds' maps 86 and 96 the cave's ceiling is the lower layer's
autotile 4500 (chipset 46's D autotile 10), whose lower passability is
`0x30` —"above the hero"—, so it goes to BG2, which a message without a
background takes on its lines.

taro, on 2026-11-02, in their words, translated:

> ah! and since a charset can take up more than a chipset tile, we need
> it drawn over the sprites, just in case… hmm…
>
> the only option that is cheap in CPU, but expensive in implementation,
> is to detect which of those tiles never overlap an event. On that map,
> it's almost all of them.
>
> in general, if a ceiling tile is marked with that setting, only the
> ones next to a walkable tile matter. If it's impossible to stand next
> to one of those tiles, then they would never share space with a
> sprite, and they don't need to use the SNES's layer 2.
>
> another alternative, simpler: only the "top edge" tiles of an autotile
> use BG2. I think, in practice, that's the case, isn't it?

Hornero picked the first, at conversion time: a 24x32 character standing
on a cell covers that cell, the one above and 4 px into each side, so
only an above tile next to a cell a character can stand on —passable for
the hero, or where an event starts— can ever be under a sprite; the
"top edge" rule misses the sides. Conservative where the analysis cannot
see: a map with events that pass through walls, jump or move freely,
`SetEventLocation` / teleports to cells, tile substitutions that change
passability, keeps today's BG2 for what it cannot prove.

**Done**: wally sends to BG1 the above tiles no character can reach, so
the map looks the same pixel for pixel when nothing overlaps them; on
Zounds' maps 86 and 96 the sign's message no longer blacks out the
ceiling; the goldens that move are looked at; and the inventory of how
many above tiles leave BG2 across the nine games, measured.

## Working notes (Aguará, 2026-11-02)

From the-advocate `0ba09da4`, the-advocate-ports `31fb291`, the book
`4433ad5`; branches `aguara-above-tiles`.

**A route that jumps or walks through walls is everywhere**, so "keep
BG2 on any map that has one" would leave almost nothing: counted over
the nine dumps, every game has `MoveEvent`s with command 24 (begin jump)
or 36 (walk everywhere on) —Zounds' maps 86 and 96 among them, and its
common event 7—, and ABL, El Dorado and Vampires Dawn have
`ChangeEventLocation`s by variables. So those are modelled instead of
refused: each character's possible cells, a fixed point over every route
that can run on the map, as RM2k moves them (easyrpg's
`Game_Map::CheckOrMakeWayEx` and `Game_Character::Jump`: a jump lands
only on a cell passable from some side, and rises at most 16 px —
`GetJumpHeight`—, one row more of footprint). What is left
unprovable makes that character "anywhere" —variables, phasing left on—.

**Where it lives.** The analysis is RM2k's and knows nothing of the
console: `rm2k/rules/src/reach.rs`, `covered`, from the map, its
ChipSet's passability, the commands that can run there and what only the
whole game knows —[`Outside`]: where the hero arrives—. Wally's
background half asks it (`layers::below`) and draws the above tiles of the
cells no sprite can cover into the background (`lower_cells`), over each
drawing of the lower layer; the characters half knows nothing. The
converter gathers the arrivals once per cartridge (`convert/src/reach.rs`)
and sends them as the map request's `reach`; without the key, nothing
changes.

**Three refinements the first try needed**, each measured on Zounds:

* **The page that starts with the hero beside its event.** A door that
  walks the hero through the wall (`[36, 0, 0, 0, 37]`, map 96's events 85,
  86, 94, 95) walked him through every wall, applied again and again: the
  hero was everywhere. A page triggered by the action key or a touch, that
  no `CallEvent` reaches, starts with him beside the event —next to it, or
  two away in a line, the counter—, and its routes on him start there; and
  on "this event" only from the cells where the hero can be beside it.
* **A run of commands, in order.** A `ChangeEventLocation` at the top of
  the page puts the event exactly there before its routes —map 96's Unamë,
  event 81, put at (4, 25) and walked through the wall—.
* **A `RecallToLocation` whose variables the game works out** —ABL: the
  hero's cell five rows up; Zounds' map 2: a map typed in with
  `InputNumber`— puts the hero on any cell one can step on, not anywhere.
  Taken on trust; without it no game but two would keep anything.

**What it cannot prove, measured: map 96.** Its statue (event 83) is
pushed with "walk through walls" on —`[36, 10, 37]`, away from the hero—
only when its own coordinates, copied into variables 52 and 53, say so;
the analysis does not follow variables, so the statue can be pushed
through any wall the hero is beside, and that is every ceiling of the
map. Without the statue it would still free only 187 of 880 cells: the
hero's jump (common event 7, "Saltar") lifts him a row over every cell he
stands on.

**A Blurred Line has no room for it, and so it is a project's choice.**
The first build drew below every unreachable cell, also a roof's edge
over grass: each such pair became an 8-bit background cell of its own,
and ABL's release stopped fitting —"the data does not fit: … the 126
banks the cartridge has for data are taken"—: `rm2k-snes-space` on the
release of `31fb291` says 126 of 126 banks used, 10 KB of gaps. Two
changes: only a cell **over nothing** goes below —what shows through the
tile above is black or the panorama's hole: the background's new cell is
then the tile above alone, and the blocks stay one per tile— which is
also the only place where the window leaves black; and `[graphics]
unreachable_above_below = true` in a game's `advocate.toml` turns it on,
as `painted_maps` does —without it the converter sends Wally no `reach`—.
On in the eight other games, off in ABL with a comment saying why.

**And only if the map loses nothing.** Vampires Dawn's release built with
it lowered cells on 300 maps, spilt 108 KB more into its `.msu` —its
cartridge is full too, and it needs MSU-1 anyway—, and 36 of its maps
merged colours they had not merged (map 112 from 0 to 111, its panorama
baked instead of flattened) and six fused more background cells. So Wally
converts each map both ways and keeps the lowered one only if the
panorama's way, both layers' merged colours and the fused cells are the
same (`lowering_costs` in `wally/src/map.rs`); otherwise its log says
`the tiles above the hero no character can cover stay above: below, …`.
