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

## Work

Tijereta, from 2026-10-19, at the-advocate `9592b88b` and the ports
`c420032`; branches `tijereta-inns` in the-advocate, the ports and the
book.

**How the runtime fades and plays from a page today**: `OP_ERASE_SCREEN`
and `OP_SHOW_SCREEN` are the teleport's brightness fade cut in half, with
the world frozen while they go (`fade_tick` returns nonzero); `OP_FADE_BGM`
lowers the song without blocking; `OP_BGM` plays a `Songs` index at a
level. What is missing for `CallInn` is two things the bytecode cannot
say: **the song that was playing before**, which `CallInn` keeps apart
(`music_before_inn`, not the memorized one), and **waiting for the jingle
to play once** —`BGM_PlayedOnce`, or ten seconds— with the world frozen.

**Plan**: `ShowInn` stages as RM2k's `Scene_Map::CallInn`, built from the
opcodes above plus `OP_INN` (0x3B, the one handed out), with a phase
operand: 0 notes the song playing and its level, 1 freezes the world until
the song playing has come round once (or ten seconds) and stops it, 2 puts
the noted song back from the top. The page emits:

    OP_INN 0, OP_FADE_BGM (800 ms), OP_ERASE_SCREEN (the fade),
    [OP_BGM the System's inn music, OP_INN 1], OP_HEAL,
    OP_INN 2, OP_SHOW_SCREEN (the fade)

with the bracket left out when the inn music is `(OFF)` —ABL's, Desert
Nightmare's and Sunset's—, which is `StartInn` going straight to
`FinishInn`.
