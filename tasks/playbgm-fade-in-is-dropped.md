---
name: "PlayBGM's fade-in is dropped"
description: "The compiler reads a PlayBGM's volume, tempo and balance and emits it without the fade-in, so the theme starts at once"
type: bug
status: testing
assignee: taro
agents: [Carpintero]
---

Seen by Cardón on 2026-10-14 (`what-the-compiler-ignores-silently.md`),
tools `14e200fc`, ports `f775b66`.

**What is seen**: not played. `PlayBGM`'s first parameter is the fade-in in
milliseconds; the arm of `compile_command` takes the others and emits
`OP_BGM` with no fade, so a theme that RM2k fades in starts at full volume.
Found by changing that parameter in every `PlayBGM` of the game: the
compiler's answer did not move.

**How much ABL uses it**: 3 commands set one, all of 1,000 ms: map 16
event 1, and map 18 event 36 (two pages). 585 of its 588 `PlayBGM` use 0.
Other games: Sunset Over Imdahl 25, Vampires Dawn 16, Dooms 2 4, The Book
of Three 1.

**How to see it**: `rm2k-snes-events compile` on `abl/data` with the
`release` request, with and without that parameter changed to 0 in those
commands: same `events.json`.

## Defined (2026-10-16, Carpintero)

An audio detail: three commands in ABL, a few dozen in other games;
nothing stops. **Done**: `OP_BGM` carries the fade-in and the driver
ramps the volume in over it, with a compiler unit test and a ROM test that
hears the first frames quieter. **First step**: whether the music driver
already has a volume ramp to reuse.

## Doing (2026-10-19, Carpintero)

The driver already had the ramp: `FadeOutBGM`'s, `bgm_fade_tick`, a
sixteen-bit level that scales each music voice's volume —or the MSU-1
track's— by a factor from 0 to 256. The fade-in is the same ramp going up:
`bgm_fade` at 2, from zero by the step `ceil(65536 / frames)` each frame,
the same number `OP_FADE_BGM` carries. `OP_BGM` carries it as a word after
the step, and the map table and `OP_SYSTEM_BGM` carry it too, so a map's
own song and a battle's fade in if their RM2k music asks.

## Done (2026-10-19, Carpintero)

`OP_BGM` carries the fade-in as a word after the step —the same
`ceil(65536 / frames)` `OP_FADE_BGM` carries, clamped to easyrpg's ten
seconds— and the ROM ramps the level up from zero over it, with the
fade-out's ramp going up: `bgm_fade` at 2, `bgm_fade_rise` and, with
MSU-1, `bgm_fade_track`, both in FAR3. A song fading in that gets a
`PlayBGM` of itself goes on fading; a `FadeOutBGM` in the middle drops from
where it got to. `bgm-fade-in-dropped` is gone from the degradations.

**Tests**: the compiler's `a_play_bgms_fade_in_is_carried`; ABL's
`test_volume_and_tempo.py` —two seconds of fade-in: `bgm_fade` at 2 when
the song starts, each voice the stream's times `FADE_N` a second in, the
stream's once it ends— and the ports' `test_book_of_three_music.py` —map
21's `roved` starts with `bgm_fade` at 2, and it is over a second later—;
red with main's tools.

**Heard**: map 21's fade-in runs but cannot be heard, in RM2k either:
`roved` starts with about a second and a half under the ambient sound, so
its notes come after the fade. The recordings, before and after, are in
`/shared/audio/2026-10-19-book-of-three-music/`.

**Not covered by any test**: the fade-in over an MSU-1 track
(`bgm_fade_track`, which the MSU-1 fade-out test does exercise going
down), and a `FadeOutBGM` in the middle of a fade-in.

**When merging**: see the battle task; this is the same branch.
