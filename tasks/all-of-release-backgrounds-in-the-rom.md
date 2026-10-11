---
name: "All of release's backgrounds in the ROM"
description: "Every background a battle in the cartridge asks for goes in the ROM, at 128x64 with 16 colours and enlarged by the console; the replacement is kept for what can't be known when converting"
type: feature
status: done
---

From taro, on 2026-09-27, after trying to take two of the three backgrounds out of the
ROM (it saved 32 KB, from 75.8 % to 75.0 %, and he thought it made little difference): **the
opposite, put in the ROM all the backgrounds `release`'s maps use,
with quality as low as needed**, and leave the replacement only for
what doesn't fit. With MSU-1 nothing changes. It follows
`todos-los-fondos-en-el-msu-1.md`.

Everything measured here is from 2026-09-27, on `91b5a37d` (before) and this branch
(after), with throwaway scripts.

# 1. Which backgrounds a release battle can ask for

With `release`'s converter running in-process: the troops named by a
compiled `EnemyEncounter`, the map background of each map with random
encounters (going up the tree), and if the map names none, that of each terrain
of its blocks.

Of the game's maps, **thirteen**:

    SJBackdropABL04   ev in 2 (the droid)
    ABLBackdropSJ02   ev in 32
    ABLBackdropSJ03   random in 20, 28, 59; ev in 9 (Back Alleys, Sector 27)
    ABLBackdropSJ08   random in 21 and 26; ev in 21 and 26 (Rat Tracks)
    SJBackdropABL01   random in 32, 60, 61, 62 (the Warehouse)
    mroad4            random in 76; ev in 76 (Sorbe Mountain)
    66, by cell terrain (cells of the map in parentheses):
      forest5 (2,946)  river5 (1,738)  mroad2 (970)  plains5 (823)
      desert1 (464)    plains6 (361)   Galaxy (198)

Of the test maps `release` also carries, three more: `underbridgeback`
(255, which is on the main path), `Castle` (133) and `SurlBattleBack` (269).

No `EnemyEncounter` in a game map asks for "the place's"; only the
cases `pelea-113`, `pelea-222` and `tropa-talan-aura`. With that, in all the
maps without encounters the background comes from the terrain under the hero, and there
`LasheBat`, `Forest1`, `Sea`, `SeaBeach` and `Galaxy` show up: they're only asked for by a
test page that fights in those maps, and when converting it's not known which one.

# 2. Space

With the method in `AGENTS.md` (a `.res` linked to the recipe's `.o`) and
bank 1 relinked without the `.align`:

    release                 cartridge  last bank    bank 0   bank 1   BSS  ZP
    before (91b5a37d)         81.8 %   $71 (19 KB)     189    7,863   138   4
    after (this branch)       82.2 %   $72 (1.4 KB)    189    7,761   138   4

Before, there were twelve whole banks left ($72 to $7D) and 19 KB in $71. After,
eleven whole ($73 to $7D) and some 41 KB in gaps from $70 to $72: the bytes that
grew are 17 KB, half a bank, and the other half is the sequential packing of
`bancos.py`, which leaves a block that doesn't fit for the next bank.

**The remaining main path** (Tasgarde, Eisen, 259 and 255) is about ten
banks according to `el-mundo-y-lo-que-sigue.md` (`m2` 112 against `m4` 122,
measured with the three backgrounds from before). With this it has **one** left instead of
two, plus the backgrounds of its own maps, at 4 KB each. Milestone 3 of that
plan (first-fit decreasing) gave eight more.

# 3. What each variant weighs

**Measured** weights: each background actually converted and compressed with `lz2`.
"LZ2 8bpp" is the stream that would decompress straight into WRAM, with the
fixed planes included. In bytes, colours included (the 2 B index per tile, in
the deduplicated ones):

    the game's 13                 raw     dedup  dedup+mirror     LZ2  LZ2 8bpp
    256x128 16c 4bpp (before)   213,408 200,224    199,520   139,269  149,550
    256x128 8c 4bpp             213,200 181,360    180,432    95,281  101,383
    256x128 4c 2bpp             106,600  71,272     70,168    37,265   43,983
    128x64 16c 4bpp (chosen)     53,664  53,472     53,216    39,782   42,659
    128x64 4c 2bpp               26,728  21,224     21,096    11,521   13,588

    the 16 the cartridge asks for
    256x128 16c 4bpp (before)   262,656 245,056    244,256   166,285  178,736
    256x128 8c 4bpp             262,400 217,408    216,224   111,867  119,082
    256x128 4c 2bpp             131,200  86,864     85,408    44,070   52,100
    128x64 16c 4bpp (chosen)     66,048  65,728     65,472    47,396   50,856
    128x64 4c 2bpp               32,896  26,160     25,952    13,945   16,464

Deduplicating doesn't help: a photo doesn't repeat tiles, and the mirror barely adds. What
the ROM's three weighed before was 49,248 B.

What each one costs, **against the 16**:

    variant                   +ROM      leaves the path  code             load frames
    256 16c raw              +208 KB   doesn't fit      0                 as before
    256 16c LZ2              +114 KB   doesn't fit      ~150 B bank 1     ~+15 (model)
    256 8c LZ2                +61 KB   0 banks          ~150 B bank 1     ~+15 (model)
    256 4c 2bpp raw           +80 KB   0 banks          ~10 B             as before
    256 4c 2bpp LZ2            -5 KB   two              ~150 B bank 1     ~+15 (model)
    128x64 16c raw            +17 KB   one              +102 B bank 1,    +4 (measured)
                                                        +512 B of table
    128x64 16c LZ2             -2 KB   two              ~250 B bank 1     ~+5 (estimated)

"Leaves the path" is what's left after the main path's ten
banks, before milestone 3. The code of the ones that weren't implemented is
estimated. **None touches bank 0.**

The chosen one's load frames are `ESC_CUADROS`, measured without MSU-1 in
snes9x and bsnes: the world battle goes from 6-7 to 10-11, Sector 27's (three
battlers) from 12 to 16; with MSU-1, 5 and 11-12, the same as before. Those of the
LZ2 ones aren't measured: they come from `LZ2_CICLOS_POR_COMANDO` and
`LZ2_CICLOS_POR_BYTE` in snes_convert.py, which is a high bound, and 32 KB per
buffer plus the copy of the second. The raw 2bpp ones would use the same
DMA path as before, without CPU.

**How each one looks**: `/shared/capturas/2026-09-27-fondos-en-la-rom/variantes/`,
one PNG per background with the `.msu` one as reference and each variant next to it,
with its weight. At 128x64 with 16 colours it looks pixelated but with all the
tones; with four colours the sky, the droid's monitor and the
signs are lost.

# 4. The recommendation, and what was done

**128x64 with 16 colours, uncompressed, enlarged by the console.** It's the
only one that puts in all the backgrounds without costing the main path more than half a bank
and without throwing away the colours. LZ2 on top would save another 19 KB in exchange
for one more frame and one more path; it isn't needed today, and it's noted.

* **The converter** (`escena_de_la_rom`) puts in the ROM **everything that's
  asked for**: troops, maps with encounters and the terrains of the maps with
  encounters that don't name a background. `escena.FONDOS` no longer exists. The
  replacement (`ABLBackdropSJ08`) goes in only if some battle can land on a
  background that isn't there: a place troop in a map without encounters.
* **The fallback** (`escena.fondo_liviano`) is 128x64, 16 colours merged
  by `merge_least_visible`; `respaldo_bytes` emits it in the order
  `esc_doblar` reads without arithmetic, with half a byte of two planes per byte.
* **The ROM**: `esc_llenar` leaves in the two buffers only the fixed planes (one
  32 B DMA per tile), and `esc_doblar` —new, in bank 1, entered through the
  fast mirror— writes the bottom half of each tile with the
  `respaldo_doble` table, in both buffers at once.

# Tests

* `test_msu_cada_camino_dibuja_su_fondo` and
  `test_msu_una_pelea_del_mundo_lee_su_terreno` (formerly `…_o_el_reemplazo`):
  the clean background in WRAM against the light one **built from its doubled
  indices**, without going through `respaldo_bytes`: it compares what the ROM does
  against the image, not against the same byte order. The world one is now
  plains6, not the replacement.
* `test_escena_una_pelea_del_lugar_usa_el_fondo_del_mapa`: 60 now has its
  background in the ROM.
* `test_escena_una_pelea_cuyo_fondo_no_esta_usa_el_reemplazo` (new, with the
  new case `pelea-113-en-7`): place troop 113 in 7, without
  encounters and with a single terrain (`LasheBat`, which the ROM doesn't carry): the
  replacement, and along the way the `M_TERRENO_PLANO` branch of `esc_terreno`, which
  until today no test ran.
* **Goldens that changed, on purpose** (the background without MSU-1 becomes 128x64;
  in `msu-mundo-rom`, also, from the replacement cave to the prairie):
  `batalla`, `batalla-blanco`, `batalla-droide`, `batalla-hab`,
  `batalla-hab-blanco`, `batalla-hab-dos`, `batalla-item`,
  `batalla-item-blanco`, `batalla-textos-lejos`, `encuentro`,
  `msu-datos-rom`, `msu-mundo-rom`. Before and after in
  `/shared/capturas/2026-09-27-fondos-en-la-rom/goldens/`.

# What taro has to look at

* **Without MSU-1 (Mednafen)**: the usual battles with their background pixelated at
  double size, and **the world ones with the terrain underfoot** (prairie on arrival,
  forest, mountain, desert, river), not the cave. Sorbe Mountain (76) with its
  mountain road. Entering the battle takes about four more frames.
* **With MSU-1**: same as before, the quality one.
