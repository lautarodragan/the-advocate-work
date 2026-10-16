---
name: "PlayBGM's fade-in is dropped"
description: "The compiler reads a PlayBGM's volume, tempo and balance and emits it without the fade-in, so the theme starts at once"
type: bug
status: wishlist
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
