---
name: "The font carries a box's icons twice"
description: "An ExFont icon used both by the database and by a message box goes into the cartridge's one font twice, among the screens' glyphs and among the boxes' letters: 22 glyphs, 18,304 bytes in Zounds"
type: refactor
game: zounds
status: draft
assignee: taro
author: aguara
agents: [cardon]
links:
  found-in: [the-text-screens-draw-latin-1]
---

Seen by Aguará on 2026-11-22, in
[`the-text-screens-draw-latin-1`](the-text-screens-draw-latin-1.md), with
the-advocate at `1b8825d8`, the ports at `544f9bc` and Zounds' release
build of that morning.

**What happens**: the cartridge's one font (`font_glyphs` in the screens
stage's `convert.rs`) is the console's 96, the figure's blank and the
halves of the icons the screens draw, and after them the boxes' letters,
which carry the halves of the icons the boxes draw. Zounds' screens draw
25 icons (`$D $E $I $J $K $L $M $N $O $Q $R $T $V $W $Z $a $d $f $g $j $o
$u $v $x $z`), and its boxes 11 (`$D $E $J $K $N $T $V $Z $d $o $v`), all
11 among the 25: 22 glyphs are in the font twice, 22 × 104 bytes × 8
phases = 18,304 bytes of ROM. Measured from `FONT_LETTERS_AT` (147) and
`MESSAGE_PAIR_FIRST` (136) in its `mapdata.inc`, and the boxes' letters
from `rm2k-snes-events compile` over its `events-request.json`.

The other eight games lose nothing: Vampires Dawn's one screen icon
(`$o`) is not its boxes' (`$s`), and the rest have no icons on their
screens. Zounds has 51 free data banks.

## Comments

### 2026-11-24, Cardón: a question for taro

Measured, and nothing seen changes; what
is not clear is whether it is worth it: 18,304 bytes of ROM in Zounds alone,
which has 51 free data banks, at the cost of the boxes' letters looking the
screens' icons up (the event compiler and the screens stage agreeing on one
list of icons).

* **a)** do it now; **b)** `wishlist`, until a game's ROM is tight;
  **c)** cancel.

Recommendation: **b**.

## Log
