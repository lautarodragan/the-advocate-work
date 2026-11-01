---
name: "SP in the menu and in the item target picker"
description: "The main menu's and the item target picker's party boxes show HP and Ex but not SP, so an SP item cannot be aimed; the selection rectangle leaves a pixel of the text out on top; and the debug map needs a full party to try it"
type: feature
status: testing
assignee: taro
agents: [Tijereta]
---

taro, on 2026-11-01, in their words, translated:

> Something we left pending: it would be nice to show the SP/MP/whatever
> in the main menu. And, above all, in the character selection menu when
> choosing to use an item. In ABL, if you want to use Cheap Wine SP, for
> example, you don't know who to apply it to because you have no idea how
> much SP they have. You have to be in battle to see it.
>
> I thought we could try the big resolution again, with the wide font, but
> it might complicate that screen too much and not end up solving the
> problem, so maybe the best is to extend each character's box vertically,
> as we already did in the past to include HP and Ex, and include SP in
> that new line.
>
> On the other hand, a nitpick from the past: at a glance, it looks like
> the red selection rectangle doesn't quite cover 100% of the text at the
> top edge — one pixel is left out. I'd like it to be inside, and to have
> one or two pixels of padding, too.
>
> To put it to the test: I don't know if in ABL at some point you have
> more than 3 characters in the party. The easiest would be to generate it
> artificially: an option in the debug map that adds several characters to
> the party. It wouldn't make sense for the game itself, but it helps to
> debug the screen itself, and it wouldn't need touching code — it can be
> done with an event and RPG Maker commands. We can add Kersh, Core, Manta,
> and have Talan at the same time. I don't remember if RPG Maker allows
> more than 4. In that case, I'd add Arden and Saldra, too.

**Done**:

* each actor's box in the main menu and in the item target picker has one
  more line, with SP (the game's own term for it, from the database's
  vocabulary), for every game; the boxes grow vertically, in the 256-wide
  mode —not the 512 one—;
* the selection rectangle covers the whole text, with one or two pixels
  of padding, wherever that cursor is drawn the same way;
* ABL's debug map has an option that fills the party —Talan with Kersh,
  Core and Manta; RM2k's party is four at most, so Arden and Saldra in a
  second option, if that is the cap—, made with RM2k commands in the
  map's patch, not in code;
* goldens moved, red before, looked at, captures in `/shared/captures/`.

## Where it starts

Tijereta, from the-advocate `422f904d`, the ports `cd41913` and the book
`9407191`, on branches `tijereta-sp-in-the-menu` of the three.

**The box never grew before.** `git log -S MENU_EXP_Y` finds `27b65b66`,
the experience line: it did not add a line of cells to the row, it put
the line **in sprites**, eleven pixels below the HP, because "a fourth
line of cells does not fit in the row's 56 pixels". The rows were seven
cells from the menu's first commit (`606911f4`), and four of them are
exactly the 224 lines.

## Does a fifth line fit? Measured

On `menu-party`, Kersh's row (y 0 to 55): the name's ink is on rows 3 to
12, the level's 19 to 28, the HP's 35 to 44 and the experience's 46 to
55. A line of this font is **ten rows of ink** with its shadow, so five
lines need at least 5 x 11 - 1 = 54 rows with one blank between them,
and the bar's padding on top of that: the row has 56. And it is not
only height: the lines of cells are two cells each, at 16 pixels, and
only a line in sprites can sit eleven below another. The experience
already uses 4 x 30 = **120 of the 128 sprites**, so a second sprite line
in the menu does not fit either.

So **in the main menu a fifth line does not fit with four actors**, in
256 wide. Sideways neither: the text column is x 152 to 255, 104 pixels,
and the HP line already ends at 221 and the level's at 227.

**In the actor choice it does**: `Window_ActorTarget` has no experience,
so the fourth line, where the menu has "Ex", is free. That is what taro
put first ("above all, in the character selection menu").

**What was done, then**: the SP go on the actor choice's fourth line, in
sprites like the menu's experience, the number in the HP's cells so each
digit sits under the HP's: `MENU_SP_X` in `layout.rs`, `menu_sp_build` in
`runtime/menu_experience.s`. The choice for an item and for a healing
skill are the same screen, so both get them; a use rebuilds every row's
line and uploads the OAM in the next vblank, with the HP —a medicine
changes its target's SP and a skill its user's—. The menu keeps its four
lines, and equipping and the skills, which choose over the menu, too.
The book's divergence `what-the-party-panel-does-not-model` says it.

## The bar, measured

`barscan.py` over the goldens (scratch): every System cursor of the text
screens, the commands, the slots and the battle has **two rows of red
above the text's ink**. The two party bars had **none**: `TARGET_BAR` and
`MENU_BAR` started their red on the name's first row of ink —y 3 of the
row in `choice-sandwich` and `equipment-a-who`—, and that is the pixel
taro saw out. Both are now one rectangle, `MENU_BAR`, from y 1 to 58: a
line of red over the name and two under the fourth line. Not higher: on
the choice's first row y 0 is the window's frame. The choice's bar
reaches into the next row's first cell row like the menu's always did,
so `target_layer` and `compact_target` take eight cell rows per party
row (`BAR_CELL_ROWS`).

## The debug map

Two NPCs on ABL's debug map, `patches/manual/maps/Map1000.json`, at
(23,6) and (28,6): Talan with Kersh, Core and Manta, and Talan with
Arden, Saldra and AG7-17. Four is RM2k's most —`Game_Party::AddActor`
returns at `size() >= 4` in easyrpg-player—. Each removes everyone but
Talan with `ChangePartyMembers` and adds its three, and touches no
switch: the doors keep reading the companion the NPCs on the left chose.

## Tests and goldens

In ABL's `tests/rpgmaker/test_menu_heal_drawing.py`, on `release` through
the debug map's first full-party NPC, with two Cheap Wine-SP, Core at 5
SP and Manta at 30: the choice against `screens.target` with those SP,
the new golden `choice-sp-full-party` —the bar on the last row—, and the
wine on Core, 25 after it on the panel at once. `test_debug_map.py`
talks to each full-party NPC. The healing skills' comparison passes the
party's SP now: the user's go down on the panel.

**Red before**, honestly: the drawing tests compare against the render of
the same tools, so with `main`'s tools they pass —there is no SP on
either side—. What shows the change is the capture: with `main`'s tools
the full party's choice has three lines per row.

Goldens that moved, side by side in `/shared/captures/2026-11-01-sp-in-the-menu/`:
`choice-sandwich` (SP line, bar), `equipment-a-who` (the bar a line up),
the new `choice-sp-full-party`, and **the farm's two,
`paradise-127-celebration` and `paradise-127-farmers-jump`, which are not
the SP**: the debug map's NPCs grew the data, map 127's poses moved banks
and four farmers are caught a frame apart in their idle animation. Same
with `main`'s tools and the NPCs alone; green without them. Draft:
[`the-farm-s-goldens-move-with-the-bank-packing`](the-farm-s-goldens-move-with-the-bank-packing.md).

Space: with the SP code in bank 1, `release` had 149 B left there and
`test-msu` overflowed, so it lives in `FAR3`.

Found and not fixed: [`the-rust-on-main-is-not-formatted`](the-rust-on-main-is-not-formatted.md)
—`cargo fmt --check` fails on main, outside these lines—.

## The other games: a bug in Adeleine's tile merging

`just boot` stopped on Dooms 2: "the actor choice's windows are 65 8bpp
tiles", one over its 64. Dooms 2's System only fits there through
`skin_for` in `fit.rs`, which merges the least visible tiles with
Adeleine and pins the empty cell with half of `u64::MAX`; the merge added
weights with a plain `+=`, so the first tile that went into the empty
one wrapped it negative —a panic in debug— and the empty cell became the
next victim. With the bar's new cells that was one tile too many. Fixed
with a saturating sum in `snes/adeleine/src/fuse.rs`, its own commit and
test (red before in debug and in `--release`); Dooms 2 fits again with
the bar from y 1 to 58. ABL's ROM came out byte for byte the same with
and without the fix.

The test game's `renamed-menu` and `rename-slot` moved: the command and
slot cursors share the actor choice's sixteen BG1 colours, the test
game's System has more, and with the bigger bar the edge's dark green
merged into its neighbour, a shade lighter. Committed in the-advocate.

## What to install when merging

`just install screens mapdata` in the-advocate: the Adeleine fix goes
into `screens`, and the runtime (`runtime/menu.s`, `actor_choice.s`,
`menu_experience.s`) comes with the merge, since the cartridges are
assembled from the checkout the tools were installed from.

## Branches and what was run

Branches `tijereta-sp-in-the-menu` in the-advocate, the ports and the
book, with `origin/main` merged (the-advocate at `3071048a`, the
conditions; the ports at `0aca8ed`; the book at `5c982c2`).

Run on the merged tree, with `just install-local .local-tools battle
events screens mapdata cartridge` —the last two branches' Rust—: ABL's
`just tests` all green, `just boot` of the ports, `just test`, `just
test-game` and `just crate-test` of `screens`, `mapdata` and `adeleine`.
`just space` has room in every cartridge; the SP's code is in `FAR3`.

**What the suite does not cover**: the SP after a healing skill from the
skills screen is compared by `test_healing_skills.py` with the user's
SP, but no test uses a skill on the full party; and the pause menu's
SP —it has none, see above— is not drawn anywhere to compare.

## What taro has to look at

* The debug map, the two new NPCs right of the companions: each leaves
  four in the party.
* Items, Cheap Wine-SP: each row with its SP under the HP; use it on
  someone, and the number changes right there. The last row's bar
  reaches the screen's bottom edge, over the window's frame.
* Tech Skill, a heal: the same panel, the user's SP going down.
* The bar on every party row —the actor choice, choosing whom to equip
  or whose skills—: a line of red over the name now.
* The main menu, as it was: no SP, it does not fit with four actors.
  If taro wants it anyway, it costs something they choose: the state
  "Normal", the experience, or the 512-wide mode.
