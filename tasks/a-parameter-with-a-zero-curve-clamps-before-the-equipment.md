---
name: "A parameter with a zero curve is clamped before the equipment is added"
description: "The ROM clamps an actor's attack, defense, spirit and agility to 1 at the level's value and then adds the equipment; RM2k adds first and clamps after. It only shows with a curve of zeros, which no game of the nine has"
type: bug
status: wishlist
---

Seen by Aguará on 2026-10-16 in the test game, with the-advocate
`af7c399d`, while writing the case `actor-stats`
([`zounds-the-intro-on-map-106-waits-for-a-key-nobody-reads`](zounds-the-intro-on-map-106-waits-for-a-key-nobody-reads.md)).

**What happens**: `level_param`, in `runtime/level.s` of the-advocate,
clamps the curve's value to 1..999 —0 for the SP— before anyone adds the
equipment; `eq_parameter` (the equipment screen, the battle through
`ba_param`) and `actor_stat_other` (`ControlVars` from an actor) add each
item's points to that and clamp again. RM2k's `Game_Actor::GetBaseAtk`
adds the equipment to the curve's value and clamps once: with a curve at 0
and a +5 weapon it answers 5, and the ROM answers 6.

**Where it shows**: only when a curve holds a 0, which the editor does not
write —its curves start at 1— and no game of the nine has. The test game's
actors have no curves, so its `actor-stats` case expects the ROM's 6 and
says so.

How to see it: give an actor a curve of zeros and a weapon, and read its
attack with `ControlVars` or on the equipment screen.

## Defined

Wishlist, on 2026-10-16, by Cardón: no game of the nine has a curve with a 0.

**Done** means `level_param` in `runtime/level.s` leaves the curve's value
unclamped and `eq_parameter` and `actor_stat_other` clamp once after the
equipment, as `Game_Actor::GetBaseAtk`, with the test game's
`actor-stats` expecting RM2k's 5. **First step**: who else reads
`level_param` and relies on its clamp.
