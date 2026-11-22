---
name: "ChangeGold by a variable does not give its variable a slot"
description: "The variable sweep of the event compiler does not name ChangeGold's variable, so a page whose variable only ChangeGold names is left out"
type: bug
status: testing
assignee: taro
agents: [Cardón, Hurón]
author: chaja
---

Seen by Chajá on 2026-10-14, reading the code while doing
[`changeitems-and-changemonsterhp-by-a-variable`](changeitems-and-changemonsterhp-by-a-variable.md);
the-advocate `705222aa` (branch `chaja-by-variable`). Not seen in a game.

**What happens**: `command_variables`, in `rm2k-snes/events/src/indices.rs`,
is the sweep that gives each variable the game names its slot. It names
the `ControlVars`, the branches, `ChangeHP` and `ChangeSP` by a variable
and others, but not `ChangeGold` by a variable (`[1]` at 1, the variable
in `[2]`), which compiles since `OP_GOLD` has `GOLD_BY_VARIABLE`. If no
other command names that variable, it has no slot, `variable_slot` says
`Cannot`, and the page is left out whole.

In ABL it does not bite: the unit test `change_gold_by_a_variable_is_its_slot`
says variable 48 is named by another command. Whether any of the other
seven games has one named only there was not measured.

**To reproduce**: a test page with `ChangeGold` add, by variable 999
—which no command of the game names—; `just culprits` gives it as a
culprit.

**The fix** is one arm in `command_variables`, like the ones `ChangeItems`
and `ChangeMonsterHP` got on 2026-10-14. It can shift slots in a game
that had such a variable, which only breaks saves.

## Defined

Todo, on 2026-10-16, by Cardón: still missing at the-advocate `f4709d0b`, and the fix is
one arm.

**Done** means `command_variables` in `rm2k-snes/events/src/indices.rs`
names `ChangeGold`'s variable when `[1]` is 1, as `ChangeItems` does, with
a unit test red before; and `just culprits` run over the eight ports, to
say whether any page comes back. **First step**: the arm and its test.

## Log

### 2026-11-22, Hornero: still missing, taken by Cardón

taro, translated:

> Is this one still current? Fixing it should be simple, right?

Still so at the-advocate `6a8f4162`: `command_variables` has no
`CHANGE_GOLD` arm.

### 2026-11-22, Cardón: the arm, and an audit of the sweep

#### ChangeGold

the-advocate `097f0385`, branch `cardon-gold-slot`: the arm in
`command_variables`, `[1]` at 1 and the variable in `[2]`, which is what
`CHANGE_GOLD` in `compile.rs` reads for OP_GOLD with `GOLD_BY_VARIABLE`.
Its unit test, `change_gold_by_a_variable_names_its_variable`, was red
before it (`just crate-test events change_gold_by_a_variable`).

#### The audit

Every `variable_slot` call in `compile.rs` against the sweep's arms. Three
more forms compile with a variable the sweep did not name, each one arm
like Gold's, fixed in `b479c453` with its test red before:

* `ChangeEXP` and `ChangeLevel` by a variable (`[3]` set, `[4]`): OP_EXP
  with `EXP_BY_VARIABLE`; the page was skipped.
* `MovePicture` to two variables (`[1]` at 1, `[2]` and `[3]`): without
  the slots `compile_picture` accepts the move and does not do it.
* A choice option's `\V[n]` (`ShowChoiceOption`'s text), which
  `choice_boxes` runs through `with_variables`; the page was skipped.

The rest are covered: `ControlVars`, the variable branches, `KeyInputProc`,
`InputNumber`, the timer, `ChangeEventLocation`, `StoreTerrainID`,
`MemorizeLocation`/`RecallToLocation`, `ChangeHP`/`ChangeSP`,
`ChangeItems`, `ChangeMonsterHP`/`MP`, `ShowPicture` and the messages.
`compile_counter` reads a variable from the patches' `counters`, which no
command names by itself; but a counter common event is, by what the
declaration takes on trust, a chain of branches on it, so
it has its slot.

#### The eight ports, before and after

Release cartridge and `just culprits` of each game, with `events` and
`convert` installed locally twice —before, at the-advocate `ec6c7c7b`;
after, at the branch merged with it—, the rest from the global ones and
the runtime unchanged between both (`runtime/` the same from `90535658`
to `cce50c91`): `PATH=<worktree>/.local-tools/bin:$PATH just cartridges
release` (ABL with `--without-tracks`) and `just culprits`, in a ports
worktree at `001cfb7`. Zounds went too.

**No page comes back and nothing changes**: in all nine the culprits'
totals and pages are the same, and the release `.sfc` and `.msu` come out
byte for byte equal —every cartridge rebuilt, not up to date—. So no
game has a variable only these commands name, no slot shifts, and no
suite had to run: the change is covered by its four unit tests (`just
crate-test events`, 219 green) and by the ROMs being identical.

**To merge**: the-advocate `cardon-gold-slot` (`4f822987`, main merged);
reinstall `events` and `convert` (`just install events convert`). Nothing
in the ports.

### 2026-11-22, Hurón: no capture

Nothing to see: the change gives a slot to variables that only
`ChangeGold`, `ChangeEXP`/`ChangeLevel`, `MovePicture` by variables or a
choice's `\V[n]` name, and no port has one. Cardón rebuilt every release
before and after and the `.sfc` and `.msu` came out byte for byte equal,
so no screen of any game changes. It is checked by its four unit tests in
the events crate (`just crate-test events`) and by `just culprits` in each
game listing the same pages.
