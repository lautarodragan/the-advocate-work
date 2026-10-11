---
name: "The battle scene on the console"
description: "Background and enemies composed when the battle starts; the dead disappear"
type: feature
status: done
---

**The battle scene, composed on the console and not in the converter.**

Today `tools/port/escena.py` bakes background and monsters into one image per troop, at
32 KB each (six in `abl`). That multiplies images per combination, and a
dead enemy is still visible.

The idea, from taro on 2026-09-21: store **each background once and each enemy
once**, and compose when the battle starts.

- The clean background goes to WRAM; the battlers are overlaid with `AND`/`OR` per
  bit plane —8bpp is planar—, and the scene goes up to VRAM as today.
- Each battler has **15 colours plus transparent**: its low 4 bits come
  from its drawing and the high 4 are the palette it gets in this battle. It's an
  artistic decision —colours are lost compared with today— and it goes to `parches/`.
- When an enemy dies, its cells are recomposed from the clean background and
  uploaded by DMA. No precomputed versions.
- With no background —or without MSU-1, later on— it's the same code over a flat background.

PoC: two backgrounds in the ROM, `SJBackdropABL04` (the droid battle, troop 82) and
`ABLBackdropSJ03` (the random encounters in the Back Alleys: troops 88–93 and
99–101). If both don't fit, only the Back Alleys one.

What decides whether it works: **how long it takes to compose the busiest scene** and **how
the battlers look at 15 colours**.

## The PoC, done (2026-09-21)

It works in `abl`: the droid battle over `SJBackdropABL04` and the random
encounters in Sector 30 and Sector 27 over `ABLBackdropSJ03`, inherited from the map as
`Game_Map::SetupBattle` does. A dead enemy disappears. The how is in
`tools/port/escena.py` and above `escena_subir` in `main.s`; the fifteen
colours of each battler, in `parches/battlers/`.

The captures to look at are in `/extras/capturas/escena-runtime/`
—before and after, and an erase frame by frame—, and those of the eleven goldens
that moved, next to each one as `<nombre>.nueva.png`, without
replacing it.

**How what decides whether it works is measured**, which isn't written here because it changes:

* how many frames composing takes: `ESC_CUADROS`, in RAM, as soon as the
  battle opens. The busiest in the PoC is troop 100 —the encounter in
  `test_escena.py`—.
* how much it takes up: the sum of the ROM segments in the `.dbg` of the
  `abl` build, against the previous one.
* bank 0: the method in `AGENTS.md`, in the four cartridges.

## What's missing for it to be the mechanism of every battle

* **The other backgrounds.** The game names about fifteen between the
  `EnemyEncounter`s and the maps, at 32 KB each uncompressed. Compressing them
  is cheap on this side —the clean background is already built in WRAM, so the
  decompression goes there and the composed buffer comes out of it with an `mvn`—, and it's
  what would be needed before adding them; or bring them through MSU-1.
* **The map's background in an `EnemyEncounter` that names none**
  —`parameters[2] == 0`—. Today it goes flat; RM2k uses the map's, just like a
  random encounter. And the terrain's, `background_type` 1, which the port doesn't
  have.
* **A troop that two `EnemyEncounter`s ask for with different backgrounds** keeps
  the first, as before: the background belongs to the troop and not to the battle. For
  that the opcode would have to carry it.
* **The erase is all at once**: RM2k fades out the enemy that dies. Here it goes in
  the frames it takes to upload, in rows of tiles, and the battle freezes
  while the ROM recomposes.
* **The fade into battle doesn't exist in the port**: the composition
  happens with the screen black. RM2k does two flashes and a 41-frame
  transition to leave the map and another of 41 to come in, so the black
  would fit inside the first one.
