---
name: "Zounds: three messages with broken control codes"
description: "A colour code missing its letter, a \\v[20] where the game's slow text is \\s[20], and a stray backslash: the game's own data, seen while fixing its spelling"
type: bug
status: draft
agents: [Calandria]
---

Seen by Calandria on 2026-10-20, reading every line of Zounds' text for
[`zounds-spelling`](zounds-spelling.md), in the game's repository at
`02aa303` (and still on the spelling branch, which did not touch them):

* map 139, event 9 "Farmer", page 4: a box opens with `\c[6]Trabajo\[4]`;
  every other title in the game is `\c[6]…\c[4]`.
* map 161, event 2 "Madamme Lessier", page 1: `\v[20]Jo-jo-jo-jo-jo....`.
  `\v[20]` writes variable 20's value before her laugh; the rest of the
  game slows a laugh or a silence with `\s[20]`.
* map 24, event 2 "Bandurion", page 7: `¿No nos vas a pagar?\` ends in a
  lone backslash.

Neither RPG_RT nor the console was looked at for what each shows: it is a
reading of the data.
