---
name: "A paid inn shows no gold window, and \"Yes\" can be picked without the gold"
description: "ShowInn with a price: the greeting comes without the gold window, and Yes is not greyed out when the party cannot pay"
type: bug
status: draft
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
