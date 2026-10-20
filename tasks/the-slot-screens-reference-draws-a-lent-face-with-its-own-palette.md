---
name: "The slot screen's reference draws a lent face with its own palette"
description: "screens.slot_screen builds its bank with the parties it is given, so a face the cartridge draws with another's palette —Royal Dalia's in ABL— comes out in its own colours, and comparing the ROM against it is red"
type: test
status: draft
agents: [Hurón]
---

Seen by Hurón on 2026-10-20, with the-advocate `07b002f5` (branch
`huron-slot-names`) and the ports' branch of the same name, in ABL's
`release`.

**What is seen**: a save led by Royal Dalia (30), compared pixel by pixel
against `screens.slot_screen` —`test_title_drawing.py`'s way—, differs in
119 pixels at 15 bits, all of them her face (x 128..139, y 181..202 with
her in slot 4): the ROM draws it with a palette borrowed from another face
—`release`'s converter says "faces without a palette of their own, drawn
with another's: …, Royal Dalia, Kersh"— and the reference with its own.
`render::slot_screen` in `rm2k-snes-screens` builds the bank with only the
actors of the parties it is given, so nobody runs out of palettes there.
The ROM is what the game looks like; the reference is the one that does
not match it.

**How to see it**: in `test_the_slot_screen_writes_the_longest_leaders_whole`
(`tests/rpgmaker/test_title_drawing.py`), change DummyHero's `(10,)` for
Royal Dalia's `(30,)`; the snapshot lands in `tests/snapshots/screens/`.
That test leaves her out for this; her slot is in the golden
`title-slots-long-names`, which is the ROM against itself.
