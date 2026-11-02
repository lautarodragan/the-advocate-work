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
