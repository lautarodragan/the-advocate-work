---
name: "ABL: room for still events in the background"
description: "Find the ~38 KB that turning `posed_events` on for every map of A Blurred Line costs, in a release that already fills its 126 banks: what the cartridge carries that could shrink, and what could move to the .msu without the game stopping being playable without it"
type: research
status: testing
assignee: taro
agents: [Mulita]
---

From [`abl-still-events-painted-into-the-background`](abl-still-events-painted-into-the-background.md):
`posed_events` makes signs, doors and monitors look as the map draws
them (map 8's monitors get their green back), but on every map it costs
+38,722 B of data —map tiles +32 KB against sprite tiles −8.5 KB— and
`release` already uses 126 of 126 banks with 302 B of gaps. taro, on
2026-11-16, after the captures in `captures/2026-11-16-abl-posed-events/`:

> It improves a lot! I think it is worth making room. I'd look for those
> 38 KB to apply it to the whole game! Maybe there are 38 KB we could move
> to the .msu without preventing the game from being playable without the
> .msu?

The standing rule: the whole game plays without MSU-1, and the .msu only
improves it (today it carries the battle backgrounds, which the ROM also
has in a lighter form: see the book's `internals/the-msu-file.md`).

Done means: measured, where `release`'s 8 MB go (by kind: map tiles,
map code, text, music/samples, battle, pictures, the runtime…), and a
ranked list of ways to get ≥ 38 KB, each with its measured gain, its cost
(CPU, load time, look) and whether it keeps the game whole without the
.msu —e.g. better compression of something, deduplication, something that
the .msu could carry in its best form while the ROM keeps a lighter one,
or making posed tiles themselves an MSU-only improvement with the sprite
fallback—. A recommendation for taro. Nothing implemented unless it is a
throwaway measurement.

## Log

Mulita, from the-advocate a83c4a12 (main; the global tools) and the
ports ff7ac5b, in throwaway worktrees (`mulita-abl-room`). Read first:
Carpintero's "Fitting the whole game in 8 MB" in the book
(`ports/abl/research/2026-10-14-…`), whose four big cuts landed on
2026-10-14 (samples, actor tables, NPC pose tables, poses without their
empty tiles). Its other lossless options —nested repeats, panorama tiles
in LZ2, NPC tables per entry, the sprite pool, the three fonts sharing
one ink layout— did not, by `git log`: they are the first candidates,
measured again on today's release. Hornero adds taro's question: which of
the 426 posed events are chests, and what a chests-only list costs.

### Where release's data goes (2026-11-16)

`release` built in the throwaway worktree with the global tools: 126 of
126 banks, 527 B of gaps (`just space`). The data pieces, by label family
from the `.dbg` (ld65's symbols, each label up to the next) and from the
`.inc` sizes the packing counts —both give 7,667,185 B—. The two whole
banks with no label are the text block's middle and the song streams'
crossbank tails. Scripts in `~/scratch/mulita/abl-room/scripts/`
(`inventory.py`, `kinds.py`, `incsize.py`). The table is in the research
page.

`posed_events = true` reproduced: +38,722 B exactly (map tiles +32,103,
the posed record +15,699, grids +4,749, against sprite tiles −8,522,
poses −2,588, NPC tables −2,448 and small ones).

### LZ2 over what is stored raw

`lz2 compress --no-increasing` piece by piece, on the bytes of the ROM:
page records 193,376 → 68,513 (−124,863); panorama tilemaps 169,600 →
69,038 (−100,562); panorama tiles 358,720 → 273,809 (−84,911, the same
as Carpintero's in October); big pictures' tiles −41,899; the posed
record itself 15,699 → 5,728. The page records are the find: they carry
no linker symbol —their code pointer is `GRID_HIGH + offset`, the
bytecode already lives behind the grid—, so the converter can compress
them, and they fit behind the grid with the bytecode (ABL's most taken
of `$7F`'s upper half is 12,153 B, the largest record 12,192).

The four precomposed fonts (485 KB) are 5:1 in LZ2 but are read at
random per letter, and 120 KB per font has no WRAM to land in.

### The chests (Hornero's question)

ABL has 101 chests: `BLObjs` character 2 (closed pose 0, open pose 1,
facing left), plus four ChipSet-tile ones on map 17 (`chests.py` matches
by graphic and by name; four "Orchestra…" and `SetBoulderChests` were
false positives). With `posed_events = true` **none goes into the
background**, so none of the 38,722 B is theirs:

* 33 (maps 38, 59–62, 261, 263, 289, 292, 293): "a pose is drawn past its
  cell". The chest in `BLObjs.png` is 16×15 px at x 5–20, y 14–28 of its
  24×32 frame, so on the map it stands 1 px right of its cell and 2 px
  above it; a background block covers only its 16×16 cell.
* 49 (maps 17, 20, 21, 26, 49, 133–140, 316): "a command moves it" —
  ABL's older chests are a closed and an open event, and opening one
  `SwapEventLocations` them (the open one waits at (0,0)).
* 19 (maps 32 and 255): the map has a panorama that stays (mode 1), and
  `posed_events` skips it.

Measured with a throwaway copy of the game whose `BLObjs.png` has the
two chest frames moved 1 px left and 2 px down (in
`~/scratch/mulita/abl-room/game-chest`, `~/juegos` untouched): the 33 go
in, and on top of every other map's posed events they cost +2,535 B,
of which +2,456 are the pose bank's bytes changing with the edited
image —not posed—: the chests themselves are about +80 B (map tiles
+3,074, posed record +1,301 against sprite tiles −4,568).

The chest maps alone, as a `posed_events` list ([38, 59–62, 261, 263,
289, 292, 293], with the edited image and the list-taking `convert` and
`wally` of a83c4a12 installed locally): 98 events go in —the 33 chests
and 65 others— for +4,720 B. It does not link either.

### The rest, measured

* `debug_screen = false`: −146,168 B (121,056 its font), `release` packs
  into 122 banks.
* The ROM's sound effects capped at 11,025 Hz: −109,077 B over 18
  effects (16 kHz: −56,593), from `audio.json`. With MSU-1 nothing
  changes —the effects come from the `.msu`—; without it they sound
  duller.
* The posed tiles as an MSU-only improvement free nothing (the ROM keeps
  today's map) and would need a second version of each posed map read at
  load; written up in the research page, not recommended.

### Recommendation, and where it is written

**The event page records in LZ2, behind the grid** (−124,863 B,
lossless, every port): then `posed_events = true` fits with ~86 KB to
spare. If more margin is wanted, the panoramas' tilemaps and tiles in
LZ2 next. The research page, with the table by kind and the ranked list:
`ports/abl/research/2026-11-16-room-for-still-events-in-the-background.md`
in the book, branch `mulita-abl-room` (links checked).

Branches: the-advocate-docs `mulita-abl-room`; the-advocate and the
ports only throwaway worktrees (nothing committed there). Nothing to
install. Note that the global tools were not yet reinstalled after
Cardón's merge: `posed_events` as a list is refused by them.
