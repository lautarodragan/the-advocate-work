---
name: "Vampires Dawn builds from its toml"
description: "Re-sweep VD's maps with today's main —mandatory MSU-1, 255 sounds, NPCs, events in RAM already fixed— and commit its exclusions and its start map, so that it builds from rm2k-snes.toml like the others"
type: feature
status: testing
agents: [Aguará]
assignee: taro
---

taro, on 2026-10-11: the next thing for Vampires Dawn. Today the committed
toml has `excluded = []` and `start_map = 3`, and it stops at map 15
("this map can't carry a message window"). Tijereta built it with the 82
exclusions from Aguará's re-sweep (2026-10-10) starting on 8, without
committing that configuration.

The table of what blocked it (research [`2026-10-10-otros-juegos-de-nuevo.md`](https://lautarodragan.github.io/the-advocate-docs/research/2026-10-10-otros-juegos-de-nuevo.html)
in the book, section 2) is old: since then the songs with more than 255
sounds (28 maps), the NPCs that don't fit in OAM (25) and
the events that don't fit in RAM (15) were fixed. What remains is measuring it.

The window of map 15 is being fixed by Tijereta in parallel
(`window-in-the-tile-bank`): here it is excluded like any other, and
taken off the list when that arrives.

## What was done (Aguará, 2026-10-11)

Base: ports `ebcde04` (branch `aguara-vd-toml`, own worktree), the-advocate's
global tools `0bb1120a`, untouched.

The sweep is the "each map alone" one from 2026-10-10 (`barrer.py` in
Aguará's scratch): one `release` cartridge per map, `maps = [8, m]`, with the
whole game from `~/juegos/vampires-dawn.zip` (the 281 songs, no longer the
125 copy) and `--without-tracks`. Map 8 to start because 3, the
game's own, didn't fit in BOOT_FRAMES on 2026-10-10; it is measured again.

First try: 8 builds (4 s), 15 stops at the window (576 of background,
820 of sprites, 130 of upper layer), as was known.

**The game's start, map 3, now fits**: `maps = [3]` alone builds (5 s);
what blocked it on 2026-10-10 (46 of 44 frames of BOOT_FRAMES) was with
the 125-song copy and before mandatory MSU-1.

**Each map alone, next to 8: 433 of 440** (2,843 s of CPU in total,
6 in parallel). The seven that don't:

| map | what blocks it |
|---|---|
| 1 | the world: `map_cells` is 147,232 B and 32,768 fit in WRAM (the LZ2 reserve in `far_ram.s`) |
| 15 | the window: 576 of background, 820 of sprites, 130 of upper layer, and no layout leaves 8 KB + 2 KB |
| 57 | VRAM: 609 of background, 768 of sprites, 130 of upper layer |
| 99 | VRAM: 451, 640, 177 |
| 399 | VRAM: 716, 512, 136 |
| 402 | panorama in mode 1: 120 + 244 + 137 + 435 of panorama |
| 403 | panorama in mode 1: 123 + 248 + 141 + 435 |

Out of yesterday's sweep come, among others, 28, 95, 165 (Uruya), 195, 225,
236 and 351. Map 1 no longer stops at the animation (that got fixed) but at the
grid.

**But alone isn't the same as whole.** With those seven out and 3 as the
start, the cartridge stops at **150**, the window: whole it spends 609 of
background and 436 of sprites, and alone 384 and 312. In the whole cartridge
more pages compile —those that teleport to maps that aren't there alone— and with them
more events get in, and more are baked as background (`chara_01~horneado`). So
what rules is iterating over the whole cartridge: the map that stops it is
excluded and it is built again (`iterar-vd.py` in the scratch).

**The passes over the whole** (`iterar-vd.py`, ~40 s each):

1. with the seven + 3 as start: it stops at **150** (the window, see
   above);
2. + 150: it stops at **165** (Uruya), VRAM: 817 of background, 768 of
   sprites, 95 of upper layer —alone, it fits—;
3. + 165: it stops at **225**, VRAM: 780, 704, 116 —alone, it fits—;
4. + 225: **the troops**: "277 troops of 255, 554 members". It isn't one
   map's: `BA_TROOP_K` is a byte (`emit.rs` in mapdata, 406fc5e0, which on
   2026-10-10 widened only the start of the members to a word). With
   yesterday's 82 exclusions they were 234 and it fitted.

   It is brought down by excluding the maps whose troops nobody else asks for
   (`tropas.py` in the scratch, encounters + direct `EnterBattle`; it counts
   304 because it doesn't know which pages compile): 98, 182, 327, 338 and 339,
   five each. With those the troops fit (338 turned out not to be needed
   for that: see the pruning).
5. + those five: **the ROM**: "a piece of 65536 bytes needs a new bank, and
   the 127 banks … are taken, even with the 2645 piece(s) that may go to
   the .msu". Of the `.block`s in `mapdata.inc` (`bloques.py`): 7.49 MB
   fixed in the ROM, 5.12 of them poses (10,002 of 512 B), and 6.71 MB that
   can go to the `.msu`. Yesterday, with 82 out, the poses were 4.3.

   **The poses repeat because of quantisation**: the converter keeps a bank
   of twelve poses per (CharSet, index, data), and a character that on another
   map comes out quantised differently carries its own bank —506 "goes
   with a pose bank of its own" warnings in this build; up to 6,072 poses, 3.1 MB,
   before the deduplication of identical poses—. That is what has to be
   measured as the next fix.

   To build today, the maps that contribute the most own banks are sought
   (quantisation warnings + characters nobody else uses) and the
   shortest prefix of that list that fits is sought (`busqueda.py`).

**The search** (`busqueda.py`, binary over 40 candidates ordered by
quantisation warnings + own characters): the first eight are enough,
164, 219, 222, 170, 429, 95, 239 and 221. Then, **the pruning**
(`podar.py`): each of the 13 added because of troops or poses was tried
by returning it, one at a time. None comes back: 98, 182, 327 and 339 break the
troops (256 of 255); 338 and the eight from poses, the ROM. So 338, which
went in because of troops, is actually held by the ROM. It is a local minimum, not
the global one: another order of candidates could give fewer.

## The result

`vampires-dawn/rm2k-snes.toml`, ports `c914245` in `aguara-vd-toml`:
`start_map = 3` (the game's) and **23 out** —417 of 440 in—,
each one with its why on the line:

| what blocks | maps |
|---|---|
| the message window | 15 (alone too; Tijereta), 150 (only in the whole) |
| no VRAM layout | 57, 99, 399 (alone too), 165, 225 (only in the whole) |
| panorama in mode 1 | 402, 403 |
| the grid in WRAM (147,232 B of 32,768) | 1 |
| the troops in a byte (277 of 255) | 98, 182, 327, 339 |
| the ROM: what doesn't go to the `.msu`, mostly poses | 95, 164, 170, 219, 221, 222, 239, 338, 429 |

**Verified**: `just cartuchos` in the worktree's `vampires-dawn/`, from
scratch (`build/release` deleted) and with the committed toml: rc 0, 137 s
(130 s the first time, with Tijereta running alongside). `vampires-dawn.sfc`
8,388,608 B (sha256 `52d80b8d7c367533…`), `vampires-dawn.msu`
22,980,864 B (`edebede5bea80193…`); 12,903 pieces in 127 banks, 64
slow, and 2,227 in the `.msu` (6,473,120 B). Poses: 8,320 distinct of
14,868. In snes9x (libretro, with the `.msu`): it starts on 3 with "Skip
Intro ?", and with "Yes" moves on to the house. Captures in
`/shared/capturas/2026-10-11-vampires-dawn-desde-su-toml/`. ABL wasn't
touched: the commit changes only `vampires-dawn/rm2k-snes.toml`, so
its suite wasn't run. **It wasn't played**: not a step beyond the
house, nor Mednafen, nor without `.msu`.

## The next thing in the tools (measured, not implemented)

1. **One quantisation per character for the poses** —the one that unblocks
   the most—. mapdata's `record.rs` keeps a bank of twelve poses per
   (CharSet, index, data): a character quantised differently on another
   map carries its own bank. In this build they are **420 of 1,239 banks**
   ("goes with a pose bank of its own" warnings); the poses are 4.26 MB of
   the ROM's 8, and they can't go to the `.msu` because they are uploaded on the fly.
   Sharing the quantisation would return the nine maps of "the ROM" and
   make room for those that come back when the others are fixed; how much it
   saves exactly wasn't measured (the deduplication of identical poses already
   eats part of it), on the order of a MB by rough count.
2. **`BA_TROOP_K` in two bytes** (`emit.rs`, the check `used.len() >
   255`): it returns 98, 182, 327 and 339 —four—, and with 277 troops without
   any map in between.
3. The window (15, 150) is being done by Tijereta; VRAM (57, 99, 165,
   225, 399) and the panoramas are the usual ones.

When merging there is nothing to install: the tools weren't touched.
