---
name: "An event in a bush is drawn whole"
description: "Only the hero's feet are half transparent in a bush; an event standing on a bush terrain is drawn opaque"
type: bug
status: draft
assignee: taro
author: aguara
agents: [Aguará, cardon]
links:
  found-in: [terrains-encounter-rates-and-bushes]
---

Found by Aguará on 2026-11-01, doing
[`terrains-encounter-rates-and-bushes`](terrains-encounter-rates-and-bushes.md),
with the-advocate `e1627246`.

**What it is**: RM2k draws the lower part of **any** character on a bush
terrain half transparent —`Game_Character::GetBushDepth`, for one on the
hero's layer that is not jumping—. The console does it only for the hero:
`bush_oam` in `runtime/terrain_steps.s` is called from `place_hero`. An
event standing or walking on a bush cell is drawn whole.

**What it would take**: each event's cell terrain, which the ROM does not
look up today —`hero_terrain` is the hero's—, and four or eight more
objects per event in a bush, in a palette of 4 to 7 with a copy of its own;
two events in two palettes need two copies.

**Not seen while playing**: it was read in the code, not looked for in a
game.

## Log

### 2026-11-24, Cardón: a question for taro

Still so at the-advocate `8b069fc2`: `bush_oam`
(`runtime/terrain_steps.s:263`) is called only from the hero's placement
in `runtime/oam.s:1025`. Towards RM2k, but at a cost to choose: four to
eight more objects per event in a bush and a sprite palette copy per event
palette, from the same 4-7 range that
[`a-bush-on-a-map-with-more-than-four-character-palettes`](a-bush-on-a-map-with-more-than-four-character-palettes.md)
already finds short.

**Options**: (a) `todo`, every event on a bush; (b) only events walking a
route (the visible case), within the palettes' budget; (c) `wishlist`, a
declared divergence until a game shows it.

**Recommendation**: (c): read in the code, not seen in any port, and it
competes for the objects and palettes the crowded-lines drafts already
lack.
