---
name: "ShowPicture, phase 1"
description: "The One year previously card"
type: feature
status: done
---

### ShowPicture

The "One year previously" card is the only `ShowPicture` the port does.

It is the easy case of the picture system: 
- it appears only once, between two fades, 
- over a single-tile map, 
- so it fights no ChipSet or CharSet for VRAM or colours. 

What to keep at hand when touching it:

* **One card per ROM**, and who keeps the slot is decided by
  `Imagenes.elegir` looking at all the maps in table order, before
  compiling anything. With "the first that comes along" the two sides could choose
  differently, because the maps are compiled in an order that depends on whether the ROM
  carries a window.
* **The fade is a tone fade, not a transparency one.** The two `MovePicture` leave
  `top_trans` at zero and move (r, g, b). And **the duration comes in tenths**:
  the 35 of the first one are 210 frames. That raised the "1 year earlier" page
  from 105 tenths to 160, and that is why `test_a_year_before.py` went from 900 frames to
  1200.
* **Fifteen colours out of the PNG's 226**, and the glow's gradient
  bands. It is the declared cosmetic of this round; taro still has to
  confirm it by playing.
* **The state lives at `$7E30E8`, in far RAM**, because it did not fit in bank 0:
  the BSS was at **7680 of 7680**. Whatever asks for bank 0
  RAM next will have to loosen something.
* **`armar_paleta` leaves Y at 32.** Calling it from an opcode without `phy` moves
  the interpreter's cursor. It cost the first red and did not look like a broken
  card: the page kept running, just a different one.

#### What the whole picture system would cost

Measured over the game's 328 maps, not estimated:

    ShowPicture in the game                    34, in 23 pages
    distinct cards                             20
    pages that show 2, 3 and 4 at once         2, 3 and 1
    commands today's model can do               7 of 34
    with the screen already tinted to black    10 of 34

And what each one would ask for, counted per command —one command can ask for
several—:

    the PNG's transparent colour               21
    stuck to the map (fixed_to_map)             9
    translucent (top_trans)                     8
    zoom other than 100                         7
    rotate or wave                              6
    saturation other than 100                   5
    the position from a variable                2

What that table says is that **the expensive part is not the cards**. Of the 20
distinct ones, six are text cards that fit in a tall object
—`Oneyearprev`, `MeanwhileLashe`, `SevDaysPrev`, `Ready`, `Fortitude` and the
16x16 `9`— and the other fourteen are large illustrations, five of them
**exactly 320x240**, that is, the whole screen.

A 320x240 one **cannot be done with objects**: scaled it is 256x224, which is
8x7 objects of 32x32 —56 of OAM's 128, 896 tiles of 8x8, 28 KB of a sprite
bank that measures 8 or 16— and on each of its 224 lines it spends 32 of the 34
tiles per line, which means it takes out every character on the map.
For those a layer has to be lent to the card, with all that implies: the map
is reloaded when it is erased. It is exactly the case the note in `eventos.py` already
anticipated, and that is why the cutscene shortcut —tinting to black first— works
for ten of the 34 and not for the other twenty-four.

If some day it is done in full, the order that comes out of these numbers is: first
**the transparent colour** (21 commands, and it is one colour less in the palette),
then **more than one card at once** (six pages), then **the borrowed
layer** for the illustrations, and at the end zoom, rotation and wave,
which are five or six commands each and each one a system.
