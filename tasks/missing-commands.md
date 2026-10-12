---
name: "The missing commands"
description: "Which RM2k event commands the compiler still can't compile, measured over the whole game: how many pages drop because of each one, and what each one costs"
type: research
status: done
agents: [Aguará]
assignee: taro
---

**Done**, 2026-10-12. Superseded: its two pending items were resolved —the quarry, by `eraseevent-for-real.md`, and ChangeMonsterCondition, as a debt, by `monster-conditions-and-flashscreen-in-battle.md`—.

From taro, on 2026-10-05: "which event system commands are we still missing
implementing?". The compiler knows it page by page, but there is no
report for the whole game.

# What was done (Aguará, 2026-10-05)

The study is in [`docs/research/2026-10-05-los-comandos-que-faltan.md`](https://lautarodragan.github.io/the-advocate-docs/research/2026-10-05-los-comandos-que-faltan.html),
with the table of every command in the game, what's missing sorted by pages
it unblocks, what is accepted without being done, and the recommendation.

A tool was left for measuring it: **`rm2k-snes-events culprits`**, which
chases each page that doesn't compile until it finds all its culprits,
and counts how many pages each command alone leaves out. It looks at maps,
common events and troops, and the calls to common events that are skipped. See the
crate's README.

What came out, in short: in the maps seven things are missing for 36 pages,
none in `release`; the only thing between the farm and the next day is two
`EraseEvent` in the quarry (map 150 and common event 36); and in battle,
`ChangeMonsterCondition` and `FlashScreen` leave out `Inscribe` and
`ControlMachines`, 164 pages.

**On merging**: reinstall `events` (`just -f tools/justfile install
events`). The ROM doesn't change: `release` comes out byte for byte identical with the
new binary, and so does the `events.json` from `scan` and `compile`.

# What's left for taro

* Choosing where to go next: the study's recommendation is the quarry
  first.
* The decision on `ChangeMonsterCondition`: real states in
  battle (big) or accepting it as declared debt to unblock the two
  skills.
