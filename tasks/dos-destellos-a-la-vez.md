---
name: "Two flashes at once"
description: "Kersh stays blue on the terrace: two flashes together upload only one palette"
type: bug
status: done
---

**On the terrace of map 32, the Agency Captain —Kersh— stays tinted blue
for several messages**, until the full-screen `FlashScreen`. In RM2k the
flash fades out on its own while the conversation goes on. taro saw it on
2026-09-23 with the build of `3e028a0`: `kersh-blue-{1,2,3}.png` and the three
`kersh-blue-original-*` in `pruebas-manuales/2026-09-23-3e028a0-snes/`. It is not
new.

They are two `FlashSprite` of `EV0005` almost back to back: command 97 on event 2
—blue, 40 tenths— and command 101 on event 6 —Arden, light blue, 40 tenths—, with
a single message in between.

# The cause, read in the code

There are `FLASH_MAX` flash slots (4), but **a single 32-byte `flash_buf`
and a single `flash_pend`**. `flashes_tick` runs all the slots and each
one copies its palette there, so on a frame with two live flashes the vblank
uploads only the last one's. When Kersh's ends, its last frame —strength
zero, that is, the palette as it was— is overwritten by Arden's and never reaches
CGRAM: Kersh's palette keeps the last tint that did get uploaded. It is fixed by
the next full palette upload, which is the `FlashScreen`.

It was born like this with `FlashSprite`, in `7340b1a` (2026-09-04): the test that
came with it has a single flash, and no case in the suite has two that
overlap.

# The fix

**One palette per slot**, in far RAM: `FAR_FLASH_PAL`, $6900 to $69FF,
reserved on 2026-09-23 —the BSS had 75 bytes left and 96 more were needed—.
What is pending upload goes in byte +7 of each slot of `flash_ev`,
which was free: the CGRAM entry of its palette, which is never zero because
the sprite ones start at 128. The vblank uploads all the pending ones. `flash_buf`,
`flash_pend` and `flash_pend_cgadd` leave the BSS: 34 bytes.

It is guarded by `test_destellos_encimados`, with the case `destellos-encimados`: event
1 flashes for ten tenths, and two tenths later event 4 flashes for thirty. At
tick 90, event 1 has to look as it did at the arrival tick. It was seen red
against the `main.s` from before.

Two things that were hard and are worth knowing:

* **The comparison has to be against the arrival tick**, not against one
  after both flashes: with the bug the first one **never comes back**, so
  the end is tinted too and the first version of the test passed with
  the ROM broken.
* **Flashing the hero on map 6 changes the palette allocation of the whole
  map**: the first version of the case did that, and the goldens of
  `grafico`, `grafico-heroe`, `sprite-actor` and `destello-compartido` moved —with
  either of the two `main.s`—. That is why the second target is event 4.

With all that, `just pruebas` green and no golden moved.

**taro, on 2026-09-26: it improved, but it is not perfect; he suspects what is left is lag and not a bug.** The chips investigation measured that on the terrace, in the heavy loops, almost 200 of the 262 lines go to recomputing palettes (`destello_tick` + `flashes_tick`): it continues in `la-terraza-pierde-cuadros-en-los-destellos.md`.
