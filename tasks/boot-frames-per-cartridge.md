---
name: "BOOT_FRAMES per cartridge"
description: "Vampires Dawn's start map asks for 46 frames of BOOT_FRAMES and the ROM has 44, a constant: have each cartridge carry its own without moving ABL"
type: feature
status: done
assignee: taro
agents: [Carpintero]
---

From the re-sweep of 2026-10-10 (`other-games-the-re-sweep.md`): VD's map 3 doesn't fit in `BOOT_FRAMES` (46 of 44). Raising the constant moves, in ABL, the frame in which the loop starts, and with it the tests that count frames. Tijereta's proposal: have the converter emit each cartridge's own, `max(44, the estimate)`, so ABL doesn't move.

## What was done

Tijereta's proposal, as is (branch `carpintero-boot-frames` of the-advocate: `3b03dffc` and the merge of `main`):

* `runtime/far_ram.s` no longer has `BOOT_FRAMES`: it has `BOOT_FRAMES_FLOOR = 44`, with the why.
* `rm2k-snes-audio cartridge` reads that floor —as it used to read the constant— and writes into the cartridge's `musicdata.inc` `BOOT_FRAMES = max(floor, ceiling of the estimate)`, next to the header (further down, `rm2k-snes-assemble` splits the file into banks and the comments are lost). It no longer refuses to build; the only ceiling is the `boot_frames` byte: more than 255 doesn't build.
* The floor stays in the runtime and not as a knob in `rm2k-snes.toml`: what it protects belongs to the runtime, and no game asks for another.
* The book (branch `carpintero-boot-frames` of the-advocate-docs): the decision `el-arranque-esta-dimensionado-para-el-paquete-de-arranque.md` and `internals/audio.md`.

No opcode was needed.

## Verified

* Before, with the global ones: VD's map 3 alone (`maps = [3]`, on Aguará's copy of the game with `Music/` trimmed) doesn't build: "the boot doesn't fit in BOOT_FRAMES ... 46 frames, against 44".
* After: it builds, `BOOT_FRAMES = 46`, and in snes9x it leaves the wait at frame 46 (`nmi_seen`): it didn't overrun.
* ABL: `abl.sfc` `5852b72358b6…`, same as main; ABL estimates 40.5 and stays at 44. The suite, with my tools on the-advocate `main` 0b1ed124 merged and the ports at 493f39e: 1174 green.
* `just crate-test rm2k-snes-audio` and `just test` green on the merge.

## What the suite doesn't cover

* No ABL cartridge goes past the floor: the "the estimate wins" path is executed only by the unit test of `cartridge::boot_frames` and the hand-built VD above.
* **VD's map 3 ("Intro") looks broken**: instead of the panorama (Vampires Dawn's title, `mode3`) the screen shows stripes and red blocks, still. It isn't because of the boot: with the floor at 90 it looks the same. Left for another task.

## When merging

Reinstall `rm2k-snes-audio` (`just install rm2k-snes-audio` in `~/the-advocate`), **together with the merge**: the binary reads `runtime/far_ram.s` from the checkout it was installed from, and an old one with the new runtime doesn't find `BOOT_FRAMES`, and a new one with the old runtime defines the symbol twice. The rest of what it builds (`cartridge`, `convert`, `project`) doesn't change code.
