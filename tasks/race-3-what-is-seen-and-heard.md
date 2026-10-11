---
name: "Race 3: what is seen and heard"
description: "The race's controls card as a message, and the sound effects inside forced routes"
type: feature
status: done
assignee: taro
---

# What

Milestone 3 of `race-and-what-comes-next.md`: gaps 4 and 5. It branches from
`main` at `69e66ed`.

* **The controls card** (`EscapeInst`): decided, option (a). A
  fork of 49 that changes the `ShowPicture` for a `ShowMessage` with the same
  text as the image.
* **The sounds inside the routes**: what
  `sounds-inside-move-routes.md` asked for. The case that asks for it is the race's
  bridge, but general.

Reserved numbers: opcode 0x32 and far RAM $7E79A0-$7E79BF. Neither
was needed.

# Status

2026-09-27, in `testing/`: done. What is left is taro's, playing: see
below.

# The card

The text, read from the game's image:

    Escape from Lashe City

    Use the UP and DOWN arrow keys to change lanes, and avoid the
    traffic!

    Fewer crashes means better rewards!

    Press any key to begin.

It does not fit in a window of 39 columns by four rows, so it is two
boxes: the title and the controls; the crashes and "Press any key to begin."
Fork in `parches/manual/mapas/Map0049.json`, layers from the original.

**The `KeyInputProc` that waited for the key was removed**, and the `ErasePicture` of
the image that is no longer there. The message is closed with A and the `KeyInputProc`
then asked for yet another key, with the screen black and nothing saying so:
two presses where the original asks for one. Variable 151, where it stored the
key, is not read by any map nor any common event (measured over `data/`).
What is lost: in the original any key starts, and here only the one that
closes the message.

# The routes' sounds

## How it turned out

Order 35 of a `MoveEvent` goes with two bytes after it, the index of the sound effect
in `Temas.sonidos` —the same as `OP_SOUND`—, and the ROM plays it with
`sonido_tocar`, the `OP_SOUND` path: with MSU-1 and without it, without costing a
frame. `sonido_heroe` in `ruta_del_heroe.s` and `sonido_ev` in
`rutas_de_eventos.s`. It is still dropped inside a jump (RM2k does not
execute it there) and in a page's own route (there is nowhere to put the
operand; only one asks for it, that of event 40 on map 2).

**First the hero's route had to stop being copied** to a 32-byte
buffer: the cut fell silently, and with two-byte operands it could fall in
the middle of one. Now it is a pointer to the bytecode, like an event's. Nine
hero routes in `release` went over 32 (the bridge's six, the
`SceneDriver` on 14, one on 19 and one on 45). It came out cheaper in bank 0
and in BSS.

## What goes into each package, and what does not

The sound effect goes into the map's audio package, like a `PlaySound`'s,
so it competes with the music. taro's rule was applied —no
instrument loses rate— map by map, comparing the rate of each
theme-instrument pair of the `release` allocation before and after (a script that
wraps `build_varios`). Where it cost, the sound effects that only a route asks for
do not go in: `SE_DE_RUTA_SIN_PAQUETE` in `tools/audio/snes_music.py`, with the
why for each map.

They sound, with the music allocation identical pair by pair:

    map   new route sound effects in the package
    13    Blow5
    21    Blow4
    28    Switch2
    33    Blow1, Blow6
    51    Wind7 (the race's bridge; Annihilation2 was already there)
    60    Blow6
    61    Blow6
    62    Blow6

and on 8 and 19, where they already were because of the pages. They do not sound:

    3     Decision1, Blow1 to Blow6, Shot2 (the evilrhys scene): they do not fit
          even with the samples at the minimum. Switch1 does, through the pages.
    7     Blow2: it lowers an instrument of Deflector1 from 22,9 to 16,4 kHz
    13    Flash1  } each new sound effect in the cartridge takes a directory
    21    Earth4  } entry away from the first batch of `copias`; with two
                    new ones two hits go down 7 kHz. Earth4 also lasts 1,36 s
                    and would fit clipped
    14    Kill3, Sword1, Sword2, Explosion4: with them `hzbreach` stops
          being an exit theme and the package does not fit
    121   Earth8 (test map): it lowers 25 pairs

All the ones that went in last less than three quarters of a second, so
they sound whole. And **Annihilation2** —the hit against the edge of the
lanes and the one at the end of the bridge— became whole, at 8 kHz: it sounded clipped
and looped. Any higher makes 49's sound effects wait for the `PlayBGM`.

What would be left for some day: the first batch of `copias` counts the
cartridge's sound effects, so each new sound effect costs the music even if its
package has room. It is what left out Flash1 and Earth4. Changing that
is a decision about the allocation, not about this task.

## Heard

In the whole race (`test_la_carrera_entera`), on the bridge six
14-frame Wind7 and one 87-frame Annihilation2 start, and the hit starts 101 ticks
before the `Teleport` to 53: it sounds whole. The bridge's audio is in
`pruebas/snapshots/playthrough/carrera-entera/el-puente.wav`.

# Tests

`just cartuchos` and `just pruebas` green on each commit and on the
merge with `main`.

* **New: `pruebas/rpgmaker/test_sonido_en_ruta.py`**, with the cases
  `sonido-en-ruta`, `sonido-en-ruta-evento` and `sonido-en-ruta-salto` (map
  10, `Close1`, which was already in its package): on the hero it sounds with the
  third step starting, on an event it sounds, and inside a jump it does not
  sound and the route continues. With the converter dropping the order, the first two
  go red.
* `pruebas/abl/test_msu_efectos.py`: with the `.msu`, the route's one sounds at 22
  kHz with the WAV's envelope.
* `pruebas/abl/test_recorrido_carrera_golden.py`: photographs the card's two boxes
  (`el-cartel-1`, `el-cartel-2`) and counts the bridge's sound effects.
  Its photos are still unblessed.
* No golden of the suite changed.

# What taro has to test by playing

* The race's intro: the card in two boxes over black, that it reads
  well, and that one A press after the second starts the race.
* The bridge: the six winds while the car crosses and the hit at the end,
  with MSU-1 and without it.
* The hit against the edge of the lanes (pressing outwards in an edge
  lane): that it sounds whole and does not stutter.
* Where reachable, the maps that gained sound effects: 33 (Blow1 and Blow6),
  21, 28, 60 to 62, 13.

# Tested

taro, on 2026-09-27, on the SNES with the FX Pak: everything worked, including the path
of selling the Idol, bribing the guard and taking AG7; the race without lag or
bugs (the companion at the wheel, too). Separate is the black hero after
changing graphic on the same map (Lazer Teeth HQ, Boss Wick).
