---
name: "The compressed title screen"
description: "The title takes 31.7 KB uncompressed; in LZ2, by the same path as the Game Over, it would be 15.2 KB without changing a pixel"
type: refactor
status: done
assignee: Chajá
---

From taro, on 2026-09-28, after the Game Over screen
(`game-over-screen.md`). Carpincho left `pantalla_subir` and
`tools/port/pantalla_completa.py` not knowing which screen they upload, so
that the title could use them, and measured:

    today, uncompressed                 31,744 B
    LZ2, without changing a pixel       15,241 B   (saves 16.5 KB)
    light in the ROM + quality in .msu   2,483 B   (saves 29 KB)

taro chose the second: only compress. The title screen has to come out the
same pixel for pixel: the `title` golden does not change.

2026-09-28, in `testing/`: done by Chajá on his branch, over `main` at
2df404b7. What is left is taro's: see "What taro has to test".

# What taro has to test

* **Look** at the title on power-up, without and with MSU-1: it has to be
  the usual one, and appear just as fast. And come back from "Resume the
  Story" with B: the title has to come back without a long flicker.
* Start and load a game from the title, and a Game Over that returns to the
  title: the title track that keeps playing on starting
  (`title-track-keeps-playing-on-starting.md`) was not touched, but it goes
  through the same place.

# What was done

* **The image travels by the Game Over one's path**: an LZ2 stream with the
  tiles, the tilemap and the colours (`tools/port/pantalla_completa.py`),
  and a second row in `pantallas_tabla`. `titulo_tiles`, `titulo_celdas` and
  `titulo_cgram` no longer exist; the menu stays uncompressed, separate.
* **The menu's colours go in the same stream**, below the image's
  (`comprimida(..., debajo=)`): the whole CGRAM in one DMA, as before, and
  without another DMA in bank 0.
* **The image's tilemap moved** from $4000 to `PANTALLA_MAPA` ($7C00), which
  is where `pantalla_subir` puts it. What is seen does not change; two
  `.assert`s in `titulo.s` make sure the image and the menu do not overlap
  in VRAM.
* **`pantalla_subir` was split in two**: `pantalla_descomprimir` (to
  `PANTALLA_BUFFER`) and `pantalla_subir` (from there to VRAM and CGRAM).
  The Game Over calls both in a row.
* **The title is decompressed at boot, before the BOOT_CUADROS wait**, and
  `titulo_subir` only uploads it. See "The frames".
* **`pantalla_subir` leaves the PPU as `ppu_reset` does, not at zero.** It
  set TMW and CGWSEL to zero, which the Game Over does not care about
  because the reset follows it; the map follows the title, and with TMW at
  zero the message window stopped covering the objects: nine goldens red
  (`window`, `talk-60`, `apertura-830`…), green again with TMW at $10 and
  CGWSEL at $30, the values of `ppu_altos`.

# The frames

Measured with snes9x, frame by frame from reset, against the `title`
golden (throwaway scripts):

                                         before  decompressing     at
                                                 when showing      boot
    the title appears, from reset          43          52             43
    it returns, from the B in the slots     2          11              2

Decompressing the 34,304 B takes about nine frames. Doing it when showing
the title meant nine more frames of black on both paths, so it was moved to
boot, which had frames to spare waiting for BOOT_CUADROS; and on returning
from the slots it is not decompressed again, because nothing that runs in
the title writes bank $7F. In `release` the buffer finishes filling at
frame 42, meaning that **the boot of a ROM with a title overruns
BOOT_CUADROS** by one or two frames: it does not matter, because what
counts frames since reset is the loop, and that is reached after the title.
The converter's count (`cuadros_del_arranque`) does not add it, on purpose:
it looks after ROMs without a title.

# Space

`just space release`, before (2df404b7) and after:

    data banks       115 of 124, 9 free          115 of 124, 9 free
    gaps             15,250 B                    32,139 B
    bank 0           50 B                        175 B
    bank 1           5,135 B                     5,122 B

The title's stream is 17,407 B (the image, the tilemap and the colours, from
34,304 raw) against the 34,304 uncompressed of before: the 16.9 KB that are
freed stay as gaps in the used banks and are not enough to free a whole
bank. Bank 0 gains 125 B: three `titulo_subir` DMAs that went away.

# Tests

No new ones and no golden changed. `title`, `title-2`,
`title-slots`, `title-slots2`, `game-over` and the `CINEMATICAS` come
out the same.

**A path that `just tests` does not execute**: cancelling the slots
screen with B and returning to the title, which now uploads the image
**without** decompressing it again. No test returns to the title that way.
I ran it by hand with a throwaway script —the capture comes out equal to the
`title` golden, two frames after the B, as before— but with empty SRAM:
with filled slots the screen draws more things, and none of them writes
bank $7F according to the code, not according to a test.
