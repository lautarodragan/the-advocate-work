---
name: "Zounds' mining and the jail's guards do not compile"
description: "Loops that only end with a BreakLoop, Control Variables taking a modulo or a quotient by a constant past the word, and the branch on the event started by the action key keep Zounds' mining, smelting and its levels, and the jail's guards, out of the cartridge"
type: bug
status: testing
assignee: taro
agents: [Calandria]
---

taro, on 2026-11-01, in their words, translated, after Hornero listed
what keeps Zounds' pages out:

> Let's go with the Zounds stuff, including the bought / did not buy
> branches for the cafeteria and Unamë's rescue

The cafeteria's shop is
[`a-shops-bought-and-did-not-buy-branches`](a-shops-bought-and-did-not-buy-branches.md),
Carpintero's. This one is the rest, measured by Hornero with
`just culprits` in `zounds/` at the-advocate 0ba09da4:

* **A loop with no wait in its body does not compile** (`loop_waits` in
  `rm2k-snes/events/src/compile.rs`), even when it ends with a
  `BreakLoop` on a condition: map 134 event 46 (the boss's young man who
  pays the mining, Misërenia's north cave), map 57 event 125 (the
  merchant's autostart scene in the mining place), map 133 event 6 (the
  smelting oven), common events 51, 52 and 54 (mining, thief and smithing
  next level's EXP). They count items or variables down and break.
* **`ControlVars` modulo / divide by a constant past 0x7FFF does not
  compile**: common event 26 (mining EXP and level, `mod 100000`), 62 and
  63 (money and coins split in digits, called from map 168). For a 16-bit
  variable a modulo by a constant past the word is the identity and a
  quotient is 0, so it can compile exactly.
* **`ConditionalBranch` type 8, the event started by the action key**:
  the guards' parallel pages on maps 145, 147, 148 and 149 (Unamë's
  rescue, the jail). Without them the guards never catch the player.

**Done**: the three compile with what RPG_RT does (easyrpg's
`CommandConditionalBranch` case 8, `triggered_by_decision_key`), Zounds'
culprits list loses those pages, and a loop that never breaks and never
waits still does not compile. Tests in the events crate, and a ROM test
for what the runtime changes.

## Calandria's work

Branches `calandria-zounds-mining` in the-advocate (from 0ba09da4) and the
ports (from 31fb291). Only the events compiler changes; the runtime does
not, so no opcode was taken —`0x52` stays free—.

* **Loops**: `loop_ends` next to `loop_waits`. A loop compiles if it waits
  or if its body has a way out: a `BreakLoop` that lands past its own
  `EndLoop` (one inside an inner loop ends only that one) or a
  `JumpToLabel` to a label outside it. `EndEventProcessing` would be one
  too, but the command does not compile on its own, so it is left out
  rather than carrying an untested path. A loop with neither still does
  not compile.
* **ControlVars**: modulo by a constant past the word is an add of 0
  (identity, and it still refreshes), a quotient is a set to 0; RPG_RT's
  `/` and `%` are C's (easyrpg `VarDiv`, `VarMod`), which truncate toward
  zero and give the remainder the dividend's sign. 32768 itself: modulo is
  by -32768 (same remainder for every word), divide does not compile
  (-32768 / 32768 is -1).
* **ConditionalBranch 8**: answered when compiling, no opcode. easyrpg sets
  `triggered_by_decision_key` only for frames pushed as `Action`, which an
  action page always is and a parallel or automatic page, a common event
  or a called body never is. Touch and collision pages start either way,
  so there it still does not compile; troop pages too (RPG_RT says yes,
  but their calls are pasted flat). It is a new `Ctx::decision_key`, set
  from the page's trigger where map pages are compiled and to no for
  common events and pasted calls. Every port's data was searched: only
  Zounds asks it, seven times, all on parallel pages, where it is always
  no —the guards' `ShowAnimation` on the action key never ran in RPG_RT
  either—.

`just culprits` in `zounds/` with the branch's events compiler: commons
62 → 68 of 69 compile, maps 3995 → 4005 of 4014; every page this task
listed leaves the list. Map 156 event 26 now stops at an `InputNumber`
of one digit into variable 98, which the loop was hiding.

**On the ROM**: two tests in the ports' `tests/test_zounds.py`,
`test_the_jail_guard_catches_the_player` (map 145, switch 250 on, the
player west of the guard: the guard's box, the jump to map 144 and the
switch off) and `test_the_mining_is_paid` (map 134, switch 283 on, three
asked and mined, two Querril and two Sonifal held: he takes both Querril
and one Sonifal, pays 50 and turns the switch off). Both red on the
cartridge built with the global tools (0ba09da4), green with the branch's.
What it took to write them, so the next one does not measure it again:
from the boot, map 7's parallel scene is still walking the hero when the
player gets control, and a `go_to_map` takes the walk along —the hero
drifts north on the map it lands on—, so both start past map 8's talk, as
`test_from_the_cave_to_arriba_5_and_back` does; and map 134's slimes walk
into a hero that stands still and start a battle, so their switches 319
to 321 send them away.

**The book**: the loop divergence (`a-loop-that-never-waits-does-not-compile`,
now titled "nor ends"), the 16-bit variables one and the ConditionalBranch
decision, and a Known issues line for the dice man.

**Draft**: [`an-input-number-after-a-label-has-no-message`](an-input-number-after-a-label-has-no-message.md),
map 156's dice man, which the loop was hiding.

**Run, with the branch's `events` installed locally**: `just test` (29
passed) and `just crate-test events` (184 passed) in the-advocate; ABL's
`just tests`, 1610 passed, 2 skipped, `abl.sfc` sha256
`de98298a26284577e188b3ee472dbbc8d6ee0a62c2a820b84df018668fd18258`; `just
boot` from the ports root, 131 passed; `just space` on every game: the
runtime did not change, and bank 0 and 1 are what they were (Sunset 244 B,
ABL release 327 B, test-msu bank 1 856 B; the tightest bank 1 is Vampires
Dawn's, 833 B). No golden moved.

**When merging**: reinstall only `events` (`just install events` in
the-advocate). No opcode taken: `0x52` stays `OP_RESERVED_52`.

**What no test covers**: the guards of maps 147, 148 and 149 (same pattern
as 145's, checked only by the culprits list); the smelting oven (map 133),
the mining merchant's scene (map 57) and the level-up common events 51,
52, 54, 26, 62 and 63 run on no ROM test, only compile; a jump to a label
out of a loop is covered by the crate test alone.
