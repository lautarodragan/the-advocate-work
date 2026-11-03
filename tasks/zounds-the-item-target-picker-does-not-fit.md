---
name: "Zounds: the item target picker does not fit"
description: "Using an item in Zounds, the item's name wraps and its windows run under the faces, and the party list's border is cut; taro proposes the item's line on top, in one row, and the party list full width"
type: bug
status: testing
assignee: taro
agents: [Aguará]
---

taro, on 2026-11-02, playing Zounds' build of the-advocate `23b413cd` and
the ports `3e4e95d` on the console, with a photo of the screen
(`/shared/captures/2026-11-02-zounds-item-target/taro-on-the-console.webp`),
in their words, translated:

> problems... I don't know how we can fix this screen (use item). Without
> the faces, it would be easy. With the faces... the only thing I can think
> of is moving what is on the left to the top (ideally in a single row), and
> the list of characters being full width

## What the photo shows

The Green Potion used from the item screen, two in the party:

* the item's name, "Poci?n Verde", wraps into two lines, and its `ó`
  comes out as `?` —the item list draws the same names without that—;
* the item's window and the "Tienes: 1" one run under the faces, which
  are drawn over their right border;
* the party window's own frame is cut where the left windows meet it, and
  the highlighted actor's cursor box covers the name and stats but not the
  face.

RM2k lays it out on 320 pixels: 136 for the item and the count, 184 for
the party with its faces. On 256 they do not fit side by side.

## Asked

taro's layout: the item's name and how many one has, on top, in a single
row, and the party list below, full width, faces included.

## Log

Aguará, from the-advocate `23b413cd`, the ports `3e4e95d` and the book
`9e82b10`, on branches `aguara-item-target` of the three.

### What RM2k does, read

`Scene_ActorTarget::Start` (easyrpg-player): `Window_Help(0, 0, 136, 32)`,
`Window_TargetStatus(0, 32, 136, 32)` and `Window_ActorTarget(136, 0, 184,
240)`. `Window_ActorTarget::Refresh` draws per actor, on a pitch of 58
(`i * 48 + y`, `y += 10`): the face at 0, the name at `48 + 8`, the level
and the condition under it, and the HP and the SP in a second column at
`48 + 8 + 46 (+12)`: **three lines** a row. Its `UpdateCursorRect` is
`{48 + 4, index * 58, 120, 48}`: **the cursor never covers the face**,
for one row, for the whole party (`-100`) or fixed on one. So the photo's
"the bar covers the name and stats but not the face" is RM2k's, and stays.

### Which games show faces there

All nine: ABL 25 of 50 actors with a face, The Book of Three 14/15,
Desert Nightmare 1/1, Dooms 2 10/11, El Dorado 1/1, The Frozen World
11/12, Sunset 1/1, Vampires Dawn 12/14, Zounds 5/5 (`actors.json` of each
`data/db`). So the side-by-side layout loses for every one of them, and
the decision is **one layout, always**, not only with faces: the left
column was 104 pixels in every game —a name of more than eleven letters
went on two lines in ABL too— and two layouts would be two screens to
draw, test and keep.

### How many rows fit

With the item's line as a 32-pixel window (RM2k's `Window_Help`), 192
lines are left: **four rows of 48, a face's height, exactly**, and no
room for a party window's two frames (four rows and the frames are 208,
and with the line on top 240: RM2k's height). So the party goes **without
a window**, like the pause menu's panel, and no scrolling is needed: RM2k's
party is four at most (`Game_Party::AddActor`). Each row is
`Window_ActorTarget`'s three lines: the menu's block —name; level and
condition; HP— moved to the left edge, and the SP beside the HP (in RM2k
under it, where the condition shares the level's line here). The full
width leaves room for them as cells, so the SP left the sprites the actor
choice drew them in since 2026-11-01.

### The `?` of "Poci?n"

`emit.rs` wrote the medicine names for the actor choice with `if
c.is_ascii() { c } else { '?' }` (from `ac8b075b`, the port to Rust), and
the screens stage handed them the database's name as is: no plain
stand-in, which the item list gets through `item_text`. Now the stage
stores the line as `texts::target_text` —`item_text` without icons, padded
to the cells— and the emission refuses anything that is not that. Skills
the map can use get their own copy too, `skill_target_names`, instead of
reading the battle's text and cutting it in two lines with
`skill_name_cut`. Both keep their ExFont icons: the menu's bank carries
the screens' glyphs since `b8e28d6a` —for the skill's name, which went by
reference—, and the medicines dropped theirs only because their table was
ASCII. So the potion shows its icon there now, as RPG_RT's `Window_Help`.

### The SP, from sprites to cells

With the SP beside the HP on the third line, they are cells, like the
pause menu's: `menu_sp_cells` in `menu_list.s` writes both screens' line
from a slot of words, `menu_sp_slot`, and the actor choice's refresh after
a use makes every row's slot outside the vblank and uploads them with two
DMAs a row in it (`target_sp_refresh`). The slots are the start of `oam`,
which the sprite version already used on this screen. The sprite code
(`menu_sp_build`, `menu_sp_paint`, `menu_sp_refresh`, `target_ppu_with`)
is gone. `menu_row_vram` got a fifth entry, the pause menu's painting
place, so the actor choice's four rows can be anywhere.

### A side effect: the gradient Systems

The test game's gradient System (`system_gradient.rs`) needed the actor
choice's windows fused until today; with the item's line as its only
window its cells fit the bank as they are. The todo
[`a-gradient-system-stops-the-converter-at-the-actor-choice`](a-gradient-system-stops-the-converter-at-the-actor-choice.md)
is about the 65 tiles of the old layout: whether it still happens for a
gradient System with no `[windows.background]` was not measured here.
Zounds' own windows, with its flat background, went from 91 tiles to 67
of the bank's 64: still fused, less.

### The name's room

A first version stored sixteen letters: the build's WARNING cut eight of
ABL's medicines ("Strength Potion-ATK", 113 pixels) and eight of Zounds'
("Tostado de Jamón y Queso" with its icon) by their letters, with pixels
to spare. So the converter cuts a name by **pixels**, where it reaches
the term —`borders::target_name_room`, right-aligned to the count— and
the cartridge stores thirty letters, the window's cells, found at `k *
30` with the multiplier. With that no medicine of ABL or Zounds is cut.

### Tests and goldens

* **New, in the ports**: `tests/test_zounds_item_target.py` with the case
  `zounds/cases/item-target.json` —Unamë and Kazar, two Green Potions, map
  86—: the pause menu, Items, the potion, A; golden `zounds-item-target`
  in snes9x and identical in bsnes; then Kazar, his SP put at 2, drinks
  one: 37 SP in RAM and on the screen, golden `zounds-item-target-used`,
  one potion left. **Red before**, with main's tools: both goldens differ,
  40673 and 39093 pixels of 57344 —the old layout, taro's photo—.
* **Moved, in ABL**: `choice-sandwich` and `choice-sp-full-party`, in
  `test_menu_heal_drawing.py`, which compares the ROM against the render
  first and matched it. Nothing else moved: the pause menu's
  `equipment-a-who` and the rest stayed, with the menu's block at six
  cells.
* Before, after and difference of the four, with a contact sheet and a
  README, in `/shared/captures/2026-11-02-zounds-item-target/`, next to
  taro's photo.

### What was run, with the branch's tools

`just install-local .local-tools screens mapdata cartridge project` in
the-advocate's worktree, and with it:

* the-advocate: `just test` 29 passed; `just rust-test` 1144 passed;
  `just lint` clean; `just crate-test screens` and the mapdata tests
  green.
* ABL: `just cartridges` and `just tests`, **1639 passed, 2 skipped**,
  twice in a row with nothing new red (the second after the name's room).
* The ports: `just boot`, **144 passed** —the 142 of before and the new
  two—.
* `just space` (bytes free): ABL's `release` 126 of 126 banks, bank 0
  296, bank 1 1428, far RAM 269; its tightest bank 1 is `test-msu`'s, 851.
  Vampires Dawn 126 of 126, bank 0 225, bank 1 805, far RAM 1007. Zounds
  bank 0 234 (244 on main: `menu_row_vram`'s fifth word and the tables),
  bank 1 1389, far RAM 302 —the same: the SP's slots are `oam`, not far
  RAM—.

**What the suite does not cover**: an ExFont icon in a name against the
render —ABL's medicines and skills have none; Zounds' golden has one, but
golden only—; a healing skill's choice in Zounds; the vblank's budget of
`target_sp_refresh` on the console, which no emulator here measures —eight
DMAs of 14 bytes and the row lookups, where the sprites' version was one
DMA of 544—.

### Found and not fixed

* [`zounds-skill-names-show-a-question-mark-for-an-accent`](zounds-skill-names-show-a-question-mark-for-an-accent.md):
  the battle's text carries Zounds' skill names with a `?` for an accent
  ("L?tigo"), found in the cartridge's text; a line in Zounds' "Known
  issues" in the book.

### What to install when merging

`just install screens mapdata cartridge project` in the-advocate: the
runtime (`actor_choice.s`, `menu.s`, `menu_list.s`,
`menu_experience.s`) comes with the merge, and the cartridges are
assembled from the checkout the tools were installed from.

### Branches

`aguara-item-target` in the-advocate (`3defe2ed`), the ports (`4075030`
the Zounds test, `d14fad3` ABL's goldens) and the book (`ab27ed3` the
divergence, `7fc9e40` Zounds' known issue). Their mains had not moved
since `23b413cd`, `3e4e95d` and `9e82b10`.

## What taro has to look at

* Zounds: any medicine from the items screen, with two or more in the
  party —the item's line on top with its icon and "Tienes", the rows
  below, the SP beside the HP and going up when used—.
* ABL: the debug map's full-party NPC and a Cheap Wine-SP —four rows to
  the screen's last line—; a heal from Tech Skill, its name and cost on
  the same line.
