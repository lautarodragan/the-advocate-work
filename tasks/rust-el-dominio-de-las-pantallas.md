---
name: "Rust: the screens domain"
description: "The converter's menus, title, shop, message window and text fitting (menus, screens, texts, font, message_window, end_game, title) to a domain crate in Rust, with the ROMs byte-for-byte identical"
type: refactor
status: done
assignee: taro
---

From taro, on 2026-09-30, in the migration of the converter to Rust: the
screens domain, which already uses `rm2k-render` for the faces and the System. It is a
domain crate in `tools/rm2k-snes/`, shaped like
`tools/rm2k-snes/battle/README.md` ("One stage of a converter"), as
Mara did with the maps.

It branches off `main` at `52156e5b`. Baseline measured there, with `cartridge` installed in
the local `bin/` —the fingerprint is going to need it, and the `.dbg` changes depending on which
assembler builds; see the trap Mara noted—: `NO_CACHE=1 just
cartuchos`, 1032 files in `rom/build/` (without the cache, the `.o`s,
`sello.txt` or `conversor.log`; the PNGs decoded), their sha256 in
`<scratchpad>/tataupa/sha-base.txt`.

## Inventory: what the Python does today

Read on 2026-09-30:

| module | what it does | which domain it belongs to |
|---|---|---|
| `font.py` | easyrpg's two 6x12 fonts (ttyp0 and rmg2000), generated from their `bitmapfont_*.h`, and which one the System's `font_id` asks for | the font |
| `window.py` | the game's System (`skin`, which looks for the PNG and remembers what `rm2k-render system` drew), and `draw_line`/`page`: a line of text with its shadow over the System's colour blocks, like `Font::Render` | the font; `skin` is also used by `map_convert` for the timer |
| `texts.py` | `refit`: fits a `ShowMessage` box to the width of the console's window (TeX in miniature, with costs to taro's taste), and `refit_commands`, which applies it to a list of commands | the texts; used by `compiler.boxes` —the box table `rm2k-snes-events` receives— and `lcf.REFIT_TEXTS`, with which the Python reads the pages |
| `message_window.py` | the message window as the ROM carries it: the tiles of the empty window, its palette, its cells, the 240 tiles of the text area, the colour of each glyph row and that of the shadow (`convert_window`); the inverted font (`font_bytes`) and the four precomputed tables per phase (`font_prerender`) | the window; its constants (`WINDOW_*`, `FONT_*`) are emitted by `mapdata` |
| `title.py` | the title menu on BG2 at 4bpp (`menu`: tiles, palette, one tilemap per option) and the drawing of the whole title for the tests (`render`) | the title; the background image is converted by `palette.convert` + `fullscreen`, which are also used by the Game Over, the images, the animations and the battle backgrounds |
| `menus.py` | the bank of the slots and of the pause menu (`slots_screen`: pre-drawn texts, glyphs, faces with their palette —Adeleine if they go over fifteen colours, and borrowed if there are no palettes left—), the font bank of the text screens (`items_screen`, four colours), the System frames on BG1 for items, equipment, shop and actor selection (`borders`, `*_layers`, `compact_target`), the text rules of those screens (`item_text`, `split_description`, `name_text`, `level_text`, `max_text`, `name_in_lines`, `digits_of`) and the drawings for the tests (`render_menu`, `render_items`, `render_target`, `render_slots`) | the screens; the geometry and the text rules are also read by `mapdata` when emitting |
| `screens.py` | the equipment and the shop: the geometry (`EQ_*`, `TI_*`), their windows and bars, what each one writes (`equipment_screen`, `shop_screen`, over a `TextGrid`) and what it does (`equip`, `candidates`, `can_buy`), `compact_shop`; and **the battle's text screen** (`BA_*`, `victory_lines`, `command_text`, the victory lines) | the equipment and the shop belong to the screens; the battle part doesn't: see the boundary |
| `end_game.py` | `Scene_End`: the drawing at 320x240 or 256x224 (`draw`), the screen as the ROM uploads it —one index per pair of colours, two palettes— (`convert`), the fade ramp and its drawing for the tests (`render`) | the screens |

And what they use from outside: `rm2k-render` (`system`, `face`) through
`render/render_map.draw`, `port/adeleine.py` (`merge_least_visible`,
`luma_distance`), `port/experience.py` and `port/rules.py` (`level_of`,
`param_of`, `equipped_params`, `initial_level`, `next_exp`), `port/palette.py`
(`BLACK`, and `convert` in the title), `port/snes_format.py` (`pack_tile`,
`cgram_word`), `port/map_layers.py` (`CGRAM_RESERVED`), `port/constants.py`
(`COLUMNS`, `LINES`, the screen, `MENU_CGRAM`), `port/events.py`
(`escape_tail`, `CannotCompile`, the `ShowMessage` codes, `ITEM_MAX`),
`rpgmaker/lcf.py` (the database, the terms) and Pillow and numpy.

Who calls it: `snes_convert.py` —once per cartridge: the window, the
slots and the menu, the four frames, End Game, the title menu—,
`mapdata.py` —the emission: geometry, text rules, `compact_*`,
`end_game.ramp`—, `vram.py` —the four checks of where the
screens fall—, `compiler.py` —`texts.refit`—, and the ABL tests that draw
with the Python model: `render_menu`, `render_items`, `render_target`,
`render_slots`, `equipment_screen`, `shop_screen`, `end_game.render`, and the
text ones (`test_textos_del_juego`, `tools/tests/test_texts.py`).

## The boundary

**What the domain receives from the orchestrator** —decisions of the cartridge,
never data the dump already has—:

* which actors can be in the party (`possible_members`) and which items
  the ROM knows (`possible_items`): they belong to the cartridge;
* how many save slots there are, and whether the cartridge carries a title;
* the VRAM layouts, as data: where each BG1 bank of
  each layout starts (`vram.LAYOUTS`), and `SLOT_VRAM` and `SLOT_MAP`. Mara left the
  layouts in Python because the emission and the maps read them too; the
  checks of where the screens fall (`_check_slots`,
  `_check_items_border`, `_check_target`, `_check_shop`) belong to this
  domain, and move with it;
* the width of the message window (`constants.COLUMNS`, `LINES`), which
  `rm2k-snes-events` also receives today.

**What it reads from the game itself**, with Ditto's library: the
terms, the actors, the items and the database's System —the font, the
stretching, the title—, and the System's PNG, the faces and the title from the
game's folder.

**What it returns**, which today `snes_convert` and `mapdata` read:

* the message window: tiles, palette, cells, text background, row colours
  and shadow, the font and its four precomputed tables;
* the title menu: tiles, palette and one tilemap per option;
* the bank of the slots and the menu: tiles, palettes, headers, rows,
  faces, and the menu's blocks with their glyphs;
* the font bank of the text screens, with its four palettes and
  its glyphs;
* the frames for items and equipment, for the shop and for actor selection,
  **already compacted** as the ROM stores them (`compact_target`,
  `compact_shop` move with them);
* End Game: tiles, tilemap, row, the two palettes and the ramp;
* the texts of the screens the ROM composes —each actor's strips,
  the medicine names on two lines, the shop messages in
  lines—, and **the geometry** it drew with, so that the emission doesn't have
  a second copy of each number;
* the table of fitted boxes, which goes into the `rm2k-snes-events` request and into
  `lcf.REFIT_TEXTS`.

**What belongs to another domain and stays outside:**

* **the emission** —`mapdata`—: the domain returns data and the emission
  writes it. The `item_texts` that `mapdata` builds mixes the texts of the
  screens with the battle's, and belongs to the emission;
* **the battle's text screen** (`screens.BA_*`, `victory_lines`,
  `command_text`, `revived_text`, the victory lines): it draws
  nothing when converting; it is geometry and texts that `mapdata` emits and that the ROM
  composes with the screens' font. It belongs to the battle, and stays in
  Python with it;
* **the VRAM layout** (`vram.py`): of the maps and the emission; it arrives here
  as data;
* **the title image and the Game Over** (`palette.convert`,
  `fullscreen.compressed`): they are also used by the images, the animations
  and the battle backgrounds, and the scaling is Pillow's `LANCZOS`. The
  domain does the title menu; the background image stays in Python;
* **what compiles and how what compiles is split into boxes**: the compiler's.
  Here it is decided how a box is fitted to the window's width; the rule
  of the escape tail (`\|`, `\^`) belongs to the compiler, and the fitting
  needs to know it: it is the same rule, with the same tests
  (`rm2k-snes/events/tests/escapes.json`), as today between `events.py` and the
  crate;
* **RM2k's rules** —the level, the parameters, the experience
  curve—: `rm2k-rules`'; **which colours are lost** in a face:
  Adeleine's; **what each piece of the System is and how a window is built**:
  `rm2k-render`'s. All three as libraries.

## One crate or several

Two, so that Cargo enforces what today only the order of the
imports enforces:

* `rm2k-snes/text/` (`rm2k-snes-text`, library): the font, a line of
  text drawn over the System, and the fitting of boxes to the window's
  width. It doesn't know menus exist: the screens use it and the compiler
  could use it.
* `rm2k-snes/screens/` (`rm2k-snes-screens`, the stage): it reads the game, and
  does the message window, the title, the slots and the menu, the
  text screens with their frames, End Game, the drawings for the tests
  and the box table. It depends on the one above, on `rm2k-render`,
  `rm2k-rules`, `adeleine` and `ditto`.

## The plan

In parts, each in its own commit, with the ROMs identical:

1. **The font and the texts**: `rm2k-snes-text`, and the box table through the
   stage.
2. **The message window and the title.**
3. **The slots, the menu, the screens' font, the frames and End
   Game**: `snes_convert` calls the stage once.
4. **The geometry and the texts the emission reads**, published by the
   stage.
5. **The tests' drawings**, asked from the stage.
6. Delete the Python nobody uses anymore, and the prose.

## Done

**The whole screens domain is in Rust**, in two crates, and the
Python that did it was deleted. The three ROMs, the `.sym`s, the `.inc`s and all of
`rom/build/` come out byte-for-byte identical to `main`'s with the Python; the
only difference comes from the prose of the last commit: a comment in the
`.inc` and the size of the runtime sources the `.dbg`s name, see
below.

| commit | what |
|---|---|
| `40963731` | the task: inventory and boundary |
| `1083d4c7` | merge of `main` (`248c0134`, Yacutoro's patches) |
| `2b017b2e` | `rm2k-snes-text` and the `rm2k-snes-screens` stage; `snes_convert` calls it once, and `compiler.boxes` and `lcf.REFIT_TEXTS` ask it for the boxes |
| `7ef985d1` | the emission reads the geometry and the texts from the stage; the battle's text screen, to `battle_screen.py` |
| `ea8eb3c3` | the ABL tests ask the stage for the drawings (`pruebas/arnes/pantallas.py`) |
| `44cae8e1` | the tests of the two crates against the Python's hashes, with their small game |
| `04e31c5e` | the deletion, deletion only |
| `d431b9e3` | `luma_distance` from adeleine.py, which was left unused |
| `eab433fa` | the prose that named what was deleted |

The plan was done in fewer commits than the six parts: the whole conversion
in one, because the pieces share the System, the bank and the font, and
splitting it left intermediate commits with both halves at once.

**The crates** (`wc -l` of `src/`, without the tests):

* `rm2k-snes/text/` (`rm2k-snes-text`, library, ~990 lines):
  `glyphs.rs` (the two fonts, generated from easyrpg), `font.rs`,
  `line.rs` (a line over the System's blocks, `Font::Render`) and
  `refit.rs` (the box fitting, with its copy of the escape
  tail). It depends on `rm2k-render`.
* `rm2k-snes/screens/` (`rm2k-snes-screens`, the stage, ~4550 lines):
  `game.rs` (the dump and the System), `cells.rs` (cutting a drawn screen
  into cells, banks and palettes), `layout.rs` (the geometry, and
  `publish`), `texts.rs`, `message_window.rs`, `title.rs`, `slots.rs` (the
  bank of the slots and the menu, with the faces), `items.rs` (the font of
  the text screens), `borders.rs` (the frames and their compacted forms),
  `end_game.rs`, `checks.rs` (where they fall in VRAM), `boxes.rs`,
  `convert.rs`, `render.rs` (the tests' drawings, with the rules
  of the equipment and the shop), `request.rs`, `main.rs`. It depends on
  `rm2k-snes-text`, `rm2k-render`, `rm2k-rules`, `adeleine`, `voodoo` and
  `ditto`. Its README states the subcommands, the request and what it writes.

Subcommands: `convert` —the converter's, one per cartridge—, `boxes` —the
box table, for `compiler.boxes` and `lcf.REFIT_TEXTS`—, `render` —the
screens for the ABL tests—, `refit` —refitting loose boxes, for
`test_textos_del_juego`— and `layout`.

On the Python side remain `port/screen_stage.py` (the request and the shape of
the answer `mapdata` emits), `port/battle_screen.py` (the battle's text
screen, moved as is from screens.py) and `window.py` reduced to the
System and the timer, which belong to the maps.

**What changed from the planned boundary:**

* **The item list isn't a single one.** The emission writes the texts of
  `items_rom` plus what the enemies drop (`drop_items`), and the menu's
  bank carries the letters of the medicines of `items_rom` alone. The
  request carries both (`items` and `bank_items`), and the long one is built before
  calling the stage. See "What's missing".
* **The geometry is published by the stage** (`layout.rs`, `publish`), and
  `mapdata` reads it by the same names (`screen_stage.layout()`): no
  second copy of any screen number was left. The ABL tests
  ask for it the same way (`pantallas.disposicion()`).
* **`compact_target`, `compact_shop` and `font_prerender` moved to the
  stage**, which returns what the ROM stores.
* **The escape tail ended up in Rust twice**: in the compiler and in
  `rm2k-snes-text`, with the same cases (`escapes.json`); the Python one
  went with `texts.py`.
* **`equip`** —`Game_Actor::ChangeEquipment`— ended up in two places: in
  `render.rs`, to draw the list, and in `pruebas/arnes/pantallas.py`,
  so that the test knows what to expect from the RAM.
* **The title image** stayed in Python (`palette.convert` and
  `fullscreen`), as planned; the menu on top belongs to the stage.
* **The timer colours** still come out of `window.py`: they belong to the
  maps (Mara already noted it).

## How it was verified

With throwaway scripts in `<scratchpad>/tataupa/`:

* **Piece by piece, Python against Rust** (`compara_convert.py`): a
  converter that runs the usual Python and compares each piece against
  `rm2k-snes-screens` with the same inputs —the window, the font and its
  four tables, the title menu, the bank of the slots and the menu with
  the faces (five borrowed in `release`), the screens' font, the
  three frames and their compacted forms, End Game, the texts, each number of the
  geometry against its Python constant and the game's 1245 boxes—:
  all identical in `release`, `test-special` and `test-encounter-every-step`.
* **The drawings** (`compara_render.py`): 297 screens of the Python model
  against `render`, at eight bits —the menu with four parties, each cursor and
  the two permissions, with HP, levels and experience; actor selection
  with and without medicine; the items with the list scrolled; the slots in the
  two modes with saves; the equipment in each slot and row; the shop in
  its seven modes, three types and three message sets, with the errors
  in the same cases; End Game—: all identical.
* **The cartridges**: `NO_CACHE=1 just cartuchos` and the sha256 of all of
  `rom/build/` —minus the cache, the `.o`s, `sello.txt` and `conversor.log`;
  the `.dbg` without `mtime`; the PNGs decoded—: 1032 files, identical to
  `main`'s (`248c0134`, with the Python) after each commit up to
  the deletion; what the converter prints, identical line by line. After
  the prose, identical except the three `mapdata.inc` —with the old comment
  put back, the same sha256— and the three `.dbg`s —with the old sizes of
  the sources put back, the same sha256—.
* **The sha256 of the ROMs**, identical in `main` and here:
  * `release/abl.sfc` `cdcc323197ee6c66d82b1304ce20c3c37f4124d13a6867e851fd13226046b7df`
  * `tests/special/prueba.sfc` `15e4f331fe8ff8123803ae3819a2212a5b84d71cd0a053b7261a9188bbab84b9`
  * `tests/encounter-every-step/prueba.sfc` `dc83ed698b348032514dbb76eaf5f535b6296944075fcba786087533ed5b8a4b`
* **The suites**: `just pruebas`, 878 —the same as `main`—;
  `just -f tools/justfile test`, 49 —they were 85: the 36 of `test_texts.py` and
  `test_escapes.py` moved to `rm2k-snes-text`—; `cargo test` of `text`,
  `screens`, `events` and `cartridge`, green.
* **The crates' tests don't depend on ABL**: `rm2k-snes-screens`
  compares against the sha256 of what the Python gave over a small game
  that lives in `tests/game/` —the whole `convert` answer, nineteen
  screens and the box table—, and `rm2k-snes-text` over three hundred
  boxes a congruence builds and a line in the two fonts; plus the
  fitting rules one by one, which were `test_texts.py`. They were made by
  `referencia.py`, before deleting.
* `cargo test --workspace` (`just -f tools/justfile rust-test`) is red on
  three tests of **Adeleine**, which wasn't touched: they compare the JSON it
  writes as text, and with the whole workspace together `serde_json` comes out with
  `preserve_order` —`rm2k-snes-audio` turns it on— and the keys change
  order. It is like that in `main`: both things are from 2026-09-29. The tests
  of `rm2k-snes-screens` compare the answer sorting the keys, and
  pass with and without.

## On merging

* Install globally `screens` —the new binary— and `cartridge` —the
  cartridges' fingerprint names it—: `just -f tools/justfile install
  screens cartridge`. `text` is a library. Without `rm2k-snes-screens` in the
  PATH the converter stops and says how to install it, and so do the screens'
  tests.
* It doesn't move goldens or the ROM.

## What's missing

* **The letters of the medicines only the enemies drop don't go into the
  menu's bank.** It is what the Python did —`medicine_letters` came from
  `items_rom`, before adding `drop_items`— and it was kept so that the ROM
  came out identical, but actor selection writes the name of any
  medicine in the long list with those glyphs: one that can only be obtained
  by fighting and has a letter nobody else uses would show with a gap. It
  wasn't found out whether it is on purpose: `git log -S` only reaches back to the
  translation. Fixing it means passing the same list in both fields, and it
  moves the ROM.
* **`equip` is there twice**, in the stage and in the tests' harness.
* **The escape tail is there twice in Rust**: the compiler could use
  `rm2k-snes-text`'s, which is the library below.
* **`lcf.REFIT_TEXTS` looks in the table of the game being converted**
  (`resources.GAME_DIR`): Python only reads from the boxes how many commands
  they are, but if one day it reads another game without converting it, it reads it without refitting.
* **The title image and the Game Over one** stay in Python
  (`palette.convert`, Pillow's `LANCZOS`): they belong to the full
  screens, together with the images and the battle backgrounds.
* Adeleine's red in `rust-test`, from above.
