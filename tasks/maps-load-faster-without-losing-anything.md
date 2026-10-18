---
name: "Maps load faster without losing anything"
description: "Measure where a map load spends its frames, phase by phase and map by map, in every game, and cut what can be cut without losing quality or features"
type: optimization
status: doing
assignee: Cardón
agents: [Cardón]
---

taro, on 2026-10-18: "is there some optimization we can do so maps load
faster? We kept accepting tradeoffs to improve or implement things that
slowed down map loading… and some take quite a while. I wouldn't sacrifice
quality or functionality to load them faster, but maybe there is something
we can improve without losing anything."

Done means: a measured table of the load's frames by phase (from the fade
out to the fade in: decompression, VRAM uploads, the audio package, the
grid, events, the refresh…) for the slowest maps of each game; the lossless
cuts done, each measured before and after, ROM byte for byte where the
change claims to be a no-op in output; and what was not done, with its
cost, for taro to decide.

## Log
