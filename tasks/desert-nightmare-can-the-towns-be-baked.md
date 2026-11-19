---
name: "Desert Nightmare: can the towns be baked?"
description: "A feasibility study, map by map: whether the hundreds of still events that make Desert Nightmare's towns can be drawn into the background generically, what each rule that rejects them protects, and what does not fit the console's VRAM and CGRAM"
type: research
status: doing
assignee: Cardón
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
