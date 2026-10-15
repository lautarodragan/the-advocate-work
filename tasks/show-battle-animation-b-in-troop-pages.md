---
name: "ShowBattleAnimationB in troop pages"
description: "The battle animation on a monster is not in the troop pages' command list: it keeps out Taran's Last Stand in 52 troops and the two scripted endings of The Book of Three (the Cauldron-Born at map 26, the Horned King with Dyrnwyn at map 78), which may leave those fights without an end"
type: feature
status: testing
assignee: taro
agents: [Tijereta]
---

Seen by Calandria on 2026-10-14, with the-advocate `14e200fc` and the ports
`f775b66`, measuring what The Book of Three leaves out
([research](https://lautarodragan.github.io/the-advocate-docs/progress/book-of-three-and-frozen-world.html)).
**Read in the data, not played.**

**What is seen**: `ShowBattleAnimationB` (13260) is not in `TROOP_COMMANDS`
(`rm2k-snes/events/src/troops.rs`), so any troop page with one is left out.
Book of Three has 56 uses, no other game any:

* 52: the Last Stand page of troops 83 to 135 (with
  [`changeitems-and-changemonsterhp-by-a-variable`](changeitems-and-changemonsterhp-by-a-variable.md));
* 3 in troop 96, **three Cauldron-Born** (map 26, event 10, a fixed fight):
  page 11, at turn 6, is Gwydion's "Summon... BLAZING STAR!" (animations 128,
  129, 130) and ends the battle with `TerminateBattle`. Page 9 says they
  "cannot be killed" and page 8 heals them. Without page 11 the fight can
  only be won by killing them, which the story says cannot be done;
* 1 in troop 136, **the Horned King with Dyrnwyn** (map 78, event 6): page 1,
  on the enemy's HP, plays Dyrnwyn (117) and ends the battle.

**Not looked at**: whether the player can flee from those two fights, and
what happens when the party loses.

**What it would take**, as a measurement: accepting the command as a declared
debt (no animation, a wait) lets the two ending pages in and ends both fights
at the cost of the animation; drawing one needs the battle scene to play an
animation on a monster, which it does not do for anything today (see
[`animations-in-battle`](animations-in-battle.md), for the skills').

## Done (Tijereta, 2026-10-14): accepted as a debt

From the-advocate `14e200fc` and the ports `f775b66`, branch
`tijereta-bot-fixes` in both. taro: "we can ignore it for now so the page
doesn't fall; not having this command shouldn't stop anyone from playing".

* `SHOW_BATTLE_ANIMATION_B` (13260) in `codes.rs`, checked against liblcf's
  name like the others.
* `TROOP_ACCEPTED_UNDONE` in `troops.rs`: the troops' own list of what is
  accepted without being done, next to `TROOP_COMMANDS`; `runs_in_battle`
  lets it in and the page's debts list it, so the converter warns.
* Its arm in `compile_command`: an `OP_DELAY` of the animation's length
  (two ticks per frame, as the map's animation) when the page waits for it,
  nothing otherwise. No new opcode.
* Test `an_animation_on_the_monsters_is_a_wait_and_a_debt` (troops.rs), red
  without the change.
* The divergence: a paragraph in the book's
  `divergences/what-troop-pages-do-not-model.md`.

The other commands of troop 96's page 11 and troop 136's page 1 all
compile (`just culprits` after: troops 497 to 499 compiling, 13260 gone
from the list). The Last Stand pages (52) are still out, now only by
`ChangeMonsterHP` with the damage in a variable —the culprits report gives
it 52 pages "alone"—: the animation no longer counts among their culprits.

**In the ROM**: `tests/test_book_of_three_endings.py` in the ports (in `just boot`), with two test pages of the game, `book-of-three/cases/battle-96.json` and `battle-136.json`: Taran alone, his HP filled every frame (and the Horned King put at a third), A tapped; each battle ends with neither the victory nor the defeat handler, RM2k's Abort. Red with the old tools: troop 96 never ends, 136 is won. Measured with a probe: troop 96 reaches turn 6 and the battle goes to `BA_M_ABORT`; troop 136 does at turn 1. **Not played by hand**, and the real fights on maps 26 and 78 were not reached by playing: what the test covers is the troop, not the map event that starts it. Fleeing was not looked at.

**When merging**: reinstall `events`, `convert` and `cartridge` (the runtime changed with the other task, `controlvars-random-ranges-wider-than-255`, same branches). The animation is still not drawn: that is [`animations-in-battle`](animations-in-battle.md) territory, and a line in Book of Three's Known issues says so.
