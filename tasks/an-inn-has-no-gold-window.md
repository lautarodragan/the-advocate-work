---
name: "A paid inn shows no gold window, and \"Yes\" can be picked without the gold"
description: "ShowInn with a price: the greeting comes without the gold window, and Yes is not greyed out when the party cannot pay"
type: bug
status: doing
assignee: Hurón
agents: [Tijereta, Hurón]
---

Seen by Tijereta on 2026-10-19, at the-advocate `35dcc348` and the ports
`71e7528`, while staging the inn's night
([`book-of-three-inns-in-scenes-are-not-staged`](book-of-three-inns-in-scenes-are-not-staged.md)).
They are the two debts `compile_inn` already declared, and until now no
task carried them.

**What is seen**, in ABL: at a paid inn —the bum of map 20, `InnBum`, at
5 credits— the greeting and its "Yes"/"No" open without the gold window
RM2k puts next to them, and with less than the price "Yes" can still be
chosen: it does nothing, as "No". In RM2k the window shows the party's
gold and "Yes" is greyed out and cannot be picked (`CommandShowInn` in
easyrpg: `SetShowGoldWindow(true)`, `PushChoice(accept, can_afford)`).

**What the build says**: `degradations.json` lists every paid inn as
`inn-no-gold-window`.

**How to see it**: talk to the bum below him at (91, 28) on map 20 with
fewer than 5 credits; `rpgmaker/test_inn.py`'s
`test_without_gold_it_neither_charges_nor_heals` is that case.

## Hurón, 2026-10-19: the plan

From Tijereta's branches (the-advocate `35dcc348`, the ports `71e7528`, the
book `7a83e9f`), in `huron-inn-gold` of each.

What RM2k does, from easyrpg's `CommandShowInn` and `Window_Message`: the
gold window is `Window_Gold`, 88x32 at the right edge, at the top of the
screen unless the message is at the top, then at the bottom; the number
right-aligned in colour 0 and the gold term after it in colour 1. "Yes" is
pushed with `can_afford`, which the window draws in `Font::ColorDisabled`
—System colour 3— and which A refuses with the buzzer, the choice staying
open. Cancel is never refused.

What there is to reuse, measured:

* The shop's gold is a text screen's, not the map's: nothing to take.
* The greys —skills, items, the title's "Load"— are all text screens or
  baked menus. The message window composes its letters from tables with
  the colour baked in —`font_pre*`, 117 KB—, so a second colour there is
  new work. RM2k's ShowChoice cannot grey an option, only the inn does.
* The message arrow is already drawn as objects in a window without a
  background, where the map has room past its sprite bank and a free
  sprite palette (`arrow_objs`): the gold window goes the same way, in the
  same palette, after the arrow's two tiles.

The plan:

* **Greyed option**: no new opcode. The inn compiles to `OP_INN 3` —"the
  next choice is the inn's: its gold window, and Yes greyed"— and a gold
  branch that, with the price paid for, goes through `OP_INN 4` —"Yes not
  greyed"—. The choice's pick moves out of bank 0 into FAR3, where it
  refuses A on a greyed option. The grey is a recolour of each letter just
  composed on a greyed line, glyph pixels only, to the window palette's
  nearest entries to System colour 3: the palette has no room for a grey
  of its own (the backgrounds start right after it).
* **Gold window**: 44 8x8 objects, in the arrow's sprite palette, with the
  window's colours plus the free entries of that palette for the term's.
  The converter draws the empty window with the term; the console composes
  the number into a copy of its middle two rows when the box opens and
  uploads one row of tiles per line the composer uploads.
