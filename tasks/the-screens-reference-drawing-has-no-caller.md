---
name: "The screens' reference drawing has no caller"
description: "With rm2k-snes-screens' binary gone, render.rs's screens drawn as the console has to show them —the menu, the items, the actor choice, the slots, the equipment, the shop, the skills, End Game, the title's menu— are dead code of the crate"
type: refactor
game: advocate
status: doing
assignee: carpintero
author: carpintero
agents: [Carpintero]
links:
  found-in: [tests-without-the-stages-subcommands]
---

Found by Carpintero on 2026-11-27, doing step 3 of
[`tests-without-the-stages-subcommands`](tests-without-the-stages-subcommands.md),
on the-advocate's `carpintero-tests-step3`.

**What is left**: `rm2k-snes-screens`' binary went —its `render` was what
ABL's tests compared the console against, and they compare goldens now—,
and with it the only caller of most of `render.rs`. Made `pub(crate)`,
rustc names as never used `Painter`, `compose_text`, `state_row`,
`paste_text`, `actor_row`, `menu`, `target`, `target_skill`,
`target_with`, `sp_cells`, `slot_screen`, `item_screen`, `candidates`,
`new_value_color`, `equipment_screen`, `shop_screen`, `shop_item` and
more past them —`render::equip`, `fit::skin_for`, the request's `Json`
helpers the binary read, `stage::game_with_font`—, some thousand lines.
What the converter does call from there (`Grid`, `SYSTEM_INK`, `Party`,
`Shop`, `item_screen_text`, `shop_text`) stays.

**What to do**: take out what only the binary reached, by rustc's
dead-code warnings with the module made `pub(crate)` —mechanical, the
ROMs byte for byte the same—; the crate's tests that draw a screen
through it, if any, go with it or move to what the converter calls. Left
out of step 3 so that the binaries' commit stayed small and checkable.

## Log

### 2026-11-27, Hornero: promoted to `todo`

Promoted by Hornero: dead code since step 3 removed its last caller; deleting it changes nothing seen or heard.

### 2026-11-27, taro: go

> Can you take this one too? If it is plain dead code, I suppose we can
> delete it and that is it, and if everything builds and the tests pass,
> we are fine, right?

### 2026-11-27, Hornero: taken, to Carpintero

Yes: the deletion is mechanical, and its net is the build without
dead-code warnings, the-advocate's suites and every port's ROMs byte for
byte equal to `main`'s. With equal ROMs ABL's suite has nothing new to
say, so it is not run; Cardón is measuring battle suite times meanwhile.
