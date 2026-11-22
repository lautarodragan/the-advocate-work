---
name: "Frozen World: every turn re-uploads the battle screen's audio"
description: "Each turn of a fight teleports map 3 → map 1 → map 3, and each teleport uploads the map's audio package again: a tick of ~62 frames entering map 1 and ~34 entering map 3, about 66 frames of every turn"
type: bug
status: doing
assignee: Chajá
agents: [Chajá]
author: aguara
game: frozen-world
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

## Log

### 2026-10-20, Tijereta: checked

Not measured again. Two things moved since: `maps-load-faster-without-losing-anything`
(`testing`) uploads a teleport's package in the fade's frozen ticks, and
`frozen-world-map-1-audio-package-does-not-fit-in-aram` is `done`. Whether
a turn's two teleports gain from the first depends on whether they fade;
the turn's frames have to be counted again on today's `main` before this
is defined, with the same steps as above.

### 2026-11-22, Chajá: smaller, still there

Measured in snes9x with a throwaway script over the ports' `tests/games.py`
(Frozen World's release, the ports `89f77b4`, global tools at the-advocate
`0ae40e0a`), counting the hardware frames of every tick. The audio
packages are still the same in `build/release/converter.log`: map 1 "0
song(s), 16 sound effect(s), and separate …" (six more), map 3 "0 song(s),
7 sound effect(s)".

* **The fight's own entry** —walking right from (11, 33) on map 12 into
  Sandflower.1, tapping A— enters map 1 with ticks of 8, 4, 13, 27 and 20
  frames over some 45 ticks, and the grid, map 3, with one tick of 11.
* **A round trip by the harness's door jump** (`FADE_DOOR`, the same
  request `go_to_map` writes), twice, the same both times: into map 1,
  122 frames in 74 ticks, with ticks of 8, 4, 22 and 17 frames; into map
  3, 84 frames in 74 ticks, one tick of 11.

So against the numbers above —one tick of ~62 frames into map 1 and one
of ~34 into map 3, ~94 frames over a frame a tick— a round trip now
costs some 57 extra frames: ~47 entering map 1, spread over four ticks
of its fade, and 10 entering map 3. The one-tick black stalls are gone
(`maps-load-faster-without-losing-anything` moved the package into the
fade's ticks); the cost per turn is not.

**Not measured**: the turn itself —my script tapped A on the grid with
switch 6 on and never left map 3 in 4,000 ticks, so the round trip is
the harness's jump and not the game's teleports, which may fade
otherwise—; and how much of those frames is `package_load_l`: no line
profiler was run, so that the extra frames are the audio is still
Aguará's measurement, not mine. To `todo`, with the numbers above.

### 2026-11-22, Hornero: taken by Chajá

taro, translated:

> Can something be done about it? I can confirm it is pretty annoying.
> Does it also happen with MSU and PCM?

Hornero's read of the runtime: with a valid `.msu`, `se_msu_prepare`
(`runtime/msu_effects.s`) forgets every sound effect on each package
load and uploads them all again from the `.msu`, at the package's rate;
so with MSU-1 a round trip should cost the same or more. Without MSU-1,
`package_load_done` keeps what was already in ARAM. Not measured.

The plan taro approved ("Go ahead!"), from the simplest:

1. In the runtime, a package equal to the one loaded uploads nothing.
2. In the converter, two maps that teleport into each other all the
   time —the grid and the battle screen— share one package, the union
   of both, if it fits.
3. If it does not fit, the effects both share stay, and only the
   difference goes up.
