---
name: "Zounds: three messages with broken control codes"
description: "A colour code missing its letter, a \\v[20] where the game's slow text is \\s[20], and a stray backslash: the game's own data, seen while fixing its spelling"
type: bug
status: testing
assignee: taro
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

## Fixed (Calandria, 2026-10-20)

Hornero, on taro's behalf: fix the three in the game's data as the
author evidently meant them. In `~/juegos/zounds`, branch
`calandria-codes` from master at `75dc0e6`, one commit for the three
maps, written with `ditto read`/`write` —each map round-tripped byte for
byte before editing, and read back equal to the JSON written—. How each
was decided:

* **map 139**: `\c[6]Trabajo\[4]` → `\c[6]Trabajo\c[4]`. The same
  farmer's other page asks the same question with the same title,
  `\c[6]Trabajo\c[4]`; the `c` was lost.
* **map 161**: `\v[20]Jo-jo-jo-jo-jo....` →
  `\s[20]Jo-jo-jo-jo-jo....`. Variable 20 is a level the game shows
  elsewhere as `Nivel: \v[20]`, nothing to do with Madamme Lessier; the
  game's eleven other lines that open with a `[20]` code all open with
  `\s[20]`, and slow a laugh, a scream or a silence
  (`\s[20]Jajajajajajajajajajaja\^`, `\s[20]¡Vas-a-morir!`,
  `\s[20]Mmmmm.....`, `\s[20]................`).
* **map 24**: `¿No nos vas a pagar?\` → `¿No nos vas a pagar?\|`. The
  game's only pause code is `\|` —669 of them, no `\.` at all—, 384 of
  them closing a line before the box's next one, as the line above this
  one does (`Erm...\|`); the next line is `¿Millones?`, so the pause
  before it fits. The bar was lost.

Not run in RPG_RT nor looked at on the console: the console does not yet
interpret `\c[n]` or `\s[n]` (Tijereta is on it), and the change is three
strings.

## Both tasks: the ports, the book, what was run

The two tasks went together, one commit each in the game; the rest is
shared with
[`zounds-three-messages-name-an-item-otherwise`](zounds-three-messages-name-an-item-otherwise.md).

**The ports**: `calandria-codes`, the new `zounds/data/` dumped from the
game's branch —eight string values in seven files, nothing else—. No
test, case, patch or `advocate.toml` quotes a line that changed.

**The book**: two bullets in the Zounds page's "What is fixed in the
game itself", branch `calandria-codes`.

**Run**: `GAMES=<dir of the game's worktree> just boot -k zounds` in the
ports' branch: 29 passed. Not looked at in RPG_RT nor on the console.

**When merging**: nothing to install. The game's `calandria-codes` goes
to its master (taro's repo), the ports' and the book's to their `main`.
