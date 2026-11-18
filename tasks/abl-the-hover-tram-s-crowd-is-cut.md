---
name: "ABL: the Hover-Tram's crowd is cut"
description: "Map 13 has more characters on a line than the PPU draws; still people could be baked into the background if what they draw outside their cell lands where nobody can stand"
type: feature
status: doing
assignee: Cardón
agents: [Cardón]
game: abl
---

taro, on 2026-11-17, translated (screenshots kept in
`~/scratch/hornero/hover-tram-in-game.png` and `hover-tram-sprites.png`):

> An age-old bug (not a bug, technically): in `Hover-Tram` (map 13), not
> all the characters are drawn because there are too many sprites.
>
> My original plan was a patch of that map that baked the sprites that do
> not move (almost all), but now that we have several optimisations that
> detect things statically, maybe we could build on that and detect this
> at compile time, without a patch.
>
> In that map, event `EV0028` has all the commands. Some NPCs move (they
> get off/on the hover tram) —targets of `EV0028`'s `MoveEvent`s—. They
> seem to be named accordingly: `Leave1`, `Leave2`, etc.; and `Jump1` and
> `Jump2`, which jump.
>
> If we can bake at compile time, it would also be good to deduplicate:
> `EV0020` and `EV0019` are the same graphic —same CharSet + same ChipSet
> tile—. The resulting baked tile should be one for both.
>
> Maybe it's best to tackle it in two stages: one that simply bakes the
> ones that 100% don't move, and then see where that takes us.

**Why they are not baked today** (Hornero, reading `wally` at the-advocate
`7dab7d82`): `posed_events` skips any map with a visible panorama (map 13
has `Evening2`), and `posed::select` takes only poses that fit their
16x16 cell within `baked_events_nudge`; a person is 24x32. The twenty
still ones have one page with no commands, action trigger: with an empty
list RPG_RT does not turn them toward the hero (EasyRPG's
`ScheduleForegroundExecution` returns before facing).

**Stage 1, generic** (this task): a pose may spill out of its cell into
cells **nobody can stand on** —impassable for the hero and for every
event—, so nothing can be behind its head. Not if anything on the map or
in a common event can phase: a route with Phasing On for anyone (the hero
too, by `MoveEvent`), an event page with "through", a `SetEventLocation`
that can land there. And a visible panorama does not exclude the map if
every cell the bake writes is opaque. taro noted, translated:

> True, but the ones in the lower row do not meet that condition… but
> anyway, what you propose is worth it.

and:

> Regarding passability: shouldn't we take into account MoveEvent
> commands that turn phasing on?

So the lower row (y=9), whose heads fall on the aisle, stays out of this
rule. **Measure, don't assume**: how many events bake in ABL and in the
other games, the background tiles and blocks it costs (`just space`), the
sprites left per line on map 13, and whether identical people on
identical floors share their blocks (`EV0019`/`EV0020`). Then say what is
left for map 13's lower row: e.g. the part of a pose drawn over a cell
only walkers *behind* it can reach going to the layer above (BG2, in
front of objects), or stage 2, a patch of the map.
