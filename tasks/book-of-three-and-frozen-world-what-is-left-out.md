---
name: "Book of Three and Frozen World: what is left out, and why"
description: "Both already carry every map; their culprits report still leaves pages and common events out. Which, by which variant of each command, and what fixing each would take"
type: research
status: testing
assignee: taro
agents: [Calandria]
---

taro, on 2026-10-14: "can you do the same for Book of Three and The Frozen
World?" —the same as for ABL: what is left out and what the compiler
ignores silently—.

Measured by Hornero on the-advocate `14e200fc`, ports `f775b66`: both
`release`s already carry every map (Frozen World excludes 1 and 2, each
with its reason in its `rm2k-snes.toml`). `just culprits`:

* **Book of Three**: maps 1273 of 1282 pages; commons 20 of 25 (left out
  9, 13; parallel 18, 21 do not compile); troops 497 of 746 (95 with a
  trigger the ROM cannot look at). Culprits: ControlVars, ShowChoice,
  ConditionalBranch in commons; ChangeItems, MoveEvent, ControlVars in
  maps; ControlVars, ChangeItems, ShowBattleAnimationB, ChangeMonsterHP in
  troops.
* **Frozen World**: maps 3823 of 3891 (1 stops at the page as a whole);
  commons 89 of 100 (left out 15, 31); troops 0 of 80 (all with a trigger
  the ROM cannot look at). Culprits: ShowMessage (494 culprits in maps,
  668 in commons), ConditionalBranch, ChangeMapTileset, ShowChoice,
  ChangeActorFace, InputNumber, ControlVars.

The silent holes of the compiler for both games are counted in the
research `research/2026-10-14-what-the-compiler-ignores-silently.md`.

## Log

### Calandria, 2026-10-14

Research: [The Book of Three and The Frozen World: what is left
out](https://lautarodragan.github.io/the-advocate-docs/progress/book-of-three-and-frozen-world.html)
(the-advocate `14e200fc`, ports `f775b66`). Measurement only: nothing in the
tools or the games was changed; the only builds run were two throwaway ones
with map 1 and map 2 of Frozen World brought back, in a worktree of the ports.

* **Frozen World's combat is on maps 1 and 2** (no `EnemyEncounter` in the
  game; its 80 troop pages are empty). Both exclusions still hold with the
  same message. 324 pages on 72 maps teleport into them and are left out, plus
  the common events only they call; that is what "the game" loses, and what
  its drafts said was "not looked at".
* **Found while measuring, a bug**: `ControlSwitches` past switch 1,023 is not
  refused and writes past the 128-byte switch table (Frozen World 78 commands,
  Vampires Dawn 1,014). The existing page-conditions draft said the compiler
  refuses them; corrected there.
* **Book of Three**: the scripted endings of two fights (the Cauldron-Born at
  map 26, the Horned King with Dyrnwyn at map 78) use
  `ShowBattleAnimationB`, which troop pages do not accept: probably two fights
  that cannot end (not played). Its party's special commands are a page each in
  52 troops and do nothing; the chests' random loot is 82 skipped calls.
* **The "trigger the ROM cannot look at"** (95 and 80 pages) is an empty
  default page: nothing is lost.
* **Silent holes for these two games**: only the elemental attributes weigh,
  and only in the Book of Three (66 of 80 enemies); the save and escape flags,
  `overlap_forbidden` and the first strike are all nil.
* Drafts, one per cause: `controlvars-random-ranges-wider-than-255`,
  `controlvars-multiply-and-divide`, `controlvars-from-an-item-count`,
  `changeitems-and-changemonsterhp-by-a-variable`,
  `show-battle-animation-b-in-troop-pages`,
  `a-choice-with-more-than-four-options`,
  `variables-in-a-choice-option-and-before-an-input-number`,
  `a-literal-backslash-in-messages`,
  `branches-and-switch-commands-past-switch-1023`,
  `changemaptileset-is-not-compiled`, `changeactorface-is-not-compiled`,
  `culprits-counts-empty-troop-pages-as-a-bad-trigger`. Notes added to the
  drafts for map 1, map 2, page conditions past 1,023 and Reraise/Eilonwy.
* "Known issues" lines in both games' pages of the book.
* **Not checked**: anything played; why the 1,801-command `CombatController`
  page stops "as a whole" (a guess: 16-bit offsets); what comes after the
  flash stop on map 1.
