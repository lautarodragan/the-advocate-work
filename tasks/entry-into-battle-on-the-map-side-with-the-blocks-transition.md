---
name: "The entry into battle, on the map side, with the blocks transition"
description: "Leaving the battle, and entering on the battle side, it's already the blocks one; entering, on the map side, it's a fade"
type: feature
status: done
assignee: taro
---

From taro, on 2026-09-30: "let's make the transition into battle the same as
the one out of it —the blocks one—. It's already like that in the battle-side
half, on entering, but on the map side it's a fade out".

## What the game asks for

The `System` of *A Blurred Line* (`rom/data/db/system.json`) says
`battle_start_fadeout = 16`, `battle_start_fadein = 17`,
`battle_end_fadeout = 17` and `battle_end_fadein = 16`. In
`Game_System::GetTransition`, 16 is the zoom and 17 the mosaic. That is,
**the game doesn't ask for blocks to cover the map: it asks for the zoom**,
which the console doesn't do and which since 2026-09-26 had been a fade. The
ROM wasn't disobeying the `System`; what taro asks for is a design change,
and it went into `divergences/the-way-into-battle-in-mosaic.md`.
The `System` isn't read: the mosaic always goes.

The return to the map (`battle_end_fadein = 16`, the zoom) **is still a
fade**: taro didn't mention it. If he wants it in blocks too, it's the same
change in `battle_fade_to_map`, which is in bank 0 and would cost about 15 B
there —or a bridge to the far one—.

## What was done

`battle_fade_in` (`tools/runtime/battle_fade.s`, in the far bank) writes
MOSAIC tied to the brightness as the map goes down, with the same ramp as
`battle_fade_out`, and turns it off once in black. Sprites don't pixelate
—the hero stays sharp—, same as in the teleport's mosaic; the message window
that opened the battle does, because it's a background layer. Bank 0 didn't
move: 182 B free in `release` before and after.

## The test

`test_la_entrada_tapa_el_mapa_con_el_mosaico_de_la_salida`, in
`rom/pruebas/rpgmaker/test_fundido_de_pelea.py`: it measures the side of the
blocks of each frame **by looking at the screen** —on each line, at which
columns the color changes; with blocks of side n they can only be multiples
of n, and it counts per line so that the hero, who doesn't pixelate, doesn't
hide the map—, and demands that the map's descent on entering be the same
sequence as the battle's on leaving.

Red without the fix: `al entrar [], al salir [2, 2, 3, 4, 4, 5, 6, 6, 7, 8,
8, 9, 9, 10, 11, 11, 12, 13, 13, 14, 15, 15]`. With the fix, both the same.
A first version that counted per pixel and not per line lost the mosaic from
9 onwards near black, with the hero dominating the changes.

`just pruebas`: 901, green (900 + this one). No golden moved: none falls
inside the transition, which spends no ticks.

The strips, from the `linkage` case talking to the droid —the 26 frames
before black—: `/shared/capturas/2026-09-30-entrada-a-la-pelea/antes.png` and
`despues.png`.

## For taro

Enter a battle —the opening droid, or any encounter—: after the two flashes
the map has to turn into blocks down to black, with the hero sharp on top.
And say whether you want the return to the map in blocks as well.

When merging there's nothing to install: it's only the runtime, which the
global assembler reads from the main tree.
