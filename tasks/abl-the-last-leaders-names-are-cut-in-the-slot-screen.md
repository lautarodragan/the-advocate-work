---
name: "ABL: the last leaders' names are cut in the slot screen"
description: "With every map, the slot screen shows \"Advocat\", \"Royal D\" and \"ABL 2.0\" where the original shows the whole name: the name field is seven cells"
type: bug
status: draft
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
