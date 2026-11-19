---
name: "Desert Nightmare: can the towns be baked?"
description: "A feasibility study, map by map: whether the hundreds of still events that make Desert Nightmare's towns can be drawn into the background generically, what each rule that rejects them protects, and what does not fit the console's VRAM and CGRAM"
type: research
status: testing
assignee: taro
agents: [Cardón]
game: desert-nightmare
---

From [`desert-nightmare-what-it-takes-to-be-playable`](desert-nightmare-what-it-takes-to-be-playable.md)
(Hurón, 2026-11-19, the book's
`ports/desert-nightmare/research/2026-11-19-what-it-takes-to-be-playable.md`):
the towns are hundreds of 24x32 events; drawing them halves the speed on 18
maps and leaves buildings out or white rectangles on 34; the current bakes
take almost none (`decorative_events`: 434 of 436 rejected for moving the
CGRAM split; `baked_events = true` on a throwaway build: 32 events on 4
maps, no town). Baking those with one appearance would leave no map with
more than 16 drawn events.

taro, translated:

> What interests me most of all this, now, is number 6, because it may turn
> out impossible, and it would make the game unplayable even if we solve
> everything else —and everything else does have a solution. Should I start
> with a deep analysis? A plan? See whether we can offer a generic
> solution, or whether there is no choice but to modify the game heavily to
> run it on the SNES?

And, to a feasibility study before a plan: "dale".

**Questions**:

1. What the pieces are: one appearance always, or pages that change by
   switch (doors, day/night), routes, moves. Which can bake plainly and
   which need the posed mechanism.
2. Why each is rejected today —the CGRAM split, poses past the cell, a
   panorama with holes, others— and whether each rule protects something
   real here or is conservative.
3. Whether it fits: with a throwaway prototype that forces the bake,
   per map, the background tiles and blocks needed against VRAM and the
   block budget, and the colours against CGRAM; what does not fit, and by
   how much.
4. For what does not fit: how much of the game would have to change
   (patches like map 13's fork in ABL), map by map.

**Done means**: a research page in the book, under the port, dated, with
the commits measured: a table of the 189 maps —fits generically / fits
with rule X relaxed / does not fit, short by N—, and the recommendation:
a converter feature (and which), patches, or a redesign. No fix; the
prototype stays throwaway.

## Log

**2026-11-19, Cardón.** Worktrees `cardon-dn-towns` at the-advocate
`62b6e5cb` and the ports `1ea90bf`, under `~/scratch/cardon/dn-adv` and
`dn-ports`. First: the release built with `baked_events = true` (global
tools) for the per-map reasons the converter gives today, and a
classification of every drawn event from the dump.

**Findings so far.** 161 of the 189 maps have a panorama fixed to the map
(the size of the map, or one screen): the game is a painting with pieces
on it. With `baked_events = true` the reasons the converter gives, summed
over events: 572 "someone can stand behind what it draws past its cell",
434 decorative ones refused for the CGRAM split (the panorama baked into
the background already merges colours, and the rule takes no decoration
over a ground that merges), 194 "drawn past its cell and can go away"
(the pages call common events 2 and 3, the message box, and no common
event of the game erases), 109 "the panorama shows through", 81 "above
the hero"; and posed never runs on the 111 maps whose panorama goes
baked nor on the 7 in mode 1.

Prototype (`cardon-dn-towns` in the-advocate, `rm2k-snes/wally/src/town.rs`,
never to merge): every still one-look event painted into the fixed
panorama, its row dropped, what goes over a character into the front
mask, and the ChipSet's layers folded in, so the map goes painted. All
189: 135 go painted, and **the cartridge does not link: painted maps carry
every 8x8 cell, 85 banks of them**; only 50,480 of their 174,516 cells are
distinct (25 banks). Next: the 28 maps with 30 or more drawn events only,
to measure on the console.

**The 28 towns on the console** (the maps with 30 or more drawn events
and a fixed panorama, prototype on them only): the cartridge links, 100
data banks against 91; frames per tick 1.0 on all 18 slow maps (1.13 on
12, 1.07 on 172; 35 at 1.56 is its 27 walkers); none of the 28 over the
PPU's line any more. Map 4 still showed white: the RAM's 120-row trim
runs before Wally, so the pieces it leaves out never reach the bake; the
prototype now paints those too (36 of 40 on map 4, 31 of 31 on 66).

**All 189 relaxed** (log only, the cartridge overflows): 3,014 pieces
painted, 137 maps painted; no map keeps more than 31 drawn events (105
and 48, ChipSet maps with pages), the towns at most 16. Colours: the
painting's mean distance to the composite, 8-bit RGB, 5.5 over the 38
maps without map pictures drawn in (max 10.8), against 7.1 for today's
panoramas alone on the 24 comparable ones. BG2's 128 tiles for the roofs'
edges: 156 pixels on the wrong side of the hero on map 172, 0 elsewhere.

**The rest, and the answer (2026-11-19, Cardón).** The 27 other maps that
went over the line on 2026-11-17, baked on their own cartridge: only map
44 still goes over (36 slivers: eight events drawn with a ChipSet tile,
which the prototype leaves alone). The 55 together: 115 banks, the
cartridge links, only 35 and 44 over. The table of the 189: 133 fine
today, 48 fit with the bake and rules relaxed, 8 short by 1 to 12 sprite
slots or a line (35, the exit's walking crowd, is the only one a patch
would help). Written up in the book:
`ports/desert-nightmare/research/2026-11-19-can-the-towns-be-baked.md`.

Recommendation, in short: a converter feature —the still pieces painted
into a panorama fixed to the map, the ChipSet folded in, the front for
what RM2k draws over a character—, the bake before the RAM's trim, a
`CallEvent` not counting as an erase unless what it reaches erases, and,
to paint every map and not only the 55 that need it, the painted cells
stored once. No patches but map 35; no redesign.

Drafts: [`painted-maps-carry-every-cell`](painted-maps-carry-every-cell.md),
[`a-call-counts-as-erasing-a-still-event`](a-call-counts-as-erasing-a-still-event.md),
and a section added to
[`desert-nightmare-roofs-left-out-show-white`](desert-nightmare-roofs-left-out-show-white.md)
(the trim runs before any bake).

Captures: `/shared/captures/2026-11-19-dn-towns/` —EasyRPG, the port
today and the prototype on maps 2, 3, 4, 5, 14 and 62, and every map
played with the prototype—.

**Branches**: the book, `cardon-dn-towns` (the page and SUMMARY.md), to
merge. the-advocate, `cardon-dn-towns` at `cb45d5a4`: **the throwaway
prototype, not to be merged**; it is there so the numbers can be redone.
The ports: none (only `advocate.toml` was changed to measure, and put
back). Nothing to install.
