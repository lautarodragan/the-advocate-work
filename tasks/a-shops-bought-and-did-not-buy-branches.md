---
name: "A shop's bought and did-not-buy branches"
description: "OpenShop with its 'bought' / 'did not buy' branches does not compile, so Zounds' cafeteria on the Hover Tram has no shopkeeper"
type: feature
status: testing
assignee: taro
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

## Log

* **The compiler and the runtime**, the-advocate 3c4bbcbb: `OP_IF_TRADED`
  (0x53), `shop_traded` in far RAM, `if_traded` in `FAR3`, a 7-byte stub
  in bank 0. Six tests in `rm2k-snes-events`; five go red with the old
  `q(2) != 0` refusal put back (the sixth guards that a shop without
  branches is unchanged).
* **The ROM test**, in ABL: case `shop-branches` —the same shop twice in
  a row, each block writing a variable— and
  `tests/rpgmaker/test_shop_branches.py`: leave twice, buy in the first,
  sell in the second. Red before: with the global tools `just cartridges
  release` fails, "the test page doesn't compile".
* **The ROM test green**, the-advocate-ports 5472bbd: 3 passed. What
  bit on the way: the shop freezes the game clock, so the harness's
  `sess.run` —which waits for ticks— never returns while a shop is open;
  the test waits in frames, and the case has a `Wait` before each shop
  so the session's start, and the test's look at the first shop
  closing, end before the next one opens.
* **Zounds' cafeteria compiles**: `just culprits` in zounds with these
  tools no longer lists map 21; with the global ones its event 7 pages 1
  to 3 were culprits with `OpenShop`, `Transaction`, `NoTransaction`,
  `EndShop`.
* ABL's whole suite with these tools, before merging main: 1613 passed, 2
  skipped. `just space` in abl: `release` bank 0 320 B (327 before: the
  7-byte stub), `test-msu` bank 1 844 B (856: the 12 bytes of the flag in
  the shop screen).
* `just test` in the-advocate: 29 passed. `just boot` at the root of the
  ports with these tools: 129 passed. `just space` in every game: all
  link; Sunset `release` bank 0 237 B, Vampires Dawn bank 1 821 B, the
  tightest.
* Main merged into the ports branch (1cad9a1: only Zounds' map 96 dump,
  nothing ABL builds); the-advocate's main had not moved. `abl.sfc` of
  `release` with these tools: sha256 `8487c243c59057df…`.

## Done

The cook of Zounds' cafeteria opens his shop, and after it the page goes
on through `Transaction` if something was bought or sold and through
`NoTransaction` if not; map 21's three pages compile.

**What has to be installed when merging**: `just install cartridge convert
events` from the-advocate —the bytecode declaration changed, so
`rm2k-snes-assemble` has to write the new `event_opcodes.inc`, and the
compiler is in `convert` and in `rm2k-snes-events`—.

**What no test covers**: Zounds' cafeteria itself on a ROM —it is checked
by `just culprits`, which says the pages compile, not played—; and a
`NoTransaction` with no `Transaction` above, or a shop inside a shop's
branch, are covered only by the crate's tests: no game has them.

**For taro to look at**: Zounds' Hover Tram cafeteria (map 21): talk to
the cook, buy something or leave without buying; after buying, switch 32
is turned on, which is what the game's pages do next.
