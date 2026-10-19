---
name: "The Book of Three: a night's rest in a scene has no fade or music"
description: "The game uses ShowInn as the night passing in several scenes; the port heals on the spot, without the inn's fade to black and its jingle"
type: bug
status: doing
assignee: Tijereta
agents: [Tijereta]
---

Seen by Mulita on 2026-10-15, comparing the port with the original under
Wine, with the-advocate `fa9d1a14` (and `362d3765` for
`degradations.json`) and the ports `0ca371b`, in The Book of Three.

**What is seen**: besides the village inn (map 15), the game calls
`ShowInn` at price 0 as "the night passes" or a free rest: inside scenes
—Gwydion's camp (map 17), the cell in Spiral Castle (32), Medwyn's house
(80), map 63—, at the free resting places of maps 20, 24 (two abandoned
buildings), 41, 53 and 62, and in common event 10. In the original
the screen fades to black with the inn's music and comes back; in the port
the party is healed at once and the scene goes on.

**What the build says**: `degradations.json` lists the twelve as
`inn-not-staged`, "the inn heals on the spot, without the fade to black or
its music".

**How to see it**: the ports' case `milestone-campfire` —its scene ends
with one—, or `milestone-guard`.

## Defined

Wishlist, on 2026-10-16, by Cardón: at the-advocate `f4709d0b` `compile_inn` heals on the
spot for every inn, of every game, and says so as `inn-not-staged`; the
scenes go on, only without their fade.

**Done** means `ShowInn` fades to black with the System's inn music and
comes back, at price 0 too, as RM2k's `Scene_Map::CallInn`, and the loss
goes for both prices or only the free one; a golden of
`milestone-campfire`'s end. **First step**: how the runtime does a fade
and a song from a page today (`TintScreen`, `PlayBGM`), to stage it with
them.
