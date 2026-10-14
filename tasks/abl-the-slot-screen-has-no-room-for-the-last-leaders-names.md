---
name: "ABL: the slot screen has no room for the last leaders' names"
description: "With every map of ABL, the leaders' names the slot screen composes ask for 48 tiles and the menu's bank leaves 44: rm2k-snes-screens stops the cartridge"
type: bug
status: testing
assignee: taro
agents: [Chajá]
---

Seen by Cardón on 2026-10-14, with the-advocate `a7f278e6` and the ports
`6a9d53c`, in ABL, building a cartridge with every map of the game: see
[`abl-release-stops-at-the-first-night`](abl-release-stops-at-the-first-night.md).

**What is seen**: `rm2k-snes-screens` stops with "the menu's bank has no
room for the composed names, even with the slot screen's text last: the
menu shows 326 tiles and leaves 122 free up to its tilemap, and its names
can ask for 100: 70 the party's and 30 a medicine's; the slot screen shows
403 and leaves 44, and its leaders can ask for 48". The check is
`strips_fit` in `rm2k-snes/screens/src/convert.rs`, which reserves four
slots times the widest leader. The actors that join in the last chapter and
the ending —Royal Dalia (30), the Advocate (31), "ABL 2.0 Save" (34)— are
the ones the build also warns as cut in the slot screen.

It is point 4 of `degrade-instead-of-failing.md` —"the names that don't fit
in the menu's bank"—, which was left undone; the Dooms 2 draft
[`dooms-2-slots-and-menu-dont-fit-in-their-bank`](dooms-2-slots-and-menu-dont-fit-in-their-bank.md)
is the bank itself, another stop of the same screen.

**How to see it**: a cartridge with every map of ABL, and the converter's
output.

## Log

**Chajá, 2026-10-14.** Tools `51b4b1b2`, ports `d91049e`; branch
`chaja-end-blockers`.

**Measured**: every leader's strip, at `NAME_COLS`: four ask for 12 tiles
—DummyHero, Gang Member, CarBLUE and the Advocate— and Royal Dalia and
"ABL 2.0 Save" 10. So 4 x 12 = 48, and the worst case is real even with
one strip per distinct name: deduplicating the slots would not help. The
bank grew by the new faces.

**Found without losing anything**: the bank had `Bank::add_mirrored`
(End Game's frame and the borders use it) and the slot screen and menu
did not. With every block through it the bank is 400 tiles instead of
403, and the names get 48 of 48 —`free_after` rounds to even—. Exactly,
so a new face or text in that bank would stop it again, with the same
message.

**The catch**: `menu_exp_paint` draws the loose glyphs and the "Ex" term
as sprites and passes only the tile number to the OAM, so those two keep
plain `add`. The emitter keeps the flip bits (`entry` ORs). And the
reference renderer of the menu tests (`render.rs`) ignored the flips:
fifteen menu tests went red by 92 pixels (Kersh's face) while the
console was right —the frozen menu goldens did not move—; it now draws
them, as End Game's did.

Commits in the-advocate: `screens: the slot screen and menu's bank takes
a tile flipped when it is one` and `screens: the reference renderer draws
the flip bits of the menu's bank`.

**Verified**: whole-game experiment builds past the slot screen ("menu
bank: 400 tiles of 448 ... 48 of the 48 the slot screen does"); captured
four saves with the Advocate, Royal Dalia, "ABL 2.0 Save" and DummyHero
and the pause menu with them, against the original's save screen under
Wine. `release` changes bytes (its bank is mirrored too) and draws the
same: `just tests` 1303 passed —menu, slot and title goldens included,
which is what runs the mirrored path—, `just boot` 9, `just test` 27.
`abl.sfc` of `release`: sha256 `d8bfa204…9c76`.

**The names**: the bank's room did not change them, and they are cut as
before at seven cells (56 px, `letter_spacing = 1`): "Advocat", "Royal D",
"ABL 2.0", "DummyHe", where the original writes them whole. Readable as
abbreviations; not fixed here, because it is the slot layout (text from x
56, faces from 112) and wider names would ask for more of the bank. Draft:
[`abl-the-last-leaders-names-are-cut-in-the-slot-screen`](abl-the-last-leaders-names-are-cut-in-the-slot-screen.md).

To install when merging: `screens`.
