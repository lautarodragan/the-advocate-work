---
name: "An effect played while it still waits for its upload is heard late"
description: "Since a teleport's sound effects go up after the fade, one played before its turn goes up in the tick that plays it: the picture freezes while it does, and with the .msu it was heard some thirteen frames after the ROM started it"
type: bug
status: draft
assignee: taro
agents: [cardon]
author: chaja
links:
  found-in: [frozen-world-every-turn-re-uploads-the-battle-screens-audio]
  relates: [lashe-city-transitions-lag]
---

Seen by Chajá on 2026-11-22, doing
[`frozen-world-every-turn-re-uploads-the-battle-screens-audio`](frozen-world-every-turn-re-uploads-the-battle-screens-audio.md),
with the-advocate `e920866f` (branch `chaja-tfw-turn-audio`, before
`se_msu_chunk`), in A Blurred Line's `release` in snes9x.

**What was seen**: with the cartridge's `.msu`, case `sound-in-route` of
ABL's `test_with_msu_a_routes_sound_effect_plays_whole` —a forced route
on map 10 plays `Close1` on its first ticks—. `Close1` was still waiting,
so `effect_now_l` uploaded it whole from the `.msu` inside `sound_play`;
`SE_FRAMES` went up on the same frame the upload ended, but the recording
stayed silent for some 11 steps of 20 ms (~13 frames) before the effect,
whole and right, began: the test's envelope alignment, which allows five
steps, failed.

Not seen since: the `.msu`'s effects now go up in pieces in the idle end of
the ticks, and in that case `Close1` is up before the route plays it. The
path —an effect played while it still waits— is still there for a map that
plays one of its effects on its first ticks, and nothing measures how late
it sounds. Without the `.msu` it was not measured either. Why the sound
lags the upload by that much is not known: the music's IRQ is held back
one block at a time during it, not for the whole upload.

**To reproduce**: at that commit, ABL's `just tests
tests/abl/test_msu_effects.py`; or play any waiting effect on demand and
compare the frame `SE_FRAMES` goes up with the first frame of its audio.

## Comments

### 2026-11-24, Cardón: a question for taro

**What to decide**: whether this path is worth chasing. Not heard since
the `.msu`'s effects go up in pieces in the ticks' idle end; the path is
still there (an effect played before its turn uploads whole inside
`sound_play`), and Chajá's later measure says Lazer Teeth HQ's action
pages could play one up to ~21 frames late. Why the sound lags the upload
is not known, so the task does not say what to do yet.

**Options**: (a) to `todo` as a measurement first —a case that plays a
waiting effect on purpose, the lag with and without `.msu`— and then a
fix; (b) `wishlist` until a player hears it; (c) cancel.

**Recommendation**: (b): nobody heard it in a game, and the HQ figure is
an estimate; if taro hears a late effect on map 11, it becomes (a).

## Log

### 2026-11-22, Chajá: on busy maps the effects wait for seconds

Measured in [`lashe-city-transitions-lag`](lashe-city-transitions-lag.md)
at the-advocate `ec672f4c`, on Mesen2's core, walking after each door: the
effects a teleport leaves waiting go up in two to three seconds on
Lashe's sectors with the `.msu` (121 to 161 ticks), but **in the Lazer
Teeth HQ (map 11) more than five and a half**: its ticks rarely end before
`PUMP_LINE`, so in 330 ticks one effect went up and two were still
waiting —likely `Glass` and `Dark1`, 21.6 and 20.2 KB in the `.msu`—;
without the `.msu`, 249 ticks. No gameplay tick got longer, and on these
doors no page played an effect in that window, but the HQ's puzzle plays
those from action pages: at ~1 frame a KB, up to ~21 frames late.
