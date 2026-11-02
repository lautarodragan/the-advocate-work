---
name: "Zounds' map 96 without its decoy switches"
description: "An experiment: map 96 patched to keep only the switch that opens the door, to measure how much of its lag the 57 decoy switches are"
type: feature
status: doing
assignee: Cardón
agents: [Cardón]
---

Follows [`zounds-map-96-has-too-many-switches-for-the-sprites`](zounds-map-96-has-too-many-switches-for-the-sprites.md),
where Cardón measured 240 frames per 120 ticks —the map runs at half
speed— before and after making the switches share their graphic, with
`build_oam` at about 4 scanlines per row drawn and 40 to 64 objects on
screen; and found that only event 20 opens the door, the other switches
only turn when looked at from above.

taro, on 2026-11-02, in their words, translated:

> I'd like to look at the lag of the Zounds map we already analysed,
> again.
>
> I'd start with the cheapest test: a patch of the map without any of the
> switch events that aren't needed to progress. Only one is needed.

**Done**: a fork of map 96 in Zounds' `patches/manual/maps/` without the
decoys —check first that none of them is read by anything else: a
switch, a variable, another page—; the lag measured with and without, at
the same spots, the same way as before; a ROM taro can play delivered to
`/shared/captures/2026-11-02-zounds-map-96-no-decoys/`. Whether the fork
stays —or the change goes to the game, which is taro's— is taro's call
after measuring; until then it lives on the branch only.
