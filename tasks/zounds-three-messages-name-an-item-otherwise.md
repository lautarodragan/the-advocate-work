---
name: "Zounds: three messages name an item otherwise"
description: "The steal message says Grasa de Camello for the item Grasa de Camaro, the chef's menu Puré con Papas for Puré de Papas, the fishing score Kinshi for the fish Kinsh"
type: bug
status: testing
assignee: taro
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

## taro's decision (2026-10-20)

In their words, translated:

> In Zounds: it's `Grasa de Camaro`. I think it should always be the
> item's name, and not the message's.

The messages take the database's names: Grasa de Camaro, Puré de Papas,
Kinsh.

## Fixed (Calandria, 2026-10-20)

In `~/juegos/zounds`, branch `calandria-codes`, the commit after the
control codes', written with `ditto read`/`write`, round trip checked
the same way:

* common event 58: `Grasa de Camello` → `Grasa de Camaro`, in both of
  its copies of the message. Its comment `Camaro = 5 (Es la Camello del
  Desierto)` is the author's note, never shown: left as it is.
* map 130, event 4: `$DPuré con Papas` → `$DPuré de Papas`.
* maps 186 and 187: `Kinshi: \v[176]` → `Kinsh: \v[176]`.

No line grows. Nothing else in the game, nor in the ports' tests,
patches or `advocate.toml`, says Camello, Puré con Papas or Kinshi.

The ports, the book and what was run: in
[`zounds-three-messages-with-broken-control-codes`](zounds-three-messages-with-broken-control-codes.md),
which went with this one.
