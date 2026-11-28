---
name: "The on-screen timer is expensive to draw"
description: "While a timer is shown, `timer_oam` takes ~18 of the frame's 262 lines on every frame for its five 8x8 glyphs, and on a busy map that is what tips a tick over the frame"
type: refactor
status: todo
author: aguara
agents: [cardon]
links:
  found-in: [abl-lazer-teeth-s-rock-lags]
---

Seen by Aguará on 2026-11-17, measuring
[`abl-lazer-teeth-s-rock-lags`](abl-lazer-teeth-s-rock-lags.md) from taro's
own Mesen2 save state (`~/scratch/hornero/lazer-teeth/taro-abl_1.mss`, the
delivered `abl.sfc` of the ports `428e7c3` and the-advocate `95863f36`), on
Mesen2 2.2.1's core with the line profiler of that task's shim (marks at
routine entries, no change to the ROM).

taro's game reaches map 11 with a timer on screen (`timer_visible` 1).
With the screen's saturation set back to neutral, a stone at `Light5`
loses 6 frames; with the timer turned off as well, 3, the harness's
number. The profiler, standing still on map 11: from `timer_oam`'s entry
to `anim_drawing_oam`'s, **~18 lines every frame**, for four digits and
the colon; with the timer off, the `build_oam` bucket drops by ~20.

How to reproduce: load the state, write `tint_s` = 100 (and, to compare,
`timer_visible` = `timer_active` = 0), and profile `timer_oam` against the
next routine `build_oam` calls. Or in the harness: any map with
`timer_visible` on.

What it would take: the glyphs do not change between seconds, so their
five OAM entries could be built when a digit or the colon changes and
copied otherwise, or written straight to OAM as the raindrops are —see
"The raindrops go straight to OAM" in the book's "Lossless: CPU time in
the frame"—. Not measured.

## Comments

### 2026-11-27, taro: a comment

> Quick test with the debug menu: 7 frames of lag tracked by Mesen with the timer off, 9 with the timer on, for the first light, 5 and 7 for the PC., 7 and 10 for the second light.
>
> Not a huge deal. Do you think we could improve those dropped frame numbers and lose nothing in exchange?

### 2026-11-27, Hornero: yes, losing nothing seen

Yes: the gap taro measured —2 to 3 frames per stone with the timer on—
is about what `timer_oam`'s ~18 lines a frame add up to over a stone's
busy frames, and the glyphs change at most once a second. Building
their five OAM entries only when a digit or the colon changes, and
copying them otherwise, should bring the timer-on numbers close to the
timer-off ones. What it costs: some 25 bytes of far RAM for the built
entries and the last value, and a few bytes of ROM; nothing on screen
changes, and the suite's timer goldens hold it. Whoever takes it
measures the three stones before and after with the same debug-menu
method, and the timer's cost with the line profiler. Still `todo`.

## Log

### 2026-11-24, Cardón: to todo

Measured by Aguará with the line profiler (~18 lines a frame for five
glyphs), and `timer_oam` in `runtime/timer.s` is unchanged since: at
`8b069fc2` it still rebuilds the five glyphs' objects every frame (only
`230325f9`, the debug screen forcing it off, touched it). Lossless CPU
time, nothing seen changes; the task says the two ways (rebuild when a
digit or the colon changes, or straight to OAM as the raindrops).
