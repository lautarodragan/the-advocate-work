---
name: "Goombario reads widths from an untaken .if branch"
description: "The test game's linter test is red on main: in `tl_glyph_hi` Goombario takes the `.a8` of the `.if ::DEBUG_SCREEN` branch the test game does not assemble, and flags the `.else` branch's 16-bit `and #$0007` as an immediate the widths do not explain"
type: bug
status: draft
agents: [Chajá]
---

Seen by Chajá on 2026-11-17, running `just test-game` in a worktree of
the-advocate at `865163eb` (main), with the global tools, for
[`a-message-and-the-choice-after-it-share-a-box-in-rm2k`](a-message-and-the-choice-after-it-share-a-box-in-rm2k.md).

**What was seen**: `test-game/tests/test_linter.py::test_the_runtime_falls_in_no_trap`
is red: five width findings in `tl_glyph_hi`, `runtime/text_layer.s`
lines 3811 to 3818 —"`lda` is under a 8-bit A in the source, and on the
path from `tl_glyph_hi` it is 16 bits wide"— and "immediates whose size
the source's widths do not explain: 1, runtime/text_layer.s:3812", the
`and #$0007`.

**What it looks like**: those lines are the `.else` of `.if
::DEBUG_SCREEN`, which the test game assembles (it has no debug screen).
The `.if` branch ends in `sep #$20` / `.a8`; ca65 does not process it, so
the `.else` runs and assembles under the `.a16` above —the ROM is right,
the immediate is two bytes—, but Goombario seems to read the source's
widths in text order, untaken branch included. ABL, which has the debug
screen, takes the other branch. By AGENTS.md's rule the fix goes in
Goombario (follow `.if`/`.else` as ca65 does, or take the widths from
the listing), not in the runtime. Not looked into further; the test
game's other reds on main, `test_leader_name.py`, are
[`the-test-games-leader-name-goldens-are-red-on-main`](the-test-games-leader-name-goldens-are-red-on-main.md).

**To reproduce**: in a worktree of the-advocate at `865163eb`,
`SOUNDFONT=<a free .sf2> just test-game -k linter`.
