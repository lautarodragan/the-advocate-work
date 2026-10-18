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

### 2026-10-18, Cardón: the method

Starting points: the-advocate `b066b885`, the ports `74068b8`, the book
`239069e`. Branches `cardon-map-load` in the three.

Measured with a temporary probe, never committed: `PROBE n` stores
`(n, boot_frames, V counter)` in a far RAM log at each phase boundary of
`load_requested`, `enter_map_no_events`, `load_map`, `load_above` and
`load_sprite`, plus `start_fade`, the fade's end and the top of the main
loop. `boot_frames` is counted by the NMI, which keeps running during the
load, so a timestamp is `frames * 262 + (V - 225) mod 262` scan lines;
a phase is the difference between two. A harness script in scratch jumps
to each map with `go_to_map` —the same `FADE_DOOR` a door asks for— and
reads the log. The probe shifts the code, so absolute numbers carry a few
lines of noise; the phases are what is compared.

The fade is 68 ticks: 23 going dark, the load on tick 24 (`FADE_LOAD`),
black until 43, and 24 coming up. A tick is a loop iteration, so what the
load takes beyond its frame does not shorten the black: it is added to
it. That is the whole cost seen by the player, and what is measured.

### 2026-10-18, Cardón: where the frames go, before

Every map of each game reached with a door fade from the one before it in
the cartridge's order —`go_to_map`, which is what a door asks for—, on
snes9x, with the tools at `b066b885` plus the probe. ABL with 200 of its
real door pairs instead: for each `Teleport` from map A to map B in its
pages, A is loaded and B measured, so the package starts from what its
neighbour left, as when playing. Without MSU-1 tracks: every song goes up
through the SPC700, which is the slow case and the one the suite runs.
Vampires Dawn apart, below. Frames the load adds to the black, mean per
load; "slowest" names the map, or the pair.

| game | loads | mean | slowest | package: music | package: effects | package: placing | grid | backdrop | above + pano | sprites | clear + fill_window | tint | carry | events & routes | OAM | other |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| abl (pairs) | 200 | 30.3 | 95.2 (11>9) | 10.1 | 7.2 | 0.6 | 1.1 | 3.1 | 0.2 | 1.2 | 4.8 | 0.7 | 0.0 | 1.0 | 0.1 | 0.2 |
| el-dorado | 13 | 35.7 | 60.5 (2) | 2.4 | 16.2 | 1.0 | 1.4 | 2.9 | 0.6 | 2.9 | 4.0 | 0.8 | 0.2 | 1.8 | 1.4 | 0.1 |
| sunset-over-imdahl | 65 | 26.2 | 58.1 (12) | 5.6 | 4.7 | 0.2 | 1.1 | 0.2 | 1.1 | 2.3 | 8.4 | 0.8 | 0.4 | 1.0 | 0.3 | 0.2 |
| book-of-three | 89 | 26.2 | 78.0 (22) | 9.3 | 5.1 | 0.3 | 0.8 | 3.3 | 0.2 | 0.7 | 4.5 | 0.7 | 0.1 | 0.8 | 0.2 | 0.1 |
| dooms2 | 93 | 34.8 | 94.3 (42) | 23.3 | 3.0 | 0.7 | 0.3 | 1.2 | 0.1 | 0.7 | 3.9 | 0.7 | 0.0 | 0.7 | 0.1 | 0.2 |
| frozen-world | 155 | 27.5 | 78.8 (135) | 10.1 | 4.1 | 0.7 | 0.9 | 2.4 | 0.2 | 2.9 | 4.3 | 0.7 | 0.0 | 0.9 | 0.1 | 0.2 |
| desert-nightmare | 189 | 29.1 | 78.0 (48) | 0.0 | 4.5 | 0.1 | 5.2 | 3.4 | 0.3 | 2.2 | 4.8 | 0.9 | 4.8 | 1.1 | 1.6 | 0.1 |
| zounds | 188 | 23.1 | 84.9 (34) | 7.3 | 3.6 | 0.6 | 0.7 | 2.2 | 0.2 | 1.2 | 4.8 | 0.7 | 0.7 | 0.9 | 0.2 | 0.2 |

ABL's every map from the one before it (307 loads, an earlier run of the
probe without the package split): 28.9 mean, 17.0 of it the package,
98.9 the slowest (map 1).

What it says:

* **The audio package is most of it**: 17 of ABL's 30 frames, 26 of
  Dooms 2's 35, 19 of El Dorado's 36. It is the SPC700's handshake, about
  55 KB a second (`spc700.rs` in rm2k-snes-audio), and a package that
  changes much is most of the ARAM.
* **`fill_window` is the second, everywhere**: four to five frames, eight
  in Sunset. It builds the 64 columns of the window one by one.
* Then the decompression: the background tiles (two to three), the grid
  (one, five in Desert Nightmare) and the sprites (one to three).
* `code_carry_after` decompresses the whole bytecode of the map left
  behind when a page goes on after the jump: five frames a load in Desert
  Nightmare, where the harness's jumps found a page running. Every door is
  a page that jumps.
* The tint, `apply_tint`, is 0.7 frames on every map even with the tint
  neutral.

The fade around it is 68 ticks: 23 going dark, the load, 19 of black and
24 coming up, all frozen. A frozen tick does nothing but write the
brightness: **43 idle frames after every load**, where nothing can sound
and nothing moves.
