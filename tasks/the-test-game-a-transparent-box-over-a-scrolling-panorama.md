---
name: "The test game: a transparent box over a scrolling panorama"
description: "A scene in the test game with characters, a transparent message in the middle of the screen, a floor and a panorama that scrolls on its own, with a test that measures it: the stress case of ABL's map 1, kept where it costs ABL nothing"
type: feature
status: done
assignee: taro
agents: [Aguará]
---

From [`a-window-line-cannot-wait-forever`](a-window-line-cannot-wait-forever.md):
taro's stress case —ABL's map 1 with `EV0002` transparent and in the
middle— was measured but not kept as a test, because in ABL it needs the
whole page in `release`, which moves the text block and the goldens.
taro, on 2026-11-16:

> Can you add this case to the test game? Characters + text in the
> middle, transparent background + floor + a panorama that moves. Even if
> it breaks, it's worth having a test that shows it.

Done means: a map in the test game with a panorama that scrolls on its
own, a floor, characters moving, and a transparent box in the middle
whose letters go over the panorama; a test that measures, per line, the
vblank line it goes up at and its margin, that no display access happens
on the accurate core, and what it looks like (a golden). If something is
wrong —the striped edges of
[`a-transparent-window-over-a-flattened-panorama-shows-striped-edges`](a-transparent-window-over-a-flattened-panorama-shows-striped-edges.md),
for instance— the test shows it: an `xfail` naming the draft, or a golden
of the broken state said as such, not a test bent to pass.

## Log

**Aguará, 2026-11-16.** From the-advocate `63555c31`, branch
`aguara-test-game-pano` (merged with main `7fa94195`); the book, branch
`aguara-test-game-pano`. Scratch in `~/scratch/aguara/test-game-pano/`.
Nothing of ABL is touched.

**The scene**: map 9, the terrace, 30x15: a slab of grass in a night sky,
`Panorama/Stars.png` —ours, CC0, 320x240, 11 colours, drawn by a script,
loops on x— scrolling 3 a step on its own; two trees whose crowns make it
**flattened, mode 3**, as ABL's map 1 (the converter's log says so). The
case `terrace` teleports the hero to (10, 12); the map's event 1, a
**parallel** page, shows four transparent middle boxes (4, 4, 3 and 1
lines; `MessageOptions` `[1, 1, 0, 0]`: no dodge, or the hero low on the
screen sends a middle box to the top, as RM2k does) and erases itself.
Parallel and not automatic because under a running automatic page the
walkers' own routes stop —RM2k's `Game_Event::UpdateSelfMovement`, and
ours— and taro asked for characters moving. Three walkers with repeating
routes, walking through everything. Sky is left where the lines start and
in a hole in the slab.

**The test**, `test-game/tests/test_terrace.py`:

* `test_each_line_goes_up_inside_the_vblank` (snes9x, bsnes), on a new
  cartridge `test-vblank` (`--vblank-probe`, maps 4 and 9, only that
  case): no forced blank, no line missing its second vblank, the window's
  writes ending by line 258;
* `test_nothing_reaches_the_screen_while_it_is_drawn`, `release` on the
  audit core with the accurate PPU; skips without it (`AUDIT_CORE`,
  default where ABL's `just audit-core` installs it);
* `test_what_it_looks_like` (snes9x, bsnes): goldens `terrace-first-box`
  and `terrace-three-lines`, the same at 15 bits on both cores. They keep
  the known divergence —the panorama black on the box's lines, the
  walkers over the letters—, said in the docstring and the commit.

For that the harness got a cartridge other than `release`, the core's
options, and the display audit: `retro.py` is ABL's again at the ports'
`ebe3367`, and `bsnes-display-audit.patch` is copied; the CI builds the
audit core next to bsnes.

**Measured** (identical on snes9x, bsnes and the audit core but for the
second tries' lines): 34 calls of `upload_line`; 22 went up on their first
try reading line 235 or 236 —margin 3 or 2 to `LINE_LATEST_BARE`, 238—;
6 read 239 or 240, missed it by 1 or 2 and went up on the next vblank at
235 to 237 —margin 11 to 9 to `LINE_LATEST`, 246—. No line waited two
vblanks, the ceiling never fired, the window's writes ended at worst on
line 256, `flush_video` at worst on 259; **0 display accesses**. The same
picture as ABL's map 1. Red when it should be: with the probe's
`VBLANK_STALL` at 251 the first test fails, the ceiling firing on every
line; at 245 it passes (every line on its second try, as designed).

**Not broken here**: the striped edges of
[`a-transparent-window-over-a-flattened-panorama-shows-striped-edges`](a-transparent-window-over-a-flattened-panorama-shows-striped-edges.md)
do not show, with the camera against the map's edge or inside it: no
xfail, since nothing fails; the draft says what it leaves.

**Verified**: `just test-game` on the merge with main: 65 passed, 1
skipped (bsnes's SRAM), 3 failed —the three of `test_leader_name.py` of
[`the-test-games-leader-name-goldens-are-red-on-main`](the-test-games-leader-name-goldens-are-red-on-main.md),
not this—; `tests/test_test_game_assets.py` green. Tools: the global ones
(installed from main), nothing installed locally.

**What it does not cover**: the console's timing and an FX Pak's hooks;
the layer above for the text (a flattened map has none); a camera that
moves while a box is up; the CI's audit core, written and not run.

**To merge**: the-advocate `aguara-test-game-pano` and the book's
`aguara-test-game-pano` (one bullet in `progress/the-test-game.md`).
Nothing to install. Captures: shared folder,
`captures/2026-11-16-test-game-pano/`.

**2026-11-16, taro**: declared done.
