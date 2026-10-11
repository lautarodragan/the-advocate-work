---
name: "Victory gives neither gold nor items"
description: "RM2k gives and reports the gold and the items on winning; the port does not yet"
type: feature
status: done
---

It was left out of `la-victoria-avisa-la-experiencia.md` (2026-09-26): in
RM2k, on winning, the same victory page reports the gold won and the items the
enemies dropped (`ProcessSceneActionVictory` in EasyRPG), and the party
receives them. The port does not give gold or items on winning yet. The data
is in the LDB's troops and enemies (`gold`, `drop_id`, `drop_probability`);
the items' randomness has to use the battle's generator (see `ENC_SEMILLA` and
the battle's own seed).

## How it ended up, on 2026-09-27

On winning, `ba_vic_empezar` does what `ProcessSceneActionVictory` does in its
first sub-state, in the same order: it hands out the experience, adds the
troop's gold —`GetMoney`, capped at ORO_MAX like `GainGold`— and rolls the
loot —`GenerateDrops`—: for each enemy, in the troop's order, **one roll if it
has an item**, with `ba_pct` on the battle's seed. `ChanceOf(n, 100)` is
`GetRandomNumber(1, 100) <= n`, which with our randomness is the same as
`PercentChance`; the one with chance 100 is rolled anyway. What comes out adds
one to the inventory, capped at 99.

The model rolls the same: `batalla.Batalla.tirar_el_botin`, which
`jugar_turno` calls on winning, after the last hit, and it is point 5 of the
class's randomness order. Since it is the last thing the battle rolls, it does
not move anything in any earlier prediction.

The first page now reports, after the victory and the experience, the gold
—" You found 285Cr credits!", which is `gold_recieved_a`, a space, the number
stuck to `gold` and `gold_recieved_b`, as RM2k builds it without
placeholders— and one line per item, "Healing Draught-HP obtained!"
(`item_recieved` stuck to the name, without a space: the space is RM2k3's).
They are lines of the same message, so what does not fit in the four goes on
another page with A, same as an actor's skills (`ba_vic_linea`). With the
victory split in two lines, the experience and the gold fill the first page
and the items always go on the second.

The converter's part:

* `tropa_oro`, `enemigo_botin` and `enemigo_botin_pct`, in RODATA with their
  `.bloque`;
* the items that some enemy of the cartridge's troops can drop go into the
  item list (`items_del_botin`), to have their name;
* `cobrar_la_victoria` also enforces the gold line and the line of each item
  that can be dropped.

Adding the gold with a cap moved out of the shop's sale into a routine,
`oro_sumar`, which both use.

Far RAM: `$7E79E0-$7E79E8` (`BA_BOTIN*` in `ram_lejana.s`), from the range
handed out. No opcode.

It is covered by `pruebas/rpgmaker/test_victoria.py` with the new case
`pelea-222`, three Crazed Marauders: the model picks the seed —the first one
with which it wins without casualties and the three rolls do not come out the
same— and it is written into `BA_SEM` when the battle opens, with 1 HP for
each enemy. The test compares the gold, the inventory and the first two pages
against the model and the lines from `pantallas`, and another one enforces the
cap of 99.

## What taro has to look at

In Lashe City no enemy drops items —the `release` troops that drop are those
of the test maps' encounters, which cannot be reached playing—, so what is
seen is **the gold**: after any battle with enemies that give gold, the first
page says " You found NCr credits!" and the menu's gold goes up by that. The
droid on map 2 gives zero and does not say it, which is RM2k's behaviour
(`if (money > 0)`). The items on the page are only seen with the case
`pelea-222`.

* That the gold page reads well and that A moves past it as before.
* That the menu's gold after fighting is the previous one plus what the page
  said.
