---
name: "The colour escape \\c[n] in messages"
description: "Any escape but a tail of \\| and \\^ refuses the box, on purpose; Zounds colours speaker names with \\c[n] in 2,604 of its 7,102 message lines, and that alone keeps 678 map pages out of 981"
type: feature
status: done
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

**Absorbed** by [`unknown-message-escapes-are-dropped-with-a-warning`](unknown-message-escapes-are-dropped-with-a-warning.md) (Mulita, 2026-10-15): the 678 pages are not out by `\c[n]`, which was already dropped, but by letters the console's font does not have —Zounds is in Spanish, and its hero is `Unamë`—; see [`latin-1-letters-stop-a-box`](latin-1-letters-stop-a-box.md). The colour itself is still lost: [`message-colours-and-speed`](message-colours-and-speed.md).

Done by [`unknown-message-escapes-are-dropped-with-a-warning`](unknown-message-escapes-are-dropped-with-a-warning.md)
(the-advocate `2a142635`, merged in `a9b3e144`): `\c[n]` and every escape
the console cannot show is dropped and noted in `degradations.json`
instead of refusing the box. What is still lost, the colour itself, is
[`message-colours-and-speed`](message-colours-and-speed.md); the letters,
[`latin-1-letters-stop-a-box`](latin-1-letters-stop-a-box.md). Checked on
2026-10-16 at the-advocate 759aa0ba (Mulita).
