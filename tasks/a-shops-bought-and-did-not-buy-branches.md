---
name: "A shop's bought and did-not-buy branches"
description: "OpenShop with its 'bought' / 'did not buy' branches does not compile, so Zounds' cafeteria on the Hover Tram has no shopkeeper"
type: feature
status: doing
assignee: Carpintero
agents: [Carpintero]
---

taro, on 2026-11-01, in their words, translated:

> Let's go with the Zounds stuff, including the bought / did not buy
> branches for the cafeteria and Unamë's rescue

`OPEN_SHOP` in `rm2k-snes/events/src/compile.rs` (the-advocate) refuses
the shop when its third parameter asks for the branches: "none of the
game's 43 shops uses them" was ABL. Zounds' map 21 (Hover Tram / Piso 1 /
Cafetería) event 7, pages 1 to 3, uses them: `OpenShop`, `Transaction`,
`NoTransaction`, `EndShop`.

**Done**: the shop opens and, after it closes, the page goes on through
the "bought" branch if something was bought or sold, the other one if
not, as RPG_RT (easyrpg's `CommandOpenShop` and `CommandTransaction` /
`CommandNoTransaction`); map 21's three pages compile. Tests in the events
crate and a ROM test.

## Plan (Carpintero, 2026-11-01)

Branches `carpintero-shop-branches` in the-advocate (from 0ba09da4) and
the-advocate-ports (from 31fb291).

RPG_RT's shape, read in easyrpg (`Game_Interpreter_Map::CommandOpenShop`):
after the shop, the sub-index of the shop's indentation is "transaction" if
`Scene_Shop` bought or sold anything —`did_transaction`, set by every
confirmed deal— and "no transaction" if not; `Transaction` and
`NoTransaction` run or skip their body by it, like a choice's options.
`parameters[2]` is not looked at.

How here: a new opcode, `OP_IF_TRADED = 0x53 (destination: word)`, which
goes to `destination` if the last shop closed without a deal and on
otherwise. The shop screen clears a far-RAM byte when it opens and sets it
in `ti_close_deal`. The compiler builds the block the way it builds a
branch with `else`: `Transaction` is the `OP_IF_TRADED`, `NoTransaction`
an `OP_GOTO` to the end, `EndShop` patches them.

Why not the alternatives the assignment preferred:

* **Extending `OP_SHOP`** with the destination would put two bytes in every
  shop, branches or not, and the bank-0 handler would have to read them
  past the list.
* **A new kind of `OP_IF`** costs 11 bytes of bank 0 in `op_if`'s
  dispatch, against 7 of a `jsl`/`jmp` stub, and lands in the same lines
  Calandria is touching for `ConditionalBranch` type 8.
