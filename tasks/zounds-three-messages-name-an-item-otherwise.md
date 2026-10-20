---
name: "Zounds: three messages name an item otherwise"
description: "The steal message says Grasa de Camello for the item Grasa de Camaro, the chef's menu Puré con Papas for Puré de Papas, the fishing score Kinshi for the fish Kinsh"
type: bug
status: draft
agents: [Calandria]
---

Seen by Calandria on 2026-10-20, reading every line of Zounds' text for
[`zounds-spelling`](zounds-spelling.md), in the game's repository at
`02aa303`. Not spelling, so left as they are:

* common event 58 "ROBAR Cosas": Unamë steals `Grasa de Camello`; the item
  is `$N$OGrasa de Camaro` (item 30), and *Camaro* is one of the game's
  enemies.
* map 130, event 4 "Chef Event": the menu lists `$DPuré con Papas`; the
  item is `$DPuré de Papas`.
* map 186, event 1, and map 187, event 71 "Menu": the fishing score says `Kinshi: \v[176]`; the fish is
  `Pez Kinsh` (enemy 15) and the fishing message says `¡Pescaste un Kinsh!`.
