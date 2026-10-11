---
name: "The terrace drops frames during the flashes"
description: "Recomputing FlashSprite's and FlashScreen's palettes eats almost the whole frame on map 32's terrace"
type: bug
status: done
---

taro notices lag in the terrace scene (map 32) and in Kersh's blue flash
(`dos-destellos-a-la-vez.md`: "it got better, but it isn't perfect; what's
left is lag"). The chips research (`chips-sa-1-y-s-dd1.md`, "Dónde se va el
cuadro hoy") measured that in the heavy loop iterations almost 200 of the 262
lines go into recomputing palettes: `destello_tick` ~103 and `flashes_tick`
~94. It's pure CPU, and measured in snes9x: on hardware it may be worse (see
what the bsnes measurement of map 11's minigame gives).

Ideas that research proposed, without a chip: computing the flashed palette
once per intensity step and not every frame, or spreading the work across
frames. Measure in bsnes first.

# Status

2026-09-26, in `testing/`: both computations redone without changing a single
value. `just pruebas` green and no golden moved; `test_cores.py` green twice.
What's left is for taro to play the terrace —slot 2 of the `.srm`s in
`/shared/experimentos/2026-09-26-paralelos-cada-n/`— and say whether the lag
is gone, also in Kersh's blue flash.

Besides the goldens, the terrace scene was run with the ROM from before and
the one from after pressing A once per loop iteration and not per frame —that
way one dropped frame fewer doesn't shift the scene—, and the 1971 screens,
one per iteration, came out identical in snes9x and in bsnes.

# Where the time went

Measured with the chips research's line probes
(`/extras/scratch/chips/instrumentar.py`, adapted), in the usual scene:
`ir_al_mapa(32, 41, 8)`, up, and A every 20 frames until the battle. snes9x
and bsnes agreed to within one line.

* **`flashes_tick`, ~94 lines per character flash.** Almost all of it was
  `tabla_canal_flash`: for each of the 96 entries of the three tables, two
  products and a hardware division with their waits, some 150 cycles each.
  `armar_paleta` (16 colors), the copy to `FAR_FLASH_PAL` and
  `restaurar_tablas` are the least of it.
* **`destello_tick`, ~104 lines on the odd frame.** Two parts: building the
  three tables (`una_tabla_de_destello`, some 70 cycles per entry: compare,
  subtract and a `jsr` that built the `prod31_tabla` index) and passing the
  palettes through them (`destellar_rango`, ~135 cycles per color). The second
  is the one that remains.

# What was done

Both tables are built by walking instead of computing each entry, with the
same result entry by entry (checked for every possible target and strength,
32 x 32 in each):

* `tabla_canal_flash`: the blend's numerator always grows by the same amount
  from one entry to the next (255 - alpha), so it divides once and then
  carries the remainder. ~30 cycles per entry.
* `una_tabla_de_destello`: the distance to the target goes down by one and
  then up by one, so X walks the `prod31_tabla` row. <30 cycles.

"Once per strength step" wasn't tried: a `FlashSprite`'s strength changes
almost every frame, and the `FlashScreen`'s step is tied to the even and odd
phase; with the above it was no longer needed.

# What was measured

    terrace, A every 20 frames         before   after
    dropped frames, real ROM             9         0      (snes9x and bsnes)
    iterations over 262 (probed)        62         0
    flashes_tick, worst iteration      101        42
    destello_tick, worst iteration     110        91
    both together, worst iteration     198       132
    worst iteration with flashes       290       224      (probed: ~27 from probes)

Bank 0 (`TABLAS`, release): from 721 free bytes to 777. BSS: one more byte
free (`dest_v` and `dest_d` are no longer used; `dest_hacia` became two
bytes).

What's left, if more were needed: `destellar_rango`, 72-91 lines on each
frame of a `FlashScreen`. With word tables already shifted into place it
would save ~20% per color, but they need 64 more bytes of bank 0's RAM or
moving them to the far one with the indices swapped to another register.
