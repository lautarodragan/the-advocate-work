---
name: "ABL: Lazer Teeth's rock lags"
description: "In the Lazer Teeth mini-game on map 11, while the rock flies and when it hits a lamp or a computer, Mesen counts ~35 lag frames: frames the main loop missed"
type: bug
status: doing
assignee: Aguará
agents: [Aguará]
---

taro, on 2026-11-17, playing ABL's build on Mesen, translated:

> In ABL, in the Lazer Teeth mini-game (map 11), while the rock flies and
> on impact with a lamp or a computer, Mesen registers ~35 frames of lag.

Mesen counts a frame as lag when the game does not read the pad in it:
with the runtime reading it once per tick from the main loop, these are
ticks that took longer than a frame —real lag, unlike
[`abl-the-equip-screen-s-cursor-runs-ahead-of-its-lists`](abl-the-equip-screen-s-cursor-runs-ahead-of-its-lists.md)'s,
which Mesen does not see—. Map 11 has 84 events (lights, sentries, the
puzzle's blocks and stones).

Done means: the scene reproduced in the harness; lag frames counted the
way Mesen counts them (ticks over a frame), during the flight and at each
kind of impact; what eats the frame —the event interpreter, routes, the
events' drawing, a page refresh, an upload, a sound—; the lag reduced or
removed, with a ROM test that holds the count; the same measured against
RPG_RT's behaviour where it matters (the original does not lag, so any
frame the port loses is ours).

## Log

* 2026-11-17, Aguará: taken from the-advocate `865163eb`, the ports
  `8042dc8`; branches `aguara-lazer-teeth`. The scene is already in the
  harness: `tests/harness/stones.py` gives Talan the stones and
  `tests/abl/test_stones.py` throws one at the PC. Lag is counted as
  hardware frames minus main-loop ticks —the loop reads the pad once per
  tick, so it is Mesen's count—.

### Before (the-advocate `865163eb`, snes9x through the harness)

A throw from the fence's engine (`stones.talk_to_the_fence`, then A and a
direction from a cell under the target), 110 ticks from the direction's
press —flight, impact, the animation and the engine's round—. Lag frames
per throw:

    target, from                   lost   where
    Light5 (22,43), from (22,48)      8   5 in the animation, 2 at the hit's page and its refresh, 1 at the end of the round
    LTComputer (19,44), (19,52)       5   2 in the animation, 2 at the end of the round, 1 at switch 45's refresh
    Light4 (15,42), (15,48)          14   10 in the animation, 3 at the hit's page and its refresh, 1 at the end of the round

The flight itself, before the hit, loses nothing; the stone keeps flying
while the animation plays, which is the "while the rock flies" seen. With
a line profiler (not committed: a mark at each boundary of the main loop
reads the PPU's vertical counter), the frame on map 11 with the stone in
the air, out of 262 lines:

    build_oam            83-90   ~30 events on screen, the cones
    parallel_tick        65-69   twelve parallel pages
    the rest             ~50
    idle                 ~60

and the battle animation on the lamp —"Hit A", 15 frames, with a flash
of the target on frames 2, 7 and 12, 10 frames each— adds:

    the target's flash   ~44 every tick for 33 ticks
    the frame's drawing  13-72 every other tick: LZ2 5-43, clear and copy 3-19
    its DMA in vblank    ~14 every other tick
    its four objects      ~7

The hit's page —11 `ChangeEventLocation` that take a cone off and a
switch— is 380-600 lines in one tick (~50 per event: `fit_far` shifts the
NPC table with `mvp` for each one), and the switch's refresh ~155 the next.

### 1. The lights' pages take the `parallel_cell` shortcut

Nine of map 11's parallels (`Light1-4,6`, `TheIdol`, `LTSentry1/2`,
`LTComputer`) and some forty more pages in ABL write **their own** cell
into two variables before the fused cell test, so they started with two
`OP_VAR` and paid the whole interpreter every frame. The compiler now
fuses those two into an `OP_CELL_TEST` of their own whose comparisons hold
by construction (`cell_own_piece`), and `parallel_cell` runs a chain of
them. No new opcode —Hornero offered 0x59; a lone 0x59 leaves a gap that
does not compile before Chajá's and Tijereta's merge—. `parallel_tick`
65-69 → 44-47 lines. Lag per throw: Light5 8 → 4, PC 5 → 2, Light4 14 → 7.

### 2. A character's flash without saturation, without the tables

`palette_with_flash` built the three channel tables (96 entries), ran the
palette through them and put the tint-only ones back on every frame of a
flash: ~44 lines, 33 ticks per "Hit A". Without saturation —every flash in
ABL— `flash_direct`, in bank 1, does the same arithmetic only for the 48
channels of the sixteen colors, with the multiplier and the divider:
~32 lines with everything around it. Checked byte for byte: the flash
palettes (`FAR_FLASH_PAL` and `pal_buf`) of the three throws, tick by
tick, are the same as before. Lag per throw: Light5 4 → 3, PC 2, Light4 7.

### After (the-advocate `aguara-lazer-teeth`)

    target, from                   before   after   what is left
    Light5 (22,43), from (22,48)      8       3     the hit's page, switch 44's refresh, the round's refresh
    LTComputer (19,44), (19,52)       5       2     the round's refresh, switch 45's refresh
    Light4 (15,42), (15,48)          14       7     3 in the animation, 2 at the hit's page, 2 refreshes

The flight loses nothing, before and after. ROM tests, in the ports'
`tests/abl/test_stones.py`: `test_a_stone_flies_without_losing_frames`
(the control: 0 to the lamp), `test_a_stone_at_a_lamp_loses_few_frames`
(ceiling 8) and `test_a_stone_at_the_pc_loses_few_frames` (ceiling 3).
Red with the global tools at `865163eb`: 14 and 5.

What was not done, measured:

* **The animation's frame**: LZ2 5-43 lines and clear-and-copy 3-21,
  every other tick. Moving the decompression to the frame's other tick
  does not fit: that tick already has the DMA of the frame (~14) and
  only 3-30 lines spare.
* **The hit's page**, 380-600 lines: draft
  [`change-event-location-shifts-the-npc-table-per-event`](change-event-location-shifts-the-npc-table-per-event.md).
* **The refreshes**, ~155 lines on map 11: one frame each. Added to the
  draft [`a-refresh-costs-frames-on-maps-of-many-pages`](a-refresh-costs-frames-on-maps-of-many-pages.md).
* **`build_oam`**, 83-93 lines with the cones on screen: draft
  [`build-oam-costs-a-third-of-the-frame-on-busy-maps`](build-oam-costs-a-third-of-the-frame-on-busy-maps.md).
* Not compared against RPG_RT running: the task's premise —the original
  does not lag there— is taro's, and every frame counted here is the
  port's.
