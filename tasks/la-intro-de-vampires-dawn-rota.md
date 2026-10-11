---
name: "Vampires Dawn's intro, broken"
description: "VD's map 3 ('Intro') builds alone, but instead of the panorama with the title it shows still stripes and red blocks; it isn't BOOT_FRAMES"
type: bug
status: testing
assignee: taro
agents: [Hurón]
---

Seen by Carpintero on 2026-10-11 (`boot-frames-por-cartucho.md`): with the floor at 90 it looks the same, so it isn't the boot. If it is an engine error with panoramas, it may be in other games too.

## The cause (Hurón, 2026-10-11)

**It's the engine's, and it's in any game**: a zero-byte DMA on the SNES is a 65536-byte one, and `load_map`, `load_sprite` and `load_above` (`runtime/load_graphics.s`) fired theirs with what the map's record said without checking whether it was zero.

* **Zero sprite tiles wipe VRAM.** VD's map 3, alone in the cartridge (`maps = [3]`, `party = []`), draws nobody: `SPRITE_TILES = 0` and `SPRITE_CGRAM = 0` in its record. The DMA uploaded 64 KB of the LZ2 buffer —uninitialised WRAM, which snes9x fills with `$55`— over the whole VRAM from `$0000`: dumped, the whole VRAM is `$5555` except the tilemaps, which are written afterwards. The stripes are that pattern (alternating columns of colour 1) and the red blocks, the panorama's tilemap with its palettes. The loop runs fine (`ticks` advances); it isn't a hang.
* **Zero background colours dirty CGRAM.** A background that is all panorama has no colours (`MAP_CGRAM = 0`): the palette went 128 times over the whole CGRAM, window included. With map 3 together with 4 and 27 —so that its page compiles and the message shows—, the map now has sprites and the panorama comes out, but the "Skip Intro ?" window comes out **white**. **ABL has it today on maps 94 and 99** (all panorama, `MAP_CGRAM = 0`); it didn't show because the other palettes are uploaded afterwards and no test reads CGRAM.

With 4 and 27 in the cartridge, map 3 already has 52 sprite tiles —two leader candidates, which come from the other maps—: in the whole game what would be seen is the white window, not the stripes, which come from building it alone.

Against RM2k (the original with Wine, `RPG_RT_2015.exe`): the whole panorama and the "Skip Intro ?" without background, at the bottom, with Yes/No.

## The fix

A `beq` after each `sep #$20` that follows the length calculation (Z is from the `asl`): branch `huron-vd-intro` of the-advocate, `6f933ff8`. New test in ABL, `pruebas/rpgmaker/test_dma_de_cero.py`: a copy of `release` with map 94's sprites at zero in the record; VRAM from `M_VRAM_MAP` on has to stay the same as untouched. **Red before the fix**, with the global tools: "sin sprites, 19050 palabras de la VRAM desde $1800 quedaron distintas".

## Verified

* VD's map 3 built alone with the fix: the panorama, still, like the original. With 4 and 27 in the cartridge, the "Skip Intro ?" window is no longer white. The captures, with the original alongside: `/shared/capturas/2026-10-11-vd-intro/`.
* ABL, with the-advocate `6f933ff8` (`cartridge` and `project` installed locally) and the ports at `b499ab4`: the suite, 1177 green (1176 + the new one), no golden moved. `abl.sfc` `24dd24adb52f…` (before `ea49ff07fd9d…`).

## What the suite doesn't cover

* **CGRAM**: the emulator doesn't let it be read, so the guard for the colours —the one that changes something in ABL, on 94 and 99— is covered only by having looked at it in VD. No ABL golden saw it: none shows the window on those maps.
* Zero tiles and colours of the upper layer (`load_above`): I didn't see them on any map; the guards are there for the same reason, with no path that executes them.
* A real map without sprites: the test fabricates it by patching map 94's record.

## What remains and isn't part of this

* The intro's message without background comes out over a black band: on a map with the panorama in mode 3, the panorama is the BG2 that the window uses in its 80 lines. It was already a divergence (the window without background and the upper layer); it was stated in it, branch `huron-vd-intro` of the book, `88c8b9c`.

## When merging

* the-advocate: `huron-vd-intro` (`6f933ff8`), only the runtime. Reinstalling `cartridge` in the global isn't needed if it is merged in `~/the-advocate`: the runtime is built from there.
* the-advocate-ports: `huron-vd-intro` (`b499ab4`), the test and its line in the README. No goldens.
* the-advocate-docs: `huron-vd-intro` (`88c8b9c`).
