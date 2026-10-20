---
name: "Frozen World: every turn re-uploads the battle screen's audio"
description: "Each turn of a fight teleports map 3 → map 1 → map 3, and each teleport uploads the map's audio package again: a tick of ~62 frames entering map 1 and ~34 entering map 3, about 66 frames of every turn"
type: bug
status: draft
---

Seen by Aguará on 2026-10-17, measuring
[`frozen-world-the-battle-maps-lag`](frozen-world-the-battle-maps-lag.md),
with the-advocate `a15a9111` (the ports `bd92975`), in snes9x.

**What was seen**: a whole turn of a real fight —A on Lutine's first slot
in the command grid (map 3), the walk to Monster A on the battle screen
(map 1), A, until the grid has control again— takes ~155 ticks and ~333
hardware frames. Two ticks are most of the excess: the one that enters map
1 lasts 62 frames and the one that enters map 3 lasts 34, both with the
screen black. The line profiler puts ~111 lines per tick of the turn —~66
frames— in `package_load_l`, the map's audio package, during the load. The
two maps have different packages (map 1: 16 effect samples and 6 more;
map 3: 7 effects), and map 1's does not fit with its music, so each round
trip uploads them again.

[`frozen-world-map-1-audio-package-does-not-fit-in-aram`](frozen-world-map-1-audio-package-does-not-fit-in-aram.md)
anticipated the round trips without measuring them.

**To reproduce**: from a fight —walk into Sandflower.1 on map 12 from
(11, 33)—, with switch 6 on so the first slot has a plate, A on it from the
grid and A on Monster A; count the hardware frames of the ticks that load
maps 1 and 3.

## Checked (2026-10-20, Tijereta)

Not measured again. Two things moved since: `maps-load-faster-without-losing-anything`
(`testing`) uploads a teleport's package in the fade's frozen ticks, and
`frozen-world-map-1-audio-package-does-not-fit-in-aram` is `done`. Whether
a turn's two teleports gain from the first depends on whether they fade;
the turn's frames have to be counted again on today's `main` before this
is defined, with the same steps as above.
