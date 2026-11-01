---
name: "A wider font for the 512-wide debug screen"
description: "At 512 wide the debug screen's text is hard to read on a CRT; try one or two new fonts about 1.5 times as wide as the current one, drawn for that mode, and show taro how the screen looks with them"
type: feature
status: testing
assignee: taro
agents: [Hurón]
---

taro, on 2026-11-01, in their words, translated, after
[`the-debug-screen-redraws-and-goes-wide`](the-debug-screen-redraws-and-goes-wide.md):

> It turns out the 512 screen isn't particularly readable on the CRT. I've
> been wondering whether it's worth doing another experiment in that
> resolution, making the fonts bigger but not necessarily double
> (horizontally). We already saw that multiplying the fonts' width by
> non-integer factors gives ugly/unreadable fonts, so we'd have to "invent"
> a new font, about ~1.5 times the current one on average, and try it in
> that resolution.
>
> Could you make one or two, and send me screenshots of how the debug
> screen looks/would look with those fonts?

**Done**: one or two new font sheets, drawn by hand for the 512-wide
pixel —not the current one scaled—, about 1.5 times its average advance;
captures of the debug screen with each, next to the current one, in
`/shared/captures/`. An experiment: nothing is merged into the engine
until taro picks.

## Work log (Hurón)

Worktrees from main —the-advocate 1dc83c6c, the-advocate-ports ab38e40—,
on branches `huron-wide-fonts`.

### The two sheets

What taro sees today is `low-variable` with ABL's `letter_spacing = 1`:
an ASCII mean advance of 5.95 of the 512-wide pixels, 5.96 the lowercase,
and every vertical stroke one of those pixels wide —half a pixel of the
TV's usual 256—, which is what the CRT's horizontal blur eats.

Both new ones are drawn on the 512-wide pixel, at the same height —RM2k's
baseline, capitals rows 1 to 9, x-height 3 to 9—, with **vertical strokes
two pixels wide** and horizontal ones one tall, and two pixels of air
after the ink (the shadow takes the first, so a black column always
separates letters). Their own air, so `letter_spacing` goes to 0. ASCII
only: Latin-1 goes plain, as the README says of a sheet without it.

* `hires-wide`: round counters three wide —`o` is `##...##`—. Lowercase
  mean advance 8.35 (1.40 times today's), capitals 8.77, ASCII 8.01.
* `hires-compact`: the same letters with the counters two wide —`##..##`—,
  taken from `hires-wide` by cutting a column where that works, the rest
  (digits, `K`, `k`, `R`, `Q`, `r`, `Z`, `z`, `A` and some punctuation)
  redrawn. Lowercase 7.73 (1.30 times), capitals 8.23, ASCII 7.48.

`m`, `w`, `M`, `N` and `W` are eight of ink, the composer's limit
(`INK_MAX`), and move the line ten. That is more than a cell, which
`with_spacing` refuses as a game's font, because the battle checks its
victory lines one letter per cell. As the debug screen's own font it does
not matter: there a cell is sixteen of the font's pixels.

### Names that fit, measured

With `Geometry::of` and `fitted` of `debug_screen.rs` replayed over each
game's `switches.json` and `variables.json` with each sheet's advances:
**every named switch and variable of all nine ports fits whole with
both fonts**. ABL's widest switch, `SecondMonthWakeupDON`, is 180 of the
236 pixels `hires-wide` leaves (165 of 252 with `hires-compact`); the
ranges' window grows from 7 cells to 9 (wide) or 8 (compact). RM2k's
names are twenty characters at most, so there is room for an even wider
font before a name is cut again.

### The captures: a real ROM, with the font for the debug screen alone

The first try was to make each sheet the whole game's font. The converter
refused: ABL's custom menu's help and its lines no longer fit, and every
screen that measures text would follow. So the branch has a variable,
`HURON_TABLES_FONT`, read by the screens stage. With it set, the
cartridge's glyph tables —the bitmaps, the text layer's precomposed inks
(`text_inks`), the advances and the reach— and the debug screen's geometry
and name cuts come from the named font. Everything else keeps measuring
with the game's font, so it builds; it then draws the new glyphs in boxes
measured for the old ones, and nobody looks at that here.
`Font::with_latin_from` fills in, from the game's font, the Latin-1 letters
an ASCII-only sheet lacks. The cartridge's fingerprint does not see the
variable, so each build is `just cartridges --force release`.

A throwaway test in the ports, `tests/rpgmaker/test_huron_wide_fonts_shots.py`,
takes four shots per font: switches 71-80 (taro's report), 311-320 (the
range with the most letters), and variables 141-150 (the widest names) and
51-60 (the busiest). The three builds —current, wide, compact— use the same
tools. The shots are in `/shared/captures/2026-11-01-debug-wide-fonts/`:
native 512x224, a 4:3 copy, a stacked comparison, the sheets and a
README.txt.

### The limit: the text's VRAM in mode 5

On switches 311-320 both new fonts run out of room. The page's last
`[OFF]`s don't show, and with `hires-wide` neither does the end of
`WyldenDogSceneDone`. Waiting 400 frames instead of 60 changes nothing.
The text's quads are `DBG_QUADS`, from word 0 up to `CM_BG1_MAP`: 223 with
ABL's layout. A wider font inks more 16-pixel cells per row. Counting the
inked cells in the captures, 71-80 needs 139 with the current font, 199
with wide and 181 with compact; 311-320 needs 161, and both new fonts top
out around 208-209, cut. A model of each page's demand (ranges' labels,
plus each row's number, name and tail) estimates 38 of ABL's 145 ranges
short with `hires-wide` and 4 with `hires-compact` against that observed
ceiling. It is an estimate: the model gives 216 for compact's 311-320,
which the ROM shows short of 223, so something more holds quads (perhaps
the previous page while the new one composes). **Whichever font is
picked, adopting it first needs more VRAM for the debug screen's text**,
or quads that are not spent on blank cells. That is not a bug on main:
with the current font the densest page needs about 164.

### Where it was left

Branches `huron-wide-fonts`:

* the-advocate: 96433bf7 (the two sheets, bundled, and the fonts README)
  and 76463efa (`HURON_TABLES_FONT`, the experiment's hack, not to merge);
* the-advocate-ports: c16cd5f (the throwaway shots test, not to merge).

Nothing to install or merge until taro picks. Then the real work is: a
font of its own for the 512-wide mode (`[debug] font` or similar, its own
tables in the cartridge and the hires glyph path reading them, instead of
the hack's swap of the whole tables), and the VRAM room above.

**Not covered**: no test runs the new fonts; the pages counted short come
from the model, not from shooting all 145 ranges; the new fonts were not
seen on a CRT, which is the point of the experiment.

## taro's decision

taro, on 2026-11-01, after trying the three experimental ROMs on a CRT, in
their words, translated:

> I remembered right: the current one is practically unreadable.
>
> But the wide and the compact are good! The compact makes my eyes hurt,
> and I don't think I could read it from a certain distance, or on a
> lower-quality TV, but the wide reads perfectly, looks very nice, and more
> characters fit on screen!
>
> Let's go with the wide for the debug menu.

**Done**, now: `hires-wide` is the 512-wide debug screen's own font in the
cartridge, for every game, whatever font the game uses elsewhere; the
experiment's `HURON_TABLES_FONT` hack does not reach main; and no page of
the debug screen loses text for lack of VRAM —measured over every range of
the nine games, not estimated—. Goldens of the debug screen moved, red
before.

## Work log, the real thing (Hurón)

Branches `huron-debug-font` from the-advocate 422f904d and the ports
cd41913, with the sheet's commit cherry-picked from the experiment and
`hires-compact` deleted. The experiment's branches go once this is merged.

**The font is the engine's fixed choice, not a knob.** `Font::debug_screen`
in `rm2k-snes-text`, out of the bundled list a project can name: its
letters move the line up to ten pixels, more than a cell of the 256-wide
screens, so no game can use it as its font, and a `[debug] font` knob
would choose among one. If a second one is ever drawn, that is when a knob
earns its keep.

**Latin-1.** The nine games' switch and variable names use `ä ö ü Ä Ö ß`
(Desert Nightmare, El Dorado, Vampires Dawn) and `á ó ú ô ë Ë ñ Ñ`
(Zounds). The screens' text layer was ASCII only —a name went plain,
`Händler` as `Handler`—. `hires-wide` now draws 54 Latin-1 letters, made
from its own ASCII by a throwaway script (accents from its own `` ` ``,
`^`, `~`; capitals squashed to rows 2-9 so `Ö` is not `ö`); the cartridge
carries only the ones the game's names use, as glyphs 97 on —byte 129 on
in the names, past `TL_FIGURE`—.

**The VRAM: measured with a model first.** A throwaway model of the
screen —the geometry, the font's advances and reach, the layer's columns
of sixteen— over every range of the nine games, counting the quads each
page inks and what a step from one range to the next asks for while the
old one is still on screen (a row's old quads wait for the switch, and
the rows not typeset yet keep theirs):

| game | densest page | worst step |
|---|---|---|
| ABL | 233 | 256 |
| The Book of Three | 240 | 264 |
| Desert Nightmare | 219 | 242 |
| Doom's 2 | 195 | 213 |
| El Dorado | 209 | 233 |
| The Frozen World | 246 | 270 |
| Sunset over Imdahl | 222 | 242 |
| Vampires Dawn | 233 | 260 |
| Zounds | 224 | 255 |

(values at their widest, `-00000`; the experiment's ROM saw 311-320 short
of 223 and the model gives 233 for that page, so it agrees.) **A tilemap
word names 1024 tiles, 255 quads**, so moving the tilemaps out of the way
—the most VRAM can give— is not enough: some steps ask for 270. Cutting
names on dense pages would lose text, and blanking the rows not typeset
yet when the pool runs out is the black block taro saw on 2026-10-20.

So **two pools, one per half of the screen**: an HDMA writes BG12NBA at
line 112, so BG1's upper half takes its tiles from word 0 and the lower
half from $4000, each its own 1024; the text layer keeps a pool per half
(255 and 191 quads) and a row only takes, releases and adopts in its own.
A half is five lines; what it can ask for at once is its five lines and a
sixth one changing, and a line inks at most 30 columns (1 to 30, inside
the frames): 180, which both pools hold. **So no page can lose text, in
any game, whatever its names**: an `.assert` in the runtime, not a
measurement. The windows' tiles go to $7000 (256 tiles at most; was
1024 in the converter's check), the tilemaps to $7800 and $7C00.

**Two bugs on the way**, both in the ROM's first try and both seen in the
captures: `tl_dma_quads` took a quad's VRAM address with `xba`, which is
times 256 only below quad 256 —the lower half's text went up over the
upper half's—; and the waiting stack's top was taken as relative to the
pool's base when it is an index of the whole `TL_FREE`, so the lower
pool's waiting quads went past the array.

**And measured anyway, in the ROM**: a test walks every range of every
page —down round the page, right to the next— and reads both pools from
RAM every frame; a column is left blank only when its row's pool has none
free. ABL's in `test_debug_screen_golden.py`, the other eight's in the
ports' `tests/test_debug_screen_room.py` (it opens the pause menu
allowing it, and goes up to its last row). **Red first**, with the
runtime built as one pool of 255 —the split moved past the last row,
everything else the same—: The Book of Three ran out (least free 0, 239
in use); ABL got to 233 of 255 without running out.

**Green** with the two pools, in all nine games: neither pool got to
zero on any frame of any step. The tests print, per game, the most quads
each pool had in use and the least it had free —`just boot
test_debug_screen_room.py -s` at the ports' root, and ABL's
`test_no_range_runs_out_of_quads` with `-s`—; on 2026-11-01 no pool had
more than about half of its quads in use. "Least free" goes low on
purpose: the layer only switches, and recycles what waits, when a row
does not fit. Sunset over Imdahl's menu never opened with B —it forbids
it, reads B itself and walks its hero on an endless route—, so the walk
asks for the menu in RAM, as `request_menu` does, and ends the route.

**A shop golden moved** with nothing of the debug screen in it:
`shop-armors-sold`, the walking actor's pose in the party window, 223
pixels. The party's frames go up only if the vblank's line leaves room,
and the font's ~125 KB of tables moved other data between fast and slow
ROM (the packing puts the biggest pieces first). With main's tools it
matches and the text settles on the same frame with both; moving the
512-wide finish out of the 256-wide one (which now pays less per column
than before) did not bring it back. Blessed in its own commit.

### Where it was left

* the-advocate `huron-debug-font`: c2811eb5 (the font, its Latin-1, out of
  the bundled list), 93b0bd2b (the screen writes with it; the two pools,
  the HDMA and the VRAM; `tl_dma_quads` past quad 255).
* the-advocate-ports `huron-debug-font`: c74f879 and 4ae04b1 (the walks),
  487ac4c (the four debug screen goldens), 18a4fef (the shop golden), and
  main merged.
* the-advocate-docs `huron-debug-font`: 8ea9f0b (the pause menu, VRAM and
  the divergence), and main merged.
* **To install when merging**: `just install screens mapdata` —`text`
  changed too, but only by a function those two call—. The runtime comes
  from the checkout, as always.
* Captures: `/shared/captures/2026-11-01-debug-wide-font-final/`, with the
  goldens before and after and photographs of the Latin-1 names.

**Not covered**: no test looks at the Latin-1 letters' pixels (the
photographs are for taro); the walk steps down and right, so a step up,
left or a jump between pages that are not neighbours is covered by the
`.assert`'s argument, not by a measurement; and the font was not seen on a
CRT after the Latin-1 was drawn. And a note, not a bug: `tl_text_at`
measures a capped text with the game's font even in the 512-wide mode; the
debug screen never caps (it writes its names whole, already cut by the
converter), so nothing measures wrong today.
