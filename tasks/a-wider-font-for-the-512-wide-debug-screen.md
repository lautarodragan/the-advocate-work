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
