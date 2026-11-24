---
name: "The test game's terrace, in the rain"
description: "Add rain to the terrace's stress case: an event that starts the rain when talked to, and more steps and snapshots at the end of the same test, to see whether the striped edges of ABL's map 1 come from the rain"
type: feature
status: done
assignee: taro
author: taro
agents: [Aguará]
links:
  relates: [a-transparent-window-over-a-flattened-panorama-shows-striped-edges]
---

Follows [`the-test-game-a-transparent-box-over-a-scrolling-panorama`](the-test-game-a-transparent-box-over-a-scrolling-panorama.md):
the terrace does not show the striped edges of
[`a-transparent-window-over-a-flattened-panorama-shows-striped-edges`](a-transparent-window-over-a-flattened-panorama-shows-striped-edges.md),
and ABL's map 1 has rain, which the terrace does not. taro, on
2026-11-16:

> Rain! True, I forgot that. That map has too many things on screen! We
> push the SNES to the limit. Can you add a rain case to the existing
> test? I think, instead of cloning the whole test, I'd just add more steps
> and snapshots at the end. It could be an event that makes it rain when
> you interact with it.

Done means: an event on the terrace that starts the rain when talked to;
the terrace's tests go on after the four boxes —the rain on, boxes again
with the rain— and measure the same (vblank lines, margins, waits, the
ceiling, display accesses) plus snapshots; if the stripes show, the test
says so honestly (xfail naming the draft, or a golden of the broken
state); the draft updated either way.

## Log

**Aguará, 2026-11-16.** From the-advocate `3f3eede3`, branch
`aguara-terrace-rain`; the book, branch `aguara-terrace-rain` from
`838df3d`. Scratch in `~/scratch/aguara/terrace-rain/`. Nothing of ABL is
committed: its measurement was a detached ports worktree at `4e3bfac`.

**The rain's event**: `Rain`, event 5 of map 9, at (11, 12), the hero's
right. Talked to, it sets the rain strong —`WeatherEffects [1, 2]`, 75
drops, two objects each— and turns switch 1500 on (free: the game uses
1100 to 1403); its second page, parallel on that switch, shows four boxes
more —4, 4, 3 and 1 lines, transparent, middle— and turns it off. The
rain stays. Parallel, not the talked page itself, so the walkers go on
walking, as with the dry boxes. ABL's map 1 has it weak (`EV0001`,
`[1, 0]`, 15 drops) while `EV0002` talks; strong here, to push.

**The test**: the same three of `test_terrace.py`, with `play` going on
after the four boxes: turn right, A, wait for `far_weather` to say rain,
the four rain boxes, and at the end the rain on with live drops. The
probe's calls are tagged dry or wet, and it asks that some went up in
the rain. Two goldens more: `terrace-rain-first-box` and
`terrace-rain-three-lines`; the two old ones change by the event's sprite
only (294 pixels).

**Measured**, snes9x and bsnes (the audit core: 0 display accesses over
both halves): dry as before —34 calls, 22 first try at 235/236, 6 missed
at 239/240 and went up at 235–237, writes at worst line 256—. In the
rain: 29 calls, 27 first try at 235 (margin 3), 1 missed at 240 and went
up at 236 (snes9x) or 237 (bsnes), no line twice, no forced blank, writes
at worst line 257. The rain moves its drops and fills the OAM outside the
vblank, and the OAM's DMA is 544 bytes with or without them, so the
window does not feel it. Red when it should be: with the event's
`WeatherEffects` taken out, all five tests fail "still not raining".

**The stripes: not the rain.** None on the terrace in the rain. And on
ABL's map 1 itself —the draft's stress copy, built twice, with and
without `EV0001`'s rain— the screen's 12 edge columns on the box's rows
are identical at 15 bits: the stripes show in both. snes9x's layer
switches put them on BG2, the window's layer: they stay with BG1, the
objects or the clip windows off. Written in
[the draft](a-transparent-window-over-a-flattened-panorama-shows-striped-edges.md).

**Found**: the drops fall over a box without a window's letters, where in
RM2k the window is above the weather. It is the known divergence of the
characters over the text —they are objects too—, so it went into that
divergence's page in the book, not into a draft.

**Verified**: `just test-game`: 65 passed, 1 skipped, 3 failed —the known
three of `test_leader_name.py`—; `just test`: 29 passed. Tools: the
global ones (main), nothing installed locally. Captures in the shared
folder, `captures/2026-11-16-terrace-rain/`.

**What it does not cover**: the console's timing and an FX Pak; the rain
weak, as ABL has it (strong is the heavier case for the vblank, not
necessarily for the stripes, which are ruled out on ABL itself); and the
rain's sound, which the terrace does not play.

**To merge**: the-advocate `aguara-terrace-rain` (two commits: the scene
and the test, then the goldens) and the book's `aguara-terrace-rain`.
Nothing to install.

**2026-11-16, taro**: declared done.
