---
name: "The text screens draw Latin-1"
description: "The message boxes draw the accents, ¿, ¡, umlauts and ß each game uses; the menu, the shops, the battle, the slots, \\N[0] and a troop page's box still show the plain stand-ins. Measure the room each screen has for those glyphs and estimate the work before doing it"
type: feature
status: done
author: taro
assignee: taro
agents: [Hornero, Aguará, Calandria]
links:
  relates: [the-font-carries-a-box-s-icons-twice]
---

> How complex or feasible would it be to add accents and opening question
> and exclamation marks for Zounds, and umlauts or whatever for other
> games?

taro, 2026-11-22. Hornero's answer: the message boxes already draw them
(since 2026-10-16); what is left is the text screens. See the book's
divergence "Letters the font does not have". taro, to measuring first:

> Dale

## Log

### 2026-11-22, Hornero: taken for Aguará, to measure and estimate

### 2026-11-22, Aguará: measured, and the estimate

Read at the-advocate `1b8825d8` and the ports `544f9bc`. Measured on the
release cartridges the ports checkout built this morning (07:19 to 07:22,
global tools `ec672f4c`): their `mapdata.inc`, `.sfc.sym`,
`converter.log` and `degradations.json`, and `rm2k-snes-space <rom>` on
each, which builds nothing. The letters per game come from a throwaway
script over each game's `data/`, and which letters each game's boxes carry
from `rm2k-snes-events compile` over its `events-request.json`, written to
scratch. Nothing was built and no Rust was compiled: none of it needed a
worktree of the code repos.

#### The short answer: the glyphs are not where the room is

Since 2026-11-20 —`the-font-is-precomposed-three-times`— **the cartridge
carries one font**, `font_pre0` to `font_pre7`, and every writer composes
from it: the message window, the text layer of the items, equipment, shop
and battle screens (`tl_glyph`), the menu's bank and the slot screen
(`tl_paint_slot`, `tl_strip`), and the battle's troop-page box
(`ba_page_message`, through `ba_t_glyph`). And since 2026-10-03 the text
screens **compose** their lines into pairs of tiles from a pool, as the
message window does: no screen holds a tile per letter. So:

* **VRAM: nothing**, on every screen. A pool is spent per column a line
  inks, and a letter inks what its stand-in inks: of the letters below,
  only `í` is one pixel wider than `i`, and `ß` is five narrower than
  `ss` (measured from `msg_font_advance` in Zounds' and Vampires Dawn's
  builds). The battle is not the suspect it was when a letter was a tile.
* **WRAM: nothing**: a run's record keeps one byte per letter, whatever
  the letter.
* **The text block: nothing**, or less: a letter is a byte either way, and
  `ß` is one where `ss` is two.
* **ROM: only what the boxes do not carry already.** The boxes' letters are
  in the one font, at `FONT_LETTERS_AT + k`, and the text screens can name
  the same glyphs. A letter only the screens use costs 832 bytes —104 per
  phase, eight phases—, and the screens' `font_advance` and `font_reach`
  two bytes per glyph they reach.

What the screens show today with the stand-ins, and what they already
draw: **what the screens stage draws when building is already Latin-1**
—End Game's question and options, the title's options, the menu's
commands and the windows' terms, the slot screen's header—, because it
draws the database's text as it is with the game's font. Checked with
`rm2k-snes-screens render` of Zounds' End Game: it draws `¿Deseas salir?`
and `Sí`. What goes plain is **what the cartridge composes at run time**
from the text block: names, items, skills, enemies, conditions, the shop's
and the battle's terms and lines, and a troop page's box.

#### 1. The letters each game would need on the text screens

Over the database's texts —actors' names and titles, classes, items, skills
with their messages, enemies, conditions with their messages, the terms
(without the 2003 ones the battle never shows), a 2003 game's battle
commands, the project's `[battle.terms]`— plus each `ChangeHeroName`
literal and each troop page's box. A text with a cp1252 hole (`C1` in the
screens stage's `game.rs`) is a Shift-JIS leftover and is left out, as the
stages do. "The boxes carry" is the events stage's `messages.letters`.

| Game | The text screens need | Of those, the boxes already carry | Only the screens' |
|---|---|---|---|
| Zounds | 15: `¡¿ÁÉÚáäéëíñóúûü` | 14 (its boxes carry 18 letters and 11 icons) | `Á` |
| Vampires Dawn | 5: `Äßäöü` | 4 (6 letters and 1 icon) | `Ä` |
| Desert Nightmare | 0 | (`ßäöü` in its boxes) | — |
| El Dorado | 0 | (`ä`) | — |
| Sunset over Imdahl | 0 | (`äô`; `…` stays `...`) | — |
| ABL, The Book of Three, Dooms 2, The Frozen World | 0 | — | — |

Per source, in the two that need any:

| Source | Zounds | Vampires Dawn |
|---|---|---|
| actor names | `ë` (Unamë) | — |
| actor titles | `í` | `ö` (Höllenbulle) |
| classes (2003) | `íó` | — |
| battle commands (2003) | `é` (Técnica) | — |
| item names | `Ááéíñóü` | `äü` (Rüstung, Säbel) |
| item descriptions | `¡ÉÚáíñóúû` | — |
| skill names | `Ááéñ` | `Äßä` (Ätherstaub, Große Heilung) |
| skill descriptions | `éíñó` | `ö` |
| terms | `¡¿áäéíó`, and `Œ–` in a leftover | `ü` (Goldmünzen) |
| the project's `[battle.terms]` | `áíñ` | — |
| a troop page's box | `¡Áéáëó`, 795 commands, all of one common event the pages call | none of its boxes with letters reaches the cartridge (0 `letter-plain` losses) |
| `ChangeHeroName` | none | none |

Vampires Dawn is the English release, and those are German leftovers in its
database. Desert Nightmare's, El Dorado's and Sunset's letters are only in
their boxes, which already draw them: for them this task has nothing to do.

#### 2. How each screen holds its glyphs, and its room

What each text screen asks of its pool, from each build's
`converter.log` —the busiest list, at the font's widths—; the glyphs
change none of these but for `í`'s pixel:

| Game | Shop (of 191) | Items/equipment | Skills screen (of 447) | Battle: skill list / item list (of 255) |
|---|---|---|---|---|
| Zounds | 150 | 175 of 358 | 263 | 60 / 161 |
| Vampires Dawn | 141 | 161 of 365 | 279 | 154 / 130 |
| Desert Nightmare | 4 | 0 of 366 | 22 | 0 / 23 |
| El Dorado | 84 | 43 of 371 | 225 | 28 / 23 |
| Sunset over Imdahl | 7 | 0 of 377 | 27 | 0 / 23 |
| ABL | 165 | 202 of 376 | 290 | 170 / 167 |

The limits that **do** count glyphs:

* **A text screen's byte is its glyph plus 32** (`tl_text_at` and the
  by-reference fetch subtract `' '`), so the screens reach glyphs 0 to
  223. `ICON_GLYPH_FIRST`, the icon halves and the letters have to stay
  there. Zounds' letters start at 147 (`FONT_LETTERS_AT`: the console's
  96, the figure's blank, 25 icons), so it has 77 places: its 18 box
  letters, its 22 box icon halves and `Á` take 41. Vampires Dawn's start
  at 99: 125 places. The rest, 127 or 128. A game with all 52 icons on
  its screens would have 22.
* **A troop page's box** writes the glyph itself, below `$FD`
  (`MESSAGE_NAME`, `MESSAGE_CONTROL`, `MESSAGE_VARIABLE`): 253, so the
  screens' 224 is the tighter.
* **The font**: 256 glyphs (`font_glyphs` in the screens stage). Zounds
  has 187, Vampires Dawn 107, the rest 96 to 100.
* **The boxes' 64** (`MESSAGE_PAIR_FIRST`): untouched, unless a name's
  letter has to join them (see 3). Zounds has 40 of 64.

The ROM, `rm2k-snes-space` on each release ROM, in the three that matter:

| Game | Data banks | Gaps | `$C1` (`FAR3`) | `$FF` (`FAR4`) |
|---|---|---|---|---|
| Zounds | 56 of 126, 51 free | 18,518 B | 930 B | 27,738 B |
| Vampires Dawn | 126 of 126 | 509 B, and 405 pieces already in the `.msu` | 3,475 B | 27,544 B |
| Desert Nightmare | 80 of 126 | 43,466 B | 409 B | 27,892 B |

Vampires Dawn is the only full one, and its `msu = "required"`: a glyph
more is 832 bytes more of some piece in the `.msu`, as the packing already
does with 405 of them (`MSU_SPILLED` in its `.sym`).

The debug screen is the precedent: its own font, `hires-wide`, draws
Latin-1 since 2026-11-01 with the same shape —the console's 96, the
figure's blank, then the letters: `Glyphs::of` and `LATIN_CODE` in the
screens stage's `debug_screen.rs`—, its letters cached from the `.msu`.

#### 3. The paths, and where a letter goes plain today

All in the converter but one place of the runtime:

* `item_text` in the screens stage (`texts.rs`): names, items, the shop's
  terms, the actor choice's line, the equipment's slots. It keeps the ExFont
  halves and stands in the rest.
* `item_text` in `rm2k-snes-battle`'s `screen.rs`: the battle model's
  texts —victory lines, the prize—. The same rule, its own copy.
* `plain` and `db_text` in the mapdata stage's `emit.rs`: the database's
  texts the text block takes —names, the battle terms, skills, enemies,
  conditions—; and `Texts::add`, which turns a character into the byte
  (`c as u8`, an icon half as `ICON_CODE_FIRST + 2k + side`, anything
  else `?`). `target_name_bytes` and `slot_actor_text` do the same for the
  actor choice and the slot screen.
* The troop pages' boxes: `TroopPages` compiles them with
  `Messages::new(1, troop_window)` and never carries letters, so every one
  is plain —Zounds' 795 `letter-plain` losses—; and they drop icons
  (already in Zounds' "Known issues").
* **`\N[0]` in a map's box** (`msg_name_letter`, `actor_names.s`) reads the
  name from the text block and subtracts 32, and the message composer
  takes a letter from 96 on as **box** letter `k - 96`, at
  `FONT_LETTERS_AT + k - 96`. A name byte for a screens' letter lands on
  the wrong glyph: in Zounds, `ë` at glyph 148 would draw glyph 199. It
  needs, under `.if FONT_LETTERS_AT <> FONT_CONSOLE_GLYPHS`, a `cmp` and a
  `sbc` that take a screens' glyph back to the box's index, and the
  names' letters among the boxes' (so `msg_font_advance` has them):
  Unamë's `ë` already is. The battle's `\N` (`ba_page_message`) reads the
  same bytes as screens' glyphs, and is already right.

**Renames**: there is no name entry. `EnterHeroName` is not compiled
(Dooms 2 has one, in a game without letters), and every name an actor
can carry is the database's or a `ChangeHeroName` literal, numbered when
building —see the top of `actor_names.s`—. So the letters a name can have
are known when building, and none of the nine games renames to a name
with letters.

#### 4. The estimate

**What changes**:

1. *One list of letters for the cartridge*: the boxes' (the events stage,
   as now) and, after them, the ones only the text screens use —counted
   over the same texts they write, and the troop pages'—. `font_glyphs`
   draws them all; the screens name letter k as glyph
   `FONT_LETTERS_AT + k`, byte + 32. One predicate, "the cartridge carries
   it", replaces the stand-in rule in the two `item_text`, `plain`,
   `db_text`, `Texts::add`, `target_name_bytes` and `slot_actor_text`;
   and past glyph 223 the converter stands the letter in, and says so.
2. *The screens' `font_advance` and `font_reach`* grow to the last letter
   they reach.
3. *The troop pages*: their `Messages` carry the same letters, as glyph
   indices.
4. *The runtime*: the `\N[0]` translation in `msg_name_letter`, some ten
   bytes in `FAR3`, assembled only in a cartridge whose screens carry
   icons. Nothing else: the text layer, the menu's bank, the slot screen
   and the battle already compose any glyph below 224.

Crates: `rm2k-snes-text` (the predicate), `rm2k-snes-screens`,
`rm2k-snes-battle`, `rm2k-snes-mapdata`, `rm2k-snes-events`,
`rm2k-snes-convert`; and `runtime/actor_names.s`.

**Cost per game**:

| Game | Glyphs added | ROM | VRAM / WRAM |
|---|---|---|---|
| Zounds | 1 (`Á`) | 832 B of font, ~82 B of the two tables (to glyph 187), ~10 B of code in `$C1` | 0 |
| Vampires Dawn | 1 (`Ä`) | 832 B of font, which goes to the `.msu`, ~18 B of tables, ~10 B of code | 0 |
| the other seven | 0 | 0: their cartridges should come out byte for byte the same, and that is how it is verified | 0 |

**The risky parts**:

* **`\N[0]`**: the one path where the same byte means two things. Without
  the translation, every box that writes Unamë's name draws a wrong
  glyph, and nothing fails.
* **The cuts move**: `í` is a pixel wider, so a name or description cut to
  its cells (`fit_cells`, `ITEM_NAME_WIDTH`) may lose a letter, and the
  converter's pool counts move by a pair or so. It already warns against
  each pool.
* **Tests that read the screens' bytes as ASCII**: the ports'
  `test_zounds_battle_text.py` decodes `BA_MBUF` as Latin-1 and asserts
  every character is printable ASCII; with the letters it reads bytes from
  179 up and goes red. It has to decode through the cartridge's letters.
* **The goldens that show these texts move**, in Zounds:
  `zounds-exfont-items` (Poción, Ladrón), `zounds-item-target` (Poción,
  Unamë), `zounds-battle-commands-uname` and `-kazar` (Unamë, Técnica).
  That is the point, and they are looked at.

**In stages**: the room does not ask for any —no screen runs out—; the
paths do.

1. **The database's texts on every text screen**, with the `\N[0]`
   translation in the same change, because a name is one text for the
   menu and for the boxes. That is all Vampires Dawn has, and all of
   Zounds' but the battle's boxes.
2. **A troop page's box**: the events stage, Zounds' 795 commands. Its
   icons could go in the same change (the screens' tables already carry
   `$K`, `$d` and `$g`).

Splitting the menu and the shops from the battle would gain nothing: they
are the same text block, the same byte rule and the same font.

#### 5. Tests

* **What would cover it**: the test game has no letter outside ASCII in
  its database, only in common event 4 (`test_plain_letters.py`, a box).
  It needs an item and an actor with letters —one of them only the
  screens use, so that it is not among the boxes'— and a case that opens
  the items screen, a shop and a battle with them, and a box with `\N[0]`
  of that actor: goldens against RM2k's look, and the `\N[0]` one is the
  test that goes red without the translation. In the ports,
  `test_zounds.py`'s talk with the guards writes `\N[0]` (Unamë), and the
  Zounds goldens above move.
* **What is not covered**: the byte cap past glyph 223 (no game is near
  it: a unit test in mapdata), Vampires Dawn's screens (no test of the
  ports opens its menu, shop or battle lists), and the slot screen's saved
  name with a letter (no game has one).

#### Recommendation

Do it, in the two stages above: it is converter work with one runtime
change, it costs two games under 1 KB each and the other seven nothing, and
no screen's room limits it. Stage 1 first, with the test game's case.

#### Found and not fixed

* The book's El Dorado and Sunset over Imdahl pages still say "the
  console's font is ASCII", stale since 2026-10-16; and the divergence
  says the menu draws ASCII, which is half true. Draft:
  [`the-book-says-the-console-s-font-is-ascii`](the-book-says-the-console-s-font-is-ascii.md).
* Zounds' font carries the 11 icons its boxes use **twice**, 22 glyphs.
  Draft:
  [`the-font-carries-a-box-s-icons-twice`](the-font-carries-a-box-s-icons-twice.md).

To `testing`, for taro to decide: nothing changed in the code, and nothing
has to be installed.

### 2026-11-22, Hornero: stage 1, taken for Calandria

taro, asked whether to do stage 1:

> Go ahead

Stage 1 only: the database's texts on every text screen, with `\N[0]`'s
translation, and the test game's case. Aguará is on another task.

### 2026-11-22, Calandria: stage 1, the database's texts on the text screens

Started at the-advocate `1b8825d8` and the ports `544f9bc`, in worktrees of
my own, branch `calandria-latin1` in each repo and in the book.

#### The shape

* **One rule, three places.** `rm2k_snes_text::plain::screen_text(text,
  letters)` keeps the icons' halves and `letters`, and stands the rest in;
  the screens stage's `item_text`, the battle's and the emission's
  `Texts::add` all go through it, so a letter is cut and measured where it
  is drawn. `SCREEN_GLYPHS`, 224, in `rm2k_snes_text::font`: a screen's
  byte is its glyph plus 32.
* **Which letters**: the converter's new `letters.rs` collects the ones the
  font draws over the texts the cartridge composes at run time —actors'
  names, items, skills with their messages, enemies, conditions with their
  messages, the terms but a 2003 game's unshown ones, a 2003 game's battle
  commands, the project's `[battle.terms]`, the `ChangeHeroName` names—,
  leaving out a text with a cp1252 hole, as Aguará's count did; and hands
  them to the screens stage as `screen_letters`.
* **Where they go**: `texts::ScreenLetters` in the screens stage. The font's
  letters are the boxes' and then the ones only the screens write; the
  screens reach every one whose glyph is below 224, **and none when no
  screen text has a letter**, which is what keeps the seven games without
  any byte for byte. When the screens carry letters and no icon, the blank
  at 96 goes in anyway: the text layer takes glyph 96 for `TL_FIGURE`.
  The screens' `font_advance` and `font_reach` grow to the last letter;
  the message window's too, by the letters only the screens write, so a
  name's letter in a box has its advance.
* **`\N[0]`**: `msg_name_letter` takes a glyph from `FONT_LETTERS_AT` on
  back to the window's letter, `.if FONT_LETTERS_AT <> FONT_CONSOLE_GLYPHS`.
* `mapdata.inc` names each letter the screens carry, `FONT_LETTER_<code>`,
  an equate and no byte: the tests decode a screen's bytes with them.

**Changed on the way**: the `.if` is not `FONT_LETTERS_AT <>
FONT_CONSOLE_GLYPHS`, as planned, but `.defined(FONT_SCREEN_LETTERS)`,
an equate `mapdata.inc` writes only when the screens carry letters. The
planned one is also true of a cartridge whose screens carry icons and no
letter: The Book of Three's ROM moved by those six bytes, with nothing to
translate. And `Texts::add` does not stand a letter in: what comes raw to
it —the shop's three terms— keeps its `?` for a letter the screens do not
carry, as before, and the mapdata stage's Python test holds.

#### Measured: every game's cartridges, byte for byte

Each game's `just cartridges` in the ports at `544f9bc`, once with the six
crates —`project cartridge battle screens mapdata convert`— installed from
`1b8825d8` and once from this branch, the rest global; every `.sfc` and
`.msu` of each `build/` compared:

| Game | Result |
|---|---|
| ABL (22 cartridges), The Book of Three, Desert Nightmare, Dooms 2, El Dorado, The Frozen World, Sunset over Imdahl | the same, ROMs and `.msu`s |
| Zounds | both ROMs move, the `.msu`s do not: `Á` at glyph 187, its last; 916 B fewer of gaps, 6 B fewer of bank $C1 (`just space`) |
| Vampires Dawn | ROM and `.msu` move: one piece more, 5,001 B, goes to the `.msu` (406 of them), and $C1 6 B fewer |

The pools' counts in Zounds' `converter.log` do not move.

#### The test game

Actor 4, Zoë Peña —`ñ`, a box's letter too, and `ë`, only the screens'—,
item 2, the Poción Ácida, and the first enemy and troop, the Avispón
(EasyRPG's `Monster/Hornet.png`, in `AUTHORS.md`; `just game` copies
`Monster/` now). No new map. Three cases, `screen-letters`,
`screen-letters-shop`, `screen-letters-battle`, on the meadow, and
`test_screen_letters.py`: the box with `\N[0]`, the menu, the items
screen, the shop's buy list and the battle's item list, five new goldens.
**Seen red** with `msg_name_letter`'s code turned off: the box read "Zoó
PeÁa is here.", each letter the glyph after its own. For Tijereta's hub:
what was added is those four database rows, three cases, the picture, the
test, its goldens, a line in `justfile` and the README's.

#### Run, with this branch's `.local-tools`

* the-advocate `just test`: green. `just rust-test --no-fail-fast`: green,
  after updating the screens stage's Python test for the new key.
  `cargo clippy --workspace --all-targets -D warnings` and `cargo fmt
  --check`: clean.
* `SOUNDFONT=…/FluidR3_GM.sf2 just test-game`: 176 passed, 6 skipped.
* ABL's `just tests`: 1,685 passed, 1 red,
  `test_patches.py::…what_the_converter_decides`, map 145's patch.
* The ports' `just boot`: 199 passed, 2 red: the known Frozen World one,
  and `test_zounds.py::test_the_download_room_shows_the_panoramas_its_event_sets`,
  31 pixels of the map.
* **Both reds that are not the known one are red with `1b8825d8`'s tools
  too** —checked for the download room—: they are Hurón's `try_pack`,
  which the ports' goldens and patches already have and the global
  `wally`, `rm2k-snes-images` and the rest installed at 07:09-07:13 from
  `ec672f4c` do not. Not this branch's; reinstalling the global ones
  that compile `adeleine` should turn them green.
* Zounds' goldens that moved, in their own commit in the ports:
  `zounds-exfont-items`, `zounds-item-target`, `zounds-item-target-used`,
  `zounds-battle-commands-uname`, `zounds-battle-commands-kazar`. Before,
  after and difference in `/shared/captures/2026-11-22-text-screens-latin-1/`
  with the test game's new ones, for taro to approve.
  `test_zounds_battle_text.py` decodes the battle's bytes through
  `FONT_LETTER_*`, and is green.

#### Book

The divergence, Zounds' known issue —now only a troop page's boxes—,
Vampires Dawn's, gone, and the draft
[`the-book-says-the-console-s-font-is-ascii`](the-book-says-the-console-s-font-is-ascii.md),
done.

#### What no test covers

Vampires Dawn's screens with `Ä` and its umlauts (no test opens its menu,
shop or battle lists), the slot screen's saved name with a letter (no game
has one; the emission's rows go through the same byte rule), a letter
past glyph 223 on a cartridge (only the emission's unit test), and
renames with letters (no game has one).

#### Branches, and what to install when merging

the-advocate `calandria-latin1`, ports `calandria-latin1` (main merged),
book `calandria-latin1`. Install `battle screens mapdata convert`: `text`
is a library inside them, and `project` and `cartridge` were installed
here only to point the runtime at this worktree —in the main checkout
the global ones already read its `runtime/`—. `events` did not change.

### 2026-11-22, Hornero: the goldens approved, merged

taro looked at Calandria's goldens —Zounds' five that move and the test
game's five new ones— and at the two that Tijereta's reconciliation with
the hub moved again:

> Approved!

> Approved :D

Merged: the-advocate `7e8da728`, the ports `e886c7e`. Verified on that
tree, with its tools: `just test` 29 passed, the test game 208 passed and
6 skipped, ABL 1686 passed and 2 skipped, the ports' `just boot` 201
passed.

### 2026-11-23, Hornero: done

taro closed it, with eight others:

> podemos cerrar estas, no?

(taro: "we can close these, right?") Stage 2, a troop page's box, stays in the draft [`a-troop-page-s-box-drops-its-icons`](a-troop-page-s-box-drops-its-icons.md).
