---
name: "The maps' loose commands"
description: "The small cases that leave pages out: ChangeGold by variable, EraseEvent before a jump, the screen position in ControlVars, the cut in ChangeScreenTransitions, and the ControlVars = 999999 of common event 45"
type: feature
status: done
agents: [Aguará, Chajá]
assignee: taro
---

From Aguará's study, [`docs/research/2026-10-05-los-comandos-que-faltan.md`](https://lautarodragan.github.io/the-advocate-docs/research/2026-10-05-los-comandos-que-faltan.html); `rm2k-snes-events culprits` measured it. taro, on 2026-10-05: leave them in todo, without launching yet. None is in release; common event 45, since it doesn't compile, makes 47
calls from Eisen's rooms get skipped.

## Already done

Two of the ones on the list came out on 2026-10-06 with
`four-shortcuts-for-the-other-games` (Chajá), because they paid off in the other
games:

* **The condition on a character's direction**, `OP_IF_FACING`: the 31
  pages of ABL's Eisen simulation, and those of the other games.
* **Moving away from the hero in a route**, command 10, with the random step and facing
  away.

Without them and without the `ControlVars` = 999999 the Eisen simulation still doesn't
work: common event 45 is what's missing.

## 2026-10-11, Aguará

Measured first with `rm2k-snes-events culprits --every-map`, with the
request the converter sends when building `release` and the tools at
the-advocate `0bf46fb1`. Of the five in the description, two were already
done by others: **`EraseEvent` before a jump** (map 150) with
[`eraseevent-for-real`](eraseevent-for-real.md), and **the cut in
`ChangeScreenTransitions`** (map 302) with `d0e9c154`, for Sunset. What was
left: common event 45, `ChangeGold` by variable (map 321 and common events
5, 6 and 44) and the screen position in `ControlVars` (map 207).

* **Common event 45**: a constant set past the word saturates at its edge,
  in the compiler only; adding past it still does not compile. The six
  variables are only compared for equality against cells and moved by one
  after being set from a cell, so the ceiling reads as "no cell" just like
  999999. Divergence in the book.
* **`ChangeGold` by variable**: `OP_GOLD`'s sign byte gets
  `GOLD_BY_VARIABLE`, with the slot in the amount's low byte; a variable
  below zero turns the operation around, as `OperateValue` does. No new
  opcode, no new RAM.
* **The screen position in `ControlVars`** (class 6, RM2k's 4 and 5):
  `character_screen`, in the far bank, gives the centre of the cell and the
  feet on **RM2k's** screen, minus the same RM2k display the pictures that
  go with the map are placed on (`pic_on_map`). Checked against RM2k's
  numbers worked out by hand from `GetScreenX`/`GetScreenY` and liblcf's
  default pan, which showed **`pic_on_map` was eight pixels off**: it
  centred RM2k's display on the console's camera, and RM2k leaves nine
  cells left of the hero, not the half. Fixed in its own commit; the two
  `imagen-mapa` goldens move their REC eight pixels right.

What `culprits --every-map` says now, on ABL: every map page compiles; of
the common events only 32 is left, which compiles on its map (114); no call
is skipped. On Desert Nightmare the screen position was most of what was
left on its maps.

What the suite does not cover: Eisen's simulation itself. Its rooms, maps
281 to 344, are not in any cartridge, so nobody can play it yet; the tests
look at common event 45 run from a test page. The jump height is not taken
off the screen y (RM2k does), and no page asks mid-jump.

When merging: reinstall `events` and `cartridge` (the runtime changed:
`op_gold`, `op_var`, `picture_far.s`). Branches `aguara-comandos-sueltos`
in the-advocate, the ports and the book.
