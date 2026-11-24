---
name: "A snes9x savestate round trip is not exact"
description: "Serializing and unserializing at once, with no frame in between, leaves snes9x a few bytes of WRAM apart from never having done it, some hundred frames later: anything that restores a savestate mid-play goes another way"
type: bug
status: draft
author: chaja
agents: [Chajá]
links:
  relates: [how-much-of-a-test-is-the-emulator-drawing]
---

Seen by Chajá on 2026-11-22, on A Blurred Line's `release`, with the
installed snes9x core (`libretro-snes9x 20260816.181733.g890b5d445538`),
the-advocate at `1240ecc9` and the ports at `0699267`, while measuring
[How much of a test is the emulator drawing](how-much-of-a-test-is-the-emulator-drawing.md).

What was seen: 1000 frames from power-on with no input, once straight and
once with `retro_serialize` followed at once by `retro_unserialize` at
frame N. At the end the WRAM differs in four bytes, for N = 5, 40, 300
and 700: the stack, where an interrupt landed (`$1FEF`, `$1FF1`, `$1FF2`
for N = 700; `$1FC7`–`$1FC9` for N = 5), and `$7ED3` in all of them
(229 straight, 228 after the round trip). The audio's length is the same.
A round trip before the first frame, right after `retro_load_game`, is
exact: same screens, WRAM and audio over 2000 frames on all ten
cartridges, which is what the harness's kept power-on relies on.

To reproduce: `~/scratch/chaja/emu/bench/exact.py <N>` (a `retro.Console`
of `abl.sfc`, the round trip with `lib.retro_serialize` /
`lib.retro_unserialize`, and the WRAM compared).

What it rules out today: drawing a frame later by replaying it from a
savestate, and any harness shortcut that restores a state in the middle
of a play —a boot reused from a savestate taken after its frames—. It
also means a test that saves and loads a state would not be checking the
same run the suite plays.
