---
name: "Latin-1 letters stop a box"
description: "A text box with a letter outside printable ASCII —é, ñ, ¿, ü, ß, …— leaves its whole page out: it is most of what Zounds and Vampires Dawn lose of their messages"
type: feature
status: done
assignee: taro
agents: [Mulita, Aguará]
---

Seen by Mulita on 2026-10-15, measuring
[`unknown-message-escapes-are-dropped-with-a-warning`](unknown-message-escapes-are-dropped-with-a-warning.md),
with the-advocate `6fa69781` and ports `f015801`.

**What happens**: `Messages::store`, in `rm2k-snes/events/src/messages.rs`,
stops the page of any box with a letter the console's font does not have,
and the font is printable ASCII; RM2k's has Latin-1. It is on purpose
(`a_letter_the_font_does_not_have_stops_the_page`), but games in Spanish
and German lose most of their talking pages to it.

**Measured**, the map pages out only by their message commands, and of
those the ones out only by such a letter (each game's `release`,
`just culprits`, the culprit message commands classified by a throwaway
script):

* Zounds (Spanish): 919 of 965, and the other 46 by a letter and something
  else. Letters: `é á ¡ ë ¿ ó í ñ ú É ô ü î â Ó û Á ä`. The hero is called
  `Unamë`, so every box with `\n[1]` is out too.
* Vampires Dawn (German): 162 of 378 before the escapes change; 638 culprit
  boxes carry `ü ö ä ß Ü Ä Ö`.
* Desert Nightmare: 7 pages, 12 boxes (`ü ä ß ö`).
* Sunset over Imdahl: 4 pages (`ä`, `…`, `ô`).
* El Dorado: 1 page (`ä`).

**To reproduce**: build a game's `release` and run `just culprits` in its
directory; the culprit `ShowMessage`s are the ones with those letters.

**It is where Zounds' intro stops** (Aguará, 2026-10-16, the-advocate
`1a97c8ca`): once map 8 "To King's Room" stopped going black
([`zounds-the-screen-goes-black-up-the-stairs-after-the-guard`](zounds-the-screen-goes-black-up-the-stairs-after-the-guard.md)),
its autostart —event 3, Uname's talk with the two guards, which teleports
to map 9— is left out whole by its message boxes alone (`é ¿ ¡ ë`), so the
player walks on map 8 and the story does not go on.

**Taken by Aguará on 2026-10-16** (Hornero), as the next thing that blocks
Zounds: first the box shown with each such letter as its plain ASCII
neighbour and a warning, so the pages run; then the letters drawn for
real, if the font has room.

## Phase 1: the letters shown plain (Aguará, 2026-10-16)

From the-advocate `ba8fd164` and ports `18c8c87`, branches
`aguara-latin1` in both and in the book.

* `rm2k-snes-text` has a new `plain` module: the table of each Latin-1
  letter —and Windows-1252's few extras RPG_RT draws, `…`, the curly
  quotes, the dashes— to the plain ASCII a reader would write without the
  key (`é`→`e`, `ß`→`ss`, `¿`→`?`, `…`→`...`). The reflow's `Measure`
  measures a letter as its stand-in, so a box with `…` is not cut short
  once it is three periods.
* `Messages::store` stands the plain letters in before trimming to the
  window, and keeps which ones until the compiler takes them, with the
  dropped escapes: one `letter-plain` loss per command in
  `degradations.json`, with the letters. A character without a stand-in
  still stops the page. The converter prints one `WARNING, letter-plain`
  line with every letter.
* The text screens' names and terms —`item_text` in screens and battle,
  `Texts::add` in mapdata, which is where `\N[0]` and the renamed actors'
  names come from— stand the plain letters in too, where they had a `?`:
  Zounds' `Unamë` is `Uname` in the menu and in the battle. The `\N[1]`
  the compiler writes into a box goes through `store`.

Baseline culprits, each game's `release` request of the ports' main
checkout (`/root/the-advocate-ports/<game>/build/release/`), tools of
`ba8fd164` — compiled/total pages, maps, commons, troops:

    abl                    5601/5601     59/60 4451/4588
    book-of-three          1282/1282     25/25   651/746
    desert-nightmare       6787/6799     28/30     0/100
    dooms2                   493/496     10/10      1/82
    el-dorado                967/972      6/10      0/80
    frozen-world           3882/3891   100/100      0/80
    sunset-over-imdahl     1342/1369       7/8       0/1
    vampires-dawn        17989/18842     29/52     0/362
    zounds                 3514/4495     43/69    19/105

The same, with phase 1's `rm2k-snes-events`:

    abl                    5601/5601     59/60 4451/4588
    book-of-three          1282/1282     25/25   651/746
    desert-nightmare       6794/6799     28/30     0/100
    dooms2                   493/496     10/10      1/82
    el-dorado                968/972      6/10      0/80
    frozen-world           3882/3891   100/100      0/80
    sunset-over-imdahl     1346/1369       7/8       0/1
    vampires-dawn        18155/18842     29/52     0/362
    zounds                 4464/4495     60/69    41/105

Pages back: Zounds 950 of the maps', 17 common events and 22 troop pages;
Vampires Dawn 166; Desert Nightmare 7; Sunset 4; El Dorado 1. No culprit
message command of any game carries a non-ASCII character any more.

The letters the nine games' message commands use, all of them with a
stand-in —24, by uses—: `é á ë ¡ ¿ í ó ü ñ ä ö ß ú É ô î Ü â Ä … Ó û Á Ö`.
Zounds has 18 of them, and `ë` in its hero's name; Vampires Dawn `ü ö ä ß Ü
Ä Ö`; Desert `ü ä ß ö`; Sunset `ä … ô`; El Dorado `ä`.

Phase 1 is the-advocate `f6c884c1` (the stand-ins), `9c3fcb68` and
`ed37595e` (the test game's case and its golden), and the ports' `4e54fc1`
(Zounds past the guards to map 9: ~300 ticks tapping A, eleven boxes). Both
tests seen red with the tools before. ABL's converter output, `mapdata.inc`
and `degradations.json`, came out byte for byte the same as the ports'
main checkout's build.

## Phase 2: the letters drawn (Aguará, 2026-10-16)

The font has room. What bounds it:

* **The composer keeps a letter below 128**: the second letter of a pair
  waits in `FAR_MSG_SECOND` with bit 7 set. So 32 letters after the
  console's 96 at most, per cartridge; the nine games use 24 among them.
* **Each letter takes one value of the pair table**, which starts after
  them: the cartridge says it in `MESSAGE_PAIR_FIRST`, which the runtime
  already read from the converter.
* **ROM, not VRAM**: the message window composes its text in a WRAM buffer
  from `font_pre0..7`, eight tables of 156 bytes per glyph, so each letter
  is 1,248 bytes of ROM and nothing of VRAM.
* **The troops' boxes cannot**: the battle draws them with the text
  screens' glyphs, which are ASCII; they stay plain. So do the text
  screens.

The glyphs: EasyRPG's `rmg2000`, which `low-variable` comes from, has all
of Latin-1. `low-variable`'s rule —cut to the ink plus one of air, and of a
run of equal inner columns one fewer— reproduces 78 of its 94 ASCII glyphs
(the digits, the slash, the lines and `J` are by hand), so the Latin-1 rows
were derived the same way, with an accented lowercase letter being the
sheet's own letter under `rmg2000`'s accent, centred. Four come out seven
wide (`® ¾ Ø ø`) and were left out, so that `letter_spacing` keeps the
limits it had.

Which letters a cartridge carries is the compiler's: its first pass draws
all, `Messages::letters_used` counts what the boxes left use, and the
second pass draws those —most used first, up to 32—. A game in English
carries none and its text block is the same.

Measured on the builds: Zounds carries 17 letters, Vampires Dawn 6, Desert
Nightmare 4, Sunset 2 and El Dorado 1 (`MESSAGE_PAIR_FIRST` minus 96 in
each `mapdata.inc`). What still goes plain: Zounds' troop boxes (795
`letter-plain` losses, every one a troop page's) and Sunset's `…` (2). The
culprits are the same as with phase 1: drawing the letters changes no page.

## Done (Aguará, 2026-10-16)

Branches `aguara-latin1`:

* the-advocate: `f6c884c1` the stand-ins; `9c3fcb68`, `ed37595e`,
  `75f7da8c` the test game's box and golden; `cbe29042` the sheet's Latin-1;
  `d620ca49` the boxes draw them; `d9ca79e1`, `33b22e07` the test game's
  golden and README; `dbeb9507` the loss's wording; `0b857e68`; merges of
  main (`b469a21f` renumbers Plain Letters to common event 4, since
  Mulita's Tileset took 3).
* ports: `4e54fc1` Zounds past the guards to map 9.
* the-advocate-docs: `b831966` the divergence "Letters the font does not
  have", the internals row, the known issues of Zounds and Vampires Dawn.

Run on the merged tree, with `.local-tools` of events, screens, convert,
battle and mapdata: `just rust-test`, `just test`, `just test-game` (36
passed, 1 skipped), ABL's `just tests` (1563 passed, 2 skipped; no golden
moved; `abl.sfc` `a3e45c59db07bb6f`), and `just boot` at the ports' root
(50 passed). ABL's `mapdata.inc` was byte for byte the main checkout's
build's on both phases, before the last merge.

**To install when merging**: events, screens, convert, battle and mapdata
—the text crate is a library in all of them—.

What no test covers: the menu, shops and battle with the stand-ins (no
golden of a menu with an accented name); a cartridge past 32 letters (unit
test only); the reflow with drawn letters, measured only in unit tests.
The captures are in `/shared/captures/2026-10-16-latin1/`.
