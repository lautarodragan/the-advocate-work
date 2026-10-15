---
name: "A literal backslash in messages"
description: "RM2k's \\\\ (a backslash on screen) is refused by escape_tail: The Frozen World uses it as the separator of its stat readouts, 320 lines on 38 map pages and 7 common events"
type: feature
status: testing
assignee: taro
agents: [Mulita]
---

Seen by Calandria on 2026-10-14, with the-advocate `14e200fc` and the ports
`f775b66`, measuring what The Frozen World leaves out
([research](https://lautarodragan.github.io/the-advocate-docs/progress/book-of-three-and-frozen-world.html)).

**What is seen** (not played): lines like `HP: \V[0031] \\ \V[0032]`,
current over maximum, in the level-up readouts (common events 20, 21, 25),
the study and steal skills' monster stats (23, 24, 37), the party statistics
(31), and on map 3 ("Command Grid", 18 pages), map 14 (3) and map 1 (17).
The pages are left out. Those that the backslash alone keeps out, outside map
1 (which is not in the cartridge): map 3's 18 pages, map 14's 3, and commons
20, 21, 25 and 31. All of this is the combat, which waits on map 1 and 2
([`flashing-hero-shares-a-palette-with-an-npc`](flashing-hero-shares-a-palette-with-an-npc.md),
[`map-streams-that-dont-fit-in-wram`](map-streams-that-dont-fit-in-wram.md)).

**Where it stops**: `with_wait_marks` in `rm2k-snes/text/src/refit.rs` keeps
a doubled backslash as two characters, and `escape_tail` refuses any
backslash left in a line. Nothing turns `\\` into one `\`. Whether the
console font has the glyph was not looked at.

No other game uses it: 320 lines in the eight dumps, all here.

**Done** by Mulita on 2026-10-14 (the-advocate `84cc60e5`, branch `mulita-escapes`; ports branch `mulita-escapes`). The console font already has the backslash glyph (it is one of the 95 ASCII cells), so nothing was added: `with_wait_marks` turns `\\` into a mark (`backslash_mark`), the reflow measures it as the font's `\` and writes it back as `\\`, and `units` draws it. `with_names` and `with_variables` skip a `\\` pair, so `\\V[1]` is a backslash and the letters. Tests: compiler unit tests and `escapes.json` cases (the compiler ones red before), ABL `test_escapes_in_text.py` with the golden `backslash-in-text`. `just culprits` in frozen-world: commons that compile 90 to 94, maps 3,823 to 3,871 (together with the other task). Install on merge: `just install text events convert` plus whatever links them.
