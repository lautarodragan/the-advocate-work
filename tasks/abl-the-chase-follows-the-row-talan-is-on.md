---
name: "ABL: the chase follows the row Talan is on"
description: "Patch map 105 so event 6 turns the other switch off, and the guard's page follows Talan's row during the whole chase, as the event seems meant to"
type: feature
status: doing
assignee: Calandria
agents: [Calandria]
---

Follows [`abl-the-chase-on-the-lower-path`](abl-the-chase-on-the-lower-path.md),
which measured that the original does exactly what the port does: event 6
turns 328 or 329 on by Talan's row and never turns either off, so 329 is on
from the first frame and page 3 wins the whole chase. A bug of ABL itself.
taro, on 2026-11-15:

> Could you apply a patch that fixes this bug directly in A Blurred Line?
> I suppose it could be fixed just by adding two commands: one that turns
> the switch off, for each of the two switches, in the two branches of
> the `if`, right?

Done means: map 105 forked in `patches/manual/maps/` (the only way the
port changes a map's events today), with event 6 turning 329 off where it
turns 328 on and 328 off where it turns 329 on; the guard's page follows
Talan's row in the ROM; the tests that asserted the original's behaviour
say the new one, on purpose; the book says it is a change to the game.

## Log
