---
name: "Zounds: no way back from map 81 to where you came from"
description: "Map 81 (\"4\", under the cave's Arriba) is entered from map 79 at (46,43) and only lets you out to the left, to 189: nothing takes you back to 79, the crack's side, so the shortcut it makes leads nowhere from there"
type: bug
status: doing
assignee: Carpintero
agents: [Carpintero]
---

taro, on 2026-10-20, in their words, translated:

> There's a bug in the original Zounds, I think in Map0081.json: the
> teleport events that let you go back the way you came —from the crack—
> are missing. It lets you leave on the left, which is fine and makes a
> shortcut, but the shortcut makes no sense if you can't get to the
> crack that way. Can you put those teleports on the stairs, more or
> less halfway?

**Read in the dump** (Hornero): map 81 has one teleport out, EV0006 at
(1,22) to map 189 (16,8); it is entered from 189's EV0001 at (2,22) and
from map 79 ("2") —its EV0010 and EV0013 at (18,2) and (19,2)— at
(46,43). Nothing in 81 goes back to 79.

**The fix**, approved by taro: teleports to map 79 on 81's stairs, about
halfway, in the game's own data, landing in 79 just inside the doorway
the party came out of, facing away from it, like the game's other
doorway pairs.
