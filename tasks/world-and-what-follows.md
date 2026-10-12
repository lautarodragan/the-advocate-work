---
name: "The world and what follows"
description: "Plan: the world map (66) in release, the Lashe Area chapter up to the tunnel to Paradise, and the space still missing to fit it whole"
type: feature
status: done
---

**Done**, closed on 2026-10-12: it was the plan, and its six milestones
were each a task of their own, all done —`world-1-map-66-fits.md` to
`world-5-tangle-forest.md`, and `world-6-yun-town-and-drust-camp.md` for the
optional parts—. The plan stayed in `todo` because nobody moved it when the
last one closed. What follows is as it was written, on 2026-09-27.

# What

What follows `race-and-what-comes-next.md`. Today the demo ends at the end
of the scene in 64, with a fork (`parches/manual/mapas/Map0064.json`) that
replaces the `Teleport [66, 71, 29]` with the end card. This is **what is
needed for the world map, 66, to fit, along with what can be reached from it**
up to the next natural cut, measured and not implemented. The milestones below
become tasks of their own when they are launched.

Everything measured here is from 2026-09-27 on `c84ed2b`, with variants of
`release` built separately: neither `release` nor `cartuchos.py` nor the
converter in `main` were touched. **None of this is covered by `just pruebas`**:
they are variants that no recipe builds, and what was run in the emulator is
spelled out in each place.

The scripts were left in `/extras/scratch/mundo-plan/`, which survives the
session (the built variants don't: they are heavy). `armar.py` builds a variant,
`medir.py` gets the space with the method in `AGENTS.md`, `far.py` bank 1,
`grande.py` relinks a variant that doesn't fit in 4 MB with fake banks and
says how many it asks for, `ffd.py` estimates the bank packing with first-fit
decreasing, `categorias.py` and `tablas.py` say what grew, `culpables.py`
which command blocks each page, `grafo.py`, `switches.py` and `dependencias.py`
build the walkthrough, and `probar66.py` runs a variant in the emulator.
`hacks.diff` holds the measuring switches that were needed in the
converter —all behind an environment variable; with none set,
`release` comes out byte for byte identical, checked—:

    MUNDO_SEGUIR=1     the VRAM, LZ2 and .msu height table limits are
                       printed (MEDICION-…) instead of aborting
    MUNDO_PASO=4       the text block in steps of 4 bytes (the ROM still
                       multiplies by 2: the texts come out shifted)
    MUNDO_SIN_TIMER=…  those maps without the timer digits
    MUNDO_BLOQUES=…    records the size of each `.bloque` for `ffd.py`
    MUNDO_TILEMAP=…    dumps the tilemap of each map
    and the fifth VRAM layout (see "66"), added at the end of LAYOUTS

# 66

    Lashe Area   100x75 cells, chipset 31, no panorama
    background   527 unique 8bpp tiles, 97 colors (100 of 103 in CGRAM)
    above          5 tiles
    sprites      222 tiles: 16 characters in 12 slots, all 8 palettes
                 (Crown3:4 drops to 14 colors so the timer digits
                 fit)
    events       42, 23 with a CharSet; 2 baked (11 and 13)
    grid         344 blocks, 15,000 B: fits in the lower half of WRAM

**Why it doesn't fit today.** The four layouts in `LAYOUTS` give, with 222
sprites, at most 480 background tiles ("+fondo" and "+ambos"), and 66 asks for 527.
But `docs/port/vram.md` already had the answer: the ceiling with 256 sprites is
**544**, and "+fondo" is 64 below it only because raising it would change the
layout of the maps that already use it. A fifth layout **at the end** changes
nothing for anyone:

    sprites     $0000   8 KB  256 tiles
    tiles       $1000  34 KB  544 8bpp tiles   <- the BG1 base
    ventana_map $5400   2 KB
    mapa        $5800   4 KB
    encima      $6000         128 tiles
    ventana     $6800         256 tiles
    tilemap     $7800         the one for the layer above

It passes `_controlar_repartos` and `_controlar_ranuras` as is, and leaves 66
17 background tiles and 34 sprite tiles of margin.

**The second limit, which shows up behind it:** the background tiles of 66 take
33,728 B and the LZ2 load buffer (`LZ2_BUFFER`, `$7F0000`) is 32 KB. What
spills over lands at `$7F8000`, which is the upper half of the grid —empty in
66, which uses only the lower one—, so **in 66 it works by accident**. The
real fix is to split the background block into two streams of up to 32 KB,
each one decompressed and uploaded by DMA before the next, as is already done
with the grid. It is code in `descomprimir.s`, which lives in `FAR`.

**Seen in the emulator** (variant `m0p2`: `release` plus 66, with the
text block in steps of 2 bytes, the harness's default core): 66 loads,
`celdas_mal_dibujadas` gives zero, the window shows the text of event 2
("I can't just walk back into Lashe City!") correctly, a forced battle with
`ENC_PIDE` (Snarling Wolf) is won and returns to the correctly drawn map, and
walking 17 cells up and 4 down `cuadros_perdidos` stays at
zero. The battle comes out **without a background**: the cartridge carries three, and the world's
are others (see question 6).

## The paths, with their limit

1. **The fifth layout (544 with 256 sprites).** Measured: it fits, with 17 and 34
   tiles of margin, and it shows. It costs one entry in `LAYOUTS` and LZ2 in two
   streams; nothing from bank 0 (the layout travels in the map record, and the
   ROM already reads everything from there). The limit is the hardware ceiling: 544 with 256
   sprites, 512 with 320 (`docs/port/vram.md`). **Recommended.**
2. **Tiles uploaded on the fly while moving**, like the poses. Measured on the
   tilemap of 66: the 64x32-cell window of 8 px that the ROM keeps
   drawn touches at most **307** distinct tiles of the 526 (the screen with
   a one-cell border, 254). That is, with this 66 would fit even in the
   448 layout. But it asks for a tile cache with allocation and eviction in
   the ROM, and uploading new columns in vblank together with the poses: a lot of
   code, and bank 0. **Not needed today**; it is the path for the day a map
   goes past 544.
3. **Splitting the chipset** into zones with their own tile set, reloading when
   crossing. It is 2 without the cache: the same 307 as the limit per zone, and a
   visible cut when switching. Worse than 1 for 66.
4. **Fewer colors with Adeleine.** It doesn't shrink what's missing: 66 uses 97
   colors and reuse is already at 98%, with mirroring deduplicated (716 cells
   use it). What's in excess are **distinct tiles**, and 148 appear only
   once: merging them would mean changing pixels, which is Adeleine's decision and
   would show.
5. **MSU-1 as a source.** **Doesn't apply**: what's missing is VRAM, not ROM, and the
   MSU-1 can only replace something the ROM already carries (`internals/the-msu-file.md`,
   "without MSU-1 the game works the same"). It helps with cartridge space, not
   with this.

# What's in the world

66 **is not a map with a vehicle**: it is walked. The towns and places are
events drawn with a chipset tile that take you to another map when stepped on
(`Teleport` and switch 236, "OnTheWorldmap", which enables saving from
parallel 26). Encounters are **by zone**: four areas (184 to 187) with
between 9 and 16 troops each, every 65 steps; the ROM already does them. The car does
appear, but as an **actor** in the party: `DaliaGoingToTasgarde` (14) removes
Dalia, adds `MobilizedCar` (22), forces a sixty-step route on it to
Tasgarde, and gives her back.

Where it leads: 67 Yun Town, 69 Sorbe Village, 68 Drust Camp, 74 Tasgarde
Military Base, 259 Northern Highway Bridge (with 252), 105 Mountain Path
("<-- Paradise Tunnel 2 Km", with a `ShowChoice`), 310 New Tangle Forest, 312
Burning Forest (with 847), 348 Small General Store, and 66 itself (crossing the
bridge, with 849).

## What the ROM doesn't do, counted

With `culpables.py` over the 44 maps of the chapter: **893 of 905 triggerable
pages compile**. What blocks the other twelve, in order of how much they
unblock:

    on the main path (all automatic: each one blocks the story)
    ChangeEncounterSteps       2  66 ev14 (Dalia's trip to Tasgarde),
                                  81 ev6 p5
    ControlSwitches toggle     2  89 ev4, 93 ev4 p2 (Eisen's story)
    ChangeScreenTransitions    2  93 ev4 p1 (to "none"), 95 ev55 (to "the cut")
    Comment                    1  81 ev6 p1, "HEALING TALAN'S ANKLE"
    Teleport -> 105            1  66 ev18: the end of the chapter (the fork goes here)

    optional
    InputNumber + compare      1  68 ev10: against 35421, which doesn't fit in a
                                  signed word (Drust)
    EraseEvent                 1  311 ev4 (Tangle)
    timer condition            2  312 ev10 (branch) and ev81 (page condition;
                                  it is the one that turns on TangleForestDONE)
    ShowChoice with cancel     1  348 ev1 p2

* **`ChangeEncounterSteps` can already be done**: the comment in
  `eventos.py` that blocks it says that "there are no random encounters", and there are
  —`rom/src/encuentros.s`—. It is writing `ENC_BASE` with the `1/steps` that the
  converter already knows how to compute (`eventos.enc_base`); zero turns them off, which is
  what Dalia's trip asks for. RM2k sets it back to the map's value when loading
  another, and `encuentro_mapa` already overwrites `ENC_BASE` on every load.
* **Toggling a switch** (`ControlSwitches` operation 2) the compiler can
  write with what's already there —a condition and the two `ControlSwitches`—,
  without new code in the ROM.
* **`Comment`** does nothing in RM2k: it is skipped when compiling.
* **The two transitions** are the instant ones; the ROM already has
  `TRANSICION_BORRAR/MOSTRAR` (`op_transition`) and is missing the "no
  fade" value. See `other-transitions.md`.

And what is already accepted without being done (`ACEPTADOS_SIN_HACER`), which compiles and doesn't
show:

    ShowPicture/Move/Erase    81: the "MeanwhileLashe" card (the story moves
                              to Dalia); 95: the Fortitude counter, two
                              digits in pictures (common events 9 and 10) over
                              variable 48, in the "Into The Machine" minigame;
                              311: the hover's shadow
    ChangeSystemBGM           76, 311, 312
    ChangeHeroTitle           81

No event on the main path depends on the optional ones: the only thing Yun
Town lends Sorbe is two dialogues (switches 241 and 247), and Tangle's 847
only changes some trees in 66 (`dependencias.py`).

# What follows

## The walkthrough

    64  the farewell: Teleport [66, 71, 29]              (today: end, fork)
    66  the world. ev1 turns on StillLimping (239): Talan limps
    69  Sorbe Village -> 76 Sorbe Mountain -> 81 Dr. Vago's House
        (77 to 80: spa, inn, weapons, mayor)
    81  the healing of the ankle; with 270, turns on TalkedWithVago (252)
        and leads to 82
    82  Director's Office -> 83 Dalia at the Factory (in Lashe City)
    84  OutsideFactory: Dalia goes out into the world (party: Dalia out, DummyHero)
    66  ev14: Dalia's car to Tasgarde (ChangeEncounterSteps)
    74  Tasgarde -> 85 Tasgarde Lab (with Dalia) -> 86 Eisen's Story
    86..95, 99, 100  Eisen's story, chained; 95 is the minigame
    101 Lab After Eisen's Story -> 102, and back to 81, with Talan
    66  ev15 -> 259 Northern Highway Bridge -> 255 Under the Bridge: turns on 849
    66  ev18, "Paradise Tunnel 2 Km": Yes -> 105 Mountain Path -> 106 -> 108
        Distant Paradise, which is another chapter (parent 0 in the tree)

**The natural cut is 66 ev18**: the `ShowChoice` "Yes - Continue onward"
leads to the tunnel to Paradise, a new chapter. That's where the fork for the end of the
demo goes, and the one in 64 is deleted.

The optional parts hang from 66 and can be left for later without breaking anything
(except Tangle Forest, which is on the way to the tunnel: see milestone 4):
**Yun Town** (67, 70 to 73), **Drust Camp** (68, 103 the mines, 199 to 201) and
**Tangle Forest** (310 to 313, which uses the timer). 75, 198 and 104 are not
reached by `Teleport` from the chapter.

## What fits today, map by map

Converting each one in the cartridge of the whole chapter, with the code in
`main`:

    66  no: VRAM (see above). With the fifth layout, yes
    69  no: "encima necesita 157 tiles y entran 128"
    67  no: twice. The timer finds no palette (it already has two
        graphics painted with someone else's palette), and the layer above asks for 163 tiles
    the other 41: yes

Behind that, warnings that don't block: 67, 68, 69 and 199 paint two to four
characters with someone else's palette, and 67, 68, 69, 77, 199 and 200 are left without
raindrops for lack of a palette.

**The layer above in 69 and 67.** The five layouts have the layer
above at 128 tiles because the window starts at index 128 of BG2
(`VENTANA_TILE_BASE`, fixed) and the tilemap of the layer above is pinned at `$7800`.
A layout with the BG2 base at `$5000` gives it 256:

    sprites     $0000  12 KB  384 tiles
    mapa        $1800   4 KB
    tiles       $2000  24 KB  384 8bpp tiles
    encima      $5000   8 KB  256 tiles      <- the BG2 base
    ventana     $6000   8 KB  256 tiles      <- indices 256..511
    ventana_map $7000   2 KB
    tilemap     $7800         the one for the layer above

69 (329 background, 157 above, 283 sprites) and 67 (253, 163, 244) fit.
What it costs: the window starts at 256 and not at 128, and `ventana_celdas`
has that index baked in, so a second window plane is needed
(2 KB of ROM) and the map has to say which one to use. **It was not tried**: it is the
alignment arithmetic, not a variant.

**The timer in 67** goes away without touching palettes: the chapter's timer
only runs between 311 (start) and 312 (stop), and outside Lashe between 7
and 9, 11 or 16. `args.timer_en` today is "all maps"; if it were the ones
reachable by `Teleport` between a start and a stop, 67 would carry no
digits. Measured with `MUNDO_SIN_TIMER=67`: with that it converts (and only the
layer above remains).

## Space

With `medir.py`, `far.py` and `grande.py`. All with the fifth layout and the
text block in steps of 4 bytes (except `release`). BSS and ZEROPAGE don't move in
any of them: 138 and 4 bytes free. "Banks" are the data ones, from `$02` to `$7D`:
**124 fit**. "FFD" is what packing with first-fit decreasing would ask for
(see below).

    variant                               maps  cartridge  banks (FFD)  bank 0  bank 1
    release today                           65     73.8%   101  (93)      224     9,000
    m0  + 66                                66     75.6%   104            224     8,298
    m1  + Sorbe (69, 76 to 81)              73     80.9%   110            192     8,141
    m2  + 82 83 84                          76     81.4%   112            192     8,141
    m3  + Tasgarde, Eisen (74, 85 to 102)   91     88.5%   121            167     8,141
    m4  + 259 255: the main path            92     90.0%   122 (114)      163     8,141
    m4  + Yun (67 71 72)                    95   doesn't fit 125          127     8,141
    m4  + Drust (68 103 199 200 201)        97   doesn't fit 126           83     7,913
    m4  + Tangle (310 to 313)               96   doesn't fit 127          117     8,022
    X = 105 (see "The rule")               100   doesn't fit 130 (121)     47     7,913
    the whole chapter                      104   doesn't fit 135 (125)      7     7,794

**The percentage is misleading**: `m4` says 90% and has **two banks** left. The 64 KB
of `$7E` and `$7F` are not ROM, and the packing leaves on average 2.3 KB free per
bank —270 KB in `release`, 280 in `m4`— because it is sequential: a block that doesn't
fit in what's left jumps to the next bank and nobody uses the gap.

**What's tight, in order:**

1. **The cartridge.** The main path fits with two banks; any of the
   three optional zones doesn't. What grew from `release` to the whole chapter
   (+917 KB in labels): poses +238 KB, background tiles +221, music
   streams +93, sprite tiles +52, blocks +51, battlers +37, grids +26,
   pages +25.
2. **The text block.** The operand of `OP_MESSAGE` is 16 bits in steps of 2
   bytes: 128 KB. `release` uses 99,346 B; **`m4` uses 131,066 of 131,072**,
   that is, the main path fits by six bytes. In steps of 4 bytes (two `asl`
   in `msg_empezar`) it is 256 KB and costs 2.2 KB of padding in `m4`. The whole
   game is about 161 KB (`Mensajes.volver`), so this is needed anyway.
3. **Bank 0.** `m4` leaves 163 bytes; the whole chapter, 7. What grows isn't
   the maps but **the item tables** (6 B per item: `item_precio`,
   `item_id`, `item_tipo`, `item_uso`; 966 B in the whole chapter) and **the
   track tables** (4 B per track). Moving the item ones to bank 1, as milestone 4 of
   Lashe City moved `tropa_codigo`, would give back almost 1 KB.
4. **The height table for the `.msu` sound effects** (`se_msu_altura`) takes
   packages × sounds × 2 B, almost all zeros, and has to fit in a bank:
   19 KB in `release`, 29 KB in `m4`, 32.1 KB with X = 105 and **33.8 KB with the whole
   chapter, which no longer fits**. Storing only its own effects per package
   fixes it.

**The bank packing (`tools/ensamblado/bancos.py`) is the cheapest lever**:
with the sizes of each `.bloque` of `m4`, first-fit decreasing asks for 114
banks instead of 122 —eight banks, 256 KB— without touching the ROM. With that X = 105
fits (121 of 124) and the whole chapter still doesn't fit (125). It is an
optimistic bound: `ffd.py` ignores any ordering constraint between blocks, and
it would have to be checked which ones there are (the `.cruza`, the tables that are walked in sequence).
What comes after that is measured elsewhere: the mirrored poses
(`compression-of-maps-and-graphics.md`, point 5) and the music
(`music-weighs-789-kb.md`, ideas 2 to 4). And
`decisiones/el-cartucho-se-queda-en-4-mb.md` says it is revisited on reaching
85-90%: `m3` is already there.

## The map rule

Today's is "id below `MENOR_A`, minus `EXCLUIDOS`, plus `AGREGADOS`". The
chapter is almost all the ids from 66 to 104, plus some high ones:

* **By id**: `MENOR_A = 105`, with the exclusion growing by six —65
  (Northern World, folder), 75 (unreachable), 96 97 98 (backups), 104 (from
  another chapter)— and the additions by four —199 200 201 259—. 255 and 348,
  which today are `MAPAS_DE_PRUEBA`, become part of the game (and 70, 73 and 74,
  which were already there, too). But **it doesn't fit** (130 banks) until the packing:
  meanwhile the exclusion adds the optional parts —67 68 71 72 103, and 199 200 201
  stop being additions—, and the list grows to sixteen.
* **By subtree**: the descendants of 66 are exactly the chapter plus
  75, 198 and 105, and minus 83 and 84, which hang from Lashe City. That
  is, "the subtree of 66, minus 75 198 105, plus 83 84", with the same
  space problem for the optional parts.

Tangle Forest (310 to 313) stays out of both while there is no room.

# Milestones

**1. 66 fits.** (Done: `world-1-map-66-fits.md`.) The fifth layout at the end of `LAYOUTS` and the background over
32 KB in two LZ2 streams. 66 in `release`; the fork in 64 is deleted and
the end of the demo moves to a fork of 66 that cuts when stepping on Sorbe (ev10), so
the world can be walked and fought in. The other entrances of 66 do nothing
—their pages don't compile because the destination isn't there—, as happened with 64
before. Cartridge 75.6%, bank 0 unchanged. It is tested with: a golden of 66
just arrived, `celdas_mal_dibujadas` at zero, a battle in 66 that returns
to the map (it is the one that would overwrite the upper half of the grid if LZ2 isn't split),
and `test_carga_descomprimida` with a two-stream background.

**2. Sorbe and the healing.** (Done: `world-2-sorbe-and-the-healing.md`.) The layout with the layer above at 256 (69), the
`Comment` skipped, and `ChangeEncounterSteps` done. 69 and 76 to 84 in
`release`; the end of the demo moves to the entrance of Tasgarde (66 ev13), which is
where Dalia's trip leads. 81.4%, bank 0 192 minus what
`ChangeEncounterSteps` takes.

**3. Space.** (Done: `world-3-the-space.md`; the main path has ten banks left, and it fits along with one or two of the optional zones, not all three.) Packing with first-fit decreasing in `bancos.py`, with the
ROM building the same and the goldens not moving; the `.msu` height table per
package; the text block in steps of 4 bytes; and `medir.py` —or whatever
replaces it— reporting free banks and not a percentage. It can go in parallel with
1 and 2; **it has to be before 4**, which leaves three banks.

**4. Tasgarde, Eisen and the bridge: the chapter.** (Done:
`world-4-tasgarde-eisen-and-the-bridge.md`. **The demo ends at the entrance of Tangle
Forest (66 ev19), not at 18**: the tunnel to Paradise is on the other side of the
forest, and from the bridge to the tunnel you can't get there walking across the world —you cross through
310, 311, 313 and 312, which exits to the west—. That is, Tangle Forest is not
optional: it is the next milestone of the main path.) Toggling switches in the
compiler, the two instant transitions, and the card and the counter
according to what taro answers (questions 3 and 4). 74, 85 to 102, 259 and 255; the end
of the demo to the fork of 66 ev18, "Continue onward". The map rule according to
question 5.

**5. The optional parts**, behind 3 (Tangle Forest, which turned out to be on the main
path, done: `world-5-tangle-forest.md`; the demo now ends
at the "Continue onward" of 66 ev18, which was the goal, and there is no bank
left free): Yun Town (the timer by reach, and the
layout from 2 for its layer above), Drust Camp (comparing against more than
32767), and Tangle Forest (the `EraseEvent`, the timer conditions, the
cancel of a `ShowChoice` for 348) when there is room: with the packing
alone it still doesn't fit. The item tables to bank 1 go here, which is where
bank 0 runs out.

What has to be split up if they go in parallel: the new VRAM layout goes
**last** in `LAYOUTS` and both (the one for 1 and the one for 2) touch it, so
it's better to use the same agent or one after the other; an opcode for
`ChangeEncounterSteps` in `tools/snes/protocol/events.toml`, the one for 2.

# What taro answered (2026-09-27)

1. **The demo ends wherever each milestone gets to**, with the end of the chapter (66
   ev18) as the goal.
2. **The optional parts go behind the space milestone**, Tangle last.
3. **The "Meanwhile in Lashe City" card**: a fork of 81 with a
   `ShowMessage`, like the one in the race.
4. **The Fortitude counter**: debt, in
   `fortitude-counter-is-not-shown.md`.
5. **The map rule**: either of the two is fine with him; it stays by id,
   as was decided in the race.
6. **The battle backgrounds**: they all go to the `.msu`, whether or not they are in the
   cartridge, and the battles whose background doesn't fit in the ROM share one of the
   ones already there, in low quality, instead of coming out black. It is its own task:
   `all-the-battle-backgrounds-in-the-msu-1.md`.
7. **The cartridge**: squeeze first. taro: "at this rate, neither 6 MB nor 8 MB
   will let us cover the whole game".

# Questions for taro

1. **Where the demo ends**: (a) at the end of the chapter, at the `ShowChoice` of
   66 ev18 toward the Paradise tunnel; (b) earlier, as each milestone lands (in
   Sorbe, in Tasgarde), and moving it. **Recommended: (b) while working,
   with (a) as the goal**: each milestone is played whole.
2. **The optional parts** (Yun Town, Drust Camp, Tangle Forest): do they go in the demo? None
   fits without milestone 3, and Tangle not even with it. **Recommended: the main
   path first, the optional parts behind space, Tangle last.**
3. **The "Meanwhile in Lashe City" card** in 81, which is the change of
   protagonist to Dalia: (a) a fork that replaces it with a `ShowMessage` with the
   same text, like the one in the race; (b) a second card per ROM
   (`picture-system.md`); (c) debt. **Recommended: (a).**
4. **The Fortitude counter** of the minigame in 95: without it you play without seeing
   how much Eisen can take. (a) show variable 48 with the timer
   digits, which are already in the ROM; (b) a message when it drops; (c) debt.
   **Recommended: (a)**, but only if the minigame can be lost —it has to be
   looked at first—; if not, (c).
5. **The map rule**: by id (`MENOR_A = 105` and the exclusion growing) or
   by subtree ("the subtree of 66"). **Recommended: by id, as was
   decided in the race, with `MENOR_A = 105` only once X = 105 fits
   whole (after milestone 3)**; meanwhile, the additions of the main
   path.
6. **The world's battle backgrounds**: the battles in 66 come out without a background
   because the cartridge carries three, and the world uses five other terrains (plains5,
   desert1, forest5, forest6, mroad2). Each is 16 KB of fallback in the ROM
   and 32 KB in the `.msu`. Do they go in this plan or are they debt? **Recommended:
   debt until after milestone 3.**
7. **The cartridge**: `m3` is already at the 88.5% that the 4 MB decision says
   triggers the review. Is it opened now (ExHiROM, SA-1, S-DD1:
   `expansion-chips-sa-1-and-s-dd1.md`) or do we keep squeezing? **Recommended:
   squeeze first** —the packing gives eight banks without touching the ROM—, and open it
   with the next chapter's number in front of us.
