---
name: "Compression of maps and graphics"
description: "How much each thing in the cartridge weighs, how much it compresses and how much it costs to decompress it; done: the pilot, the tiles and grids in LZ2 and the deduplicated poses"
type: refactor
status: done
---

# What

Compress what travels in the cartridge so that the rest of the game fits —some
7 MB uncompressed according to `decisiones/el-cartucho-se-queda-en-4-mb.md`— without
going past 4 MB. **The music is left out on purpose**: there is other work on the
samples, and taro prefers to compress the audio when everything about audio is finished.

This task **absorbs `medir-la-compresion-de-mapas.md`**, taro's idea of
2026-09-25 —chunks of blocks and separate layers for the grids—. Its four
variants are measured below, but the question it left open —whether the
grids were 5% or 30% of the problem— is only answered by looking at the
whole cartridge, and the whole cartridge changed the answer: what weighed the most
were the battle animations, which were almost all zeros. Hence a single
task and not two.

Measured on 2026-09-26 on `03c21fb`, with `release` freshly built. The numbers
are from that day and from that day's allocation of maps: whoever picks this up again
measures them again, does not copy them. The method is at the end.

# Status

**Done: the pilot and points 2, 3 and 4 of the recommendation.** Left are 5
(the mirrored poses) and 6 (battlers and backgrounds), which nobody started.

* The pilot: the battle animations without empty tiles (`bb3a4fc`).
* **2 and 3, on 2026-09-26**: the background tiles, the upper layer's, the
  sprites', the ChipSet animation's drawings and the grids travel in
  LC_LZ2 and the ROM decompresses them to WRAM when loading the map. See "What was
  done", below.
* **4, the same day**: identical poses are stored only once.

**taro has to play**: change maps a lot —with doors, teleports
and the save point— and fight, checking that the maps are drawn whole, that the
water and animated tiles move, that the characters walk with their
poses and that on returning from a battle the map and the walls are still where they were.
What looks different is **the black between maps**, longer: see the frames
below. And taro had to see a battle animation in the game because of the
pilot; that still stands.

# What was done, on 2026-09-26

Measured on `main` with audio step 6 merged (`2d6b665`), in
`release`.

    before all this (with the pilot)     2916,5 KB used, 71,2%, last bank $63
    tiles in LZ2                         2480,4 KB, 60,6%
    grids in LZ2 (and a new case)        2234,4 KB, 54,6%
    deduplicated poses                   2141,2 KB, 52,3%, last bank $46

    by class              raw        LZ2
    map_tiles            458,9    262,5
    sprite_tiles         287,8     62,4
    above_tiles           19,3     13,0
    anim_tiles            14,6      6,6
    map_celdas           278,2     32,1
    total               1058,7    376,9   (681,8 KB less)
    poses: 545 distinct of 732           (93,5 KB less)

The compressor is a separate project, `tools/lz2/`, with an optimal parser: it comes out
a bit smaller than the measurement's greedy one (262.5 against 266.4 on the
background tiles). It does not emit the increasing fill, which the ROM does not read.

**Load frames**, the loop iteration that loads each of the forty
maps, in the same order before and after and on the second pass —so the
audio package of each map is the same and the only thing that changes is the
decompression—. It includes the audio package upload, which is what weighs
the most:

    uncompressed               33,9 on average, 76 the worst (map 26, audio)
    with everything, at the end 40,3 on average, 80 the worst
    what compressing adds       6,4 on average, 14 the most (map 52)

Against the estimates taro accepted —5 on average and 12 the worst,
only the tiles— it ends up a bit above because it adds the grid, which was estimated
separately (1.2 on average, 5.8 the worst). The measurement's model (400 cycles per
command, 46 per byte) underestimated by 40%; the one the startup's count uses is
700 and 60, which what was measured does not exceed by more than half a frame.

**What would bring it down more**: a DMA to `$2180` for the literals and the fills, at
8 cycles per byte against some 46 for the `mvn`. It was ruled out for the same reason as in
the pilot —the clash of a general DMA with HDMA in the CPU's first
revision—, even though here the screen is off and HDMA could be turned off
while the load lasts. It was not tried on the console.

**Where**: the decompressor is `lz2_descomprimir`, in bank 1 (461 bytes with
its entries); bank 0 was left with 1029 free in `release` and 1727 in
`test-special`. The WRAM: `$7F0000` is the load buffer, `$7F6000` the
animation's drawings, and the grid at `$7E8000`, which is **the decision with a
cost**: `decisions/the-grid-lives-in-wram.md`.

**The grid and the battle**: the battle scene is the upper half of `$7F`, so
it overwrites the end of grids larger than 32 KB (today, only map 52's).
`volver_de_batalla` decompresses the whole grid again.

**How it was verified**: `test_lz2.py` does the round trip of each block of
each cartridge through the compressor and through a separately written reference;
`test_decompressed_load.py` compares, on the forty maps, the freshly
loaded VRAM, the grid and the animation's drawings in WRAM against what the
converter leaves uncompressed in `crudos/`, in snes9x and in bsnes, and the grid
after fighting on map 52 (case `battle-in-52`). It was seen failing
by breaking the fill and removing the second grid decompression; the
poses, by pointing each one at its neighbour (46 cases of the suite red).

# The X-ray

Adding up by symbol prefix the blocks of `mapdata.inc`, which is the
exact content of each one (the count by symbols from the `.dbg` works for
almost everything, but **it gets `map_celdas` wrong**: the grid crosses banks, and
subtracting the address of the next symbol cuts it at the border. That is why the
X-ray in `merge-release-and-test-main.md` gave 285 KB and the `.dbg` one
208: it is 278).

    release, 03c21fb           used 3162 KB of 4096 (77,2%), last bank $6B

    anim_batalla   548,0 KB   274 frames of 2 KB
    map_tiles      458,9 KB   one block per map, 8bpp
    sprite_poses   366,0 KB   732 poses of 512 B
    sprite_tiles   287,8 KB   one block per map, 4bpp
    map_celdas     278,2 KB   the grids
    muestra        262,2 KB   (audio: left out)
    tema_stream    206,4 KB   (audio: left out)
    battler         74,8 KB
    map_bloques     51,8 KB   the block dictionaries
    fondo           48,0 KB   the battle ones that do not go through the MSU-1
    paginas         39,8 KB   and evcodigo 39,2, mensajes 32,0, titulo_tiles 31,0
    above_tiles     19,3 KB   and anim_tiles 14,7, fuente_pre* 4 × 14,5

The grids **with their dictionaries** —`map_celdas`, `map_bloques` and
`bloque_pass`— are 329 KB, 10% of the cartridge: neither 5% nor 30%.

# How much each thing compresses

Per block, which is the unit that is decompressed: a map, a frame, a pose.
**LZ2** is Nintendo's LC_LZ2 (the one in the console's Mario and Zelda games:
copy, byte fill, word fill, increasing fill, and repeat with absolute
16-bit address in the output), with a greedy compressor with one
lazy step, verified with its decompressor. **LZSS 4K** is an LZSS with a 4 KB window
and lengths from 3 to 18, like those of many commercial games. **zlib -9** is the
reference bound; "together" is zlib over all the blocks of the class
stuck together, which says how much repeats **between** maps.

    class          raw       RLE     LZ2   LZSS 4K   zlib -9   together the domain's
    anim_batalla   548,0    27,2    20,4    78,5     20,0     13,8    without empty tiles: 36,0
    map_tiles      458,9   357,0   266,4   264,1    223,7    212,9    unique tiles across maps: 445,4
    sprite_poses   366,0   138,6    83,9*  103,5     67,4     64,0    repeated poses: -93,5
    sprite_tiles   287,8    91,6    63,5    82,6     53,0     33,4    unique tiles across maps: 44,4
    map_celdas     278,2   176,7    32,8    47,9     22,7     22,2    see the four variants
    battler         74,8    51,2    45,7    39,6     32,8     32,3
    map_bloques     51,8    35,7    28,3    25,7     19,9     15,8
    fondo           48,0    44,1    37,2    36,5     31,1     30,9
    evcodigo        39,0    37,6    21,4    20,4     15,9     14,2
    mensajes        32,0    32,1    18,8    16,7     13,3     13,3
    titulo_tiles    31,0    24,0    15,7    15,8     13,7     13,7
    above_tiles     19,3    16,0    13,1    12,9     11,2     10,6
    anim_tiles      14,6    11,7     6,7     6,7      5,6      5,5

\* Per bank of twelve poses. **Pose by pose**, which is how they are uploaded, LZ2 gives
139.1 KB.

What the domain columns say:

* **`anim_batalla` was 94% padding**: 1109 tiles with something out of 17,536, four
  per frame on average. It is already done: it is the pilot.
* **Map tiles do not repeat between maps** —7126 unique of 7342, and with
  mirrors the same—, because each map quantises its palette: the same drawing comes out with
  other indices. It is what the 4 MB decision already said. The same explains why
  the copies the Lashe City plan found (39≡7, 43≡34, 45≡19) are not
  shared on their own; **they are not measured here** because those maps are not in
  today's cartridge, and no per-map compression makes them cheaper: it needs
  the allocator to quantise them the same and `Materiales` to deduplicate them.
* **Sprite tiles do repeat**: 1420 unique of 9209 —the same
  characters on many maps, with the same palette—.
* **The poses have 93.5 KB of identical poses**: half within the same
  character (47.0: identical walking frames) and the other half between
  characters (46.5). And another **45.5 KB are the horizontal mirror** of a pose
  already seen: the left of many CharSets is the right flipped.

The S-DD1 agent measured the same with the chip's algorithm
(`expansion-chips-sa-1-and-s-dd1.md`) and the numbers agree: `map_celdas` 278.2
KB, zlib 22.9 against 22.7.

## The four grid variants

Over the cartridge's 39 distinct maps, grid plus dictionary plus
passability; "chunks N" are deduplicated chunks of N×N blocks, with
one-byte indices where they fit:

    1. as today                               329,1 KB   263 blocks the largest map
    2. chunks of 2 / 4 / 8 / 16               126,8 / 115,5 / 137,1 / 175,0 KB
    3. separate layers, chunks of 1/2/4/8     302,2 / 131,7 /  99,9 / 124,9 KB
    4. layers and passability apart, 1/2/4/8  437,2 / 162,5 / 130,7 / 180,6 KB
    LZ2 of the whole grid                      87,8 KB (no direct access)

4×4 chunks are the sweet spot of the first two: **-214 KB**, and with
separate layers **-229**. Separate passability (4) always loses: one byte
per cell weighs more than what separating it saves. The 512-block cap is not
approached in any: the map with the most 4×4 chunks has 285.

But there is something better than chunks, and it is in the recommendation: decompressing
the whole grid to WRAM when loading the map.

# When each thing is decompressed, and how much it costs

The cycle model for LZ2, which is the one that would be used in all the load ones:
~400 master cycles of header per command and ~46 per output byte (an
`mvn` of 7 CPU cycles, with the code reads in FastROM and the write
to WRAM at 8). An NTSC frame is 357,954 master cycles. It is a model, not a
measurement: the pilot was measured on the emulated console, this was not.

* **The tiles of the map, of the sprites, of the upper layer and of the ChipSet
  animation** are uploaded once, in `load_map`/`load_above`/`load_sprite`,
  with the screen off inside the fade: they are not seen. Decompressing LZ2 to a
  buffer in WRAM and uploading from there with the same DMA:

      map_tiles     2,97 frames on average, 7,21 the worst (27.584 B)
      sprite_tiles  1,28 on average, 2,53 the worst (15.200 B)
      above_tiles   0,20 on average, 1,03 the worst
      anim_tiles    0,56 on average, 1,13 the worst

  That is **some 5 more frames of black per map change on average, 12 the
  worst**. The buffer: the largest block is 27.5 KB, and **`$7F0000` to
  `$7F7FFF` is not used by anyone outside the battle** —it is `ESC_LIMPIO`, which the
  scene rebuilds on entering—. `volver_al_mapa` and the return from battle go
  through `load_map`, so they would decompress too, and the return from battle
  would add those frames to what it already takes.
* **The grids** today are read from the cartridge with a 24-bit pointer, every time
  a strip is built or a passability is asked: direct access, and that is why
  the original task asked for chunks. **But they can be decompressed whole to
  WRAM when loading the map and the direct access left as it is**: only
  `ptr_mas` and `ptr_menos` know that the grid is in LoROM —that on going past
  `$FFFF` it continues at `$8000` of the next bank—, and **WRAM has that
  same shape if the upper half of the two banks is used**: `$7E8000-$7EFFFF`
  followed by `$7F8000-$7FFFFF`. The largest grid is 40,000 B (map 52),
  which compresses to 1.9 KB. Decompressing: 1.24 frames on average, 5.81 the worst.
  What changes in the ROM is the load and **the two reads of
  `M_PTR_MAP_CELDAS`** (`heroe.s` and `ventana_del_mapa.s`), which would
  point to WRAM. What it costs: reserving `$7E8000-$7EFFFF` forever
  —today it is free— and, on maps with more than 32 KB of grid, decompressing
  it again when leaving a battle, which overwrites `$7F8000`.
* **The poses** are uploaded by DMA in the vblank, up to five per frame, when
  a character changes pose. Compressing them would require decompressing them in real
  time —LZ2 per pose gives 139 KB, but five poses are 2.5 KB of output per
  frame, close to a third of a CPU frame with this model— or preloading
  a map's ones into WRAM: the map with the most animated characters has 15, that
  is 90 KB, which is almost all the WRAM left free outside the battle and leaves
  no room for the grid or for the load buffer. **Neither of the two
  fits** until what is below is done, which shrinks that number. What
  does fit is deduplicating them, which costs nothing on the console: the pose
  tables already carry one pointer per pose (`npc_poses`, `actor_table`), so
  two identical ones can point to the same place. Mirrors would also need the
  mirror bit in the character's OAM attribute: more risk.
* **The battle animations** are not loaded on entering the battle, even though
  the name suggests it: they are drawn over the map and **2 KB are uploaded per vblank
  every two frames**, frame by frame. That is why the pilot
  rebuilds them in far RAM outside the vblank. See "The pilot".
* **The battlers and the backgrounds** are loaded on entering the battle, in the
  fade: 1.0 and 2.1 frames on average. The scene already uses the whole `$7F` bank;
  the largest decompressed battler (11.5 KB) would fit in far RAM. Little
  saving: -29 and -11 KB.

# The recommendation

By KB saved, with the cost and the risk alongside. The saving numbers are
against today's cartridge, after the pilot.

    what                                 saves     cost on the console                   risk
    1. anim_batalla without empty tiles   -512 KB   8 scanlines per new frame, 50        DONE
                                                    the worst; 2 KB of far RAM
    2. map, sprite, upper layer and       -431 KB   ~5 more frames of black per map      low
       ChipSet animation tiles, LZ2                 change, 12 the worst; buffer at
                                                    $7F0000; the decompressor
    3. grids, LZ2 to WRAM on loading      -245 KB   1,2 frames on average, 5,8 the       low
                                                    worst; reserve $7E8000-$7EFFFF
    4. identical poses, deduplicated       -94 KB   none: only the converter             very low
    5. mirrored poses                      -46 KB   the mirror bit in the OAM            medium
    6. battlers and backgrounds, LZ2       -40 KB   ~3 frames on entering the battle     low
    (grids in 4×4 chunks                  -214 KB   one more indirection per cell in     high
     with layers: if there were no WRAM)            each reader of the grid

**What first: 2 and 3 together**, because they are a single piece of work —an
LZ2 decompressor in the ROM and the compressor in the converter— and between the two
they are **676 KB**. LZ2 and not another for three reasons: on the tiles it ends up within 20% of
zlib, and on the grids within 10 KB; its repeat with absolute address
in the output is exactly what an `mvn` inside a WRAM bank
does in one go, so the decompressor is short and fast; and it is a
format the console already knows —there are reference decompressors and
tools to look at it (Lunar Compress)—. The 4 KB window LZSS
compresses the same on map tiles, somewhat better on battlers and backgrounds, and
quite a lot worse on sprites and grids, which is where the volume is.

**4 is free and can be done at any time**: only the converter, and
the suite verifies it as is —the ROM uploads the same bytes from another
place—.

With 1 to 4, `release` would go down from some 2650 to some 1880 KB used: from 65%
to 46%. It is an estimate, the sum of the columns above.

# The pilot

**What**: each battle animation frame is stored as the list of its
tiles with something —a byte with its number in the box and its 32 bytes— and an `$FF`
(`cuadro_sin_vacios` in `snes_convert.py`). When the tick chooses a new
frame, `anim_cuadro_armar` (bank 1, `animacion_de_batalla_cuadros.s`) erases
from `ANIMB_BUF` the tiles of the previous frame and copies those of the new one; the vblank
uploads the 2 KB of `ANIMB_BUF` with the same DMA as always. This one was chosen and not
the map tiles because it saves more than twice as much and has no decompressor: the
"decompressor" is a copy.

**How much it saves**, in `release`: `anim_batalla` from 548.0 to 36.0 KB; the
cartridge from 3162 to 2650 KB used, and the last bank from `$6B` to `$5B`.

**What it costs**:

* **Bank 0**: gives back 12 bytes —the vblank no longer computes the pointer—: 1180
  free in `release`, 1878 in `test-special`. **Bank 1**: 318 bytes.
* **Far RAM**: `$7E7000-$7E77FF`, reserved in `ram_lejana.s`, and three
  bytes at `$7E3616` (`ANIMB_PREV`).
* **CPU**: measured with an instrumented ROM —the vertical counter read before
  and after `anim_cuadro_armar`— with the fourteen animations on map 52,
  the one with the most characters that draws animations: **8 scanlines on average and 50 the
  worst**, out of 262, once every two frames. The worst is 132, where two
  consecutive frames add up to 55 tiles.
* **Frames lost** in the loop with the fourteen in a row: on map 52, 2
  before and 4 now; on 6 and on 3 (the Emitter Room, 35 characters), zero and
  zero. 52 already lost frames without this.
* **Load frames**: `anim_buf_limpiar` erases the 2 KB when loading each map,
  with the screen off: some 10,000 CPU cycles, less than one frame.

**How it was verified**: `just tests` green without touching any golden, and the
new test `tests/rpgmaker/test_animation_frames.py`, which makes the ROM
draw each animation of the cartridge —changing the row of the animation it
is drawing— and compares the VRAM box, frame by frame, all 274,
against `cuadro_de_animacion`, the uncompressed computation. It also runs in
bsnes, which powers on with WRAM full of garbage; there it compares `ANIMB_BUF`
because the core does not expose VRAM. It was seen failing by breaking the rebuild in
three ways: without erasing the previous frame (274 of 274 wrong), reading the
tiles shifted by one byte (216 of 274), and without the erasure on map load
(274 of 274, on both cores).

**If the worst case had to be brought down**: not erasing the previous frame's tiles that
the new one overwrites (on 132 it is almost all of them), or a DMA to `$2180` instead of the
CPU copy —five times faster—, which was ruled out because of the clash of a general DMA
with HDMA in the CPU's first revision; see the comment of
`animacion_de_batalla_cuadros.s`.

# Questions

Both, answered by taro on 2026-09-26: reserving `$7E8000-$7EFFFF` for
the grid, yes, as a trial and with the decision written down; and the extra frames per
map change, "perfectly acceptable".

# Method

Everything comes from `rom/build/release/`: the blocks of `mapdata.inc` read by
label —`.byte` until the next line that is neither `.byte` nor `.segment`,
because the grid crosses banks in the middle— and grouped by the name without the
trailing `_N`; the total used is the sum of the `ro` segments of the `.dbg`. The
compressors were written for this, in Python, and each LZ2 was verified
by decompressing it. The scripts were throwaway and are not in the repo; what
has to be redone is: a block reader, greedy LZ2 with lazy, and the cycle
model above.

Lost frames are counted with the harness's `lost_frames` around
each animation, set to draw by writing `ANIMB_FILA`, `ANIMB_N`,
`ANIMB_T`, `ANIMB_CUADRO` and `ANIMB_ACTIVA` —the same as the test does—,
after `go_to_map`. The scanlines, with a copy of the ROM that reads
`$213F`, `$2137` and `$213D` twice before and after the `jsl`, and notes the
four bytes at `$7E7F00`.
