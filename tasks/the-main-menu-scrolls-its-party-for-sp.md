---
name: "The main menu scrolls its party, to fit SP"
description: "The main menu's party boxes get a fourth line with SP and show three actors at a time, scrolling to the fourth, since four boxes of four lines do not fit"
type: feature
status: doing
assignee: Tijereta
agents: [Tijereta]
---

Follows [`sp-in-the-menu-and-the-item-target-picker`](sp-in-the-menu-and-the-item-target-picker.md):
Tijereta put SP in the item and skill target picker but not in the main
menu, where four boxes of five ink lines do not fit the 224 lines and the
Ex already takes 120 of the 128 sprites. Of the ways out —drop "Normal",
drop the Ex, the 512-wide mode— taro asked, on 2026-11-01, in their words,
translated:

> Hmmm, darn. Isn't vertical scrolling for the characters an option?

and, after Hornero's answer:

> Go ahead! Let's go with vertical scrolling then, once Tijereta finishes.

**Done**: each actor's box in the main menu has a fourth line with SP
(the database's term); three boxes are seen at a time and the list
scrolls a whole row when the cursor goes past them, with a sign that
there is more; the Ex's sprites fit for the three rows seen; a
divergence in the book —RM2k shows four at once—; goldens moved, red
before, with the debug map's full party.

Waits for the merge of
[`bank-1-overflows-when-merging-2026-11-01`](bank-1-overflows-when-merging-2026-11-01.md),
which is integrating the same menu code.
