---
name: "The console's custom menu"
description: "ABL's Portable Console as a custom menu of the engine, described as data, from the pause menu and full screen, instead of its 61 pictures: the study, and the implementation for any game with ABL as the first case"
type: feature
status: done
assignee: taro
---

It was born on 2026-10-04 as "the console's pictures, through the MSU-1": taro
had decided that the more than 40 pictures of the console would be only in the
`.msu`. That same day he changed his mind, before anything had been
committed: "Not having the console, I think, does not prevent playing, but
it makes the experience somewhat worse. […] I think we can turn that whole
system into something custom but generic — a feature designed to build
custom menus, that follows the same rules as the rest of the
items/etc. menu. Then we would not need any picture. Or maybe only
the ones that show the characters' art". It is the idea of
`un-menu-custom-propio.md`, without mode 5: today there is variable width
in low resolution.

And two decisions of his for the design: **it is one more option of the pause
menu**, and **always full screen** ("this system does not allow
rendering over the map. That way we solve VRAM challenges etc.").

The assignment: a study with mock-ups, **and stopping before touching the ROM**,
because it is design and taro wants to see it. Lagartija did it, from `main` at
`43b552f5`, with ABL at `5b29ba9`.

## What was done

* **The study**: `docs/research/2026-10-04-el-menu-custom.md`. The
  inventory page by page, the feature's design, what the whole VRAM
  gives, and what it would cost.
* **The captures of the original and the mock-ups**, in
  `/shared/capturas/2026-10-04-menu-custom/`, with their `LEEME.txt`: fourteen
  captures of the original under Wine —the window of Talan, Arden, Sern and
  Emily, Talan's guide, his skills, four aura tables, Sern's
  souls and the pause menu— and five mock-ups, each side by side
  with its original.
* There is no code: neither in the ROM, nor in the converter, nor in ABL. No
  ABL branch.

## What it answers

* **To progress it is not needed**: what the console writes is read by nobody
  else, and it chooses nothing —the auras are not chosen there—. **To play well,
  it is**: Talan's guides and absorption counters, Sern's
  souls, Saldra's and Lerle's techniques.
* The chosen design: the engine draws and navigates; the game declares the
  pages in a file of its own that `rm2k-snes.toml` names; the menu
  replaces common event 39, so item 81 still opens it; the common events that
  compute (48 and 49) run before their page.

## For taro

Look at the five sheets `lado-*.png` and decide:

* whether the design goes ahead —above all the navigation and the engine doing it—;
* **the art**: each actor's face, which costs nothing, or the portraits,
  48 KB at 15 colours;
* **the label**: "Console" fits in the pause menu, "Portable Console" does not;
* whether the option appears with item 81 in the inventory, as proposed.

With that, the implementation is another task: the converter, the ROM, and in ABL the
transcription of the thirteen pages and six tables, with their goldens.

## What was not done

* The mock-ups are drawn with the functions of `rm2k-snes-screens`,
  not captured from a cartridge: they show how it would look with the windows and
  the font there are, not what the ROM already does.
* The suite was not run: nothing that goes into a ROM changed.

# What taro decided

On 2026-10-04: "the design goes ahead, with portrait, \"Console\", and only with the item".
That is: the study's design (`docs/research/2026-10-04-el-menu-custom.md`)
as is, with the characters' portraits and not their faces, the label
"Console" in the pause menu, and the option visible only while item 81
is in the inventory.

## Done (Aguará)

Tools worktree from `60c1410c`, with `main` merged
(`afdaeab3`, Cardón's battle menu); ABL in the clone
`/extras/scratch/aguara/abl`, branch `menu-custom`, from `a2b1d8a` with
`main` merged (`daf2d3b`).

### What remained of the design

Everything from the study, as is: a full-screen engine screen,
one more option of the pause menu, the file of its own that `[menus]` names,
subjects with tabs and the first page whose condition holds, text
pages, table pages with sheets and special values, and counter pages, the
engine's navigation, `replaces_common` with `OP_MENU_OPEN` (0x45) and
`before` for common events 48 and 49. Portraits, "Console", and only with item
81.

What changed or was added while doing it:

* **The format** is in `custom_menu.rs` of `rm2k-snes-screens`, with an
  example at the top. The conditions are switch, variable `>=`, item and actor
  in the party. A page can have `lines` as well as `text`: rows
  that go as they are, with `center` and `color` —the lists and the centred titles
  of the pictures—. The counters carry an optional ceiling, like
  the table rows ("3 / 8" of Saldra).
* **`help` per tab**, below the characters: in ABL it carries what the
  original said with a message when there was no page ("There is no skill
  screen available for RADIN at the current time."). No text was invented.
* **On a page, left and right change sheet** if it is a table
  with several, and otherwise nothing; the study said they changed character.
  A page's header says "Talan - Tutorials", and "< 2 / 6 >" only
  on tables.
* **Up and down scroll a text page** that does not fit (the window's eleven
  lines): Radin's and Emily's skills page.
* **`before` runs the common event without its messages or pictures**, in a separate
  shared body. If the common event does something that waits, the converter
  refuses (`before_commands` in `rm2k-snes-events`).
* **A subject without a portrait** has no objects; the actor's face was not
  implemented, because taro chose portraits.
* The tabs' names are the original's, "Skills" and
  "Tutorials", and not "Guide".

### The texts

They were all readable. The ten guides were transcribed, `TalanSkill1`,
`EmilySkill1`, `ArdenSkill1` and the six aura tables (names run together,
as in the game, and what is needed to learn each one). Saldra's and Lerle's,
and Sern's souls, are the text of their messages, with their
`\V`. The only things that are ours are the counters' labels ("Enemy
souls", "FD Master skills", "Master Thespian skills") and those of the table's
columns ("Skill", "Absorbed"), which were not in the pictures; and the
sheets' colours, chosen from the System (red 1, blue 10, green 18,
yellow 4, black as grey 3, white 0).

### What it uses

* **ROM**: some 61 KB of data in `release` —the menu block 8.2 KB,
  the thirteen portraits 44.7 KB in LZ2, three window layouts of
  1.8 KB, 45 tiles of 8bpp—. Code, in `FAR2` ($C0): from 15,458 to 11,805
  bytes free before the merge with Cardón, some 3.6 KB; bank 0, some 110
  bytes (the rows table and the pause menu's dispatch). Measured with
  `just espacio release` in ABL; today it gives bank 0 2,522, $C0 10,415.
* **RAM**: `$7E3640`-`$7E367F`, between the message arrow and `FAR_HP`.
* **VRAM**: all of it while it is open. The text from 0 to `SCENE_MAP`
  (447 pairs, its own: the battle went down to 255), BG1 its tilemap at
  `SCENE_MAP` and its tiles from `$4000`, the portrait in objects from
  `$6000`. On closing, the map comes back with `big_back_far`, plus OBSEL and the
  object palettes.
* **CGRAM**: the four inks of the text screens and up to four
  of the menu (ABL uses three), the windows from 128, the portrait in
  object palette 7.
* **Opcodes**: `OP_MENU_OPEN` = 0x45; 0x44 stays reserved
  (`OP_RESERVED_44`, which ends the page like the other reserved ones).
* `text_layer.s`: only `tl_text` was split in two, so that there is
  `tl_text_at`; it changes no byte. `screen_bank.s`, nothing.

### Tests

In ABL: `test_menu_custom_golden.py`, 24 new goldens —the option with and
without the item, opening from the menu and from the item and going back to the menu and the
map, navigation around and through tabs, the blue, red and
white auras with the counters set by hand (99 as "Learned"), Talan's
guide, Emily scrolled, Sern's souls, Saldra and Lerle with what
their common events count, and going back to the same character—. `test_consola_portatil.py`
now looks at the automatic common event that opens the menu; the case
`consola-portatil-escrita` went with the test of Sern's message.
No existing golden changed. `empujon` lost its last box (the
text block shifted) and `test_items_vuelve` closes the console, which is
the item it uses.

In the tools: tests of `rm2k-snes-events` for the replaced common event and
`before`, and those of `rm2k-snes-mapdata` and
`rm2k-snes-screens` against the Python strip out the new parts.

**What there is not**: a `render` of the custom menu in `rm2k-snes-screens`, which
is how the other screens are tested with `_dibujo`; the goldens are the
only thing that looks at it, and a golden catches regressions, not birth
defects. The pause menu with "Console" does not have a `render` either.

### Verified

* **ABL's suite**, branch `menu-custom` with `main` of both repos
  merged and this worktree's tools (`cartridge`, `events`,
  `screens`, `mapdata`, `convert` locally): **1078 green**, twice
  in a row. A third round, in between, gave five reds of
  "el Teleport no terminó de fundir": it was a `just espacio` of mine that rebuilt
  the cartridges while it was running; repeated without touching anything, green.
* `abl.sfc`: `4e809540424fa129…`.
* **The red**: the new tests with the global tools, without the
  change: the 8 of `test_menu_custom_golden.py` and
  `test_el_item_81_abre_el_menu_por_su_comun`.
* `just -f tools/justfile test`: 27. `cargo test` of `screens`, `events`,
  `mapdata`, `convert`, `cartridge` and `bytecode`.
* What the suite does **not** cover: a menu without portraits or without `replaces_common`
  (ABL has none), a variable condition (the format has it and ABL does not
  use it), and a `before` that calls another common event.

### What needs looking at

Side by side with the original and the contact sheet in
`/shared/capturas/2026-10-04-consola/`. The captures of the original are
Lagartija's, from the same day and the same Wine.

## For taro

Play with the console: open it from the pause menu and from the item,
go through it, open the pages, go back, close the menu and walk. Look at the
portrait when changing character (it uploads in about eight frames) and the short
black when entering and leaving a page.

On merging, reinstall `cartridge` —it brings the runtime—, `events`, `screens`,
`mapdata` and `convert`; `bytecode` changed and goes inside `events` and
`cartridge`. And in ABL, the branch `menu-custom`.
