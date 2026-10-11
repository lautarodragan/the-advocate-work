---
name: "The effects' directory"
description: "Sound effects share slots in the SPC700 directory, and with the entries the copies free they give back to the music what can be given without lowering anyone"
type: refactor
status: done
---

# What

The SPC700's sample directory has 255 entries —the SRCN is one byte— and it
was full: the music's samples, the copies of `snes_music.copias` and one
entry for each sound effect in the cartridge. Without entries there were no
more copies, so when a full package ate the ARAM —battle's and map 3's full
effects, which go in full whatever the cost— the instrument dropped in **all**
the themes that shared the sample, not only in the package's. With the full
effects, 175 (theme, instrument) pairs dropped without MSU-1: the table is in
`efectos-de-sonido-sin-recortes.md`. taro accepted it, and the request was to
free the directory to give it back.

# Status

2026-09-26, in `testing/`: done, in the agent's branch. What's left for
taro: listening to `/shared/audio/2026-09-26-directorio/` (it has its
`LEEME.txt`).

# What was measured before choosing

All over `release`'s allocation at 868259d (main with all the MSU-1 tracks),
with the arguments the converter passes to `build_varios` captured and the
allocation rebuilt with each variant. "Dropping" is losing more than 0.5 kHz,
as in the table of the 175.

**How many slots the effects need.** The most loaded package brings 20 (map
3; then map 2 with 18, map 19 with 11), and colouring the graph "two effects
touch if they share a package" with DSATUR gives **20 slots**, the minimum
possible. So of the effects' 92 entries, 72 are freed.

**How many copies `copias` would want without a cap**: 146 (262 music
samples); with 20 slots for the effects, 119 fit. In other words the directory
stops being the limit almost entirely just by giving the effects their slots.

**But making more copies the way they were made lowers the rate for others.**
With the free entries and the usual rule —the worst first, without looking at
anyone—: of the 175 pairs, 103 remain, but **56 pairs drop compared to today**
(the koto in `rshinld` 27.7 → 13.9, cymbals from 22 to 17). It's the usual
thing with copies: the sample that's freed goes up and competes in the other
groups it's in. So the second batch of copies only accepts the ones that don't
lower any pair, and of those the one that adds the most: **of the 175, 117
remain, and 0 drop**. Trying only the worst first with that condition left
161: most of the good ones aren't "the worst".

**What no directory gives back**: of the 117 that still drop, 64 are from
themes **limited by their own package** —the battle one (battle, 20),
`evilrhys` (map 3, 13), `3D-Galax` and `Gaden` (map 19, 13 and 6),
`TF3_1_awe` (map 2, 11)—. A copy separates the themes outside the limiting
package; nothing gets the ones inside out of there except shrinking that
package. The three that lose the most are precisely those.

**The other ways, measured**:

* **A directory rewritten with each package**, with only its own things. The
  only thing it adds to what was done is ARAM: a package's directory would be
  some 30 entries instead of 241, some 850 B more for samples. Rebuilding the
  allocation with 850 B more in each package (an upper bound): `evilrhys`
  +0.3 kHz on average, the battle one +0.4, `TF3_1_awe` +0.7. And the cost is
  large: the SRCN is written in each theme's stream, so it would have to be
  translated in `music_frame` for each note, or the stream rebuilt per
  package; and the theme already playing when a package loads plays with its
  old SRCNs. Not worth it.
* **Renumbering the music's samples per package**: the same as the above
  without the ARAM saving; the copies are no longer limited by the directory.
* **Reassigning each effect's slot on loading** (the package's N-th in slot
  N): the same 20 slots as colouring, but `sonido_tocar` would have to look
  up the effect's slot in the package's list or in a 92-byte RAM table.
  Colouring it in the converter leaves the slot written in `sonido_tabla`, as
  before.

# What was done

**Effects share slots** (`lugares_de_efectos` in
`tools/audio/snes_music.py`): each effect has its number —the one the
packages' lists carry—, its `muestra_tabla` row after the music's, and a
directory slot from `SE_PRIMERA` on, which is the SRCN of its `sonido_tabla`
rows. The ROM notes in `FAR_EFECTO_EN` ($7E78D0, one byte per slot) which
effect was uploaded to each slot: `anotar_efecto` in
`rom/src/paquete_de_audio.s` forgets the one that was there if the package
brings another, `fila_de_muestra` reads the noted one's row, and
`sonido_tocar` doesn't play an effect if the one noted in its slot is another
(a common event's, which belongs to no package). The effects with MSU-1 stay
the same: they're uploaded in slot order, and `escribir_msu` puts them in the
`.msu` in that order.

**The copies in two batches** (`copias`): first the usual ones, the worst
first until the directory is full as it was when each effect had its own
entry —they're the ones taro listened to—; then, with the freed entries,
only the ones that don't lower any pair's rate compared to those, the one
that adds the most first. That batch allocates with what the effects
**actually** occupy: the free `SE_ENTEROS` go in what the music leaves free,
and without that the copies for 26 and 261 ate it and the converter stopped.
And it allocates with the directory full, so no copy charges anyone its four
bytes; the directory ended up at 241.

**`repartir` keeps the count up to date** instead of adding up each
constraint again on each round: it gives the same budgets (compared over
`release`'s allocation) and the second batch is thousands of allocations.
With that, and trying the copies in the order of what they added the previous
time —it gives the same copies as trying them all on each round, compared in
`release`—, `build_varios` takes less than one second more than before;
trying them all it was more than ten.

**The title goes silent before loading the map** (`titulo_lazo`), and not
afterwards with `music_boot`. When loading a game, `tema_actual` is already
the saved game's, and its samples the title had uploaded stayed fixed —"the
ones of the theme playing don't move"— splitting the ARAM: map 1's package,
now fuller, didn't fit, and the map's `PlayBGM` uploaded it again whole.
Loading into map 1 went from 76 to 153 frames; this way it's 99.

# How much it gives back to the music

Without MSU-1, `release`. "Dropped" is against the allocation without the
full effects paid for (the one in the table of the 175); "drop", the same
afterwards; "rise" is against today, more than 0.5 kHz.

| Theme | Dropped | Drop | Rise | What rises the most (without full → today → after) |
|---|---:|---:|---:|---|
| `T_VGFighterMAX_Masako` | 20 | 20 | 0 | (limited by battle) |
| `3D-Galax` | 13 | 13 | 0 | (limited by 19) |
| `evilrhys` | 13 | 13 | 0 | (limited by 3) |
| `TF3_1_awe` | 12 | 11 | 1 | bass 16.7 → 14.6 → 16.7 |
| `Lunar_Pyramid` | 11 | 6 | 6 | kick 16.0 → 14.1 → 22.0 |
| `T_ProjectJustice_DiscLoad` | 9 | 9 | 0 | |
| `vswar` | 9 | 1 | 8 | polysynth 21.1 → 12.6 → 21.1 |
| `cd2` | 7 | 0 | 9 | bass 16.7 → 13.3 → 23.3 |
| `escape_newyork` | 7 | 5 | 3 | polysynth 21.1 → 12.6 → 21.1 |
| `rshinld` | 7 | 7 | 0 | |
| `wb3shop` | 7 | 1 | 7 | bass 16.7 → 13.3 → 23.3 |
| `Gaden` | 6 | 6 | 0 | (limited by 19) |
| `cd4` | 6 | 6 | 0 | |
| `wb3town` | 6 | 6 | 0 | |
| `wb3mlair` | 5 | 0 | 5 | bass 16.7 → 13.3 → 23.3 |
| `11h035` | 4 | 0 | 6 | hit 51 16.4 → 13.9 → 22.0 |
| `C3classi` | 4 | 4 | 0 | |
| `Deflector1` | 4 | 3 | 2 | kick 16.0 → 14.1 → 22.0 |
| `Fire_Mustang_…` | 4 | 0 | 5 | guitar 19.9 → 13.6 → 22.0 |
| `KSSMKEND` | 4 | 4 | 0 | |
| `hzbreach` | 4 | 0 | 7 | guitar 19.9 → 13.6 → 22.0 |
| `Tnt07` | 3 | 0 | 3 | bass 16.7 → 13.3 → 23.3 |
| `bubstix` | 2 | 2 | 0 | |
| `dcbest` | 2 | 0 | 2 | bass 16.7 → 13.3 → 23.3 |
| `golden_axe-turtlevillage2` | 2 | 0 | 3 | hit 42 16.0 → 14.1 → 22.1 |
| `prepara` | 2 | 0 | 3 | program 88 19.9 → 13.8 → 22.1 |
| `Fantasia_Of_The_Wind` | 1 | 0 | 2 | strings 16.4 → 14.1 → 22.1 |
| `lufsorr` | 1 | 0 | 2 | hit 35 16.2 → 13.9 → 21.8 |
| `MML2_MotherZone`, `pn28year` | 0 | 0 | 3 | |
| **total** | **175** | **117** | **77** | |

**No pair drops compared to today**, not even by a little: 189 of the 338
rise somewhat and the others stay the same. The median of the 338 goes from
14.1 to 18.9 kHz (without the full effects paid for it was 16.2).

The ones that still drop and aren't from their own package —`rshinld`,
`cd4`, `wb3town`, `T_ProjectJustice_DiscLoad`, `C3classi`, `KSSMKEND`— share
a sample with the battle theme or with `3D-Galax`, and the copy that would
separate them lowers some other theme a bit: the rule rejects it.

# What it cost

* **Loading frames**, jumping from the title to 1, 2, 3, 8, 11, 19, 20, 23,
  26, 32, 261, 17, 255, 13, 9, 18, 121, 2, 3, 19 (hardware frames from the
  jump request to the end of the fade), against 868259d: map 1 +15, map 20
  +6, maps 2, 32, 255 and 121 +4; map 9 −2 and map 18 −3; the rest the same.
  The packages that weren't full now carry copies at a higher rate. Loading a
  game into map 1: from 76 to 99 frames (without silencing the title first it
  was 153).
* **Cycles**: `anotar_efecto` twice per effect in the package and
  `sonido_tocar`'s question, a few dozen cycles each; nothing next to
  uploading the samples.
* **Bank 0** in `release`: from 526 to 388 B free (the new code in
  `paquete_de_audio.s`, `efectos_de_sonido.s` and `titulo.s`).
* **Far RAM**: $7E78D0 to $7E78FF for `FAR_EFECTO_EN`, one per slot;
  `SE_LUGARES_MAX` in snes_music.py is that size.
* **Cartridge**: the music's samples go from 295 KB to 461 KB (58 more
  copies). The effects, their 92 samples and their pitches, byte-for-byte
  identical: only their SRCN changed.

# Tests

`just techos` (the mix changed), `just cartuchos` and `just pruebas` green,
`test_cores.py` twice and `test_musica_escrituras.py`. New, both in
`pruebas/rpgmaker/test_musica_paquete.py`:

* `test_los_efectos_comparten_lugares_y_a_las_copias_les_sobran_entradas`:
  from the cartridge, that the directory isn't full —the copies stopped
  because none added anything—, that no package has two effects in one slot
  and that the slots are those of the most loaded package. With main it
  fails: 255 entries. Since milestone 4 of the world
  (`mundo-4-el-capitulo.md`) it's called
  `test_los_efectos_comparten_lugares_del_directorio` and no longer asks for
  the directory not to be full: with the chapter's themes it fills up.
* `test_un_efecto_no_suena_con_la_muestra_de_otro`: `Success2` on map 10
  with another effect noted in its slot doesn't sound, and without touching
  anything it does. With `sonido_tocar`'s question removed, it fails.

`test_la_partida_cargada_arranca_con_su_musica` looked at `music_apagada`
three frames after choosing, in the middle of loading the map; now it waits a
tick, because during loading the title is silent on purpose.

**What `just pruebas` doesn't cover**: that the second batch of copies
doesn't lower anyone is ensured by `copias` when choosing them, over the
allocation, and it was measured with the real allocation (`Banco`, with the
rounding to blocks) comparing each pair against 868259d: none drops. The
loading frames were measured by a separate script. And the path of a common
event's effect that isn't in any package —the one `sonido_tocar`'s question
protects— doesn't exist in the game today: the test forces it.

# To listen to

`/shared/audio/2026-09-26-directorio/`, with its `LEEME.txt`: the three that
lose the most from the full effects (which sound the same: they're limited by
their package) and three of the ones that recover, before and after, without
MSU-1, at -16 LUFS.
