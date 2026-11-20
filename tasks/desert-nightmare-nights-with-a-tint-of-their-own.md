---
name: "Desert Nightmare: nights with a tint of their own"
description: "The night maps (59, 61, 62, 66…) show as day on the console: their night is two full-map pictures. Patches that make the night an RM2k tint, and a study of how to light it within the console's limits"
type: feature
status: doing
assignee: Hurón
agents: [Hurón]
game: desert-nightmare
---

taro, on 2026-11-19, looking at the captures of
[`still-pieces-painted-into-a-painted-map`](still-pieces-painted-into-a-painted-map.md)
(`/shared/captures/2026-11-19-dn-painted-pieces/`), translated:

> The map002 screenshot, for example: the before and after are much
> brighter than EasyRPG's. I see the same in 59, 61, 62, 66. In the map002
> capture in particular there is no light source.
>
> Anyway, if it is not a tint per se but an image, I prefer using map
> patches to use a normal RPG Maker tint, and analyse how we can solve the
> lights creatively, with their acceptable limitations.

**What Hornero saw** (the dump at the ports `aa850b4`): maps 59, 61, 62 and
66 are the night versions of the town. A parallel page (`EV0136` on 59,
`EV0143` on 62, `EV0166` on 66, `EV0188`/`EV0191` on 61) shows two
full-map pictures: `Lichteffekt_*_Nacht` at transparency 20 and
`Nacht_*` at transparency 0. On the console those maps look like day:
EasyRPG's 59 is the night street with lamps lit, ours the day street. That
was so before the painting too. Map 2 has no night pictures: its autostart
does a `TintScreen` to black and back to 100 in 3 s; EasyRPG's capture is
darker and greyer, and the harness's jump clears the tint (Hurón's study),
so map 2 may be a capture artefact or a tint from a common event: measure
it.

**What**:
1. Why the night pictures are not drawn (map pictures on a painted map,
   pages behind conditions, the "one shown most" rule…), and map 2's
   difference.
2. Patches of the night maps (`patches/manual/`, like ABL's map 13 and
   105 forks) that replace the night pictures with an RM2k `TintScreen`
   matching `Nacht_*` as closely as a tint can (measure it at 15 bits),
   kept as a patch of the game's data, not a converter rule.
3. A study of the lights, creatively and within the console's limits:
   lamps' cones and lit windows over a tinted night —baked into the
   painting as lit cells that the tint does not reach, sprites, colour
   math on BG2, per-map or per-cell character shading—, each measured
   against RPG_RT/EasyRPG, with what it costs. Then a recommendation.
