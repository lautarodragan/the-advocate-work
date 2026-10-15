---
name: "The colour escape \\c[n] in messages"
description: "Any escape but a tail of \\| and \\^ refuses the box, on purpose; Zounds colours speaker names with \\c[n] in 2,604 of its 7,102 message lines, and that alone keeps 678 map pages out of 981"
type: feature
status: draft
---

Seen by Aguará on 2026-10-15, in the study
[`port-zounds-an-rpg-maker-2003-game`](port-zounds-an-rpg-maker-2003-game.md),
with the-advocate `91d55d39`.

**What happens**: `escape_tail` in `rm2k-snes/events/src/messages.rs`
accepts `\|` and `\^` only as a tail at the end of the box's last line and
refuses any other escape, which is the right call for ABL (40 boxes, all
tails). Zounds writes `\c[5]Unamë:\c[0]` on the first line of most boxes.

**Measured** over Zounds' `culprits.json`: 981 map pages do not compile;
920 only because of their messages; of those, 678 carry no escape but
`\c`. The rest also carry `\|` in the middle of a line (220 pages), `\n[k]`
(15), `\v[k]` (11), `\s[k]` (10). Across the game: `\c` 5,220 times, `\|`
669, `\v` 97, `\n` 41, `\s` 24, `\^` 4. Common events: 9 more pages.

**What it would take**: the cheap version ignores `\c[n]` —strips it and
draws in the System's text colour—, which loses the colour and nothing
else; the real one carries a colour change in the box's stream, which the
composer in `runtime/` would have to honour per glyph with the font's
inks (the screens already draw text in several inks). `\n[k]` is the
actor's name, `\v[k]` a variable's value: both are things the ROM knows at
run time. Other games were not counted here.
