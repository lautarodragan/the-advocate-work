---
name: "ChangeExp and ChangeLevel"
description: "The compiler has neither ChangeExp nor ChangeLevel, and a page with a command that doesn't compile drops entirely: the debug map's doors can't give experience"
type: feature
status: done
agents: [Hurón, Carpintero]
assignee: taro
---

Hurón found it on 2026-10-04, while adding the doors of Paradise and of
after Fortitude (`workflow/tasks/*/dos-puertas-mas-en-el-mapa-de-debug.md`,
in ABL). With the two commands, each door could set the levels that
someone who played would have: after Fortitude, Talan 3, Arden 4, Saldra 5,
AG7-17 6; in Paradise, Talan 7, Arden and Saldra 7, AG7-17 8. Check whether the
game itself uses them anywhere.

## Carpintero, 2026-10-04

**The game doesn't use them.** No `ChangeExp` (10410) or `ChangeLevel`
(10420) in the maps, the common events or the troops of the dump: only
doors 7 and 8 of the debug map will use them.

**How it ends up.** The two commands share an opcode, `OP_EXP` (0x42):
the actor —0 the party—, what it does —level or experience, subtract, by
variable, with message— and the amount. In the ROM it's `exp_change`, in
`level.s`: `Game_Actor`'s `ChangeExp` and `ChangeLevel`, with the
skills taught by the levels it went through and the `SetLevel` that clips
HP and SP to the new level's maximum.

**The message is the other opcode, `OP_LEVEL_PAGE` (0x44)**, which the
compiler puts right behind when the command asks for it. `OP_EXP` notes down
the lines —the one for the level of each one who leveled up and the one for each skill
they didn't know— and `OP_LEVEL_PAGE` builds one box at a time in RAM, with
four lines or up to the end of an actor, which is RM2k's `PushPageEnd`,
and opens it with the usual window; it stays on itself until
none are left.

**The RAM**: $7E7A50 to $7E7AFF (`LVL`, what `exp_change` works on and the
noted lines) and $7E6128 to $7E61FF (`LVL_BOX`, the page). No
`release` symbol falls there.

**The model** is `Standing::change_exp` and `change_level` in `rm2k-rules`, and
`rm2k-snes-battle experience` answers it for the tests.

**What isn't the same as RM2k** is in
`divergences/what-changeexp-and-changelevel-do-not-model.md`: the
order of two skills of the same level, no message in a troop
page, and the line caps.

## In ABL

Branch `carpintero-changeexp` of Carpintero's clone
(`/extras/scratch/Carpintero/abl`):

* `pruebas/rpgmaker/test_experiencia_de_eventos.py` and four cases: level,
  experience, skills and HP against the model, each page of the message
  read from `LVL_BOX`, and a page against the same text in a
  `ShowMessage`. With `main`'s tools, the cases don't compile.
* Doors 7 and 8 of `parches/manual/nuevos/Map0900.json`: Talan and the
  branch's companion at the levels Hurón measured, with a `ChangeLevel`
  of -49 and another that raises; Arden's `ChangeSkills` that stood in for leveling
  up are gone. `test_mapa_de_debug.py` checks it on both doors, per branch.

**A trap that showed up**: a case with `ChangePartyMembers` changes for the
converter who can lead in all maps (`page_party` in
`convert.rs`), and with that the palettes: the mechanic of 20 and the tram came out
with other colors. The party case sets the party from the test.

## On merging

Reinstall in the global `cartridge events convert battle`: the runtime and the
bytecode, the compiler, and the `experience` subcommand the
tests ask for. `rules` changed only by adding, so `rm2k-render` and `mapdata`,
which compile it in, don't change behavior.

Suite: 1098 green with the branch's tools, on both trees
merged with `main`. No new or moved goldens.
