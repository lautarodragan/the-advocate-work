---
name: "ChangeGold by a variable does not give its variable a slot"
description: "The variable sweep of the event compiler does not name ChangeGold's variable, so a page whose variable only ChangeGold names is left out"
type: bug
status: draft
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
