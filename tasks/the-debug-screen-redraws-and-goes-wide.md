---
name: "The debug screen: a black block while scrolling, and the whole names in high resolution"
description: "Scrolling the debug screen redraws the left list when it does not need to and a black block covers part of it for a moment; and taro wants the screen in the console's 512-wide mode, so the switches' names fit whole"
type: feature
status: testing
assignee: taro
agents: [Hurón]
---

taro, on 2026-10-20, in their words, translated, after playing
[`a-debug-screen-in-the-pause-menu`](a-debug-screen-in-the-pause-menu.md):

> Regarding the debug menu: IT WORKS PERFECTLY! and it's great.
>
> Two small changes I'd like:
> - When scrolling, the left menu seems to redraw even when it doesn't
>   need to, and a black square covers part of it for a second
> - I'd like to try rendering this screen in the SNES mode that allows
>   double horizontal resolution. It wouldn't change anything about the
>   text, it would simply use the extra space to render the full names of
>   switches, which sometimes don't fit. It doesn't matter that it looks
>   odd from the text being squeezed to 50% horizontally. I'd apply it to
>   everything equally, even if the windows' borders get a bit deformed,
>   to keep the change simple.

Their captures are in `/shared/captures/debug-menu-report/`:
`scroll-black-rectangle-0.png` and `-1.png` (the left list's lower rows
black while the page wraps), `switch-0006-name-too-long.png` (names cut:
"LBDidn'tGoThisW", "NVGetToWorkDO", "RunningIdolEsca").

**Done**: scrolling within a page does not redraw the left list, and
changing page leaves no black block; the debug screen runs in the
512-wide mode (mode 5 or 6) with the same glyphs at half width, and the
names come out whole —or as long as the wider window allows—, windows
deformed as taro accepts. Goldens red before.

## Work log (Hurón)

Worktrees from Hornero's `hornero-integrate` of each repo —the-advocate
090b0037, the-advocate-ports a75f83c, the-advocate-docs 043cde4—, on
branches `huron-debug-wide`.

### The black block, and the ranges composed again

**The cause.** A line of the text layer is the screen's whole row: the
ranges' label and the list's row beside it are one record. A step of the
ranges' cursor changes the ten rows of the list, so the ten records
changed, and each one was typeset whole, ranges included: some 29 pairs a
row on a screen that shows some 290 of the pool's 447. The pool ran out
halfway, and the early switch —`tl_blank_dirty`, from 2026-10-18, for the
items list that showed its neighbour's row— blanked every row not typeset
yet, both windows: taro's black block, for some 35 frames.

**The fix, in the text layer, for every screen:**

* `tl_split`: the runs at the head of a record that are byte for byte what
  the screen shows keep their tiles, if every other run, old and new,
  starts in a column after the last one they ink. The debug screen writes
  each row's range first, so within a page its labels are never composed
  again; and a row asks for the list's columns only.
* The early switch blanks the rows not typeset yet **only if a row took
  another's tiles since the last switch** —`TL_ADOPTED`—: that is the
  case 2026-10-18's blanking was for. Otherwise the switch shows what is
  typeset and the other rows keep what they said until their turn.

Red before, on the tools at 090b0037: the new
`test_scrolling_the_ranges_never_blanks_a_row_nor_composes_them_again`, in
ABL's `tests/rpgmaker/test_debug_screen_golden.py` —after the first down,
frame 23, a ranges' line neither old nor new—. Green after, and the three
old goldens unchanged.

### The 512-wide mode

**Mode 5, not 6.** Mode 6 has one layer, BG1, and the windows need their
own; mode 5 has BG1 at 4bpp —the text layer's format, so the text keeps
the System's gradient— and BG2 at 2bpp for the windows. Main screen and
subscreen show both, which is what shows every pixel of the 512; no
interlace (224 lines are enough), no objects.

**The text.** In mode 5 a tilemap word is a cell 16 pixels wide, tiles N
and N + 1 side by side, so a column of the text layer is four tiles —a
*quad*, its two tops and its two bottoms— where it was a pair. The layer
got a wide mode, `tl_hires`, that the debug screen turns on after
`tl_reset` and off when it leaves: a record's x stays in 256-wide pixels
(a cell is eight) and is doubled when typeset, so the font's pixels are
the screen's; the stage is 64 columns of eight, 4 KB, which far RAM did
not have —940 B free in `release`— so it lives in `LZ2_BUFFER`, $7F0000,
which nothing decompresses into while the screen is open; a quad goes up
in four 32-byte pieces (the stage keeps a column's top and bottom
together, the VRAM a cell's two tops); the tilemap words are 4q and
4q + 2. The glyph routine for the wide stage is a copy in `FAR3` with the
data bank on $7F. What changed in shared code: `text_layer.s` only —the
branches on `TL_HIRES` in `tl_letters`, `tl_begin`, `tl_finish`,
`tl_release_cols` (`tl_pair_of`), `tl_dma_pairs` and `tl_right`, and the
new procs in `FAR3`—; with `TL_HIRES` zero every other screen runs what it
ran. `messages.s` is not touched.

**The windows**: drawn at 256 wide like every screen's, each pixel twice,
2bpp in BG2's eight palettes of three: Adeleine's `reduce_colors`. ABL's
System has three colours, so nothing is lost there; the other games'
have five to nineteen and may lose some (taro accepted the windows
deforming). No flips: a mirrored cell is its own pair of tiles.

**The names**, measured on ABL with its font's advances: 347 of 1200
switch names and 73 of 250 variable names were cut at 256 wide; none
now. The name block went from 17,470 to 19,494 bytes (a data bank, not
bank 0). The ranges' window went from 11 cells to 7.

**VRAM**: quads from word 0 to `CM_BG1_MAP` —223 with ABL's $3800, 892
tiles—; BG2's tilemap there, BG1's at `SLOT_MAP`, the windows' tiles at
`CM_BG1_VRAM` (ABL: 30 tiles, 480 B). A page of the list takes some 140
quads, so a step that changes the list whole does not fit next to it: it
shows in two goes, the rows composed so far and then the rest, never
blank —measured: settled 30 to 42 frames after the press, as before—.

### Where it was left

Branches `huron-debug-wide`, each with `origin/main` merged —the-advocate's
brought Carpintero's, Calandria's and Cardón's merges—:

* the-advocate: 6f142ab7 (part 1, the text layer), 090b9781 (part 2, mode
  5), and the merge;
* the-advocate-ports: a87d956 (the frame-by-frame test), 18b8ecc (the four
  goldens at 512 wide), the merge, and d3a1680 —`test_jumps_between_banks`
  went red on the merged test-change-system for an address coincidence in
  `note_sound`'s `.repeat`: the check now pairs an instruction with the
  symbol of its line its operand is closest to—;
* the-advocate-docs: 84fcd3f (the pause menu, VRAM, mode 3 and the
  divergence), and the merge.

**To install when merging**: `screens` and `mapdata` (the windows at 2bpp
and the geometry at half width); and the runtime is the-advocate's, so the
cartridges rebuild on their own.

**Space**, `just space` in ABL, bank 1 is the one that moved: in the MSU
test cartridge, the tightest, 252 B at 090b0037, 189 after part 1, 100
after part 2, and 8 after merging main —main's merges took the rest—;
`release` 829 → 585. Bank 0 did not move from my changes; far RAM, 12 B
of the layer's variables. The 4 KB wide stage is in `LZ2_BUFFER`.

**Not covered by a test**: no test opens another port's debug screen
—their windows, reduced to three colours a cell, are drawn from each
`mapdata.inc` in `/shared/captures/2026-10-20-debug-wide/`, and Vampires
Dawn's cursor bar comes out dark navy there—; nothing looks at a
variable's value at its widest, right-aligned in the wide mode; and no
test runs the text layer's wide mode with the pool exhausted and nothing
waiting —the case where a column stays blank—, which a page of whole
names does not reach.
