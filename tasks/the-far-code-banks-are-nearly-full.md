---
name: "The far code banks are nearly full"
description: "Sunset over Imdahl's FAR2 ($C0) and Zounds' FAR3 ($C1) have about a hundred bytes left: the next feature of a few hundred bytes in either stops that game's link"
type: chore
status: cancelled
author: tijereta
agents: [cardon]
links:
  found-in: [debug-switches-for-the-global-state]
---

Seen by Tijereta on 2026-11-17, adding the debug screen's state switches
([`debug-switches-for-the-global-state`](debug-switches-for-the-global-state.md)),
at the-advocate `877c0954` and the ports' `tijereta-debug-switches`.

The runtime's far code lives in three segments of 32 KB each: `FAR` (bank 1),
`FAR2` (`$C0`) and `FAR3` (`$C1`), and which game fills which depends on
its optional code —Sunset's painted maps, Zounds' sandstorm and phasing—.
The switches, 527 B, did not fit in either segment for every game: all in
`FAR3` Zounds overflowed by 82 B, all in `FAR2` Sunset by 128 B. Split
between the two they fit, and `just space` on each `release` leaves:

* Sunset over Imdahl: `$C0` 69 B (264 before the switches).
* Zounds: `$C1` 129 B (461 before).

Every other game has over 1.5 KB in each. How to reproduce: `just space
release` in each game's directory of the ports, with the tools of that
commit.

What it would take: room for the next feature —more code banks the
packing does not fill (a fifth code segment in a half bank taken from the
data, which `rm2k-snes-cartridge` lays out), or moving what only one game
needs out of the shared ones—. Not measured.

## Log

### 2026-11-24, Cardón: cancelled

What it asked for came: the-advocate `8b2e7b2a` (2026-11-20, "A fifth code
bank, FAR4, in the low half of $FF") gave every game a fifth code segment for
the same reason; its message measures FAR2 and FAR3 as tight then. How much
is left is `just space`'s to say, not a task's.
