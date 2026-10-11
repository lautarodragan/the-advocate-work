---
name: "Music through the SPC700"
description: "The themes through the SPC700, with the shared sample bank"
type: feature
status: done
---

### Each map's audio package

The ARAM is 64 KB, and the instruments of the demo's eight themes are 53: the
sound effects that the Linkage Block and the Emitter Room ask for —43 and
55 KB— do not come anywhere near fitting. That is why there is **one package
per map**: when loading one, **the themes its pages can start and the sound
effects they ask for** are uploaded, in the order in which they appear, which
is the priority if they do not all fit. Each theme on its own is 8 to 32 KB,
so in the Emitter Room its two themes fit, along with the fourteen sound
effects and the previous map's theme, which keeps playing.

How it is done:

* **The samples have a fixed number across the whole cartridge**: the
  music's and, behind them, the sound effects'. It is the SRCN that the music
  stream already wrote, so not a single byte of the stream changed. The
  SPC700's directory has one entry per sample and **the ones that are not
  there point at silence**, a nine-byte BRR block.
* **Which samples a theme uses** is told by its stream: the values it writes
  into the SRCN registers (`muestras_del_stream`). The converter emits that
  list per theme, and per map its themes and the samples of its sound effects
  (`paquetes`).
* **The ones of the theme that is playing do not move**: the music keeps going
  during the fade, and overwriting a sample that is playing would be noise.
  The ones the new package also wants stay where they are, and the rest are
  released. What is missing gets placed in the first gap where it fits, going
  through the list of what is occupied in order (`paquete_cargar`,
  `colocar_muestra`).
* **The SPC700 driver learned to write the ARAM**: three more commands on port
  2 —a byte, the pointer and a block of triplets— next to the usual DSP pair.
  The music keeps sending pairs with port 2 at zero, and the upload goes in
  batches of 85 triplets with interrupts disabled, so the music falls a bit
  behind and is not lost. It is some 55 KB per second.
* **A `PlayBGM` of a theme the map did not bring** —the title's, or one from a
  common event— silences the music, releases everything and rebuilds the
  package with that theme first: it freezes the picture for as long as it
  takes. A sound effect that did not fit does not play.

What it costs: a jump's fade lasts as long as the upload takes. From map 1 to
the Emitter Room it is 58 frames lost, of which some 14 are the usual map
load: some seven tenths of a second more of black.

How it is verified, because the suite does not measure audio: the ARAM is read
from the core's saved state —`retro_serialize`, locating the driver— and each
sample the ROM says it has is compared with the cartridge's byte by byte, with
its directory entry. And `pruebas/rpgmaker/test_musica_paquete.py` enforces it
on its own: for the theme the ROM says it is playing, that each sample in its
`tema_muestras` has an entry in `FAR_ARAM_DE`. A state test is needed because
**silence does not change a pixel**, and the title screen's theme is the most
exposed: it is the only one no package brings —it comes from the LDB's
`title_music` and the packages are built with each map's `PlayBGM`s— so it
depends entirely on that path.
