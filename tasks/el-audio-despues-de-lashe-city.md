---
name: "The audio after Lashe City"
description: "Recover the quality that the packages of Lashe City's new maps take away from the instruments without MSU-1"
type: bug
status: done
---

# What

Lashe City's milestone 1 (2026-09-27) added new audio packages (38 and
47 with `vswar` and `golden_axe-turtlevillage2`; `38+cd4`, with three themes
together and 1267 B free), and without MSU-1 **47 (theme, instrument) pairs go down** and
26 go up; the median goes from 18.9 to 16.5 kHz. `vswar` is the most affected
(polysynth 21.1 → 12.6, cymbals and toms 22 → 14.1); `escape_newyork` loses
again the polysynth (21.1 → 12.6) that the directory had given back to it. Part of it is
the three-theme package; part is copies that the second batch of
`snes_music.copias` stopped making (the bank goes from 221 to 212 samples).

With MSU-1 it is not heard (all the themes have a track). It is tackled **when
Lashe City's maps are finished** (each milestone adds packages and moves it
again), with the same method as `el-directorio-de-los-efectos.md`:
measuring pair by pair with `Banco` against the `main` from before the new maps,
and seeking that no instrument of the themes already there ends up worse.

**From milestone 2 (2026-09-27):** the converter does not know that `Kfmus5` keeps playing
from 41 to 45 (`temas_heredados` cuts at 41), so those packages do not
reserve room for it. It was not listened to without MSU-1: look at it in the same pass.

And from the race's milestone 3: Flash1 on 13 and Earth4 on 21 were left out
of their packages (`SE_DE_RUTA_SIN_PAQUETE`) because with them two
hits went down some 7 kHz. See whether with what is done here they fit at no cost.

# Status

2026-09-27, in `testing/`: done on 77996bf (main with Lashe City and the
race complete), on the agent's branch. For taro: listen to the wavs from
before, main and after (with their `LEEME.txt`), and play the scene in the
Vipers' HQ (38) and the guards one (47) without MSU-1: when `vswar` turns on the
scene freezes for a moment while it uploads.

# How it was measured

The arguments the converter passes to `build_varios` in `release`,
captured at 93af39f (the main from before Lashe City's new maps) and
in each variant, and the real allocation —the `Banco`, with rounding to
blocks— rebuilt with each one. A pair is (theme, program or hit), without the
key, which changes with the new themes. "Goes down" is losing more than 0.5 kHz,
as in the previous tasks. Against 93af39f, main lowers 48 pairs (the 47 of
milestone 1 and one from milestone 2).

# What was found

**`vswar` does not fit with anyone.** Alone, at the rate it had, it is 61 KB of the
63 each package has. Before Lashe City it sounded only as an exit theme
of 26 —alone in ARAM—; now 38 and 47 turn it on and put it together
with `golden_axe` (77 KB) and `38+cd4` with `cd4` (82 KB). With those packages
**no allocation** gives back what there was: a script measured it, adding up, group
by group, each sample at the old rate, and the only five groups that do not
fit are those of `vswar` with another theme. And since the outside themes
share samples with the inside ones, the copies that separated them stopped
being made: that is the rest of the 48.

I tried the cheap things first, and they are not enough: counting the first batch of copies with
the usual sound effects (47 pairs below before), tolerances against the
floor (46 to 53), isolating the cluster of `vswar`, `golden_axe` and `cd4` with copies
(50 and 55: it eats the directory), and even the second batch with the old
rate as a floor (46):
while the cluster does not fit, any copy moves something inside it.

**On the pages they never sound together.** On 47 the guards scene
turns on `vswar` and on the same page `golden_axe`. On 38 you enter the
dump through a `Teleport` (events 20 and 21), `vswar` sounds in the scene of the
empty HQ, and you leave through another one that first turns on `golden_axe` (event 26). So
`vswar` can be uploaded alone when its `PlayBGM` asks for it, like an exit
theme; what it cannot do is release the sound effects, as an exit one does: with
`vswar` playing the dump's chests are opened (Bow2).

# What was done

**The apart themes** (`TEMAS_APARTE` in `tools/audio/snes_music.py`, `vswar`
on 38 and 47). They go in a fourth list of the package, after the exit
ones; the converter allocates them **alone with the package's sound effects** and does not
pass them on to the maps you leave to from there. In the ROM,
`extra_aparte` (rom/src/paquete_de_audio.s): the `PlayBGM` of one that is not there
uploads the theme and the package's sound effects, releases the other themes and leaves the
package incomplete so that the next `PlayBGM` completes it. `extra_de_salida`
and `extra_aparte` are two entries of `extra_en_lista`.

**`Kfmus5` from 41 to 45.** `temas_heredados` carried from a map with `PlayBGM`
its themes to all its destinations; 41 and 40 only turn on themes for leaving
(`golden_axe`, `tsmedit`), so `Kfmus5`, which arrives at 41 from 37, did not
carry on. Now each `Teleport` notes which theme it jumps with (`Temas.salto`), and on
a map whose `PlayBGM` are all exit ones each jump carries its exit
theme or what came in. The startup one keeps the usual rule: it is the
router, and what comes in there would go out anywhere. With that `Kfmus5`
is inherited on 40, 42, 43, 44 and 45, which costs nothing —those packages are
empty—, **and on 20**, through event 4 of 45, which is the jump to 20 from 19
that came with the copy and cannot happen: that lowered two hits of
`Lunar_Pyramid` and two of `wb3shop` from 22 to 14 kHz. It goes in
`SALTOS_QUE_NO_SE_DAN` (snes_convert.py), which also takes away main's
`20+tsmedit`, false for the same reason.

**Flash1 on 13 and Earth4 on 21 sound.** What left them out was not
their package but the first batch of `copias`, which counted one directory
entry for each sound effect in the cartridge even if they already share places: each
new sound effect took away a copy. Now it counts the 92 from when taro
listened to it (`SE_DE_SIEMPRE`), and both fit without moving any pair (measured at
0.1 kHz). Earth4 lasts 1.36 s: on 21 it goes whole at 22 kHz with an alias
(`Earth4@entero`), in what the music leaves free; the one on 3 stays as
it was.

**And the converter's report** subtracted twice the extra of the whole
sound effects in "to spare" (since fc78dad the bank's constraints already include it):
49 said -1573 and had 1.7 KB to spare.

# How it ends up

Against 93af39f, without MSU-1, `release`:

| | main | after |
|---|---:|---:|
| pairs below before (more than 0.5 kHz) | 48 | 4 |
| of those, also below main | — | 0 |
| median of the 338 pairs | 16.5 | 18.5 (before 18.9) |

The 48 go back to the old rate (or within 0.1 kHz) except four, which stay
as in main:

    Deflector1  hit 36      22,0 -> 14,1 -> 14,1  (and 40: 14,0 -> 14,0 -> 21,9)
    TF3_1_awe   program 34  15,2 -> 14,0 -> 14,0  (from milestone 2)
    vswar       hit 45      22,0 -> 14,1 -> 14,1
    vswar       hit 46      22,1 -> 14,1 -> 14,1

All four are limited by the battle package or by `18+hzstream`, and the copy
that would separate them lowers others by a tenth; forcing the `vswar` one makes
the allocation release another one of `vswar` (strings 48). Against main 26
pairs go down, all to the old rate or within 0.04 kHz: they are the ones that went up in main because of the
copies that were made differently. The new themes (`Kfmus5`, `tsmedit`,
`fm2bar_gs`) stay at the SoundFont's rate or a tenth below.

# What it costs

* **Loading `vswar` when turning it on**: 71 frames frozen on 38 when the
  empty HQ scene starts (measured with the case `tema-aparte`), and the same on
  47. In main those samples were uploaded on entering the map, with the package.
* **21 loads Earth4 whole**: some 30 KB more on entering.
* **49 with `golden_axe` playing** —you get there like that from 36—: the last
  sound effect of its list (Flame3) does not fit alongside and waits for the race's
  `PlayBGM`, which arrives before it is used; Evasion2, which sounds earlier, is there.
  The same on 64 with the race's theme, which turns on its own on
  frame 5. It is the decision `el-tema-que-suena-gana-y-los-efectos-esperan`; the
  converter warns about it, and it was checked in the ROM going through Arden's ending.
* **Bank 0** of `release`: from 344 to 280 B free. BSS and ZEROPAGE the same.
* **Cartridge**: 228 music samples instead of 220, 454 KB instead of 426.

# Tests

`just techos` redone (the mix changed: no theme clips), `just
cartuchos` and `just pruebas` green, and `release` with `SIN_CACHE=1` comes out
byte-for-byte identical. New:

* `test_el_tema_aparte_sube_con_los_efectos_del_paquete`
  (`pruebas/rpgmaker/test_musica_paquete.py`), with the case `tema-aparte`: on
  38, `golden_axe` and then `vswar`, which has to end up whole with
  Bow2 alongside, without `golden_axe` and with the package incomplete. With
  `extra_aparte` always answering no, it fails because of Bow2.
* `pruebas/herramientas/test_temas_heredados.py`: `Kfmus5` from 41 to 40 and to
  the vidcasts with the shape of those maps, the startup one with the usual
  rule, an apart theme that does not leave the map, and what `Temas.salto` notes.

**What `just pruebas` does not cover**: the pair-by-pair rates were measured by a separate
script against 93af39f; that 49's sound effects are there on arriving with
`golden_axe` and that in the HQ scene `vswar` sounds whole with Bow2, by a
throwaway probe over the walkthrough of Arden's ending; the 71 frames,
another one.

# Listened to

taro, on 2026-09-27, with the before/main/after wavs: all good, nothing to
change. He accepts the trade-off of Deflector1 (hit 36 at 14.1 kHz, 40 at
21.9) and TF3_1_awe's program 34 at 14.0.
