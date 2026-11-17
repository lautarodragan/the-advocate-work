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
