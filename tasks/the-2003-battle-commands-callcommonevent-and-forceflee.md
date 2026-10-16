---
name: "The 2003 battle commands: CallCommonEvent and ForceFlee"
description: "The only RM2k3-only commands Zounds uses, both in troop pages: CallCommonEvent (19, the steal mechanic) is a call to a common body, which the compiler already does on maps; ForceFlee (36, the custom Escape command) ends the battle as an escape that cannot fail"
type: feature
status: testing
assignee: taro
agents: [Aguará]
---

Seen by Aguará on 2026-10-15, in the study
[`port-zounds-an-rpg-maker-2003-game`](port-zounds-an-rpg-maker-2003-game.md),
with the-advocate `91d55d39`.

**CallCommonEvent (1005)**: 19 troop pages, 18 of them conditioned on
switch 3 "Robar" —turned on by the switch skill `$fRobar`— that call
common event 2 "Robar - Battle Acion" (44 commands: messages, `ChangeSP`,
`ControlVars`, branches, two `CallEvent`s to other common events); one
calls common event 65. EasyRPG runs it as a call
(`Game_Interpreter_Battle::CommandCallCommonEvent`). The compiler
compiles a map's `CallEvent` to a common event as a call to its shared
body; in a troop page the body has to be compiled with the battle's list
(`TROOP_COMMANDS` in `rm2k-snes/events/src/troops.rs`), which has
everything that body uses except `CallEvent` itself and `Comment`.

**ForceFlee (1006)**: 36 troop pages, every one conditioned on actor 1 or
4 using the custom command "Escapar" (type `special`), all with
parameters `[0, 0, 1]`: the party flees, unconditionally. In a 2000
battle the Escape command does this with RM2k's chance of failing; the
command events that triggered these pages do not exist in 2000, so the
pages would never run and the stand-in is the built-in Escape. What is
lost is that Zounds' escape never failed.

## Aguará, on 2026-10-15: done

the-advocate `3ff55d6d`, on the branch `aguara-zounds-2003`, over the Ditto
commits that read the flags right.

* `CallCommonEvent`, and a `CallEvent` to a common event, in a troop page:
  `expand_calls` in `rm2k-snes/events/src/troops.rs` pastes the callee in
  the call's place before `TROOP_COMMANDS` is asked —nested calls too, at
  the call's indent—, and a callee with a command the battle cannot run is
  skipped with a `call-skipped` loss, as on a map. `culprits` pastes the
  same way. `ChangeSP` joins the list, like `ChangeHP`, through the sync.
* `ForceFlee` for the party is `OP_BATTLE_FLEE`, 0x51 (the number Hornero
  handed out; 0x52 and 0x53 stay reserved): `op_battle_flee` raises the
  flag of `TerminateBattle` with another value and `ba_page_step` ends the
  battle as an escape, with the fled message and sound. For an enemy there
  is no stand-in and `runs_in_battle` keeps it out.
* A page conditioned on a 2003 condition together with a 2000 one never
  runs: `trigger` leaves it out instead of running it on the switch alone.

The ROM of a 2000 game changes only by the runtime —ABL's `mapdata.inc`
and `musicdata.inc` byte for byte the same before and after; bank 0 loses
18 bytes, bank 1 none—. In Zounds the 36 `ForceFlee` pages sit on its own
Escape command, which this battle has no event for, so none of them runs
here: the opcode is for a 2003 game whose `ForceFlee` sits on a turn or a
switch. What the suite does not cover: nobody plays a troop page with
`ForceFlee` in an emulator yet —no 2000 game has one and Zounds' never
trigger—; the opcode's path in `ba_page_step` is read, not run.

**To install when merging**: `just install events convert cartridge
rm2k-snes-audio ditto` (the whole branch's). In Zounds, after it: troop
pages that compile 19 of 105 —one more than before: the one on a turn that
calls common event 65—; the 18 steal pages are kept out by the callee's
boxes, whose `¡`, `á` and `ë` the font lacks (Mulita's draft
`latin-1-letters-stop-a-box`), and not by the call: `culprits` names the
pasted command now.
