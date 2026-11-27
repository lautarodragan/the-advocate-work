---
name: "The screens' reference drawing has no caller"
description: "With rm2k-snes-screens' binary gone, render.rs's screens drawn as the console has to show them —the menu, the items, the actor choice, the slots, the equipment, the shop, the skills, End Game, the title's menu— are dead code of the crate"
type: refactor
game: advocate
status: testing
assignee: taro
author: carpintero
agents: [Carpintero]
links:
  found-in: [tests-without-the-stages-subcommands]
  found: [the-screens-older-dead-pub-items]
---

Found by Carpintero on 2026-11-27, doing step 3 of
[`tests-without-the-stages-subcommands`](tests-without-the-stages-subcommands.md),
on the-advocate's `carpintero-tests-step3`.

**What is left**: `rm2k-snes-screens`' binary went —its `render` was what
ABL's tests compared the console against, and they compare goldens now—,
and with it the only caller of most of `render.rs`. Made `pub(crate)`,
rustc names as never used `Painter`, `compose_text`, `state_row`,
`paste_text`, `actor_row`, `menu`, `target`, `target_skill`,
`target_with`, `sp_cells`, `slot_screen`, `item_screen`, `candidates`,
`new_value_color`, `equipment_screen`, `shop_screen`, `shop_item` and
more past them —`render::equip`, `fit::skin_for`, the request's `Json`
helpers the binary read, `stage::game_with_font`—, some thousand lines.
What the converter does call from there (`Grid`, `SYSTEM_INK`, `Party`,
`Shop`, `item_screen_text`, `shop_text`) stays.

**What to do**: take out what only the binary reached, by rustc's
dead-code warnings with the module made `pub(crate)` —mechanical, the
ROMs byte for byte the same—; the crate's tests that draw a screen
through it, if any, go with it or move to what the converter calls. Left
out of step 3 so that the binaries' commit stayed small and checkable.

## Log

### 2026-11-27, Hornero: promoted to `todo`

Promoted by Hornero: dead code since step 3 removed its last caller; deleting it changes nothing seen or heard.

### 2026-11-27, taro: go

> Can you take this one too? If it is plain dead code, I suppose we can
> delete it and that is it, and if everything builds and the tests pass,
> we are fine, right?

### 2026-11-27, Hornero: taken, to Carpintero

Yes: the deletion is mechanical, and its net is the build without
dead-code warnings, the-advocate's suites and every port's ROMs byte for
byte equal to `main`'s. With equal ROMs ABL's suite has nothing new to
say, so it is not run; Cardón is measuring battle suite times meanwhile.

### 2026-11-27, Carpintero: what went, by rustc

On the-advocate's `carpintero-dead-render`, from `ab885b29`. `render` made
`pub(crate)` named the drawing; deleting it named a second ring, outside
`render.rs`, found by making every module but `answer` and `request`
`pub(crate)` for a moment, with what the converter, the emission and the
crate's tests call re-exported as roots:

* `render.rs`: `Painter` and the helpers it painted with, `Party`,
  `menu`, `target`, `target_skill`, `slot_screen`, `item_screen`,
  `candidates`, `equip`, `equipment_screen`, `shop_screen`,
  `skill_screen`, `end_game_screen`, `title_menu`, `Grid::render`, and
  the `Shop` fields only the drawing read (`party`, `frames`, `phase`).
* `party.rs`: `Shown`, `shown`, `draw`, `walking_frame`, `arrow_frame`
  and their two unit tests —the cartridge animates the shop's party
  itself—. What makes the members' and arrows' tiles stays.
* `slots.rs`: `slots_screen` and `Slots::too_many`.
* `texts.rs`: `shown_state`, `equipped_params`, `max_sp`, `sp_text`,
  `exp_text`, `digits_of` (and its two asserts in a test that goes on
  covering `right` and `item_text`).
* `request.rs`: `Json`, the key-by-key reader of `render` and `equip`.

What the task feared dead and is not: `fit::skin_for` and
`stage::game_with_font` are called by `convert` and `stage::boxes`; they
stay. `render` stays `pub(crate)`, with a comment saying why.

Left out, not reached by the binary: `convert::hex`,
`message_window::{convert, font_bytes, font_reach}`, `custom_menu`'s
`replaces_common`, `befores`, `variables` and `layouts`, `layout`'s
`Variant::ALL` (and its `None` and `Left`, which only a unit test
builds), and `cells`' `is_empty`, `get` and `contains`. Dead `pub`
items of a `pub` module, from before the binary went; a draft,
[`the-screens-older-dead-pub-items`](the-screens-older-dead-pub-items.md).

The comments that cited what went —thirteen runtime headers, the
crate's README, six module docs— in a second commit, and six pages of
the book on `carpintero-dead-render` of the-advocate-docs. `LAYOUT.md`
names nothing that went.

### 2026-11-27, Carpintero: verified, to `testing`

#### The branches

* the-advocate `carpintero-dead-render`, from `ab885b29`: `249883e7` the
  deletion, 1,566 lines out and 7 in, in seven files of
  `rm2k-snes/screens/src`; `736a58f9` the comments, 81 out and 50 in.
* the-advocate-docs `carpintero-dead-render`, from `8e8d69c`: `f3fe42e`,
  six pages.

#### What was run

On the deletion with the comments on top: `cargo build --workspace
--all-targets`, no warnings; `SOUNDFONT=…/FluidR3_GM.sf2 just lint`
—rustfmt, clippy `-D warnings`, Goombario over the test game's
cartridges built with this `advocate`—, green; `just test`, 29 passed;
`env -u SOUNDFONT just rust-test --no-fail-fast`, 1265 passed, 3
ignored, none failed.

The ROMs: `just install-local .local-tools advocate`, and in a worktree
of the ports at `dd440b5`, without `SOUNDFONT`, every game's `release`
—ABL's `--without-tracks`— built once with the global tools (main's) and
once with these. The nine `.sfc` are byte for byte equal both ways, and
equal to the ones in each game's delivered build. ABL's suite was not
run: equal ROMs leave it nothing to say, and Cardón was measuring.

#### To install when merging

`just install advocate`, from `~/the-advocate`: the only binary that
links `rm2k-snes-screens`.
