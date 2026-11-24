---
name: "Frozen World: every turn re-uploads the battle screen's audio"
description: "Each turn of a fight teleports map 3 → map 1 → map 3, and each teleport uploads the map's audio package again: a tick of ~62 frames entering map 1 and ~34 entering map 3, about 66 frames of every turn"
type: bug
status: testing
assignee: taro
agents: [Chajá, Carpintero]
author: aguara
game: frozen-world
links:
  found-in: [frozen-world-the-battle-maps-lag]
  found: [an-effect-played-while-it-still-waits-is-heard-late]
  relates: [frozen-world-map-1-audio-package-does-not-fit-in-aram, frozen-world-s-turn-audio-test-passes-only-with-the-tracks, lashe-city-transitions-lag, the-fades-last-black-tick-uploads-songs-the-map-is-not-playing]
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

### 2026-11-22, Chajá: measured both ways, and what fits

Frozen World's release built with `TRACKS=1` (the build's own `.msu`
and its 32 PCM tracks), the-advocate `6a8f4162` (global tools), the
ports `001cfb7`. A throwaway script over the ports' `tests/games.py`
plays from the title to the beach, walks into Sandflower.1 on map 12
for a real fight, and counts the hardware frames of every tick; "extra"
is frames minus ticks. Without MSU-1 the core gets the ROM alone; with
it, the ROM's directory, `.msu` and tracks. snes9x, and the same again
on Mesen2 with its line profiler (`abl/tests/harness/mesen2.py`'s
`Mesen2` over the session), which agrees within two frames.

#### The round trip, before

| what | without `.msu` | with `.msu` + PCM |
|---|---|---|
| real turn: A on the grid's Fight → map 1 | 81 extra, one tick of 64 | 122 extra, one tick of 105 |
| real turn: A on Monster A → back on map 3 | 57 extra, one tick of 33 | 124 extra, one tick of 102 |
| door jump (`go_to_map`) into map 1 | 79 extra, one tick of 64 | 119 extra, one tick of 104 |
| door jump into map 3 | 32 extra, one tick of 33 | 101 extra, one tick of 102 |

Twice each, the same to a frame. The real turn is the game's own:
switch 6 on before the fight, the grid's A on its first slot (9, 4)
—the fight leaves the stamina, variable 30, at 1—, the walk onto Monster
A at (11, 4) and A, until the grid has control again. The rest of the
"back to map 3" extra is the battle's animation ticks of 2-4 frames,
not the audio.

**With MSU-1 it is worse, as Hornero read**: `se_msu_prepare` forgets
every effect on each package load, and the `.msu` versions are bigger
—each package's are fitted to fill the ARAM that the music leaves—, so
each direction goes up whole, at once, in one tick.

The profiler, over the door jumps: without MSU-1, entering map 1 is
~48 frames of uploads and ~14 of `load_map`; entering map 3, ~17 and
~14. With MSU-1, over the fight's entry: ~60 and ~86 frames of
`se_msu_upload` for maps 1 and 3. The black stall is the uploads, and
it is one tick because the door's fade leaves almost no black ticks
after the load: `package_settle` uploads at once what the ramp cannot.

#### What fits

From `build/release/audio.json` and `effects.json`:

* **Without MSU-1** —each effect at the cartridge's 6 kHz—: map 1's 16
  effects take 36,819 B, map 3's 7 take 14,049, and they share only
  `Escape` (1,557 B, in the same place, 195), so the union is 49,311 B.
  With the battle song that keeps playing, the six take 15,192 to
  21,636 B: **the union needs 64.5 to 70.9 KB of the 63,419 B the ARAM
  has for samples**. It does not fit with any of them; the overflow is
  1.1 KB (HouseOfTheRisingSun) to 7.5 KB (tjo_st6). Map 1's package is
  already relieved for this (16 of its 56 effects, its six songs
  separate), and each `1>song` group has 4,964 to 11,408 B left, short
  of map 3's other 12,492.
* **With MSU-1** —no music in the ARAM—: map 1's `.msu` versions take
  62,343 B and map 3's 61,452 (all seven at 22,050 Hz); the union at
  those versions is 118,071 B. Fitted together, most of map 1's would be
  at the bottom (3,000 Hz, or 6 kHz for the ones the cartridge carries
  whole), where they already are, and map 3's six would still not fit.
* And the places: map 3's seven take places 193 to 199, which are also
  map 1's (`effect_places` shares places between effects never in the
  same package), so even what fits could not stay put.

So **plan 2, one package for both, does not fit either way**, and
**plan 3, keeping the shared ones resident, is `Escape` alone**: 1.5 KB
of the 48 that go up without MSU-1, and nothing with it (its two
versions differ). **Plan 1**, a package equal to the loaded one
uploading nothing, does not touch this round trip —the two packages are
different— but it is still right with MSU-1, where a teleport within
the same map uploads every effect again; I do it.

#### Deviating: the effects go up after the fade, and on demand

What does fit is not uploading what no one plays. A turn plays one or
two of map 1's sixteen effects and maybe none of map 3's, and each map
is on screen for a hundred ticks or more with idle time at the end of
each. So: inside a teleport's fade the music still goes up whole before
the fade ends, but **the effects stay waiting** (`FAR_WANTS` 3, which
already exists for the fade's frozen ticks) and go up in the idle end of
the game's ticks, block by block; an effect asked for before its turn
goes up then, whole (`upload_one`, which `song_now` already uses for
songs); and a new package drops what the previous one left waiting
instead of uploading it. Outside a fade —the boot, a battle, a save—
everything goes up at once, as now. Started from here.

### 2026-11-22, Chajá: the effects go up after the fade

#### What changed

In the runtime (the-advocate, branch `chaja-tfw-turn-audio`), all in
`runtime/audio_package.s` but two calls:

* **Plan 1**: `PKG_WHOLE`. A package left whole —nothing out, no extra
  song— that is asked for again uploads nothing, not even through
  `se_msu_prepare`.
* **The deviation**: a teleport's fade ends once the music is up
  (`package_settle`, `whole_ones`, `pending_bytes` and the fade's end only
  look at entries below `SE_FIRST`, `PKG_MUSIC`). Its effects stay marked
  3 and go up block by block in the idle end of the game's ticks
  —`package_idle_l`, a `jsl` before `count_lost` in the main loop,
  `PKG_TIMED` 3, which never pumps inside a tick that overran—, or whole
  when `sound_play` asks for one that still waits —`effect_now_l`, a
  `jsl` before the presence check—. The `.msu`'s effects only go up
  whole, so they wait for that moment. A new package drops what the
  previous one left waiting (`package_drop`), and only a `PlayBGM` that
  rebuilds the same package keeps them waiting (`PKG_LAZY`,
  `PKG_LAZY_MAP`); the battle's, the boot's or a save's load uploads
  everything at once, as before. Bank 0: 8 bytes; `just space` leaves
  3,058 B in the tightest ABL cartridge and 3,218 B in Frozen World's.

#### The round trip, after

Same script, same build flags, the branch's runtime:

| what | without `.msu` | with `.msu` + PCM |
|---|---|---|
| real turn → map 1 | 33 extra (was 81), longest tick 16 | 33 (was 122), 16 |
| real turn → map 3 | 39 (was 57), 16 | 37 (was 124), 15 |
| door jump into map 1 | 31 (was 79), 16 | 31 (was 119), 16 |
| door jump into map 3 | 15 (was 32), 16 | 15 (was 101), 15 |

The 16-frame tick left is the map's own load (`load_map`, ~14 frames in
the profiler); the 17-frame tick after it on map 1 was there before too.
The real turn plays no effect of map 1's package that the port has: the
profiler saw `sound_play` called twice in Monster A's attack and returning
before `effect_now_l`, because those effects are among the 40 the battle
screen leaves out. So the on-demand path is not what the real turn
measures; the test below plays it.

#### The limits of each path, measured

* Plan 1 (the same package): does not touch the round trip; covers a jump
  within a map, which with the `.msu` re-uploaded every effect (102
  frames on map 3, now nothing).
* Plan 2 (one package for both maps): does not fit, by 1.1 to 7.5 KB
  without MSU-1 and by 55 KB with the `.msu`'s versions; not done.
* Plan 3 (the shared ones resident): `Escape`, 1.5 KB; not done.
* The deviation: cuts the stall to the load; what it costs is that an
  effect played while it waits freezes the picture while it goes up
  —a few frames from the cartridge, up to ~15 for a 22 kHz one from the
  `.msu`, each with its seek—, with the music going on.

#### Tests

* The ports' new `tests/test_frozen_world_turn_audio.py` (root `just
  boot`): the round trip without and with the `.msu`, longest tick ≤ 24
  frames; the idle ticks upload what waits; a jump within map 3 with the
  `.msu` costs nothing; Holy5 waits on arriving at map 1 and goes up and
  sounds when Lutine's turn plays it. **Red before** with the global tools
  (56 and 104 frames), green after.

### 2026-11-22, Chajá: the `.msu`'s effects in pieces, the suites, to testing

#### What changed after the first version

* **The `.msu`'s effects go up in pieces too**: `se_msu_chunk`
  (`runtime/msu_effects.s`) uploads up to `PKG_CAP` triplets from an
  offset, seeking only if the stream was left elsewhere, and a timed `pump`
  uses it as it uses `sample_block`. The first version left them for the
  moment each was played, and ABL's
  `test_with_msu_a_routes_sound_effect_plays_whole` caught `Close1` heard
  ~13 frames late after going up on demand: the draft
  [`an-effect-played-while-it-still-waits-is-heard-late`](an-effect-played-while-it-still-waits-is-heard-late.md).
* **The idle hook lives in `count_lost`**, not in the main loop: four more
  bytes there put Sunset's `bra loop` out of range (`runtime/boot.s:168`,
  all six of Sunset's boot tests red).
* Goombario's `pull-branch` on `pump`'s `pla` / `bne complete`: on
  purpose, annotated on the line.
* ABL's `test_going_from_2_to_3_does_not_upload_what_was_there_again`
  compared every placed sample before TF3's `PlayBGM`, waiting ones
  included, and a waiting effect re-placed elsewhere read as "uploaded
  again". The harness's `places_in_aram(uploaded=True)` leaves out the ones
  marked 3, and the test's `before` uses it; the rest of the test is as it
  was.

The round trip measured again with the final runtime: the same numbers as
in the table above, to a frame, with and without the `.msu`; no gameplay
tick of the turn got longer.

#### Tests, with the branch's tools (`.local-tools`: `project`, `cartridge`)

* the-advocate `just test`: 29 passed.
* `SOUNDFONT=FluidR3_GM.sf2 just test-game`: 164 passed, 6 skipped.
* ABL, `PATH=<worktree>/.local-tools/bin:$PATH just tests`: 1686 passed, 2
  skipped. No golden moved.
* The ports' root `just boot`: 201 passed, the two new ones included.
* Not run on the merged tree: main brought converter and events changes
  (Cardón's) after these runs, which merged clean and touch no runtime.

#### What the suite does not cover

The idle pump and the pieces on real hardware —both cores seek the `.msu`
on the spot—; a `.msu` seek that times out mid-effect; an effect played
while it waits, with the `.msu`, for how late it sounds (the draft above).

#### When merging

Install `project` and `cartridge` (the runtime path; no Rust changed).
Branches: the-advocate, the ports and the book, `chaja-tfw-turn-audio`.

### 2026-11-22, Carpintero: what to look at

No capture: what changed is how long the screen stays black between the
command grid and the battle screen, and a still image cannot show a
length of time.

**How to try it**: any fight —the first one is the Sandflower on the
beach, map 12, walking into it from (11, 33)—. Each turn: A on a plate of
the command grid (map 3), the walk onto Monster A on the battle screen
(map 1) and A, until the grid has control again. Before, each of those
two jumps stopped on a black screen for one long tick: about a second
without MSU-1 (64 frames into the battle screen, 33 back) and nearly two
with it (105 and 102). Now both are an ordinary door fade, whose longest
tick is the map's own load, 16 frames.

* **With MSU-1**: the build's folder as it is, `frozen-world.msu` and its
  `.pcm` tracks next to the `.sfc`. This was the worse of the two.
* **Without MSU-1**: the `.sfc` alone in another folder, so the effects
  come from the cartridge.

What to listen for in both: the battle's sound effects. They now go up
after the fade, in the idle time of the following ticks, so one played
right after arriving freezes the picture a few frames while it uploads,
and with MSU-1 it can be heard a little late (the draft
[`an-effect-played-while-it-still-waits-is-heard-late`](an-effect-played-while-it-still-waits-is-heard-late.md)).
