---
name: "ABL: the last leaders' names are cut in the slot screen"
description: "With every map, the slot screen shows \"Advocat\", \"Royal D\" and \"ABL 2.0\" where the original shows the whole name: the name field is seven cells"
type: bug
status: testing
assignee: taro
agents: [Hurón]
---

Seen by Chajá on 2026-10-14, with the-advocate `ac9897cc` (branch
`chaja-end-blockers`) and the ports `d91049e`, in ABL built with every map
of the game —the experiment of
[`abl-the-slot-screen-has-no-room-for-the-last-leaders-names`](abl-the-slot-screen-has-no-room-for-the-last-leaders-names.md)—.

**What is seen**: four games saved with the Advocate (31), Royal Dalia
(30), "ABL 2.0 Save" (34) and DummyHero (10) in front. The original, under
Wine, writes their whole names on its save screen; the port writes
"Advocat", "Royal D", "ABL 2.0" and "DummyHe". The converter already warns:
"6 leader names in the slot screen don't fit in 7 cells (56 px) and are
cut". The field runs from the text (x 56) to the first face (x 112), and
with `letter_spacing = 1` the names grow a pixel per letter.

It is not the bank's room —that one fits since this branch, 48 tiles of
48—: wider names would ask for more of it too. In `release` the leaders
that can be saved fit, as far as is known; DummyHero leads only at the
start.

**How to see it**: the captures in
`~/scratch/chaja/captures/2026-10-14-end-blockers/` (`slots-original.png`,
`slots-port-whole.png`), and the WARNING in the converter's log of a
cartridge with every map.

**Checked on 2026-10-16** at the-advocate `759aa0ba`, by Cardón: since
the ports' `74eb754` (2026-10-14, after this draft) `release` carries the
whole game, so this is no longer an experiment's: the release build's
`converter.log` in the ports checkout (2026-10-16) has the same WARNING,
six names cut —"DummyHero", "Gang Member", "MobilizedCar", "Royal Dalia",
"Advocate" and "ABL 2.0 Save"—, and the leaders that cut are reachable in
the cartridge taro plays.

## Defined

Todo, on 2026-10-16, by Cardón: in the `release` taro plays, six reachable leaders' names
are cut on the save screen.

**Done** means the slot screen writes those names whole, as the original
under Wine, and the WARNING is gone from `release`'s `converter.log`, with
a golden of a slot with "ABL 2.0 Save" or "MobilizedCar". Ways, the agent
picks and measures, minding the slot bank's tiles: a field wider than seven
cells (moving the faces, as the original lays them out), or the names
without `letter_spacing`. **First step**: the original's slot layout in
`~/scratch/chaja/captures/2026-10-14-end-blockers/slots-original.png`
against the port's, measured in pixels.

## Log

**Hurón, 2026-10-20.** Tools `3bc68ac4`, ports `3cd810d`, book `0b96ba4`;
branches `huron-slot-names`.

**The layouts, measured**: the original's save screen (Chajá's
`slots-original.png`, 640x480, so halved) writes "File 1" and the name
from x 8 and puts the faces from x ~100: easyrpg's
`Window_SaveFile::Refresh` draws the text at 4 in the window's contents
and the faces at `92 + i * 56`, so RM2k gives the name some 88 px. The
port writes the text from x 56 (`SLOT_X`) and the faces from x 112
(`FACE_COL` 14): 56 px, seven cells.

**Baseline** (`just cartridges` with the global tools): `release`'s
converter says "menu bank: 395 tiles of 448, the slot screen's text last;
the composed names ask for 100 of the 126 the menu leaves and 48 of the 52
the slot screen does". Whole, the widest leader —"ABL 2.0 Save", 67 px plus
the cell's first pixel— is nine cells, 18 tiles, so four slots ask for 72:
moving the text alone does not fit the bank.

**Why x 56**: `git blame` takes `SLOT_X = 56` back to the Python's
`RANURA_X`, with no reason given; the slot screen had a ">" cursor baked
to the left of the text until 2026-10-16, when it became the System's bar,
which RPG_RT draws from four pixels left of the text. Nothing else holds
the text there.

**Measured, the bank**: with the captured `rm2k-snes-screens` request of
`release`, the menu's own text —its commands, white and grey, the currency,
the party row, the experience term— is 154 tiles; the slot screen's own
—the headers and the rows— 74; the glyphs both use, 22; the faces, 145.

**What was done** (the-advocate `07b002f5`):

* `SLOT_X` from 56 to 8: the name gets the thirteen cells up to the first
  face, the same the menu keeps of each name (asserted).
* A third order for the bank, `Order::Apart`, tried after `Drawn` and
  `MenuFirst`: the glyphs and the faces first, then the menu's text, then
  the slot screen's, which no longer dedups against the menu's
  (`Bank::forget_from`). The menu composes over the slot screen's text as
  before; the slot screen over the menu's. The answer carries
  `slot_names`, the emission `SLOT_NAMES_FIRST`/`SLOT_NAMES_END`, and the
  runtime keeps the end in `TL_STRIP_OVER` (a free word of `TL_VARS`),
  set by `tl_strip_reset` and `tl_strip_menu`; `slot_bank_upload` puts the
  other screen's text back each time either opens.
* `release` now: "398 tiles of 448, each screen's text apart; the composed
  names ask for 100 of the 126 the menu leaves and 72 of the 154 the slot
  screen does", and no WARNING of cut leaders.

**Space** (`just space`, every cartridge of ABL and of the other eight
games, before with the global tools and after with this branch's): bank 0
does not move in any but Dooms 2's `release`, 217 → 209 —its bank goes
apart now, so `menu.s` assembles its two `jsl tl_strip_menu`—; Sunset
stays at 25 and Vampires Dawn at 45. Bank 1 loses 6 bytes, 12 in ABL's
`release` (931 → 919) and 29 in Dooms 2's.

**The other games**: every cut leader comes out whole —Hernando,
Jonathan, Unsichtbar, "Saved Game", Bandurion, "Buddy Bird", Fflewddur,
"Dark Wizard"—, with no WARNING left. All keep their order but Dooms 2,
which goes apart (432 tiles of 448; names 34 of 78 and 48 of 75) and gets
Will's face back: the converter leaves out only the two Junes' now. Its
Known issue in the book says so; nobody looked at the face in a ROM.

**Tests**: `rm2k-snes-screens`' `slot_bank.rs` checks the rule `Apart`
rests on —neither screen shows a tile the other composes over—, red without
`forget_from` (the level term is the same tile in both). In the ports
(`b2dd193`, goldens `d9caad2`): the golden `title-slots-long-names`, four
saves led by "ABL 2.0 Save", "MobilizedCar", "Gang Member" and Royal Dalia,
red with the tools of main in 4145 pixels ("ABL 2.0", "Mobiliz", "Gang
Me", "Royal D"); and the same screen against `screens.slot_screen`, with
DummyHero for Royal Dalia, whose face the ROM draws with a borrowed palette
and the reference does not —draft
[`the-slot-screens-reference-draws-a-lent-face-with-its-own-palette`](the-slot-screens-reference-draws-a-lent-face-with-its-own-palette.md)—.
The harness's `save_through_the_menu` counted presses from the first slot,
and the cursor opens on the slot in use: it counts from `slot` now.

**Goldens that move**: `save`, `save-2`, `title-slots`, `title-slots2`:
only the text moves left, and "DummyHe" is "DummyHero". Side by side, with
the new one and the original under Wine, in
`/shared/captures/2026-10-20-slot-names/`.

Found and not fixed: [`the-slot-screen-shows-no-hp`](the-slot-screen-shows-no-hp.md)
(also a Known issue of ABL in the book) and
[`test-msu-boots-different-from-its-twin-once-on-bsnes`](test-msu-boots-different-from-its-twin-once-on-bsnes.md).

**What was run**, with this branch's `screens`, `mapdata`, `convert` and
`cartridge` first on the PATH: in the-advocate, `just test` (29 passed),
`just rust-test` and `just lint` (green), `just crate-test screens` and
`mapdata`; in the ports, ABL's `just cartridges`, `just space` and `just
tests` twice —the first with the four slot goldens red, the second after
committing them: 1579 passed, 2 skipped, and one red,
`test_msu_twins.py`'s boot on bsnes, green in five runs of the file right
after (draft above)—, and `just boot` at the root (100 passed). `abl.sfc`
of `release`: sha256 `f4961966593d3ecb…`. Main of the ports and the book
merged afterwards, without running the suite again: the ports' main
brought Aguará's item-uses tests, whose tools are not in the-advocate's
main yet.

**The menu after the slot screen** (ports `0e8df3f`):
`test_the_menu_after_the_slot_screen_wrote_a_name` saves, opens Save again
—a name composed over the menu's text, checked in VRAM—, cancels and
compares the menu against the reference: green (`test_menu_drawing.py`, 11
passed). Not seen red against a runtime that does not restore the menu.

**What the suite does not cover**: Dooms 2's slot screen and menu with the
bank apart, which only the converter's output says; and a game whose
names fit in neither order nor apart, which falls back, as before, to
leaving faces out.

**To install when merging**: `just install screens mapdata convert` —and
the runtime changes, `runtime/text_layer.s`—.
