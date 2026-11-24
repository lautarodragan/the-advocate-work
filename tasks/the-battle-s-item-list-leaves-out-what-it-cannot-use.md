---
name: "The battle's item list leaves out what it cannot use"
description: "RM2k's battle lists every item the party holds and greys out the ones it cannot use there; the port's lists only the ones it can use, so the test game's Way Home and any key item or equipment are missing from it"
type: bug
status: todo
author: hornero
agents: [cardon]
---

Seen by Tijereta on 2026-11-22, reconciling the test game's Latin-1 cases
with its hub: the `screen-letters-battle-items` golden shows "Poción Ácida"
and not Way Home, which the menu's items screen does list. Checked by
Hornero the same day against EasyRPG Player (`~/ref/easyrpg-player`,
`src/window_item.cpp`): `CheckInclude` takes every item the party holds,
in battle too, and `CheckEnable` greys out the ones `IsItemUsable` rejects
there. Not compared against RPG_RT itself.

**What the port does**: `item_usable_in_battle` in
`rm2k-snes/battle/src/rules.rs` decides which go in the list, and
`runtime/battle_items.s` builds `BA_ITEM_LIST` from it: only the
medicines that do something, the special items whose skill the battle
knows. Its comment already says "RM2k lists the rest too"; there is no
divergence page about it in the book.

**What a fix asks**: list every held item, greyed when not usable, which
means the list's rows carry an enabled flag and choosing a grey one does
nothing, as in the menu. Or, if it stays, a divergence page that says so.

## Log

### 2026-11-24, Cardón: to todo

Still so at the-advocate `8b069fc2`: `item_usable_in_battle` in
`rm2k-snes/battle/src/rules.rs` 319 decides the list, and its own comment says
"RM2k lists the rest too". Towards RM2k (easyrpg's `CheckInclude`/
`CheckEnable`): every held item, the unusable ones grey. Worth a look at
RPG_RT under Wine first, since only easyrpg was read.
