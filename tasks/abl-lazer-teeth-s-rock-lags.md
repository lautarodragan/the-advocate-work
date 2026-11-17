---
name: "ABL: Lazer Teeth's rock lags"
description: "In the Lazer Teeth mini-game on map 11, while the rock flies and when it hits a lamp or a computer, Mesen counts ~35 lag frames: frames the main loop missed"
type: bug
status: testing
assignee: taro
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

With Chajá's and Calandria's merges the tightest test cartridge
(`test-change-system`) had 18 bytes of bank 0, and the first version of
the flash took 15 of them: the decision moved into `flash_direct`, which
returns with carry at 0 when there is saturation, and `paint_flash` only
calls it first. Six bytes of bank 0, same palettes. And with Hurón's
MSU-1 seek in, bank 1 overflowed in `test-msu`: `flash_direct` went to
`FAR3`, same palettes and same frames lost.

### Verified (merged with main: the-advocate `293721a9`, the ports `d618369`, the book `9a0ca9e`)

With the branch's `project`, `cartridge`, `events` and `convert` installed
locally —`cartridge` too because it carries the bytecode declaration,
which Chajá's OP_ASK changed—:

* ABL's suite: 1673 passed, 2 skipped; no golden moved. The display audit
  and the race's frame budget are in it. The two new tests of Hurón's
  (`test_msu.py`, a save's seek) are red here because the global
  `bsnes_audit` core has no MSU-1 log yet —`just audit-core` builds it—:
  an environment thing, not this branch's.
* `just boot` (all the games, on `ea529d5a`, before Hurón's merge): 155
  passed. `just test`: green; `just crate-test events`: 199 passed, the new
  `the_own_cell_in_front_goes_in_a_cell_test_of_its_own` shown red first
  (without the fusion the page starts `[OP_VAR, OP_VAR, OP_CELL_TEST…]`).
* The three ROM tests of `test_stones.py`, red with `865163eb`'s tools
  (14 and 5 lost), green with the branch (7 and 2).
* `just space`: bank 0 at 8 bytes on `test-change-system` (main had 14
  there), 36 on `release`; bank 1 at 259 on `test-msu`.
* `abl.sfc` sha256 `9a06667498bb24f5…`.

**To install when merging**: `events`, `convert` and `cartridge` —the
runtime goes with the checkout—.

## Reopened (2026-11-17, Hornero)

taro, playing the builds of the ports `428e7c3` and the-advocate
`fe5529a3`/`95863f36` on Mesen, translated:

> I still see the same amount of lag (~35 frames at each lamp/PC).

The harness counts 2-7 lost per throw, Mesen still ~35. Hornero's guess,
to be checked first: Mesen counts a frame as lag when nothing reads the
pad registers in it ($4016/$4017/$4218-$421F), and ~35 is about the 33
ticks of "Hit A"'s flash. If the runtime does not read the pad while the
animation or a page blocks input, Mesen counts those frames as lag even
when every tick fits in its frame. Then the fix is not speed but reading
the pad every tick —or nothing, if the frames are not lost—, and the
harness's count has to be Mesen's: frames without a pad read.

### Why the counts differ (2026-11-17, Aguará)

Started from the-advocate `95863f36` and the ports `428e7c3`; branch
`aguara-pad-read` in the ports (the-advocate's was dropped: nothing changed
there).

Mesen2's rule, read in its source (`Core/Shared/BaseControlManager.cpp`,
`ProcessEndOfFrame`; `Core/SNES/InternalRegisters.cpp`,
`ReadControllerData`; `Core/SNES/SnesControlManager.cpp`, `Read`): a frame
is lag when the CPU read none of `$4218-$421F`, `$4016` or `$4017` in it.
The frame ends at the start of vblank (`SnesPpu.cpp`, the NMI scanline).
The auto-read itself does not count; only the CPU's reads do. Hornero's
guess about the rule holds.

**But the runtime does read the pad every tick**: `read_pad` is the
second thing the main loop does after `wait_vblank`, unconditionally, also
in a fade's frozen ticks, and no map-side path waits for a vblank outside
that loop (the others are the title, the slots, the menu, the items and
the battle). The animation and the pages run inside the tick. So a frame
Mesen counts is a frame no tick started in: a tick that overran, which is
what "hardware frames minus ticks" already counts. Nothing to win by
reading the pad more often: it would only hide real slowdowns from the
counter. The frames Mesen counts in this scene are really lost.

**Measured with Mesen2 itself.** The libretro cores the harness has
(snes9x, bsnes, mesen-s) all count 7 at Light4, 2 at the PC and 3 at
Light5, also with the MSU-1 on. mesen-s is not Mesen2 —its libretro
`RunSingleFrame` does the auto-read at the start of the frame instead of
timing it—, so Mesen2's core was built from source (`~/ref/mesen2`,
`b9fa69d`, `make core USE_GCC=true`) and wrapped in a libretro shim
—`~/scratch/aguara/lazer-teeth/mesen2-retro/shim.cpp`, linked against the
core's objects— that runs one frame per `retro_run` on the caller's thread
and exposes Mesen2's own lag counter (memory id `0x8100`) and its `.mss`
save states. With it the harness plays the same scenes on Mesen2's core,
and its counter, phase by phase (`phases.py` and `frames.py` next to the
shim, with the delivered `abl.sfc` and its `.msu`):

    phase                                   Mesen2's counter   hardware - ticks
    60 ticks standing on map 11                     0                 0
    talking to the grate (with a door jump)        99                99
    a door jump onto map 11 (go_to_map)            100               100
    the throw at Light4, 116 ticks                   8                 9
    the throw at Light5, from a fresh session        3                 3
    the throw at the PC, from a fresh session        2                 2
    200 ticks after each throw                       0                 0

Frame by frame they differ only in where a two-frame overrun is charged.
Holding A and the direction for 8 ticks instead of 1, or throwing from
further away —(15,54) and (22,54)—, does not change it. **So the harness
already counts what Mesen counts**, and `test_stones.py` holds that number;
its comment now says it was checked against Mesen2.

**What is not explained: taro's ~35.** Mesen2's core, the same ROM
(`abl.sfc` sha256 `3cfb09a7…`, byte for byte the one in
`/shared/builds/abl/`) and the same MSU-1 give 2-8 per throw in this
scene. What could make the difference and was not tried, because there is
nothing to play it from: taro's Mesen2 version and settings (run-ahead,
overclocking, anything that changes how frames are counted), and how the
throws are really played —from where, after what, with what else on the
map; the harness reaches map 11 through the `in-11` case and a door jump,
not through the story—. A door jump onto map 11 alone costs ~100 lag
frames (the map's load), so a counter read across a map change shows far
more than the throw. The `.srm` in `/shared/builds/abl/` is empty.

For taro: two Mesen2 states made with that core, right before a throw at
Light4 and at the PC, in `/shared/captures/2026-11-17-lazer-teeth-lag/`,
with a README of what to press and what Mesen2's core counts from there
(8 and 2). If taro's Mesen2 shows ~35 from them, it is the emulator or its
settings; if it shows ~8, the ~35 come from the way the throws are played,
and a `.mss` saved in taro's own session before one —the shim loads them—
is what reproduces it. Nothing was optimised: the frames left are the
ones in the drafts above, and the "Known issues" line of ABL's page in the
book still says what is seen.

**To install when merging**: nothing. The ports' branch only touches a
comment of `tests/abl/test_stones.py`; no suite was run for it.

## taro's Mesen2 (2026-11-17)

taro's emulator is Mesen Community Edition 2.2.1, commit `20ba206`
(nesdev-org's fork, built 2026-06-05): not SourMesen's `b9fa69d` that
Aguará's shim was built from. Between them the SNES core changed
(`SnesPpu.cpp`, `Spc*`, `InternalRegisters.cpp`, `BaseControlManager.*`).
Settings seen: no overclocking (0/0 scanlines), RAM at power on "Random
Values", rewind on (300 MB), autosave state every 5 minutes, lag counter
shown. Run-ahead not seen yet (Emulation tab).

taro, a moment later, translated:

> Something interesting happened anyway: my Mesen could load the saves, and
> the numbers come out the same as Aguará's. And it was also observable by
> eye and ear.

So the 2.2.1 core counts the same 8 and 2 from Aguará's states; the ~35 of
the first report came from how the throws were played or counted, not from
the emulator. The remeasure on `20ba206` was stopped before it measured
anything. What is left to lose (the animation, the hit's page, the
refreshes, `build_oam`) is in the three drafts above.
