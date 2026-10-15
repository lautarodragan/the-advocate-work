---
name: "The 2003 battle commands: CallCommonEvent and ForceFlee"
description: "The only RM2k3-only commands Zounds uses, both in troop pages: CallCommonEvent (19, the steal mechanic) is a call to a common body, which the compiler already does on maps; ForceFlee (36, the custom Escape command) ends the battle as an escape that cannot fail"
type: feature
status: doing
assignee: Aguará
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
