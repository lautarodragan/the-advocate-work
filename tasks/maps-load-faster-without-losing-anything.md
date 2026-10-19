---
name: "Maps load faster without losing anything"
description: "Measure where a map load spends its frames, phase by phase and map by map, in every game, and cut what can be cut without losing quality or features"
type: optimization
status: testing
assignee: taro
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

### 2026-10-18, Cardón: what was done —the load leaves for the fade what nobody needs yet—

Two cuts, both in the-advocate's `runtime/`, both only inside a
teleport's fade (`LOAD_DEFER`, set by `map_access_enter` from `fade`; a
load at boot, a new game or a save from the title does everything at once,
as before):

1. **The package's uploads go in the fade's frozen ticks** (`upload_placed`,
   `package_pump`, `pump`, `package_settle`, `song_now` in
   `audio_package.s`). The package is placed in the load as always; only
   the song the map turns on goes up there —`music_start` asks
   `song_ensure`, which now uploads that song's waiting samples first—.
   The rest goes up block by block in each frozen tick after the load,
   stopping at line 180 so the tick still ends before the vblank (85
   triplets take some 88 lines in snes9x). On the last black tick (43),
   whatever 24 ticks of ramp at 512 bytes each could not take goes up at
   once —black, as the whole load used to be—, so the ramp keeps its pace;
   and the fade does not end until the package is complete
   (`package_finish` from `finish` and `cut_in`). A `PlayBGM` and every
   new package finish what is waiting first. Nothing can sound in between:
   the world is frozen and the left map's effects were silenced by
   `se_mute`. Same ARAM, same directory.
2. **The window and the tint go in the black ticks** (`tail_pump` in
   `enter_map.s`): clearing the tilemaps, the 64 columns, the panorama's
   ring and the painted slots, and `apply_tint`, with the screen in forced
   blanking —it is black already— and the tint to CGRAM in the next vblank
   through `tint_ready`. What is left on tick 43 is done there, so the ramp
   shows the whole map. `fill_window` split into `window_start` —which the
   hero's pointer needs in the load— and `fill_columns`.

Measured on ABL's 200 door pairs, frames the jump adds to the fade's 68
(the after columns count hardware frames from the request to the end of the
fade, so they include any settle):

| | mean | slowest |
|---|---|---|
| before: the load tick | 30.3 | 95.2 (11>9) |
| 1 alone | 20.0 | 79 (69>66) |
| 1 + 2 | 15.9 | 74 (69>66) |

The slowest ones are a big map whose own song goes up in the load (66:
grid 7, background 11 and the song most of the rest).

A test moved: `tests/abl/test_leader_without_graphic.py` read the sprite
shadow the moment the load ended, and the tint now fills it on a black tick
after; it waits for `LOAD_TAIL` to finish, still inside the fade.

### 2026-10-18, Cardón: the ramp keeps its pace, and before and after in every game

Checking every jump of the nine ports frame by frame (a scratch script that
watches `ticks`), two cases held a tick of the ramp for two frames: a block
that straddled the music's IRQ line pushed the IRQ's frame past line 225
(ABL's maps 3 and 9), and an effect from the `.msu` —which goes up whole—
landing in a ramp tick. Blocks now stop at `IRQ_LINE` when they start
before it, and the whole-only samples all go up on the last black tick
(`whole_ones`). After that, no tick from the ramp to the fade's end lasts
more than one frame on any map of any port. Commit `7ca45aa6`.

Frames a jump adds to the fade's 68, counted in hardware frames from the
request to the end of the fade, both sides with the same probe and the same
jumps (ABL: the same 200 door pairs; the rest: every map from the one
before). "after: load tick" is what is left inside the load's tick;
the difference to "after: mean" is the settle on tick 43.

| game | loads | before: mean | before: slowest | after: mean | after: slowest | after: load tick |
|---|---|---|---|---|---|---|
| abl-pairs | 200 | 30.7 | 96 (11>9) | 15.8 | 73 (69>66) | 11.0 |
| el-dorado | 13 | 36.1 | 61 (2) | 17.2 | 39 (13) | 14.7 |
| sunset-over-imdahl | 65 | 26.6 | 58 (12) | 13.5 | 43 (54) | 11.6 |
| book-of-three | 89 | 26.6 | 78 (22) | 13.0 | 49 (22) | 9.7 |
| dooms2 | 93 | 35.2 | 95 (42) | 21.1 | 66 (42) | 15.6 |
| frozen-world | 155 | 27.8 | 79 (135) | 18.5 | 60 (135) | 17.0 |
| desert-nightmare | 189 | 29.1 | 78 (48) | 20.3 | 49 (48) | 18.9 |
| zounds | 188 | 23.6 | 85 (34) | 11.8 | 70 (183) | 8.7 |
| vampires-dawn | 409 | 83.8 | 221 (195) | 78.5 | 216 (195) | 35.8 |

Vampires Dawn barely moves: its effects come from the `.msu` and go up
whole, so most of them end up on the settle tick. A draft says it.

### What was left, with its cost

* **The decompression is still in the load's tick**: grid, background,
  animation, upper layer and sprites, four to nine frames a load. Each
  stream is one `lz2_decompress`, one to eight frames, which does not fit
  in a frozen tick. Moving them needs a decompressor that can stop and go
  on next tick —a second copy of the body per bank that looks at the line
  between commands, some 400 bytes in a far bank, and the decompressor's
  state in far RAM— and the load buffer's users in a fixed order across
  ticks. Gain: up to those frames on loads whose package leaves the black
  ticks free, which is the common door between neighbours. Draft
  [`a-map-load-still-decompresses-inside-its-tick`](a-map-load-still-decompresses-inside-its-tick.md).
* **A door decompresses the whole bytecode of the map it leaves**
  (`code_carry_after`): Desert Nightmare's are ~14 KB each, some 2 to 5
  frames a door. Draft
  [`a-door-decompresses-the-whole-bytecode-of-the-map-it-leaves`](a-door-decompresses-the-whole-bytecode-of-the-map-it-leaves.md).
* **The song the map turns on still goes up in the load**, because it
  starts there, as in RM2k; it is what is left of the slowest loads (ABL's
  map 66: 63 to 73 frames). Starting it later, or uploading it while the
  old map fades out, changes when it is heard or risks the effect of the
  door that is still sounding: not lossless. Draft
  [`the-song-a-map-turns-on-goes-up-inside-the-load`](the-song-a-map-turns-on-goes-up-inside-the-load.md).
* **Vampires Dawn's effects from the `.msu`**: draft
  [`vampires-dawn-loads-spend-seconds-on-effects-from-the-msu`](vampires-dawn-loads-spend-seconds-on-effects-from-the-msu.md).
* `PUMP_LINE` (180) and `PUMP_TICK_BYTES` (512) are on the safe side of
  what snes9x measured (blocks ending at ~184, ~600 bytes a tick); raising
  them gains a few percent of the package and was not tried on hardware.
* The upload's timing reads the V counter, which needs `WRIO` bit 7 set
  (the power-on value; nothing writes it). The text layer already counts
  on it the same way.

### What was run

On the tree merged with main (the-advocate `f68f0b70`, ports `6b27921`),
with the branch's tools:

* `just test` in the-advocate: 29 passed.
* ABL's whole suite: 1577 passed, 2 skipped; no golden moved.
  `test_cores.py` five more times: 24 passed each.
* The other games' tests, `just boot` from the ports' root: 67 passed.
* The ramp check over every map of the nine ports: no tick from the ramp
  to the fade's end lasts more than one frame.
* `just space` in `abl/`: bank 0, `release` 130 B and the tightest 79 B
  (a test cartridge); bank $C0 2.0 KB at least; the fade-tick code is in
  $C1 (28 KB left). Sunset Over Imdahl's $C0 was what pushed the code
  there (`95783f1a`).
* `abl.sfc` of `release`: sha256 `11375e00…79b5f6`.
* Rust: none touched. Nothing to reinstall when merging; the runtime goes
  with the-advocate's checkout. The global tools must be at least main's
  `f68f0b70`: with an older runtime and the newer `rm2k-snes-screens` the
  window systems' goldens go red, which is how that merge was found to be
  needed.

Commits: the-advocate `c7360e6e`, `7ca45aa6`, `95783f1a` on
`cardon-map-load`; the ports `89da040` (the leader test); the book
`2c18fc3`, `248c117`.
